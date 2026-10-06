---
name: modern-c
description: Project contract for writing C as a modern, self-contained language profile inspired by Go, Rust, Zig, Odin and Jai - one compiler family, one C standard, one build system, vendored and pinned source dependencies, no global mutable state, one error model, explicit ownership, platform code isolated, warnings as errors and sanitizers on. Use when starting or restructuring a C project, adding a dependency, choosing build or compiler settings, designing a module API, or reviewing a C codebase for legacy practices.
---

# Modern C

C's problem is not the language. It is forty years of accumulated practice: every compiler, every standard version, every build system, every allocation model, every error convention, all supported at once. A project does not have to carry that. It can define a profile of C and refuse everything outside it, the way Zig, Odin and Go projects get one toolchain, one layout and one way to build.

This skill is that profile. It governs structure and tooling. How to write the code inside it is `c-best-practices`. How to choose dependencies is `c-libraries`, which must obey the dependency rules here.

## Stance

> We do not support 1980 to 2010 C practice. Clone, build, test. Nothing else.

Not supported, and not to be accommodated with `#ifdef`:

* K&R or pre-C11 code, compiler extensions outside the approved list
* old GCC, old MSVC, exotic compilers
* autotools, hand-maintained Makefiles, `./configure`
* system-wide installed dependencies and `-dev` packages
* macro pseudo-languages
* errno, global state, implicit ownership

## 1. One Compiler Family, One Standard

Write it in the README and enforce it in the build:

```text
Language:   C23 (C17 if MSVC is a target and lacks the features used)
Compilers:  clang >= 18 (primary), gcc >= 14, msvc >= 19.40 when Windows matters
```

* No `__STDC_VERSION__` checks. The standard is fixed.
* Approved extensions only, listed in the README. Default list: `__attribute__((warn_unused_result))` where `[[nodiscard]]` is unavailable, `__builtin_expect`, statement expressions are not approved.
* Cross-compile with `zig cc` as the C compiler when the primary toolchain cannot target a platform. It ships libc for every target and needs no SDK install.

## 2. One Build System

Pick one per project and never add a second. Default order:

1. **CMake >= 3.25** when any vendored dependency already ships CMake. Use presets, `FetchContent` is not used; dependencies are vendored, see rule 10.
2. **`build.c`** self-bootstrapping build program (nob style) when every dependency is plain source. The build description is C, the build tool is the compiler.

Required targets in either: `build`, `test`, `check` (warnings, static analysis), `clean`. A CI config runs all of them on every supported platform.

Cross-compilation is a requirement, not a feature. The build must produce at least:

```text
linux-x86_64  linux-aarch64  macos-aarch64  windows-x86_64
```

from any host, or the README must state which are excluded and why.

## 3. Repository Layout

```text
project/
├── src/            application and library code
│   └── platform/   the only place OS headers and #ifdef _WIN32 may appear
├── include/        public headers, only for a library with external users
├── deps/           vendored dependency sources, one directory each
├── tests/
├── tools/          build.c, scripts, generators
├── deps.lock       name, version, upstream URL, content hash per dependency
├── CMakeLists.txt or build.c
└── README.md       profile declaration: standard, compilers, targets, level
```

Clone, build, test must work on a fresh machine with only the compiler installed.

## 4. Headers Are Contracts

A header declares the public API of one module and nothing else.

```c
// image.h
typedef struct Image Image;

Image *image_create(Arena *arena, size_t width, size_t height);
bool   image_resize(Image *image, size_t width, size_t height);
```

* One header per module, same base name as the `.c` file.
* No implementation details, no helper macros, no inline functions beyond trivial accessors.
* Include what you use. No umbrella headers.
* `#pragma once` is approved. Include guards are also fine. Pick one per project.

## 5. Opaque for Resources, Transparent for Data

* **Opaque** (`typedef struct Foo Foo;` with the definition in the `.c`) for anything with invariants or an external resource: connections, stores, parsers, platform handles, wrapped third-party objects. The module controls the representation.
* **Transparent** plain-data structs for values the application creates, iterates and lays out contiguously: entries, strings, arrays, messages. `Foo foo = {0};` must be valid for these.

Do not make data opaque to feel safe. It forces heap allocation and pointer chasing. Do not make resources transparent for convenience. It leaks invariants.

## 6. Ownership in the Name

Every function that returns or takes memory says who owns it, by naming and by signature.

```text
foo_create(Arena *, ...)   result lives in the arena, caller does nothing
foo_create(...)            caller owns, must call foo_destroy
foo_destroy(Foo *)         releases what foo_create acquired
foo_clone(Arena *, Foo)    caller owns the copy, in the arena
foo_borrow(...), or returning a slice such as String   non-owning view
```

A function taking an `Arena *` allocates only from it. A function without one does not allocate unless its name says `create` or `clone`. Follow `c-best-practices` for arenas, scratch and pools.

## 7. One Allocation Model

The project allocates through arenas, scratch arenas and pools, as in `c-best-practices`. `malloc` appears only inside allocator implementations and inside dependency wrappers.

A vendored library must either accept allocator hooks that route into the project's arenas, or have every one of its allocations confined inside its wrapper module so nothing it allocates escapes.

## 8. No Global Mutable State

No `static` mutable variables at file scope, no globals, no singletons. State lives in a context struct passed explicitly.

```c
Store *store = store_create(arena, &config);
store_put(store, key, value);
```

Permitted: `static const` tables, and a single process-wide context created in `main` and passed down. Thread-local state is treated as global and needs the same justification.

## 9. One Error Model

One enum for the whole project, not one per module:

```c
typedef enum {
    ERR_OK = 0,
    ERR_INVALID_ARGUMENT,
    ERR_OUT_OF_MEMORY,
    ERR_NOT_FOUND,
    ERR_IO,
    ERR_PLATFORM,
} Error;
```

* Fallible functions return `Error`. Results go through out-parameters.
* Infallible queries return the value directly.
* Every `Error`-returning function is `[[nodiscard]]`.
* No errno. No sentinel values. No error strings as the primary channel. A context may carry a last-error detail string for diagnostics.
* Dependency errors are mapped to `Error` inside the wrapper, never passed through.

Programmer errors are assertions, not `Error` values. See `c-best-practices` rules 25 and 26.

## 10. Dependencies Are Vendored Source

Borrowed from Zig: the repository contains everything needed to build.

* Each dependency is copied into `deps/<name>/` at a pinned upstream version.
* `deps.lock` records one line per dependency: `name version url sha256:<hash>`. The hash comes from `modern-c hash deps/<name>`. Updating a dependency is a commit that changes the lock and the directory together.
* Dependencies build with the project's build system. If upstream uses CMake, its `CMakeLists.txt` is used via `add_subdirectory`. If it uses anything else, the project builds its sources directly.
* No `apt install`, `brew install`, `pkg-config`, or `find_package` for anything the project could carry. The single permitted exception is the platform TLS and certificate store, where tracking OS security updates outweighs reproducibility. Declare it in the README.
* Every dependency sits behind one wrapper module in `src/`. Its headers are included only there. Its types, macros, error codes and allocations do not cross the wrapper. Swapping the dependency changes one file.

## 11. Preprocessor on a Leash

Allowed:

* `#include`, include guards or `#pragma once`
* `#if` platform detection, only inside `src/platform/`
* `#define` constants where `enum` or `static const` cannot serve, such as array bounds in C17
* `static_assert`
* `countof(array)` and an `unused(x)` macro, defined once in a shared header

Not allowed: function-like macros as a substitute for functions, macro-generated declarations, X-macros, macro DSLs. Use `static inline` functions and plain code. A vendored library's macros stay inside its wrapper.

## 12. Platform Code at the Edge

`src/platform/` has one file per OS and one header declaring the portable interface in portable types: `String`, `size_t`, `Error`, opaque handles.

Nothing outside `src/platform/` includes `<windows.h>`, `<unistd.h>`, `<sys/...>`, or tests `_WIN32`. UTF-8 everywhere; conversion to wide strings happens in `platform/windows.c`.

## 13. Undefined Behaviour Is a Build Failure

Flags, always on:

```text
-std=c23 -Wall -Wextra -Werror -Wconversion -Wshadow -Wvla
-Wstrict-prototypes -Wimplicit-fallthrough -Wno-unused-parameter
```

Debug and CI builds add `-fsanitize=address,undefined -fno-omit-frame-pointer`. CI also runs `clang-tidy` with the project's checks file, and tests under the sanitizers on every platform.

Fuzz any parser or decoder that consumes external input with libFuzzer. Keep the corpus in `tests/fuzz/`.

## 14. ABI Only When Promised

An application rebuilds everything together. It links dependencies statically and does not version shared objects.

A library with external users declares an ABI boundary deliberately: opaque types, a versioned header, no struct layouts in the public API. Nothing in between.

## 15. Declare the Level

The README states which level the project meets, so a reader knows what to expect.

```text
Level 1  Modern C    rules 1, 4 to 9, 11 to 13
Level 2  Managed C   Level 1 plus rules 2, 3, 10, 14: one build, layout, lock file, cross-compilation, CI
Level 3  Hardened C  Level 2 plus clang-tidy gate, fuzzing, coverage threshold, dependency audit on update
```

New projects start at Level 2. A port of an existing project reaches Level 2 before it is called done.

## Review Checklist

Before finishing any change to a C project, run the checker and fix every finding:

```bash
ruby ~/.agents/tools/modern-c/modern-c check
```

It covers the mechanical rules below with file and line. Suppress a finding only inside a dependency wrapper or allocator, with `// modern-c: allow <rule>` on the line. Then confirm by reading:

* no new `#ifdef` outside `src/platform/`
* no new function-like macro
* no new file-scope mutable `static` or global
* every fallible function returns `Error` and is `[[nodiscard]]`
* every allocating function takes an `Arena *` or is named `create` or `clone`
* every new dependency is in `deps/`, in `deps.lock`, behind one wrapper, and builds with the project's build system
* `build`, `test`, `check` pass with sanitizers on every supported platform
* the README's profile declaration is still true

---
name: modern-c
description: Project contract for writing C as a modern, self-contained language profile inspired by Go, Rust, Zig, Odin and Jai - one compiler family, one C standard, one build system, the libmc foundation library for shared code, vendored and pinned source dependencies, no global mutable state, one error model, explicit ownership, platform code isolated, warnings as errors and sanitizers on. Use when starting or restructuring a C project, adding a dependency, writing a reusable helper, choosing build or compiler settings, designing a module API, or reviewing a C codebase for legacy practices.
---

# Modern C

C's problem is not the language. It is forty years of accumulated practice: every compiler, every standard version, every build system, every allocation model, every error convention, all supported at once. A project does not have to carry that. It can define a profile of C and refuse everything outside it, the way Zig, Odin and Go projects get one toolchain, one layout and one way to build.

This skill is that profile. It governs structure and tooling. How to write the code inside it is `c-best-practices`. How to choose dependencies is `c-libraries`, which must obey the dependency rules here. Shared code has one home, [libmc](https://github.com/sangar/libmc), rule 11.

## Stance

> We do not support 1980 to 2010 C practice. Clone, build, test. Nothing else.

Not supported, and not to be accommodated with `#ifdef`:

* K&R or pre-C11 code, compiler extensions outside the approved list
* old GCC, old MSVC, exotic compilers
* autotools, hand-maintained Makefiles, `./configure`
* system-wide installed dependencies and `-dev` packages
* macro pseudo-languages
* errno, global state, implicit ownership
* a private copy of a helper that libmc has, or should have

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
2. **`build.c`** self-bootstrapping build program (nob style) when every dependency is plain source. The build description is C, the build tool is the compiler. libmc's `tools/build.c` is the reference implementation.

Required targets in either: `build`, `test`, `check` (warnings, static analysis), `clean`, `ci`. `ci` runs `build`, `test` and `check` plus the cross-compiled builds, and is run locally before every push. It is the project's CI. Never add cloud CI config; an existing workflow stays, but it is not the gate, see the `local-ci` rule.

A project that produces an executable also has `install` and `uninstall`. `install` copies the release binary to `$PREFIX/bin`, default `~/.local`, overridable, with `DESTDIR` honoured for packaging, and nothing else: no config files, no daemons, no edits to shell profiles. `uninstall` removes exactly what `install` placed. CMake's `install()` covers the first; it has no uninstall, so add a target that removes the paths in `install_manifest.txt`. In `build.c`, both are subcommands.

Cross-compilation is a requirement, not a feature. The build must produce at least:

```text
linux-x86_64  linux-aarch64  macos-aarch64  windows-x86_64
```

from any host, or the README must state which are excluded and why. libmc does not support Windows yet, so a project built on it excludes `windows-x86_64` and says so.

## 3. Repository Layout

```text
project/
├── src/            application and library code
│   └── platform/   the only place OS headers and #ifdef _WIN32 may appear
├── include/        public headers, only for a library with external users
├── deps/           vendored dependency sources, one directory each
│   └── libmc/      the foundation library, always present
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
* A comment above each declaration states the contract: what it returns, who owns it, what fails. libmc's headers are the model.

## 5. Opaque for Resources, Transparent for Data

* **Opaque** (`typedef struct Foo Foo;` with the definition in the `.c`) for anything with invariants or an external resource: connections, stores, parsers, platform handles, wrapped third-party objects. The module controls the representation.
* **Transparent** plain-data structs for values the application creates, iterates and lays out contiguously: entries, strings, arrays, messages. `Foo foo = {0};` must be valid for these.

Do not make data opaque to feel safe. It forces heap allocation and pointer chasing. Do not make resources transparent for convenience. It leaks invariants.

## 6. Ownership in the Name

Every function that returns or takes memory says who owns it, by naming and by signature. `Arena` and `String` are libmc's.

```text
foo_create(Arena *, ...)   result lives in the arena, caller does nothing
foo_create(...)            caller owns, must call foo_destroy
foo_destroy(Foo *)         releases what foo_create acquired
foo_clone(Arena *, Foo)    caller owns the copy, in the arena
foo_borrow(...), or returning a slice such as String   non-owning view
```

A function taking an `Arena *` allocates only from it. A function without one does not allocate unless its name says `create` or `clone`. Follow `c-best-practices` for arenas, scratch and pools.

## 7. One Allocation Model

The project allocates through libmc arenas (`mc/core/arena.h`), `arena_mark` and `arena_release` for scratch work, and pools as in `c-best-practices`. Running out of memory aborts; `ERR_OUT_OF_MEMORY` is for wrapped dependencies that report it. `malloc` appears only inside libmc's arena, project pool implementations, and dependency wrappers.

A vendored library must either accept allocator hooks that route into the project's arenas, or have every one of its allocations confined inside its wrapper module so nothing it allocates escapes.

## 8. No Global Mutable State

No `static` mutable variables at file scope, no globals, no singletons. State lives in a context struct passed explicitly.

```c
Store *store = store_create(arena, &config);
store_put(store, key, value);
```

Permitted: `static const` tables, and a single process-wide context created in `main` and passed down. Thread-local state is treated as global and needs the same justification.

## 9. One Error Model

The error type is libmc's `Error` from `mc/core/error.h`. A project does not define its own.

```c
typedef enum Error {
    ERR_OK = 0,
    ERR_INVALID_ARGUMENT, ERR_OUT_OF_MEMORY, ERR_NOT_FOUND, ERR_IO, ERR_PLATFORM,
    ERR_PARSE, ERR_UNSUPPORTED, ERR_TIMEOUT, ERR_CANCELLED, ERR_NETWORK,
} Error;
```

* Fallible functions return `Error`. Results go through out-parameters. The last parameter is an optional `Err *` that receives the human-readable detail; `err_set` and `err_wrap` fill it.
* Infallible queries return the value directly. Parsers and lookups where "no" is an ordinary answer return `bool`.
* Every `Error`-returning function is `[[nodiscard]]`.
* No errno. No sentinel values. No error strings as the primary channel.
* Dependency errors are mapped to `Error` inside the wrapper, never passed through.
* A failure the enum cannot name is a PR to libmc adding the code, rule 11, not a project-local enum.

Programmer errors are assertions, not `Error` values. See `c-best-practices` rules 25 and 26.

## 10. Dependencies Are Vendored Source

Borrowed from Zig: the repository contains everything needed to build.

* Each dependency is copied into `deps/<name>/` at a pinned upstream version.
* `deps.lock` records one line per dependency, `name version url sha256:<hash>` with the hash from `modern-c hash deps/<name>`, and one line per platform for each prebuilt archive. Updating a dependency is a commit that changes the lock and the directory together.
* Dependencies build with the project's build system. If upstream uses CMake, its `CMakeLists.txt` is used via `add_subdirectory`. If it uses anything else, the project builds its sources directly.
* **Prebuilt archives.** A dependency whose source build needs its own configuration step, such as curl or mbedTLS, may also ship as a static archive per platform, as a cache of building it from source:
  * `./nob deps` builds it from the vendored source with the project's configuration and zig, deterministically, so a rebuild gives the same hash.
  * It is published as a release asset of the project's GitHub repository, tagged `deps-<name>-<version>`, with the dependency's license inside. Assets are never replaced; a changed archive gets a new tag.
  * `deps.lock` pins each platform's archive by URL and sha256, and the build refuses a mismatch.
  * The build downloads it on first use into `~/.cache/modern-c/<sha256>/` and works offline after that. Without the archive or the network, it builds the dependency from source.
  * Static archives only, never `.so` or `.dylib`.
* No `apt install`, `brew install`, `pkg-config`, or `find_package` for anything the project could carry. The single permitted exception is the platform TLS and certificate store, where tracking OS security updates outweighs reproducibility. Declare it in the README.
* Every dependency sits behind one wrapper module in `src/`. Its headers are included only there. Its types, macros, error codes and allocations do not cross the wrapper. Swapping the dependency changes one file. libmc is the one exception, rule 11.

**Bundling.** Two dependencies that serve one capability are bundled behind one interface, and a library is not split by dependency. The decision is made on the interface, never on the archive: a static archive is pulled in object file by object file, so a program pays for only the wrapper modules it calls, and splitting a library into one per dependency buys no binary size and no memory. libmc's JSON and YAML are the model: yyjson and cyaml both feed one `Node` tree, and a program that parses only JSON never links cyaml. Where performance or memory is a concern, measure the wrapper's representation and conversion step first; that is where the cost lives. A build flag that excludes a dependency is added when a consumer needs it, not before.

## 11. Shared Code Lives in libmc

[libmc](https://github.com/sangar/libmc) is the foundation library for every project under this contract: arenas, `String`, `Error`, containers, text, JSON and YAML, logging, concurrency and the platform layer. It is itself a Modern C Level 2 project that needs nothing installed beyond libc, libm and pthreads, apart from the platform TLS and certificate store rule 10 permits once a module needs them; its vendored libraries, yyjson for JSON, cyaml for YAML and utf8proc for Unicode so far, sit in its own `deps/` and build into it.

**Direction.** libmc grows toward a Modern C counterpart to Apple's Foundation: URLs and HTTP, dates, time zones and calendars, regular expressions, compression, property lists and XML, Unicode, preferences, and the rest of what Foundation offers that a C program can use. It is that capability in this contract's style, not a port of Foundation's API: arenas instead of reference counting, `Error` instead of `NSError`, explicit handles instead of shared singletons such as `URLSession.shared` or `UserDefaults.standard`. Each module still lands when a project needs it, through the contribution steps below. Out of scope is what exists only for the Objective-C runtime or Apple's services: key-value observing and coding, `NSCoding` archives, proxies, scripting, Spotlight, iCloud, XPC.

**Using it.** Vendor it as `deps/libmc/` with a `deps.lock` line like any dependency, add `deps/libmc/include` to the include path and compile `deps/libmc/src/*/*.c` with the project, plus `deps/libmc/deps/*/*.c` as C11 without the warning flags and with each `deps/libmc/deps/<name>` on the include path. A project that uses yyjson directly includes it from there instead of vendoring a second copy. Link `-lpthread -lm`, and `-framework CoreServices` on macOS. Unlike every other dependency, its headers are included wherever they are needed: `mc/text/str.h` is where `String` comes from. The checker exempts it from the wrapper rule.

Before writing a helper, read its module table:

| Area | Headers | Covers |
|------|---------|--------|
| core | `base.h`, `error.h`, `arena.h` | `countof`, `unused`, `Error`, `Err`, arenas, `arena_grow` for dynamic arrays |
| text | `str.h`, `utf8.h`, `unicode.h`, `glob.h`, `path.h`, `fmt.h`, `table.h` | views, builders, split and join, percent encoding, UTF-8, NFC, Unicode case, Norwegian sort order, globs, lexical paths, durations, RFC 3339, byte sizes, aligned columns |
| container | `strmap.h`, `hash.h`, `sort.h` | string-keyed hash map, FNV-1a, stable sort and top-k |
| crypto | `sha256.h`, `sigv4.h` | SHA-256, HMAC, hex, AWS Signature V4 |
| platform | `platform.h`, `watch.h`, `service.h` | clock, locale-independent floats, threads, mutexes, files, directories, processes, environment, signals, sockets, recursive file watching, launchd and systemd login services |
| concurrency | `cancel.h`, `debounce.h`, `queue.h`, `threadpool.h` | cancellation tokens, per-key debouncing, blocking queue, thread pool, parallel loops |
| encoding | `node.h`, `json.h`, `yaml.h` | document tree, strict JSON parse and encode, YAML parse |
| log | `log.h` | structured logging, text or JSON lines |

**Bridging stays in the project.** libmc is plain C with a plain C ABI and knows nothing about who calls it. It takes and returns its own types: `String`, `Arena *`, `Error`, `Err *`, fixed-layout structs, opaque handles. A project that uses it from Swift, C++, Rust, Zig, Go or Objective-C does the translation on its own side, in one bridging module: a Swift bridging header and a `String` to `Swift.String` layer, an `extern "C"` wrapper with RAII handles in C++, cgo conversions in Go. Nothing for that goes into libmc: no `#ifdef __cplusplus` or `extern "C"` blocks in its headers, the caller adds them; no Foundation or CoreFoundation types such as `NSString` or `CFString` in its headers; framework APIs only inside `src/platform/`, where an OS service needs them; no callback shapes designed for one host language; no OS-specific API outside `src/platform/`. A libmc PR that exists only to make one language's bridge easier is declined. The bridge changes instead.

**The contribution test.** If a function, type or module would be useful in any other C project, it belongs in libmc, not in `src/`. Base64, a ring buffer, a CLI argument parser: all libmc. What stays in the project is code that only makes sense with the project's domain, plus wrappers for its other dependencies. Anything in libmc's direction belongs there too, even when it needs a vendored library: an HTTP client is a libmc module, with libcurl or a TLS library chosen in a `c-libraries` decision report.

**Contributing.** When the project needs shared code libmc lacks, or a new `Error` code, or a platform call:

1. Clone `github.com/sangar/libmc`, branch from `master`.
2. Add `include/mc/<area>/<module>.h` with contract comments, `src/<area>/<module>.c`, and cases in `tests/test_<module>.c` registered in `tests/test.h` and `tests/main.c`. Follow the conventions in its README: arena-allocating functions take `Arena *`, fallible ones return `Error` with a trailing `Err *`, no globals, nothing for a host language or framework. A new dependency needs a `c-libraries` decision report the user has approved, goes into libmc's `deps/` and `deps.lock`, and stays inside one module, bundled as rule 10 describes.
3. Run `./nob check`. It must pass clean under the sanitizers and the `modern-c` checker.
4. Push the branch and open the pull request with `gh pr create`, describing what the module does and which project needed it. Follow the user's commit rules; no AI attribution.
5. Vendor the branch commit into the project's `deps/libmc/` and pin it in `deps.lock` with the branch URL, so the project builds now. After the merge, re-pin to `master`.
6. Tell the user the PR link and that the project is pinned to the branch until it merges.

A private helper in `src/` with a note that it should move to libmc later is not an option. The PR is part of the change.

## 12. Preprocessor on a Leash

Allowed:

* `#include`, include guards or `#pragma once`
* `#if` platform detection, only inside `src/platform/`
* `#define` constants where `enum` or `static const` cannot serve, such as array bounds in C17
* `static_assert`
* `countof(array)` and `unused(x)`, which come from `mc/core/base.h` and are not redefined

Not allowed: function-like macros as a substitute for functions, macro-generated declarations, X-macros, macro DSLs. Use `static inline` functions and plain code. A vendored library's macros stay inside its wrapper.

## 13. Platform Code at the Edge

libmc's `mc/platform/platform.h` is the platform layer: clock, threads, files, directories, processes, environment, signals and sockets, in portable types. Use it before writing any OS call.

What libmc lacks goes in the project's `src/platform/`, one file per OS and one header declaring the portable interface in `String`, `size_t`, `Error` and opaque handles, and is a PR to libmc under rule 11. Nothing outside `src/platform/` and libmc includes `<windows.h>`, `<unistd.h>`, `<sys/...>`, or tests `_WIN32`. UTF-8 everywhere, rule 16; conversion to wide strings happens in the Windows platform file.

## 14. Undefined Behaviour Is a Build Failure

Flags, always on:

```text
-std=c23 -Wall -Wextra -Werror -Wconversion -Wshadow -Wvla
-Wstrict-prototypes -Wimplicit-fallthrough -Wno-unused-parameter
```

Debug and `ci` builds add `-fsanitize=address,undefined -fno-omit-frame-pointer`. `ci` also runs the tests under the sanitizers, and at Level 3 `clang-tidy` with the project's checks file.

At Level 3, fuzz any parser or decoder that consumes external input with libFuzzer. Keep the corpus in `tests/fuzz/`.

## 15. ABI Only When Promised

An application rebuilds everything together. It links dependencies statically and does not version shared objects.

A library with external users declares an ABI boundary deliberately: opaque types, a versioned header, no struct layouts in the public API. Nothing in between.

## 16. Text Is UTF-8

Code that works on ASCII breaks on the first æ, ø or å. Handle them from the first line, not when a user reports it.

* Every `String` holding text is valid UTF-8 in NFC. Convert where text enters: `utf8_is_valid` or `utf8_from_latin1` for bytes from files, sockets and users; `unicode_nfc` for filenames, which macOS returns decomposed, with "å" as `a` followed by U+030A. Normalize a copy for comparing, searching and display, and pass the original bytes back to the filesystem: Linux filenames are byte-exact.
* Case conversion, case-insensitive comparison and sorting of text go through libmc's `mc/text/unicode.h`: `unicode_lower`, `unicode_upper`, `unicode_equal_ignore_case`. `ctype.h`, `strcasecmp` and `str_*_ascii` are for protocol tokens only, such as HTTP headers and hex, with `// modern-c: allow ascii-text` on the line. libmc's `str_equal_ignore_case`, `str_compare_ignore_case` and `strlist_sort` are ASCII-only too: use them for tokens and identifiers, not for text people read.
* Sorting for people uses `unicode_compare_norwegian` and `unicode_sort_norwegian`, not `str_compare`: bytewise order puts å before æ and ø.
* Bytes are not characters. Count, pad and cut by code point with `utf8_decode` and `utf8_count`, never in the middle of a sequence.
* Source files are UTF-8, and literals may contain æ, ø and å directly.
* Tests that touch text include æ, ø and å in both cases, and "å" in decomposed form.

## 17. Declare the Level

The README states which level the project meets, so a reader knows what to expect.

```text
Level 1  Modern C    rules 1, 4 to 9, 11 to 14, 16
Level 2  Managed C   Level 1 plus rules 2, 3, 10, 15: one build, layout, lock file, cross-compilation, local CI
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
* every helper that is not specific to the project is in libmc, or in an open libmc PR the user has been told about
* Swift, C++ or other language bridging lives in one module in the project, and no libmc change exists for its sake
* every new dependency is in `deps/`, in `deps.lock`, behind one wrapper, and builds with the project's build system
* text is compared, cased and sorted with libmc's Unicode functions, and tests cover æ, ø and å
* `ci` passes locally with sanitizers
* a project that produces an executable has `install` and `uninstall`, and `uninstall` leaves nothing behind
* the README's profile declaration is still true

# modern-c

Checks a C project against the `modern-c` skill's contract and prints each violation with its file and line. It is a line-oriented scanner in plain Ruby with no dependencies, so it runs anywhere Ruby does, including CI. It is not a compiler; `clang-tidy`, sanitizers and the compiler's own warnings cover what a scanner cannot.

## Usage

```bash
ruby ~/.agents/tools/modern-c/modern-c check [path] [--level N] [--format text|json] [--error-type Name]
ruby ~/.agents/tools/modern-c/modern-c hash <dir>
```

`check` exits 0 with no findings, 1 with findings, 2 on a usage error. The level defaults to the one declared in the project's README, else 2.

`hash` prints the content hash of a directory in the form `deps.lock` expects. Add a dependency by trimming its source into `deps/<name>`, then:

```bash
echo "yyjson 0.13.0 https://github.com/<owner>/<repo>/releases/download/deps-yyjson-0.13.0/yyjson-0.13.0.tar.gz $(ruby ~/.agents/tools/modern-c/modern-c hash deps/yyjson)" >> deps.lock
```

and publish `deps/yyjson` as that release asset; libmc's `tools/publish-dep.sh` does both the packing and the check.

Without arguments and with JSON on stdin, the tool reads `{"command": "check", "path": "...", "level": 2}` and answers in JSON. See `schema/`.

## Rules

| Rule | Level | What it reports |
|------|-------|-----------------|
| `stdc-version` | 1 | Any use of `__STDC_VERSION__` |
| `platform-ifdef` | 1 | `#if`/`#ifdef`/`#elif` on an OS macro such as `_WIN32` or `__linux__` outside `src/platform/` or `tools/` |
| `platform-header` | 1 | `<windows.h>`, `<unistd.h>`, `<sys/...>`, `<pthread.h>` and similar outside `src/platform/` or `tools/` |
| `function-macro` | 1 | `#define NAME(...)` other than `countof` and `unused` |
| `global-mutable` | 1 | File-scope variable definitions that are not `const`-qualified objects |
| `errno` | 1 | `errno` outside `src/platform/` |
| `malloc` | 1 | `malloc`, `calloc`, `realloc`, `free`, `strdup` outside files named `*arena*`, `*pool*`, `*alloc*` or `src/platform/` |
| `nodiscard` | 1 | A function returning the project `Error` type declared in a header, or `static` in a `.c`, without `[[nodiscard]]` |
| `warnings` | 1 | Build file lacks `-Wall`, `-Wextra`, or `-Werror`/`COMPILE_WARNING_AS_ERROR` |
| `sanitizers` | 1 | Build file has no `-fsanitize=address` and `undefined` configuration |
| `ndebug` | 1 | A build file defines `NDEBUG`, which removes `assert` from release builds, or a CMake build has no `-UNDEBUG` to undo the `-DNDEBUG` its release configurations add |
| `ascii-text` | 1 | Calls to `isalpha`, `isalnum`, `isupper`, `islower`, `toupper`, `tolower`, `strcasecmp`, `strncasecmp`, `str_lower_ascii` or `str_upper_ascii`, which break on æ, ø and å. Allow it on the line for protocol tokens such as HTTP headers |
| `build-system` | 2 | Makefile, Meson, autotools or other unsupported build files; no CMakeLists.txt or build.c; or both |
| `layout` | 2 | Missing `src/`, `tests/` or `README.md`; a `vendor/` or `third_party/` directory |
| `deps-lock` | 2 | `deps/` without `deps.lock`, directories without entries, malformed lines, content hash mismatch, an archive line with no source line of the same name and version |
| `dep-leak` | 2 | A header from `deps/<name>/` included from a project header, or from more than one project file unless they share one directory below the top level, such as `src/net/`. `deps/libmc` is exempt: its headers are the project vocabulary |
| `readme-profile` | 2 | README does not state the C standard or the Modern C level |
| `clang-tidy` | 3 | No `.clang-tidy` file |
| `fuzz` | 3 | No `tests/fuzz/` directory |

Files under `deps/`, `build/`, `out/`, `cmake-build-*/` and `.git/` are not scanned. [libmc](https://github.com/sangar/libmc) is pinned as `deps/libmc` in `deps.lock` like any dependency, but it may be included from anywhere.

## Suppressing a finding

On the offending line:

```c
char *copy = strdup(text); // modern-c: allow malloc
```

For a whole file, anywhere in it:

```c
// modern-c: allow-file errno
```

Use these in dependency wrappers, where the contract permits `malloc` and library globals, and nowhere else without a comment saying why.

## deps.lock format

Whitespace-separated fields; blank lines and `#` comments are ignored. A source line has four fields. An archive line, for a prebuilt archive of a dependency, has five, with the platform third, named as in `cross`:

```text
# name version url hash
curl 8.23.0 https://github.com/sangar/libmc/releases/download/deps-curl-8.23.0/curl-8.23.0.tar.gz sha256:9c7cb181...

# name version platform url hash
curl 8.23.0 macos-aarch64 https://github.com/sangar/libmc/releases/download/deps-curl-8.23.0/curl-8.23.0-macos-aarch64.tar.gz sha256:...
curl 8.23.0 linux-x86_64 https://github.com/sangar/libmc/releases/download/deps-curl-8.23.0/curl-8.23.0-linux-x86_64.tar.gz sha256:...
curl 8.23.0 linux-aarch64 https://github.com/sangar/libmc/releases/download/deps-curl-8.23.0/curl-8.23.0-linux-aarch64.tar.gz sha256:...
```

* An archive line's name and version match a source line, so every archive is a build of pinned source.
* An archive's hash is the sha256 of the downloaded file. The checker does not download it; the build verifies it.
* The archive holds `lib/lib<name>.a` and the license file. Headers come from the fetched source.

A source line's hash covers every file under `deps/<name>/` except `.DS_Store` and, at the top, `.git/` and the `deps/`, `out/` and `nob` a dependency's own build creates, as relative path plus content, sorted, so it is the same on every machine and for any archive of the same files. `deps/` itself is not committed: the build fetches each directory that is missing or differs, so a missing one is not a finding.

## Limitations

The scanner works on preprocessed-free source text with comments and string literals blanked out. It does not parse C. Known gaps:

* `global-mutable` misses function-pointer globals and declarations split across lines, and treats a pointer whose pointee is `const` but whose top-level qualifier is not as mutable, which is correct, while `static const char *name;` is reported.
* `nodiscard` recognises the attribute only when spelled `[[nodiscard]]` or `warn_unused_result` on the same or preceding line.
* `dep-leak` ignores a dependency header whose basename matches a project header, since the include is ambiguous.
* `warnings` and `sanitizers` only look at the text of `CMakeLists.txt` and `build.c`; flags set in presets or toolchain files are not seen.

## Tests

```bash
ruby tests/test_modern_c.rb
```

Fixtures under `tests/fixtures/` are a `clean` project that passes level 3 and a `violations` project that triggers every rule.

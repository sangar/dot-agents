---
name: c-libraries
description: Find and evaluate existing C libraries before implementing functionality from scratch. Use when writing C code that needs networking, HTTP, cloud SDKs such as AWS S3, TLS, JSON, compression, databases, crypto, regex, threading or any other non-trivial capability, and especially when porting a project from Go, Rust, Python or another language with a rich standard library or package ecosystem to C.
---

# Finding C Libraries

C has no standard package registry and a small standard library, so the temptation is to reimplement. Do not. Most capabilities have a mature, maintained C library. Reimplementing an S3 client, an HTTP stack or a TLS layer from scratch is a bug farm and weeks of work that a dependency replaces in an afternoon.

## Rule

Before writing more than a trivial amount of code for a capability that is not specific to this project, search for a library. Reimplement only when the search comes up empty or every candidate fails evaluation, and say so explicitly to the user with what was checked.

Triggers that must start a search:

* protocol clients or servers: HTTP, WebSocket, gRPC, MQTT, SSH, DNS
* cloud and vendor APIs: AWS, GCP, Azure, Stripe, any REST API with an official SDK
* formats: JSON, YAML, TOML, XML, CSV, protobuf, msgpack
* TLS, hashing, encryption, signatures, random
* compression and archives
* databases and caches
* regular expressions, Unicode, string encoding
* event loops, thread pools, async I/O
* image, audio, font decoding
* test frameworks, logging, argument parsing

## Workflow

1. **Name the capability precisely.** "Upload objects to S3 with multipart and SigV4" is searchable. "Storage" is not.
2. **Check the catalog below first.** Most common needs are covered.
3. **Check official SDKs.** Vendors with a C or C++ SDK usually have a C core underneath. AWS has the `aws-c-*` family. Look at the vendor's GitHub organisation before anything else.
4. **Search.** Use web search with terms like `<capability> C library`, `<capability> C99`, `<capability> single header`. Check GitHub topics `c`, `c99`, `single-header`. Check package indexes that list C libraries: vcpkg, Conan, Homebrew, Debian `apt`, the Awesome C list on GitHub.
5. **Evaluate each candidate** against the checklist below. Fetch the README and recent commit history rather than trusting memory; libraries get abandoned or renamed.
6. **Report before writing code.** Give the user the library decision in the shape below while switching is still free. A trade-off delivered after the hand-written version exists is not a decision, it is a request to rewrite. If the choice is between two reasonable libraries, state the recommendation and proceed.
7. **Integrate** following the project's existing dependency convention. If there is none, prefer in this order: single-header file vendored into the tree, git submodule under `third_party/` or `vendor/`, CMake `FetchContent`, system package via `pkg-config`.

## Library Decision Report

One paragraph per capability, before implementation starts:

* **Official or dominant option**: name it, and what it would give that a lighter choice would not. Example: the full credential chain, parallel multipart, checksums.
* **Its cost**: companion libraries, which target platforms package it, build and linking consequences, API model mismatches such as an async event loop forcing a module redesign.
* **Alternative**: the library or hand-written approach, its approximate size, and what it has been or will be tested against.
* **Recommendation and containment**: which to use now, and which file or module the swap would be confined to if the user picks the other.

Example, written before the store module existed:

> S3: `aws-c-s3` is the official client and gives the full credential chain, parallel multipart and checksums. It needs eight companion libraries plus s2n on Linux, Debian and Ubuntu do not package them, so Linux builds would statically link the family, and its async event-loop API shapes the whole store module. The alternative is libcurl with hand-written SigV4, roughly 900 lines, testable against MinIO on both platforms. Recommendation: libcurl now, confined to `src/s3.c`, so a later swap touches one file. Say now if you want the official client instead.

## Evaluation Checklist

* **License** compatible with the project: MIT, BSD, Apache-2.0, zlib, ISC are safe for most uses. GPL and LGPL need a decision from the user.
* **Maintained**: commits or releases within the last year, issues get answered, CVEs get fixed.
* **Language**: pure C, or C with an optional C++ build. A C++ library with a C wrapper is acceptable when nothing else exists.
* **Portability**: builds on the project's target platforms with the project's compiler and C standard.
* **Dependencies**: how many, and whether they are already in the project. Transitive dependency trees matter for build time and audit surface.
* **Build**: CMake, Meson, Makefile or single header. Avoid libraries that need autotools on Windows unless unavoidable.
* **API shape**: explicit allocators or custom allocator hooks, length-based or at least size-aware string APIs, no hidden global state, no hidden threads. These fit the project's C style; see the `c-best-practices` skill.
* **Scale**: handles the data sizes the project will see. Check for streaming APIs when inputs can be large.

## Catalog

Verified, widely used libraries by category. Prefer these over unknown alternatives.

### Cloud and vendor SDKs

| Need | Library | Notes |
|------|---------|-------|
| AWS S3 | `awslabs/aws-c-s3` | Official. Multipart, SigV4, parallel transfers. Depends on `aws-c-common`, `aws-c-io`, `aws-c-http`, `aws-c-auth`, `aws-c-cal`, `aws-c-sdkutils`, `aws-checksums`, and `s2n-tls` on Linux. Build via CMake with `aws-crt` or each repo as a submodule. |
| AWS HTTP, auth, event streams | `awslabs/aws-c-http`, `aws-c-auth`, `aws-c-event-stream` | Same family. Use the family rather than hand-rolling SigV4. |
| AWS all-in-one | `awslabs/aws-crt-cpp` is C++ | For pure C use the individual `aws-c-*` repos. |
| Azure | `Azure/azure-sdk-for-c` | Official, embedded-oriented. |
| Generic REST | `libcurl` + a JSON library | Fallback when a vendor has no C SDK. |

### Networking and HTTP

| Need | Library | Notes |
|------|---------|-------|
| HTTP/HTTPS client | `libcurl` | Everything. Also FTP, SMTP, WebSocket. |
| Embedded HTTP server, WebSocket, MQTT | `cesanta/mongoose` | Dual license GPL/commercial. Check license. |
| HTTP server | `civetweb/civetweb` | MIT. Fork of mongoose from before the license change. |
| WebSocket server and client | `libwebsockets` | MIT. |
| HTTP parsing only | `nodejs/llhttp` | MIT. Parser only, no I/O. |
| Async I/O, event loop, timers, threads | `libuv` | MIT. Node.js's loop. Portable. |
| Event loop | `libevent` | BSD. |
| MQTT | `eclipse/paho.mqtt.c` | EPL/EDL. |
| gRPC | `grpc/grpc` is C++ with a C core | Heavy. Consider plain HTTP + protobuf-c if feasible. |
| DNS | `c-ares` | MIT. Async resolver. |
| SSH | `libssh2`, `libssh` | BSD / LGPL. |

### TLS and crypto

| Need | Library | Notes |
|------|---------|-------|
| TLS | `openssl`, `mbedtls`, `aws/s2n-tls`, `BearSSL` | OpenSSL most compatible. mbedTLS small and portable. s2n for AWS stack. |
| Modern crypto primitives | `libsodium` | ISC. Hard to misuse. First choice for new code. |
| Hashes, HMAC, AES only | `libtomcrypt`, `mbedtls` crypto module | When full TLS is unneeded. |
| Password hashing | `libsodium` (argon2), `P-H-C/phc-winner-argon2` | |

### Data formats

| Need | Library | Notes |
|------|---------|-------|
| JSON, fast | `ibireme/yyjson` | MIT. Fastest, immutable and mutable DOM, large inputs. |
| JSON, simple | `DaveGamble/cJSON` | MIT. Easy API. Slower, allocation-heavy. |
| JSON, streaming | `jansson`, `json-c` | MIT. |
| JSON, tokenizer only | `zserge/jsmn` | MIT. Single header, zero allocation. |
| YAML | `yaml/libyaml` | MIT. |
| TOML | `cktan/tomlc99` | MIT. |
| INI | `benhoyt/inih` | BSD. |
| XML | `libxml2`, `libexpat` | MIT. expat is small and streaming. |
| Protobuf | `protobuf-c/protobuf-c`, `nanopb/nanopb` | nanopb for constrained targets. |
| MessagePack | `msgpack/msgpack-c`, `ludocode/mpack` | |
| CBOR | `intel/tinycbor`, `PJK/libcbor` | |
| CSV | `libcsv`, `semitrivial/csv_parser` | Or write it, CSV is small enough. |
| Base64, URL encoding | `libcurl` has URL API; base64 is small enough to write | |

### Compression and archives

| Need | Library | Notes |
|------|---------|-------|
| gzip, deflate | `zlib`, `zlib-ng` | zlib-ng is faster and API compatible. |
| zstd | `facebook/zstd` | BSD. |
| lz4 | `lz4/lz4` | BSD. |
| brotli | `google/brotli` | MIT. |
| xz, lzma | `tukaani-project/xz` | |
| tar, zip, many | `libarchive` | BSD. |
| zip only | `kuba--/zip`, `madler/zlib` contrib minizip, `richgel999/miniz` | miniz is single file. |

### Databases and storage

| Need | Library | Notes |
|------|---------|-------|
| Embedded SQL | `sqlite` | Public domain. Amalgamation is one `.c` file. |
| PostgreSQL | `libpq` | Ships with PostgreSQL. |
| MySQL, MariaDB | `mariadb-connector-c` | LGPL. |
| Redis | `redis/hiredis` | BSD. |
| Key-value, embedded | `LMDB`, `RocksDB` is C++ with C API | |

### Text, Unicode, regex

| Need | Library | Notes |
|------|---------|-------|
| Regex | `PCRE2` | BSD. Perl-compatible, JIT. |
| Regex, small | `kokke/tiny-regex-c`, `re2c` for compiled | |
| Unicode normalisation, case, categories | `JuliaStrings/utf8proc` | MIT. |
| ICU | `unicode-org/icu` | Large. Only when full locale support is needed. |
| UTF-8 validation and conversion | `simdutf` is C++; `utf8.h` by sheredom is single header C | |
| Length-based strings | `antirez/sds`, or the project's own `String` | sds is NUL-terminated and length-prefixed. |

### Containers and allocators

| Need | Library | Notes |
|------|---------|-------|
| Hash map, dynamic array, macros | `nothings/stb` `stb_ds.h` | Public domain. Arena-friendly if you pass realloc. |
| Hash table, intrusive | `troydhanson/uthash` | BSD. Header only. |
| Generic containers | `attractivechaos/klib` | MIT. khash, kvec, ksort. |
| Allocator | `microsoft/mimalloc`, `jemalloc` | Drop-in malloc replacements. |
| Arena, pool | Usually write these; see `c-best-practices` | Small, project-specific. |

### Concurrency

| Need | Library | Notes |
|------|---------|-------|
| Portable threads, mutexes | C11 `<threads.h>`, or `pthreads` with `pthreads-win32` | Check compiler support for C11 threads on MSVC. |
| Thread pool, work queue | `libuv` threadpool, `Pithikos/C-Thread-Pool` | Or write a small one; see `c-best-practices`. |
| Lock-free queues | `concurrencykit/ck`, `rigtorp` ports | |
| Coroutines | `edubart/minicoro`, `libco` | |

### Media and UI

| Need | Library | Notes |
|------|---------|-------|
| Image decode | `stb_image.h`, `libpng`, `libjpeg-turbo`, `libwebp` | stb for simplicity, the others for speed and correctness. |
| Image encode, resize | `stb_image_write.h`, `stb_image_resize2.h` | |
| Font rasterising | `stb_truetype.h`, `FreeType` | |
| Audio | `mackron/miniaudio` | Public domain. Single file. |
| Windowing, GPU, input | `floooh/sokol`, `SDL3`, `glfw` | |
| Immediate-mode UI | `Immediate-Mode-UI/Nuklear`, `rxi/microui` | |

### Tooling

| Need | Library | Notes |
|------|---------|-------|
| Unit tests | `cmocka`, `ThrowTheSwitch/Unity`, `silentbicycle/greatest`, `nemequ/munit` | greatest and munit are single header. |
| Logging | `rxi/log.c` | MIT. Tiny. |
| CLI args | `cofyc/argparse`, `getopt` from libc | |
| Benchmark, timing | Write it; `clock_gettime` or `QueryPerformanceCounter` | |

## Porting From Go

When converting a Go project, map each imported package before writing anything.

| Go | C |
|----|---|
| `net/http` client | `libcurl` |
| `net/http` server | `civetweb`, `mongoose`, `libwebsockets` |
| `encoding/json` | `yyjson`, `cJSON` |
| `encoding/xml` | `libexpat`, `libxml2` |
| `gopkg.in/yaml` | `libyaml` |
| `crypto/tls` | `openssl`, `mbedtls`, `s2n-tls` |
| `crypto/*`, `golang.org/x/crypto` | `libsodium`, `openssl` libcrypto |
| `compress/gzip`, `compress/flate` | `zlib` |
| `github.com/klauspost/compress/zstd` | `zstd` |
| `database/sql` + `mattn/go-sqlite3` | `sqlite3` |
| `database/sql` + `lib/pq`, `pgx` | `libpq` |
| `github.com/go-redis/redis` | `hiredis` |
| `github.com/aws/aws-sdk-go` s3 | `aws-c-s3` |
| `regexp` | `PCRE2` |
| `unicode`, `golang.org/x/text` | `utf8proc` |
| `sync`, goroutines, channels | `pthreads` or `libuv`, a thread pool and explicit queues |
| `context` cancellation | explicit cancel flag or token passed through the call chain |
| `os/exec` | `posix_spawn`, `CreateProcess` at the platform boundary |
| `testing` | `cmocka`, `greatest` |
| `log`, `log/slog` | `rxi/log.c` |
| `flag` | `argparse`, `getopt` |
| `google.golang.org/protobuf` | `protobuf-c` |
| `google.golang.org/grpc` | `grpc` C core, or redesign to HTTP + protobuf |

Go's standard library hides allocation and concurrency. When replacing it, make lifetimes explicit as described in `c-best-practices`: parse into arena memory, stream large bodies rather than buffering, and keep thread ownership visible.

### Port Completion Report

When a port is done, report in this order so the reader can judge it without opening the tree:

1. **Scope and verification boundary** in the first sentence: what was built, where, and what it was and was not run against.
2. **What was built**: size, language standard, and the module map against the original. State what is interchangeable with the original, such as config files, databases or on-disk formats. List dependencies and where they come from.
3. **Verification**, as a list: unit and integration test counts and the platforms, sanitizers or containers they ran under; service-level tests and what they exercised; end-to-end runs of the actual binary and the scenarios covered.
4. **Library decisions** in the report shape above, including any still open for the user.
5. **Differences from the original**, each in one clause, and where they are documented.
6. **Not done**: anything skipped, unported or unverified, stated plainly.

Keep it to one screen. A reader should finish it knowing what to trust, what to decide, and what remains.

## When Reimplementing Is Right

* The capability is a few dozen lines: base64, hex, a simple CSV reader, a ring buffer, an arena.
* The library would pull a dependency tree far larger than the feature.
* No candidate passes the license or platform checks, and the user has been told.
* The project's style demands a specific memory model the library cannot accommodate, and the user agrees the cost is worth it.

State the decision and its reason in the code's commit or in the conversation, not silently.

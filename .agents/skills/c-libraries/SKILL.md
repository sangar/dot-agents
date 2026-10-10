---
name: c-libraries
description: Find and evaluate existing C libraries before implementing functionality from scratch. Use when writing C code that needs networking, HTTP, cloud SDKs such as AWS S3, TLS, JSON, compression, databases, crypto, regex, threading or any other non-trivial capability, and especially when porting a project from Go, Rust, Python or another language with a rich standard library or package ecosystem to C.
---

# Finding C Libraries

C has no standard package registry and a small standard library, so the temptation is to reimplement. Do not. Most capabilities have a mature, maintained C library. Reimplementing an S3 client, an HTTP stack or a TLS layer from scratch is a bug farm and weeks of work that a dependency replaces in an afternoon.

The opposite failure is pulling in libraries on their own terms: each with its own build system, install step, macros, globals, allocation model and error scheme. That is C's legacy mess and the project does not inherit it. Every dependency enters under the `modern-c` contract: vendored source, pinned, built by the project, confined behind one wrapper. The library is a detail of one module, never a shape the whole program takes.

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
2. **Check libmc first.** [libmc](https://github.com/sangar/libmc) is the foundation library every project vendors, `modern-c` rule 11. Its module table is in that skill. If it covers the capability, there is no search. If the capability is generic and small, the answer is a libmc PR, not a third-party library and not a private helper.
3. **Check the catalog below.** Most common needs are covered.
4. **Check official SDKs.** Vendors with a C or C++ SDK usually have a C core underneath. AWS has the `aws-c-*` family. Look at the vendor's GitHub organisation before anything else.
5. **Search.** Use web search with terms like `<capability> C library`, `<capability> C99`, `<capability> single header`. Check GitHub topics `c`, `c99`, `single-header`. Check package indexes that list C libraries: vcpkg, Conan, Homebrew, Debian `apt`, the Awesome C list on GitHub.
6. **Evaluate each candidate** against the checklist below. Fetch the README and recent commit history rather than trusting memory; libraries get abandoned or renamed.
7. **Report before writing code.** Give the user the library decision in the shape below while switching is still free. A trade-off delivered after the hand-written version exists is not a decision, it is a request to rewrite. If the choice is between two reasonable libraries, state the recommendation and proceed.
8. **Integrate** under the `modern-c` dependency rules: copy the pinned source into `deps/<name>/`, record it in `deps.lock`, build it with the project's build system, and put it behind one wrapper module in `src/`. System packages, `pkg-config`, `find_package` and `FetchContent` are not integration options. If the project has an older convention, follow it and tell the user it diverges from the contract.

## Library Decision Report

One paragraph per capability, before implementation starts:

* **Official or dominant option**: name it, and what it would give that a lighter choice would not. Example: the full credential chain, parallel multipart, checksums.
* **Its cost**: companion libraries, which target platforms package it, build and linking consequences, API model mismatches such as an async event loop forcing a module redesign.
* **Alternative**: the library or hand-written approach, its approximate size, and what it has been or will be tested against.
* **Recommendation and containment**: which to use now, and which file or module the swap would be confined to if the user picks the other.

Example, written before the store module existed:

> S3: `aws-c-s3` is the official client and gives the full credential chain, parallel multipart and checksums. It is nine CMake repositories vendored into `deps/`, which is a large tree but builds with the project, and its async event-loop API shapes the store wrapper internally. The alternative is libcurl, also vendored, with hand-written SigV4, roughly 900 lines, testable against MinIO on both platforms, and without instance-metadata or SSO credentials. Both are confined to `src/s3.c`. Recommendation: `aws-c-s3` if the daemon will ever run on AWS infrastructure, libcurl otherwise. Say which now.

## Evaluation Checklist

* **License** compatible with the project: MIT, BSD, Apache-2.0, zlib, ISC are safe for most uses. GPL and LGPL need a decision from the user.
* **Maintained**: commits or releases within the last year, issues get answered, CVEs get fixed.
* **Language**: pure C, or C with an optional C++ build. A C++ library with a C wrapper is acceptable when nothing else exists.
* **Portability**: builds on the project's target platforms with the project's compiler and C standard.
* **Dependencies**: how many, and whether they are already in the project. Transitive dependency trees matter for build time and audit surface.
* **Build**: CMake or plain sources the project can compile directly. Autotools-only or Makefile-only libraries fail unless their sources are simple enough to list in the project's build by hand.
* **Allocation**: allocator hooks that can route into the project's arenas, or few enough allocations that the wrapper can own them all. A library that allocates freely and hands out pointers the caller must free is a poor fit.
* **API shape**: length-based or at least size-aware string APIs, no hidden global state, no hidden threads, no macro DSL required to use it. These fit the project's C style; see `c-best-practices`.
* **Containment**: can the library be fully hidden behind one wrapper module, so its headers, types, error codes and macros never appear elsewhere? If not, say so in the decision report.
* **Scale**: handles the data sizes the project will see. Check for streaming APIs when inputs can be large.

## Catalog

Verified, widely used libraries by category. Prefer these over unknown alternatives.

### Foundation: libmc

Already in every project as `deps/libmc`. Nothing here needs a search or a wrapper.

| Need | libmc header |
|------|--------------|
| Arena, dynamic arrays | `mc/core/arena.h` |
| Error codes and messages | `mc/core/error.h` |
| Length-based strings, builder, split, join, percent encoding | `mc/text/str.h` |
| UTF-8, globs, lexical paths | `mc/text/utf8.h`, `mc/text/glob.h`, `mc/text/path.h` |
| Durations, RFC 3339, byte sizes, aligned tables | `mc/text/fmt.h`, `mc/text/table.h` |
| String-keyed hash map, hashing, stable sort | `mc/container/strmap.h`, `mc/container/hash.h`, `mc/container/sort.h` |
| SHA-256, HMAC, AWS SigV4 | `mc/crypto/sha256.h`, `mc/crypto/sigv4.h` |
| JSON parse and encode, YAML parse | `mc/encoding/json.h`, `mc/encoding/yaml.h` |
| Structured logging | `mc/log/log.h` |
| Threads, thread pool, queue, cancellation | `mc/platform/platform.h`, `mc/concurrency/*.h` |
| Files, directories, processes, environment, signals, sockets, clock | `mc/platform/platform.h` |
| Recursive file watching, debouncing | `mc/platform/watch.h`, `mc/concurrency/debounce.h` |
| launchd and systemd login services | `mc/platform/service.h` |

libmc has no HTTP client and will not get one, since it would have to carry TLS. A project that needs HTTP wraps libcurl or a vendored TLS library in one module of its own.

### Cloud and vendor SDKs

| Need | Library | Notes |
|------|---------|-------|
| AWS S3 | `awslabs/aws-c-s3` | Official. Multipart, SigV4, parallel transfers. Depends on `aws-c-common`, `aws-c-io`, `aws-c-http`, `aws-c-auth`, `aws-c-cal`, `aws-c-sdkutils`, `aws-checksums`, and `s2n-tls` on Linux. All CMake, all vendorable into `deps/`; the tree is large but it is source, which is the contract's preferred shape. Nothing in it is in Debian or Ubuntu, which is irrelevant when vendoring. |
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
| JSON | libmc `mc/encoding/json.h` | Default. Document tree, strict, line and column errors. |
| JSON, fast or huge | `ibireme/yyjson` | MIT. Fastest, immutable and mutable DOM, large inputs. Only when libmc's parser is measured too slow. |
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
| Length-based strings | libmc `String` | Views plus arena-allocated copies. Do not add `sds`. |

### Containers and allocators

| Need | Library | Notes |
|------|---------|-------|
| String-keyed hash map, dynamic array | libmc `strmap.h`, `arena_grow` | Other key types: write it in libmc. |
| Hash map, dynamic array, macros | `nothings/stb` `stb_ds.h` | Public domain. Only inside a wrapper; its macro API does not cross one. |
| Hash table, intrusive | `troydhanson/uthash` | BSD. Header only. |
| Generic containers | `attractivechaos/klib` | MIT. khash, kvec, ksort. |
| Allocator | `microsoft/mimalloc`, `jemalloc` | Drop-in malloc replacements. |
| Arena | libmc `mc/core/arena.h` | |
| Pool | Write it; see `c-best-practices` | Generic pools belong in libmc. |

### Concurrency

| Need | Library | Notes |
|------|---------|-------|
| Portable threads, mutexes | libmc `mc/platform/platform.h` | |
| Thread pool, work queue, cancellation | libmc `mc/concurrency/*.h` | |
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
| Logging | libmc `mc/log/log.h` | Text or JSON lines, like Go's slog. |
| CLI args | Write it in libmc; `getopt` from libc meanwhile | |
| Benchmark, timing | Write it; `clock_gettime` or `QueryPerformanceCounter` | |

## Porting From Go

When converting a Go project, map each imported package before writing anything.

| Go | C |
|----|---|
| `net/http` client | `libcurl` |
| `net/http` server | `civetweb`, `mongoose`, `libwebsockets` |
| `encoding/json` | libmc `json.h` |
| `encoding/xml` | `libexpat`, `libxml2` |
| `gopkg.in/yaml` | `libyaml` |
| `crypto/tls` | `openssl`, `mbedtls`, `s2n-tls` |
| `crypto/sha256`, `crypto/hmac` | libmc `sha256.h` |
| `crypto/*`, `golang.org/x/crypto` | `libsodium`, `openssl` libcrypto |
| `compress/gzip`, `compress/flate` | `zlib` |
| `github.com/klauspost/compress/zstd` | `zstd` |
| `database/sql` + `mattn/go-sqlite3` | `sqlite3` |
| `database/sql` + `lib/pq`, `pgx` | `libpq` |
| `github.com/go-redis/redis` | `hiredis` |
| `github.com/aws/aws-sdk-go` s3 | `aws-c-s3`, or libmc `sigv4.h` with an HTTP client |
| `regexp` | `PCRE2` |
| `unicode/utf8`, `strings`, `path/filepath` | libmc `utf8.h`, `str.h`, `path.h`, `glob.h` |
| `unicode`, `golang.org/x/text` | `utf8proc` |
| `sync`, goroutines, channels | libmc `threadpool.h`, `queue.h` |
| `context` cancellation | libmc `cancel.h` |
| `os/exec`, `os`, `time` | libmc `platform.h` |
| `text/tabwriter`, `time.Duration` formatting | libmc `table.h`, `fmt.h` |
| `testing` | `cmocka`, `greatest` |
| `log`, `log/slog` | libmc `log.h` |
| `flag` | libmc PR, `getopt` meanwhile |
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

## Wrapping a Dependency

The wrapper module is where the library stops and the project begins.

* One `src/<capability>.c` and `.h` per dependency, named for the capability, not the library: `s3.c`, not `curl_s3.c`.
* The header uses only project types: `String`, `Arena *`, `Error`, opaque handles. No library header is included from it.
* Library error codes map to the project `Error` enum inside the wrapper.
* Library allocations are routed through its allocator hooks into an arena, or owned and freed within the wrapper so nothing escapes.
* Library globals and init calls, such as `curl_global_init`, happen once inside the wrapper's context create and destroy.
* The wrapper is tested through its own header, against a real instance where one exists, such as a local MinIO for S3.

Done right, the decision report's "confined to one file" claim is literally true.

## When Reimplementing Is Right

* The capability is a few dozen lines: base64, hex, a simple CSV reader, a ring buffer. Write it in libmc and open the PR, `modern-c` rule 11, unless it is specific to this project.
* The library would pull a dependency tree far larger than the feature.
* No candidate passes the license or platform checks, and the user has been told.
* The project's style demands a specific memory model the library cannot accommodate, and the user agrees the cost is worth it.

State the decision and its reason in the code's commit or in the conversation, not silently.

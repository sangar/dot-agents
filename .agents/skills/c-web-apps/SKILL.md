---
name: c-web-apps
description: Build web applications in modern C, designed for agent-driven development - the existing code is the convention to follow, with a Rails-style layout under src/ (src/app/models, src/app/controllers, src/app/views, src/config/routes, db/migrate, tests/) only to bootstrap the first resource; enforced boundaries between models, controllers, views and src/framework/; invariants held by types and checks such as compiler-enforced HTML escaping, bound SQL parameters and asserted query counts; SQLite, one binary, plain JavaScript or C compiled to WebAssembly on the client; deterministic machine-readable build, test, check and bench output. Use when creating, extending or reviewing a web app, web service, HTTP API or website written in C, or when the user mentions MVC in C, routes, controllers, models, views or migrations in a C project.
---

# Web Apps in Modern C

Written for agents building and maintaining a web app. An agent starts every session without memory, so the codebase is its convention: the existing resources show the layout, the naming and the patterns better than any description can. This skill holds what the code cannot show by itself: where the boundaries are, which invariants the machine enforces, why the less obvious decisions were made, and what to run before finishing.

A web app is a `modern-c` project at Level 2, and this skill only lays out its `src/` and `tests/` under `modern-c` rule 3. Write the code inside each module with `c-best-practices`. Choose any new dependency with `c-libraries`.

## How to Work

1. **The app has a resource.** Find the one closest to the feature, read it end to end (migration, model, rules, controller, views, routes, tests) and build the new feature the same way. Where the code and this skill disagree on layout or naming, the code wins. Where the code breaks a boundary or invariant below, the code is wrong: fix it in the same change.
2. **The app is empty.** Lay it out as below and write the first resource from [reference.md](reference.md). That resource is the template every later one copies, so get it complete, with tests, before adding a second.

Prefer the more complex design when it runs faster or is more correct. Frameworks trade performance and control for less code to write and fewer concepts to keep in mind, and an agent does not need that trade. Still build nothing a feature does not need: unused code is untested surface.

## Bootstrap Layout

The layout and naming follow Ruby on Rails, moved under `src/` where every `modern-c` project keeps its code, because language models have seen many apps laid out this way and guess a file's location before reading it.

```text
src/app/controllers/   <plural>_controller.{h,c}, actions <plural>_controller_<action>
src/app/models/        <singular>.{h,c} with SQL; <singular>_rules.{h,c} pure, no database
src/app/views/         <plural>/<action>.{h,c} -> <plural>_<action>_view, _<name>.{h,c} -> <plural>_<name>_partial
src/app/views/layouts/ application.{h,c}
src/app/helpers/ src/app/jobs/ src/app/mailers/ src/app/assets/ src/app/javascript/ src/app/wasm/
src/config/            boot.c (main), application.{h,c}, environments/<env>.c, routes.{h,c}
src/framework/         server, router, request, html, record, migrate, session, job
src/platform/          the only place for OS headers and #if _WIN32
src/<name>/            one wrapper per app dependency
db/                    migrate/<UTC YYYYMMDDHHMMSS>_<verb>_<thing>.sql, schema.sql, seeds.sql
public/                404.html, 422.html, 500.html
tests/                 models/, controllers/, framework/, fixtures/<plural>.sql, bench/, fuzz/
deps/ deps.lock tools/build.c README.md
```

The `modern-c` checker treats the app like any other project, with `src/platform/` as the platform directory and fuzz targets in `tests/fuzz/`. The include path is `src/`, so includes read `"app/models/post.h"`, `"framework/record.h"` and `"config/routes.h"`; tests add `tests/`.

Tables are plural and types singular (`posts`, `Post`, `PostList`). Keys are `id` and `<singular>_id`. Times are `<event>_at`, `INTEGER` unix nanoseconds. Model functions use SQL verbs, `post_find`, `post_insert`, `post_delete`, because `create` and `destroy` keep their `modern-c` meaning of acquiring and releasing memory. Routes are a `static const` table in `src/config/routes.c`. A `Resource` names its actions, and the router derives `index`, `new`, `create`, `show`, `edit`, `update` and `destroy` from its name. Paths come only from path helpers such as `post_path(arena, id)`.

## Boundaries

What each layer may touch. The convention check enforces what it can; the rest is on the agent.

* **Models** are the only app code that runs SQL, through `framework/record.h`. `<singular>_rules.c` includes neither the database nor the framework, so it compiles for the server and for `wasm32`.
* **Controllers** read params, call models and rules, choose a view and a status, and hold no business rules. `<singular>_params` copies named fields only.
* **Views** are pure functions of their arguments. They do not query, read the session or call models; the controller loads everything first.
* **src/framework/** includes nothing from `app/`, `config/` or `db/` and names no app concept. Dependencies point one way: app, then framework, then libmc. Code in libmc's direction, such as HTTP parsing, URLs, dates, encodings and the event loop, is a libmc pull request under `modern-c` rule 11.
* **src/platform/** is the only place for OS calls. A dependency's headers appear only in its wrapper.
* **src/config/** is the only code that reads the wall clock or the environment.

## Invariants

Each of these is held by a type, the compiler, a test or a check, never by review alone. Do not weaken the mechanism to get a change through.

* **Escaping is a type.** `html_text` escapes a `String`. `html_markup` writes trusted markup and takes only string literals. `html_append` writes `Html`, which only the builder produces. An unescaped `String` cannot reach the output.
* **SQL is a literal with bound parameters.** SQL built at run time fails the check.
* **Query counts are asserted.** `record_prepare` counts every query, and controller tests assert the count, so an N+1 query shows up as a test failure.
* **Results are deterministic.** The request reads the clock once into `req->now` and passes it to models. Tests run on a fixed clock and seed, inside a rolled-back transaction, with fixtures as SQL inserts with explicit ids.
* **Every route is exercised.** One test requests every route with fixture ids and fails on a 500 or on HTML that is not well-formed.
* **Performance has budgets.** `tests/bench/` holds a latency and allocation budget per route.
* **Forms are safe.** Every non-GET request needs a CSRF token, which `html_form_open` writes. Invalid input renders the form again with 422. A successful create, update or destroy redirects with 303.
* **Migrations are append-only.** Each has `-- migrate:up` and `-- migrate:down`, runs in a transaction, and updates `db/schema.sql` in the same commit. A migration that has reached `master` is never edited.
* **Secrets fail closed.** Production reads `SECRET_KEY_BASE` and API keys from the environment, and a missing one stops the boot with an `Error`.

## Decisions

These choices look like oversights to an agent seeing them for the first time. Keep them unless the user changes them.

* **No client framework, bundler or npm.** Every page is complete HTML and works without JavaScript. Behaviour is one plain ES module per feature in `src/app/javascript/`, attached by `data-behaviour`. Partial updates fetch HTML fragments from the same view functions. A framework saves a human from writing DOM code; an agent can write it directly.
* **Shared logic is C compiled to WebAssembly.** Rules that must agree on client and server, and compute-heavy client work, run from `src/app/wasm/` entry points that call `<singular>_rules.c`. Build with `zig cc -target wasm32-wasi -mexec-model=reactor`, with no Emscripten runtime.
* **Views are C, not templates.** The compiler checks every view, and the escaping invariant comes from the type system rather than a template language.
* **SQLite, in process.** `storage/<env>.sqlite3` in WAL mode with foreign keys on, wrapped only by `src/framework/record.c`. Jobs are rows in the same database, run by job threads; a job must be safe to run twice.
* **One worker per core.** Each worker has its own nonblocking event loop, `SO_REUSEPORT` listener, SQLite connection and arenas, and queries run inline. Application code never frees: process, worker, request and job each have their own arena.
* **One binary.** Migrations, `public/`, assets, scripts and wasm modules are embedded with `#embed` and served at content-hashed paths. TLS terminates in a proxy in front. Deploying is copying the binary and keeping `storage/`.
* **Machine-readable everything.** Logs are JSON lines on stdout, one per request with route, status, duration, query count and bytes allocated. Every `./nob` command takes `--format json`.
* **The framework is extracted, not designed.** `src/framework/` gets a module when a feature first needs it, and it is written as a library from day one. When a second app needs it, it moves to its own repository, pinned as `deps/framework/`, and is deleted from both apps, never copied.

## Commands and Checks

```text
./nob dev | server | routes | setup
./nob db:migrate | db:rollback | db:seed | db:reset
./nob test [path]     tests under the sanitizers
./nob check           warnings, clang-tidy, modern-c check, convention check
./nob bench           fails on a broken route budget
./nob build | clean | install | uninstall
```

The convention check fails on a model or controller without a test, a resource action without its view, a migration without `up` or `down`, `db/schema.sql` out of step with the migrations, `html_markup` with a non-literal, and run-time SQL. When a new boundary or invariant appears, add it to the check rather than to prose.

Before finishing, run `./nob check`, `./nob test` and `./nob bench`. Open changed pages with `./nob dev` and the `browser-automation` skill. Then confirm that the new code reads like the resource it was modelled on, and that the `modern-c` review checklist still holds.

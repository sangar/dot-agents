# The posts Resource

The first resource of an empty app, shown for `posts` with `title`, `body` and `published`. Use it only to bootstrap; once the app has a resource, that code is the template and this file is not read. The framework calls (`Request`, `Params`, `FieldErrors`, `View`, `Html`, `Statement`, `render`, `redirect`) are the `src/framework/` vocabulary; write each one when the first resource needs it, with the signature used here.

## db/migrate/20261021120000_create_posts.sql

```sql
-- migrate:up
CREATE TABLE posts (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL DEFAULT '',
    published INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

-- migrate:down
DROP TABLE posts;
```

## src/app/models/post.h

```c
#pragma once

#include "framework/record.h"

typedef struct Post {
    int64_t id;
    String title;
    String body;
    bool published;
    int64_t created_at;
    int64_t updated_at;
} Post;

typedef struct PostList {
    Post *items;
    size_t count;
} PostList;

// post_find loads the post with id into the arena; ERR_NOT_FOUND when there is none.
[[nodiscard]] Error post_find(Db *db, Arena *arena, int64_t id, Post *post, Err *err);

// post_all loads every post, newest first, into the arena.
[[nodiscard]] Error post_all(Db *db, Arena *arena, PostList *posts, Err *err);

// post_insert stores a new post and sets its id and both timestamps to now.
[[nodiscard]] Error post_insert(Db *db, int64_t now, Post *post, Err *err);

// post_update stores every column of an existing post and sets updated_at to now.
[[nodiscard]] Error post_update(Db *db, int64_t now, Post *post, Err *err);

// post_delete removes the post with id; ERR_NOT_FOUND when there is none.
[[nodiscard]] Error post_delete(Db *db, int64_t id, Err *err);
```

## src/app/models/post_rules.h

```c
#pragma once

#include "app/models/post.h"
#include "framework/field_errors.h"

// post_validate reports whether post can be saved; each problem is added to errors.
bool post_validate(const Post *post, Arena *arena, FieldErrors *errors);
```

`post_rules.c` includes only libmc text headers, `post.h` for the struct and `framework/field_errors.h`, which has no dependencies, so `./nob` compiles it for the server and for `wasm32`.

```c
bool post_validate(const Post *post, Arena *arena, FieldErrors *errors)
{
    if (str_trim(post->title).len == 0) field_errors_add(errors, arena, S("title"), S("can't be blank"));
    if (post->title.len > 200) field_errors_add(errors, arena, S("title"), S("is longer than 200 bytes"));
    return errors->count == 0;
}
```

## src/app/models/post.c

```c
#include "post.h"

static Post post_from_row(Statement *statement, Arena *arena)
{
    return (Post){
        .id = statement_i64(statement, 0),
        .title = statement_text(statement, arena, 1),
        .body = statement_text(statement, arena, 2),
        .published = statement_i64(statement, 3) != 0,
        .created_at = statement_i64(statement, 4),
        .updated_at = statement_i64(statement, 5),
    };
}

Error post_find(Db *db, Arena *arena, int64_t id, Post *post, Err *err)
{
    Statement *statement = nullptr;
    Error e = record_prepare(db, "SELECT id, title, body, published, created_at, updated_at FROM posts WHERE id = ?",
                             &statement, err);
    if (e) return e;
    statement_bind_i64(statement, 1, id);

    bool found = false;
    e = statement_step(statement, &found, err);
    if (e) return e;
    if (!found) return err_set(err, ERR_NOT_FOUND, "post %lld not found", (long long)id);
    *post = post_from_row(statement, arena);
    return ERR_OK;
}

Error post_insert(Db *db, int64_t now, Post *post, Err *err)
{
    Statement *statement = nullptr;
    Error e = record_prepare(
        db, "INSERT INTO posts (title, body, published, created_at, updated_at) VALUES (?, ?, ?, ?, ?)",
        &statement, err);
    if (e) return e;

    post->created_at = post->updated_at = now;
    statement_bind_text(statement, 1, post->title);
    statement_bind_text(statement, 2, post->body);
    statement_bind_i64(statement, 3, post->published);
    statement_bind_i64(statement, 4, post->created_at);
    statement_bind_i64(statement, 5, post->updated_at);
    e = statement_run(statement, err);
    if (e) return e;
    post->id = record_last_insert_id(db);
    return ERR_OK;
}
```

SQL is a string literal; values always go through `statement_bind_*`. `record_prepare` caches the prepared statement on the worker's connection by its text and resets it for reuse, so the caller never finalizes it, and it counts the query for the request log and the tests. `post_all`, `post_update` and `post_delete` follow the same pattern.

## src/app/controllers/posts_controller.c

```c
#include "posts_controller.h"

#include "app/models/post.h"
#include "app/models/post_rules.h"
#include "app/views/posts/index.h"
#include "app/views/posts/new.h"
#include "app/views/posts/show.h"
#include "config/routes.h"

static void post_params(const Params *params, Post *post)
{
    params_text(params, S("post[title]"), &post->title);
    params_text(params, S("post[body]"), &post->body);
    params_bool(params, S("post[published]"), &post->published);
}

Error posts_controller_index(Request *req, Err *err)
{
    PostList posts = {0};
    Error e = post_all(req->db, req->arena, &posts, err);
    if (e) return e;
    posts_index_view(req->view, posts);
    return render(req, HTTP_OK);
}

Error posts_controller_show(Request *req, Err *err)
{
    Post post = {0};
    Error e = post_find(req->db, req->arena, req->id, &post, err);
    if (e) return e;
    posts_show_view(req->view, &post);
    return render(req, HTTP_OK);
}

Error posts_controller_new(Request *req, Err *err)
{
    posts_new_view(req->view, &(Post){0}, (FieldErrors){0});
    return render(req, HTTP_OK);
}

Error posts_controller_create(Request *req, Err *err)
{
    Post post = {0};
    post_params(&req->params, &post);

    FieldErrors errors = {0};
    if (!post_validate(&post, req->arena, &errors)) {
        posts_new_view(req->view, &post, errors);
        return render(req, HTTP_UNPROCESSABLE_CONTENT);
    }
    Error e = post_insert(req->db, req->now, &post, err);
    if (e) return e;
    flash_set(req, S("notice"), S("Post was created."));
    return redirect(req, post_path(req->arena, post.id));
}

Error posts_controller_destroy(Request *req, Err *err)
{
    Error e = post_delete(req->db, req->id, err);
    if (e) return e;
    flash_set(req, S("notice"), S("Post was deleted."));
    return redirect(req, posts_path(req->arena));
}
```

The router parses `:id` into `req->id` and answers 404 itself when it is not a positive integer. `edit` is `show` with `posts_edit_view`. `update` starts from `post_find`, applies `post_params` over the loaded post, renders `posts_edit_view` with 422 when `post_validate` fails and calls `post_update`. `redirect` answers 303 See Other. `render` passes the page's `Html` to the layout.

## src/config/routes.c

```c
#include "routes.h"

#include "app/controllers/pages_controller.h"
#include "app/controllers/posts_controller.h"

static const Resource POSTS = {
    .name = "posts",
    .index = posts_controller_index,
    .show = posts_controller_show,
    .new_ = posts_controller_new,
    .create = posts_controller_create,
    .edit = posts_controller_edit,
    .update = posts_controller_update,
    .destroy = posts_controller_destroy,
};

static const Route ROUTES[] = {
    {.verb = HTTP_GET, .path = "/", .action = pages_controller_home},
    {.resource = &POSTS},
};

RouteTable routes(void)
{
    return (RouteTable){.items = ROUTES, .count = countof(ROUTES)};
}

String posts_path(Arena *arena)
{
    return S("/posts");
}

String post_path(Arena *arena, int64_t id)
{
    return str_format(arena, "/posts/%lld", (long long)id);
}
```

## src/app/views/posts/index.c

```c
#include "index.h"

#include "_post.h"
#include "config/routes.h"

void posts_index_view(View *view, PostList posts)
{
    html_markup(view, "<h1>Posts</h1>");
    html_link(view, S("New post"), new_post_path(view->arena));
    for (size_t i = 0; i < posts.count; i++) posts_post_partial(view, &posts.items[i]);
}
```

## src/app/views/posts/_post.c

```c
#include "_post.h"

#include "config/routes.h"

void posts_post_partial(View *view, const Post *post)
{
    html_markup(view, "<article id=\"post-");
    html_i64(view, post->id);
    html_markup(view, "\"><h2>");
    html_link(view, post->title, post_path(view->arena, post->id));
    html_markup(view, "</h2>");
    html_time(view, post->created_at);
    html_markup(view, "</article>");
}
```

`html_i64` and `html_time` format and escape in one step; `html_time` writes `<time datetime="...">` in RFC 3339 so scripts and tests read the value without parsing prose.

## src/app/views/posts/_form.c

```c
#include "_form.h"

#include "config/routes.h"

void posts_form_partial(View *view, const Post *post, FieldErrors errors)
{
    bool saved = post->id != 0;
    html_form_open(view, saved ? post_path(view->arena, post->id) : posts_path(view->arena),
                   saved ? HTTP_PATCH : HTTP_POST);
    html_field_errors(view, errors);
    html_text_field(view, S("post[title]"), S("Title"), post->title);
    html_text_area(view, S("post[body]"), S("Body"), post->body);
    html_check_box(view, S("post[published]"), S("Published"), post->published);
    html_submit(view, saved ? S("Update post") : S("Create post"));
    html_form_close(view);
}
```

`html_form_open` writes the CSRF token and, for PATCH and DELETE, the `_method` field. Each field helper writes a `<label>` tied to its input by id.

## src/app/wasm/post_rules.c

```c
#include "app/models/post_rules.h"

// post_rules_title_error_count answers the form script: how many validation
// errors a post with this title has, 0 when it is valid.
[[gnu::export_name("post_rules_title_error_count")]]
uint32_t post_rules_title_error_count(const char *title, uint32_t length)
{
    Arena *arena = arena_create(0);
    FieldErrors errors = {0};
    Post post = {.title = {.data = title, .len = length}};
    uint32_t count = post_validate(&post, arena, &errors) ? 0 : (uint32_t)errors.count;
    arena_destroy(arena);
    return count;
}
```

Only an entry point lives here; the rule itself is `post_validate`, compiled from `src/app/models/post_rules.c`. `./nob` builds it with `zig cc -target wasm32-wasi -mexec-model=reactor`, whose bundled libc gives libmc's arena `malloc` without importing anything from the host. `src/app/javascript/post_form.js` loads the module, copies the title into its memory through an exported allocator, validates as the user types and leaves the server to validate again on submit.

## tests/fixtures/posts.sql

```sql
INSERT INTO posts (id, title, body, published, created_at, updated_at) VALUES
    (1, 'Hello', 'The first post.', 1, 1792540800000000000, 1792540800000000000),
    (2, 'Draft', '', 0, 1792540800000000000, 1792540800000000000);
```

## tests/controllers/posts_controller_test.c

```c
#include "test_helper.h"

static void create_with_valid_params_redirects_to_the_post(Test *test)
{
    Params params = test_params(test, "post[title]", "New", "post[body]", "Text", nullptr);
    TestResponse response = test_post(test, S("/posts"), params);
    test_check(test, response.status == HTTP_SEE_OTHER, "redirects after create");
    test_check_str(test, response.location, S("/posts/3"), "redirects to the new post");
}

static void create_without_title_renders_the_form_again(Test *test)
{
    Params params = test_params(test, "post[title]", "", nullptr);
    TestResponse response = test_post(test, S("/posts"), params);
    test_check(test, response.status == HTTP_UNPROCESSABLE_CONTENT, "answers 422");
    test_check(test, str_contains(response.body, S("can&#39;t be blank")), "shows the escaped error");
    test_check(test, response.queries == 0, "an invalid post never reaches the database");
}

static void index_loads_posts_in_one_query(Test *test)
{
    TestResponse response = test_get(test, S("/posts"));
    test_check(test, response.status == HTTP_OK, "answers 200");
    test_check(test, response.queries == 1, "one query for the whole list");
}

static void show_missing_post_is_not_found(Test *test)
{
    TestResponse response = test_get(test, S("/posts/999999"));
    test_check(test, response.status == HTTP_NOT_FOUND, "answers 404");
}

const TestCase POSTS_CONTROLLER_TESTS[] = {
    {"create with valid params redirects to the post", create_with_valid_params_redirects_to_the_post},
    {"create without title renders the form again", create_without_title_renders_the_form_again},
    {"index loads posts in one query", index_loads_posts_in_one_query},
    {"show missing post is not found", show_missing_post_is_not_found},
    {nullptr, nullptr},
};
```

`test_params` takes name and value pairs ended by `nullptr`. Every test runs inside a rolled-back transaction with the fixtures loaded and the clock fixed, and requests go straight through the router with a valid CSRF token, so ids, redirect targets and timestamps are the same on every run.

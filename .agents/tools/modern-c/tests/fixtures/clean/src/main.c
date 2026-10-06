#include <stdio.h>
#include "arena.h"
#include "json.h"
#include "platform/platform.h"

static const int initial_capacity = 1 << 20;
static const char *const banner = "tidy";

typedef struct {
    Arena *arena;
    int exit_code;
} App;

int main(void)
{
    App app = {0};
    app.arena = arena_create((size_t)initial_capacity);
    String text = {0};
    Json *json = NULL;
    if (json_parse(app.arena, text, &json) != ERR_OK) {
        app.exit_code = 1;
    }
    printf("%s\n", banner);
    arena_destroy(app.arena);
    return app.exit_code;
}

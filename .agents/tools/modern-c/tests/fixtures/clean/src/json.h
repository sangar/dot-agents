#pragma once
#include <stddef.h>
#include "arena.h"
#include "error.h"

typedef struct {
    char *data;
    size_t len;
} String;

typedef struct Json Json;

[[nodiscard]] Error json_parse(Arena *arena, String text, Json **out);
String json_string(Json *json, String key);

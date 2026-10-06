#pragma once
#include <stddef.h>

typedef struct Arena Arena;

Arena *arena_create(size_t capacity);
void *arena_push(Arena *arena, size_t size);
void arena_destroy(Arena *arena);

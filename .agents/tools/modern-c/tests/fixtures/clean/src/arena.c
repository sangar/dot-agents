#include "arena.h"
#include <stdlib.h>

struct Arena {
    unsigned char *base;
    size_t used;
    size_t capacity;
};

Arena *arena_create(size_t capacity)
{
    Arena *arena = malloc(sizeof(*arena) + capacity);
    if (arena == NULL) {
        return NULL;
    }
    arena->base = (unsigned char *)(arena + 1);
    arena->used = 0;
    arena->capacity = capacity;
    return arena;
}

void *arena_push(Arena *arena, size_t size)
{
    if (arena->capacity - arena->used < size) {
        return NULL;
    }
    void *result = arena->base + arena->used;
    arena->used += size;
    return result;
}

void arena_destroy(Arena *arena)
{
    free(arena);
}

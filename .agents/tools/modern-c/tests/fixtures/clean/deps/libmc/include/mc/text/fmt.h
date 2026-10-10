#pragma once
#include <stdint.h>
#include "mc/core/arena.h"
#include "mc/text/str.h"

String fmt_duration(Arena *arena, int64_t nanoseconds);
String fmt_bytes(Arena *arena, uint64_t bytes);

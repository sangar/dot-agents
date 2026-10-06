#pragma once
#include "../error.h"
#include "../json.h"

[[nodiscard]] Error platform_read_file(Arena *arena, String path, String *out);

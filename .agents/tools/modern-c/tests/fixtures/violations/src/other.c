#include "cJSON.h"
#include "store.h"

static Error other_fail(void) { return ERR_IO; }
[[nodiscard]] static Error other_ok(void) { return ERR_OK; }

Error store_open(Store **out)
{
    *out = NULL;
    return other_fail() == ERR_OK ? other_ok() : ERR_IO;
}

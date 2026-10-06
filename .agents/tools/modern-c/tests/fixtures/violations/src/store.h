#pragma once
#include <stdbool.h>
#include "cJSON.h"

typedef enum { ERR_OK = 0, ERR_IO } Error;
typedef struct Store Store;

Error store_open(Store **out);
[[nodiscard]] Error store_close(Store *store);

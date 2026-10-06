#pragma once
#include <stddef.h>
typedef struct yyjson_doc yyjson_doc;
yyjson_doc *yyjson_read(const char *dat, size_t len, unsigned flg);

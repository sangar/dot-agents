#include "json.h"
#include "yyjson.h"

struct Json {
    yyjson_doc *doc;
};

Error json_parse(Arena *arena, String text, Json **out)
{
    Json *json = arena_push(arena, sizeof(*json));
    if (json == NULL) {
        return ERR_OUT_OF_MEMORY;
    }
    json->doc = yyjson_read(text.data, text.len, 0);
    if (json->doc == NULL) {
        return ERR_INVALID_ARGUMENT;
    }
    *out = json;
    return ERR_OK;
}

String json_string(Json *json, String key)
{
    (void)json;
    return key;
}

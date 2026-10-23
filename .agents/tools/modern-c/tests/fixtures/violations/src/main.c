#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "cJSON.h"
#include "store.h"

#if __STDC_VERSION__ >= 201710L
#define HAVE_C17 1
#endif

#ifdef _WIN32
#define PATH_SEP '\\'
#else
#define PATH_SEP '/'
#endif

#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define countof(a) (sizeof(a) / sizeof((a)[0]))

static const char *const names[] = {"a", "b"};
static int counter;
int visible_total = 0;
struct Store;
enum Mode { MODE_A, MODE_B };
typedef struct { int x; } Point;

/* static int in_comment; */
// static int in_line_comment;

int main(void)
{
    const char *text = "static int in_string;";
    int *buffer = malloc(16 * sizeof(*buffer));
    if (buffer == NULL) {
        return errno;
    }
    free(buffer);
    printf("%s %d\n", text, MAX(counter, visible_total));
    return 0;
}

bool same_name(Arena *arena, String a, String b)
{
    return str_equal(str_lower_ascii(arena, a), b) || tolower(a.data[0]) == 'x';
}

int status_code(const char *header)
{
    return toupper(header[0]); // modern-c: allow ascii-text
}

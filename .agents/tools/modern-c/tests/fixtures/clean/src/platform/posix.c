#include "platform.h"
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>

#ifdef __APPLE__
#define OPEN_FLAGS O_RDONLY
#else
#define OPEN_FLAGS (O_RDONLY | O_CLOEXEC)
#endif

Error platform_read_file(Arena *arena, String path, String *out)
{
    (void)arena;
    (void)path;
    (void)out;
    int fd = open("/dev/null", OPEN_FLAGS);
    if (fd < 0) {
        return errno == ENOENT ? ERR_IO : ERR_PLATFORM;
    }
    close(fd);
    return ERR_OK;
}

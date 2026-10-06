# Vjekoslav-Inspired C Best Practices: Detailed Rules

Companion to [SKILL.md](SKILL.md). Each rule below gives the rationale and code shape for one principle of the style.

---

# 1. Memory Is a Design Decision

Do not begin with:

> "Where do I call `malloc` and `free`?"

Begin with:

> "What is the lifetime of this memory?"

Classify allocations by lifetime.

### Long-lived memory

Use a persistent arena or pool.

Examples:

* application state
* loaded file entries
* UI state
* configuration
* persistent caches

### Temporary memory

Use a scratch arena.

Examples:

* building a path
* sorting/filtering temporary data
* formatting strings
* intermediate search results
* temporary arrays
* parsing

### Fixed-size objects

Use a pool.

Examples:

* nodes
* UI objects
* work items
* frequently created/destroyed objects

### Avoid

Scattering ownership throughout the program:

```c
foo = malloc(...);
bar = malloc(...);
baz = malloc(...);

/* ... */

free(foo);
free(bar);
free(baz);
```

Prefer grouping allocations by lifetime:

```c
Arena arena = ...;

Foo *foo = arena_push(&arena, sizeof(*foo));
Bar *bar = arena_push(&arena, sizeof(*bar));
Baz *baz = arena_push(&arena, sizeof(*baz));

/* Destroy/reset the arena when their lifetime ends. */
```

The important idea is not merely "arenas are faster."

The important idea is:

**memory lifetime should be represented directly in the allocator structure.**

---

# 2. Prefer Arenas for Group-Lifetime Memory

An arena should make the common operation extremely cheap:

```c
void *arena_push(Arena *arena, size_t size);
```

Conceptually:

```text
arena
  |
  +---- allocated block
  +---- allocated block
  +---- allocated block
  +---- allocated block
```

Instead of remembering how to free every individual allocation, destroy/reset the group.

Typical operations:

```c
Arena arena_create(...);

void *arena_push(Arena *arena, size_t size);

void arena_reset(Arena *arena);

void arena_destroy(Arena *arena);
```

For temporary work:

```c
Arena_Temp temp = scratch_begin();

...
/* temporary allocations */

scratch_end(temp);
```

The scratch arena should make temporary allocation effectively disappear from the business logic.

---

# 3. Use Scratch Arenas Aggressively

Vjekoslav specifically documented moving toward **heavier use of scratch arenas** in File Pilot.

When a function needs temporary memory, prefer:

```c
Scratch scratch = scratch_begin();

char *path = ...;
Entry *entries = ...;
SortKey *keys = ...;

...

scratch_end(scratch);
```

rather than manually managing every temporary allocation.

Scratch memory is particularly appropriate for:

* temporary strings
* path manipulation
* search/filter operations
* sorting
* parsing
* formatting
* intermediate buffers
* temporary copies

### Rule

If memory only needs to survive until the current operation finishes, it probably belongs in scratch memory.

---

# 4. Use Pools for Repeated Fixed-Size Objects

When objects have:

* identical size
* frequent creation/destruction
* relatively stable lifetime patterns

use a pool rather than general-purpose allocation.

Conceptually:

```c
typedef struct Node Node;

typedef struct {
    Node *free_list;
    ...
} Node_Pool;
```

Then:

```c
Node *node = pool_alloc(&pool);
...
pool_free(&pool, node);
```

Pools are useful when individual objects really do need independent destruction.

Do not force everything into an arena.

Use:

* arena → group lifetime
* scratch arena → temporary lifetime
* pool → individual reusable objects
* normal allocation → when a different lifetime/ownership model genuinely requires it

---

# 5. Avoid Unnecessary Allocator Abstractions

Vjekoslav explicitly documented removing an `Allocator` wrapper abstraction and using **Arenas / Pools directly**.

Prefer:

```c
Foo *foo = arena_push(arena, sizeof(*foo));
```

over unnecessary layers such as:

```c
Foo *foo = allocator_alloc(context->allocator,
                           sizeof(*foo));
```

when the actual requirement is simply:

```text
allocate from this arena
```

### Principle

Do not abstract a mechanism merely because several mechanisms share a similar function signature.

If the distinction matters architecturally, expose it.

Good:

```c
arena_push(...)
pool_alloc(...)
```

Potentially unnecessary:

```c
allocator_alloc(...)
```

that internally dispatches to either one.

---

# 6. Strings Should Carry Their Length

Prefer a string representation such as:

```c
typedef struct {
    char *value;
    size_t length;
} String;
```

rather than assuming every string is a null-terminated C string.

Vjekoslav specifically documented switching File Pilot to length-based strings:

```c
struct String {
    char *value;
    int length;
};
```

The exact integer type can vary according to the codebase; the important design principle is **pointer + explicit length**.

### Benefits

You can:

* represent substrings without copying
* handle embedded zero bytes when needed
* avoid repeated `strlen`
* compare using known lengths
* hash without requiring null termination
* pass slices into larger buffers
* make allocation requirements explicit

Example:

```c
typedef struct {
    char *data;
    size_t len;
} String;
```

Comparison:

```c
bool string_equal(String a, String b)
{
    return a.len == b.len &&
           memcmp(a.data, b.data, a.len) == 0;
}
```

---

# 7. Prefer String Slices Over String Copies

If a function only needs to inspect part of a string, do not allocate another string.

Prefer:

```c
String extension(String path);
```

returning a slice into the original memory.

For example:

```text
"documents/report.txt"
             ^^^^^^^^
```

can be represented as:

```c
String {
    .data = path.data + offset,
    .len  = 3,
};
```

The slice does not own the memory.

This makes ownership obvious:

> A String is often a view, not an allocation.

---

# 8. Make Counts and Lengths Explicit

Vjekoslav documented moving to **unsigned counts/lengths** in File Pilot.

Use an unsigned type where the value fundamentally represents:

* count
* length
* capacity
* size
* index into an unsigned-sized collection

For example:

```c
size_t count;
size_t capacity;
size_t length;
```

rather than using signed integers simply because `int` is convenient.

The important distinction is semantic:

```c
size_t file_count;
size_t string_length;
size_t buffer_capacity;
```

communicate more than:

```c
int a;
int b;
int c;
```

---

# 9. Store Capacity Alongside Dynamic Arrays

A dynamic array should normally know:

```c
typedef struct {
    T *data;
    size_t count;
    size_t capacity;
} Array;
```

The fundamental operations should be simple:

```c
array_push(&array, value);
array_reserve(&array, capacity);
array_clear(&array);
```

Avoid hiding important allocation behavior behind complicated containers.

When performance matters, you should be able to see:

* where memory comes from
* how much memory is allocated
* when growth occurs
* how many elements exist

---

# 10. Prefer Simple, Purpose-Built Data Structures

Do not reach for a general-purpose container automatically.

If File Pilot needs:

```text
file path → entry
```

build the structure appropriate for that workload.

A hash table can be preferable to repeatedly scanning an array.

Vjekoslav documented using a **custom HashMap with stb-style implementation, length-based strings, and arena allocation**.

The principle is:

> Build data structures around the actual workload.

Do not optimize for theoretical generality when a simple specialized structure is clearer and faster.

---

# 11. Favor stb-Style / Single-Unit Simplicity Where Appropriate

For small reusable C components, favor a structure that can be easily integrated into a project.

Typical pattern:

```c
// foo.h

#ifndef FOO_H
#define FOO_H

typedef struct {
    ...
} Foo;

Foo foo_create(...);
void foo_destroy(Foo *foo);

#endif

#ifdef FOO_IMPLEMENTATION

/* implementation */

#endif
```

Then:

```c
#define FOO_IMPLEMENTATION
#include "foo.h"
```

This keeps small utilities easy to move between projects.

Do not turn this into a dogma.

For large subsystems, conventional `.h` + `.c` separation may be preferable.

---

# 12. Keep Ownership Visible

A function should make it reasonably obvious who owns returned memory.

Good:

```c
String path_join(Arena *arena, String a, String b);
```

This communicates:

> The result is allocated from `arena`.

Likewise:

```c
String path_extension(String path);
```

suggests a non-owning slice.

Avoid APIs where ownership is mysterious:

```c
char *make_string(...);
```

Does the caller:

```c
free(result);
```

or:

```c
arena_free(result);
```

or:

```c
nothing;
```

?

The API should answer this.

---

# 13. Allocate According to Lifetime, Not Convenience

Bad:

```c
void process_file(...)
{
    Foo *foo = malloc(...);

    ...
    
    free(foo);
}
```

when `Foo` could naturally live in scratch memory.

Better:

```c
void process_file(Arena *scratch, ...)
{
    Foo *foo = arena_push(scratch, sizeof(*foo));

    ...
}
```

Even better when the scratch arena is implicit in the surrounding operation:

```c
void process_file(...)
{
    Scratch scratch = scratch_begin();

    Foo *foo = scratch_push(scratch, sizeof(*foo));

    ...

    scratch_end(scratch);
}
```

The allocator expresses the lifetime.

---

# 14. Avoid `malloc` as the Default Architecture

Do not interpret this as:

> "Never use malloc."

Interpret it as:

> "`malloc` should not automatically become the ownership model for every object."

Vjekoslav described File Pilot as C software focused heavily on performance and explicitly documented arenas, pools, scratch arenas, and custom data structures.

Use the system allocator when appropriate:

* OS-facing resources
* unusual lifetimes
* third-party APIs
* simple tools
* genuinely independent allocations
* allocator internals

But for application-level bulk data, first ask whether an arena/pool provides a better lifetime model.

---

# 15. Favor Contiguous Data

Prefer:

```c
Entry *entries;
size_t count;
```

over:

```c
Entry **entries;
```

when the data naturally fits into contiguous storage.

Contiguous arrays provide:

* good cache locality
* simple iteration
* fewer allocations
* fewer pointers
* simpler ownership

Prefer:

```c
for (size_t i = 0; i < entries.count; ++i) {
    process(entries.data[i]);
}
```

over pointer-heavy object graphs unless pointer indirection is actually useful.

---

# 16. Think About the Cost of Indirection

When designing structures, ask:

```text
How many pointer dereferences happen?
Where is the data physically located?
How many allocations are involved?
Will iteration touch contiguous memory?
```

Do not optimize every structure prematurely.

But in performance-sensitive code, memory layout is part of the algorithm.

---

# 17. Separate Platform Code From Portable Code

File Pilot is a Windows application, but Vjekoslav documented using UTF-8 in the non-platform layer and converting to Windows wide strings in the Windows layer.

Prefer:

```text
portable/application layer
        |
        v
platform boundary
        |
        v
Win32 / OS representation
```

For example:

```c
// portable
String path;

// Windows boundary
WString win32_path;
```

Do not spread platform-specific representations through the entire program.

---

# 18. Keep Platform Conversions at the Boundary

Bad:

```c
void search(wchar_t *path);
void filter(wchar_t *text);
void sort(wchar_t *name);
```

when the application's natural representation is UTF-8.

Prefer:

```c
void search(String path);
void filter(String text);
void sort(String name);
```

and convert only when calling the OS.

This keeps the core data model simpler.

---

# 19. Design for Large Inputs

File Pilot was explicitly designed around very large directory listings. Vjekoslav documented testing with hundreds of thousands of entries and even roughly one million files while maintaining responsive selection and scrolling.

Therefore:

**Never assume "the list will only contain a few hundred items."**

For code operating on potentially huge collections:

* avoid O(n) work inside every input event when possible
* avoid repeated allocations
* avoid repeated string scanning
* avoid pointer-heavy structures
* avoid unnecessary copies
* keep hot data compact
* consider asynchronous work
* measure before and after optimization

---

# 20. Move Expensive Work Off the UI Thread

File Pilot uses multithreaded searching/filtering and asynchronous sorting.

General rule:

```text
UI/input thread
    |
    +--> quick state changes
    |
    +--> schedule expensive work
             |
             +--> worker thread
```

Examples of work suitable for workers:

* directory enumeration
* filtering
* sorting
* thumbnail generation
* parsing
* expensive filesystem operations

The UI should remain responsive.

---

# 21. Thread Pools Over One-Off Threads

When work is naturally parallel, prefer a reusable worker infrastructure rather than constantly creating and destroying OS threads.

Think:

```text
work queue
    |
    +-- worker
    +-- worker
    +-- worker
    +-- worker
```

rather than:

```text
operation -> create thread -> work -> destroy thread
```

Vjekoslav documented moving toward more generic thread support and thread pools in the earlier Disk Voyager/File Pilot work.

---

# 22. Keep Hot Paths Boring

Performance-critical code should generally be easy to inspect.

Prefer:

```c
for (size_t i = 0; i < count; ++i) {
    Entry *entry = &entries[i];

    if (entry->visible) {
        draw_entry(entry);
    }
}
```

over an elaborate abstraction stack that obscures:

* iteration
* branches
* memory access
* allocation
* synchronization

The compiler can optimize simple code extremely well.

The programmer can understand it too.

---

# 23. Do Not Abstract Hardware Costs Away

When performance matters, make expensive operations visible.

Be suspicious of hidden:

* allocations
* copies
* string scans
* locks
* virtual dispatch
* pointer chasing
* system calls
* thread creation

An API that looks cheap but secretly performs expensive work is dangerous in hot code.

---

# 24. Prefer Explicit Initialization

For structs:

```c
Foo foo = {0};
```

is often an excellent baseline.

It provides deterministic zero initialization and makes the initial state obvious.

Then explicitly establish required fields:

```c
Foo foo = {0};

foo.capacity = initial_capacity;
foo.arena = arena;
```

Do not depend on accidental initialization.

---

# 25. Use Assertions for Programmer Errors

Use assertions to encode assumptions that should never be false in correct code:

```c
assert(arena != NULL);
assert(index < array->count);
assert(size <= capacity);
```

Assertions are especially useful around custom allocators and data structures because they turn silent corruption into an immediate failure.

Do not use assertions as a substitute for handling expected runtime errors.

---

# 26. Distinguish Runtime Failure From Programmer Error

Expected:

```text
file does not exist
permission denied
out of disk space
OS call failed
```

Handle these explicitly.

Unexpected:

```text
array index outside bounds
invalid internal state
NULL arena where one is required
corrupt container invariant
```

Assert these.

---

# 27. Measure Before Inventing Complexity

The goal is not:

> "Write clever C."

The goal is:

> "Write simple C that is fast enough, then optimize the actual bottleneck."

When profiling identifies a hot path, investigate:

```text
CPU
memory bandwidth
cache misses
allocation
branching
I/O
synchronization
```

Then change the data representation or algorithm if that is where the cost actually lives.

---

# 28. Prefer Lifetime-Based APIs

Good APIs communicate lifetime:

```c
String string_copy(Arena *arena, String source);

String string_slice(String source, size_t start, size_t length);

void *arena_push(Arena *arena, size_t size);

void *pool_alloc(Pool *pool);
```

The allocator/context is part of the API rather than an invisible global mechanism.

---

# 29. Do Not Create a Universal "Memory Manager"

Avoid building a giant abstraction like:

```c
MemoryManager
    -> allocator
        -> arena
        -> pool
        -> heap
        -> scratch
        -> ...
```

unless the architecture genuinely requires it.

If the code needs an arena:

```c
Arena *
```

If it needs a pool:

```c
Pool *
```

Use the actual abstraction.

This follows the direction Vjekoslav documented when he removed the generic `Allocator` wrapper and used arenas/pools directly.

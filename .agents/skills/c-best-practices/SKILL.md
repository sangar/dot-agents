---
name: c-best-practices
description: Write C in the Vjekoslav Babić / File Pilot style - arenas, scratch arenas and pools over scattered malloc/free, explicit memory lifetime and ownership, pointer + length strings, explicit unsigned counts, contiguous cache-friendly data, minimal abstraction, platform conversions at the boundary, expensive work off the UI thread. Use when writing, reviewing or refactoring C code, designing C data structures or allocators, or when the user mentions arenas, scratch memory, pools, or performance-oriented C.
---

# Vjekoslav-Inspired C Best Practices

## Purpose

Write C in the style and spirit demonstrated by Vjekoslav Babić in the development of File Pilot and related projects:

* performance-oriented
* explicit memory ownership
* arenas and pools instead of pervasive `malloc/free`
* scratch memory for temporary work
* simple data structures
* length-based strings
* explicit sizes/counts
* minimal abstraction over fundamental mechanisms
* cache-conscious data organization
* straightforward code that exposes what the machine is doing

This is an **inferred style guide**, based on Vjekoslav's publicly documented File Pilot development practices. It is not an official Vjekoslav coding standard.

The 29 detailed rules with rationale and code examples are in [reference.md](reference.md). Read it when designing a subsystem, allocator, string or container API, or when reviewing C code against this style.

---

# Recommended Mental Model

When writing a subsystem, answer these questions first:

```text
1. What data exists?
2. How long does each piece of data live?
3. Who owns it?
4. Is the data contiguous?
5. Is it temporary?
6. Is its size fixed?
7. How frequently is it created/destroyed?
8. Is it accessed sequentially?
9. Is it accessed from multiple threads?
10. Is it on a hot path?
```

Then choose the representation.

Typical mapping:

```text
temporary          -> scratch arena
same lifetime      -> arena
fixed-size objects -> pool
dynamic collection -> dynamic array
string             -> pointer + length
lookup             -> hash map
huge work          -> worker thread
platform API       -> platform boundary
```

---

# Preferred Style Summary

When unsure, bias toward:

* arenas over scattered heap allocations
* scratch arenas for temporary work
* pools for reusable fixed-size objects
* explicit ownership
* pointer + length strings
* explicit counts and capacities
* contiguous arrays
* simple hash maps
* purpose-built data structures
* minimal abstraction
* platform boundaries
* asynchronous expensive work
* thread pools for repeated parallel work
* simple hot loops
* assertions for invariants
* measurement before optimization

And avoid:

* allocator abstraction layers without a concrete need
* unnecessary `malloc/free`
* hidden ownership
* repeated string copying
* null-terminated-string assumptions everywhere
* pointer-heavy data structures by default
* per-object allocation when lifetimes are grouped
* expensive UI-thread work
* abstractions that hide memory or CPU costs
* optimizing based on intuition alone

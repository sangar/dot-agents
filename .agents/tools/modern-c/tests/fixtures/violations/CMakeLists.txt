cmake_minimum_required(VERSION 3.25)
project(legacy C)
add_compile_definitions(NDEBUG)
add_executable(legacy src/main.c src/other.c)

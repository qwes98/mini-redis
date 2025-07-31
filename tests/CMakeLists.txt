# Test configuration for mini-redis
cmake_minimum_required(VERSION 3.16)

# Download and configure Google Test
include(FetchContent)

FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG        release-1.12.1
)

# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(googletest)

include(GoogleTest)

# Include directories
include_directories(${PROJECT_SOURCE_DIR}/include)

# Enhanced test executable for core components
add_executable(test_redis_value
    core/test_redis_value_basic.cpp
)

# Link libraries
target_link_libraries(test_redis_value
    gtest
    gtest_main
    pthread
)

# Register tests with CTest
gtest_discover_tests(test_redis_value)
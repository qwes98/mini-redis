#!/bin/bash

# Mini-Redis Test Runner Script
# This script builds and runs all tests for the mini-redis project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -c, --clean         Clean build directory before building"
    echo "  -r, --release       Build in Release mode (default: Debug)"
    echo "  -v, --verbose       Run tests with verbose output"
    echo "  -f, --filter PATTERN Run only tests matching the pattern"
    echo "  --no-build          Skip build step and only run tests"
    echo "  --coverage          Generate coverage report (requires gcov)"
    echo ""
    echo "Examples:"
    echo "  $0                           # Build and run all tests"
    echo "  $0 --clean --verbose         # Clean build and run with verbose output"
    echo "  $0 --filter RedisValue*      # Run only RedisValue tests"
    echo "  $0 --release --no-build      # Run tests without rebuilding (Release mode)"
}

# Default values
BUILD_TYPE="Debug"
CLEAN_BUILD=false
VERBOSE=false
FILTER=""
NO_BUILD=false
COVERAGE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -r|--release)
            BUILD_TYPE="Release"
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--filter)
            FILTER="$2"
            shift 2
            ;;
        --no-build)
            NO_BUILD=true
            shift
            ;;
        --coverage)
            COVERAGE=true
            BUILD_TYPE="Debug"  # Coverage requires debug info
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Get script directory (where the script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

print_status "Mini-Redis Test Runner"
print_status "Project root: $PROJECT_ROOT"
print_status "Build type: $BUILD_TYPE"

# Change to project root
cd "$PROJECT_ROOT"

# Clean build directory if requested
if [ "$CLEAN_BUILD" = true ]; then
    print_status "Cleaning build directory..."
    rm -rf build
    print_success "Build directory cleaned"
fi

# Build the project (unless --no-build is specified)
if [ "$NO_BUILD" = false ]; then
    print_status "Configuring project with CMake..."
    
    CMAKE_ARGS="-B build -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DBUILD_TESTS=ON"
    
    if [ "$COVERAGE" = true ]; then
        CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_CXX_FLAGS='--coverage' -DCMAKE_EXE_LINKER_FLAGS='--coverage'"
        print_status "Coverage enabled - adding coverage flags"
    fi
    
    if ! cmake $CMAKE_ARGS; then
        print_error "CMake configuration failed"
        exit 1
    fi
    
    print_success "CMake configuration completed"
    
    print_status "Building project..."
    if ! cmake --build build -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4); then
        print_error "Build failed"
        exit 1
    fi
    
    print_success "Build completed successfully"
else
    print_status "Skipping build step as requested"
fi

# Check if build directory exists
if [ ! -d "build" ]; then
    print_error "Build directory not found. Run without --no-build first."
    exit 1
fi

# Run tests
print_status "Running tests..."

cd build

# Prepare test command
if [ "$VERBOSE" = true ]; then
    TEST_CMD="ctest --verbose --output-on-failure"
else
    TEST_CMD="ctest --output-on-failure"
fi

# Add filter if specified
if [ -n "$FILTER" ]; then
    TEST_CMD="$TEST_CMD -R '$FILTER'"
    print_status "Running tests matching pattern: $FILTER"
fi

# Run the tests
if eval $TEST_CMD; then
    print_success "All tests passed!"
    
    # Generate coverage report if requested
    if [ "$COVERAGE" = true ]; then
        print_status "Generating coverage report..."
        if command -v gcov >/dev/null 2>&1; then
            # Find and process coverage files
            find . -name "*.gcda" -exec gcov {} \; > /dev/null 2>&1
            
            # Create coverage directory
            mkdir -p coverage
            mv *.gcov coverage/ 2>/dev/null || true
            
            print_success "Coverage files generated in build/coverage/"
            
            # If lcov is available, generate HTML report
            if command -v lcov >/dev/null 2>&1 && command -v genhtml >/dev/null 2>&1; then
                print_status "Generating HTML coverage report..."
                lcov --capture --directory . --output-file coverage/coverage.info
                lcov --remove coverage/coverage.info '/usr/*' --output-file coverage/coverage.info
                lcov --remove coverage/coverage.info '*/tests/*' --output-file coverage/coverage.info
                lcov --remove coverage/coverage.info '*/_deps/*' --output-file coverage/coverage.info
                genhtml coverage/coverage.info --output-directory coverage/html
                print_success "HTML coverage report generated in build/coverage/html/"
            fi
        else
            print_warning "gcov not found - coverage report not generated"
        fi
    fi
    
else
    print_error "Some tests failed!"
    
    print_status "Test summary:"
    ctest --verbose | grep -E "(PASSED|FAILED)" || true
    
    exit 1
fi

# Return to original directory
cd "$PROJECT_ROOT"

print_success "Test run completed successfully!"
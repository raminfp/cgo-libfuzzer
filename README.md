# CGo Fuzzing with libFuzzer

A lightweight fuzzing tool designed to find bugs in CGo bindings. This tool helps identify memory safety issues, type conversion errors, and other potential problems when interfacing between Go and C code.

## What it Does

- Fuzzes the boundary between Go and C code
- Identifies memory leaks and corruption in CGo bindings
- Catches type conversion errors
- Tests edge cases in C-Go interactions

## Quick Start

Build the project:
```bash
./build.sh
```

Run the fuzzer:
```bash
./run_fuzzer.sh
```

## Project Structure

```
├── build.sh        # Build script
├── corpus/         # Test cases
├── fuzz.c         # C fuzzing implementation
├── fuzz.go        # Go fuzzing implementation
├── fuzzer/        # Core fuzzing logic
├── libfuzz.a      # Fuzzing library
├── libfuzz.h      # C header file
├── target.c       # Target C code
└── target.h       # Target header
```

## Requirements

- Go 1.15+
- GCC/Clang
- CGo enabled

## Using the Fuzzer

1. Add your CGo code to test in `target.c` and `target.h`
2. Put test cases in the `corpus/` directory
3. Run the fuzzer with `./run_fuzzer.sh`
4. Check `crash-*` directories for any found issues

## Understanding Results

When a crash is found:
- Input that caused the crash is saved
- Stack trace is generated
- Location in code is identified

## Common Issues Found

- Memory leaks in CGo bindings
- Type conversion errors
- NULL pointer dereferences
- Buffer overflows
- Memory corruption

## Example Usage

Testing a simple CGo binding:

```go
/*
#include "target.h"
*/
import "C"

func main() {
    // Your CGo code here
}
```

## Tips

- Start with small test cases
- Test edge cases (NULL, empty strings, large numbers)
- Check memory handling
- Verify type conversions

## Contributing

Issues and pull requests welcome. Please include:
- Clear description of changes
- Test cases if adding features
- Updates to documentation


# Implementing CGo Fuzzing with libFuzzer

A writeup on implementing effective fuzzing strategies for CGo bindings using libFuzzer. This guide demonstrates how to set up and implement fuzzing for projects that interface between Go and C code, particularly when working with external C libraries like OpenSSL, FFmpeg, or custom C implementations.

## Purpose

This writeup demonstrates how to:
- Implement libFuzzer-based testing for CGo bindings
- Set up fuzzing infrastructure for Go code calling C libraries
- Detect common issues in CGo implementations:
  - Memory safety problems
  - Type conversion errors
  - Resource leaks
  - Interface boundary issues

## Implementation Guide

### Project Structure
```
├── build.sh        # Build configuration
├── corpus/         # Fuzzing test cases
├── fuzz.c         # libFuzzer C implementation
├── fuzz.go        # Go fuzzing logic
├── fuzzer/        # Core fuzzing implementation
├── libfuzz.a      # Compiled fuzzing library
├── libfuzz.h      # Fuzzing interfaces
├── target.c       # Target C code example
└── target.h       # Target headers
```

### Setting Up libFuzzer Integration

1. Compiler Requirements:
   - Clang with fuzzing support
   - Go 1.15+ with CGo enabled
   ```bash
   export CC=clang
   export CFLAGS="-fsanitize=fuzzer"
   ```

2. Building the Fuzzing Infrastructure:
   ```bash
   # Link with libFuzzer
   clang -fsanitize=fuzzer fuzz.c -c
   
   # Compile Go code with CGo
   go build -buildmode=c-archive fuzz.go
   ```

## Implementation Examples

### Basic CGo Fuzzing
```go
package main

/*
#cgo CFLAGS: -g -fsanitize=fuzzer,address
#include <stdint.h>
#include "target.h"
*/
import "C"
import "unsafe"

//export GoFuzzTarget
func GoFuzzTarget(data []byte) int {
    if len(data) == 0 {
        return 0
    }
    
    return int(C.process_buffer(
        (*C.uint8_t)(unsafe.Pointer(&data[0])),
        C.size_t(len(data)),
    ))
}

func main() {}

```

### Library Integration Examples

For OpenSSL:
```go
/*
#include <openssl/ssl.h>
#include <openssl/err.h>
*/
import "C"

func initFuzzing() {
    C.SSL_library_init()
    // Setup fuzzing environment
}
```

For Custom Libraries:
```go
/*
#include "your_lib.h"
*/
import "C"

//export LLVMFuzzerTestOneInput
func LLVMFuzzerTestOneInput(data []byte) int {
    // Convert and pass data to C functions
    return 0
}
```

## Quick Start

Build the project:
```bash
./build.sh
```

Run the fuzzer:
```bash
./run_fuzzer.sh
```
```sh
❯ ./build.sh
Build completed. Run the fuzzer with: ./fuzzer corpus/
❯ ./run_fuzzer.sh
INFO: Running with entropic power schedule (0xFF, 100).
INFO: Seed: 1344546253
INFO: Loaded 1 modules   (10 inline 8-bit counters): 10 [0x6019797b0ea8, 0x6019797b0eb2), 
INFO: Loaded 1 PC tables (10 PCs): 10 [0x6019797b0eb8,0x6019797b0f58), 
INFO:        6 files found in corpus/
INFO: seed corpus: files: 6 min: 1b max: 5b total: 22b rss: 31Mb
#7	INITED cov: 7 ft: 7 corp: 5/17b exec/s: 0 rss: 32Mb
AddressSanitizer:DEADLYSIGNAL
=================================================================
==10095==ERROR: AddressSanitizer: SEGV on unknown address 0x000000000000 (pc 0x60197976abb2 bp 0x7fffe84581a0 sp 0x7fffe8458100 T0)
==10095==The signal is caused by a WRITE memory access.
==10095==Hint: address points to the zero page.
    #0 0x60197976abb2 in process_buffer /home/raminfp/Projects/go-libfuzzer/target.c:14:16
    #1 0x60197976aca0 in LLVMFuzzerTestOneInput /home/raminfp/Projects/go-libfuzzer/fuzz.c:6:12
    #2 0x60197966f2ca in fuzzer::Fuzzer::ExecuteCallback(unsigned char const*, unsigned long) (/home/raminfp/Projects/go-libfuzzer/fuzzer+0x4e2ca) (BuildId: 8bee81a7b79ed6c785cc5a5e2c197742e5841f42)
    #3 0x60197966e8d9 in fuzzer::Fuzzer::RunOne(unsigned char const*, unsigned long, bool, fuzzer::InputInfo*, bool, bool*) (/home/raminfp/Projects/go-libfuzzer/fuzzer+0x4d8d9) (BuildId: 8bee81a7b79ed6c785cc5a5e2c197742e5841f42)
    #4 0x601979670295 in fuzzer::Fuzzer::MutateAndTestOne() (/home/raminfp/Projects/go-libfuzzer/fuzzer+0x4f295) (BuildId: 8bee81a7b79ed6c785cc5a5e2c197742e5841f42)
    #5 0x601979670d85 in fuzzer::Fuzzer::Loop(std::vector<fuzzer::SizedFile, std::allocator<fuzzer::SizedFile>>&) (/home/raminfp/Projects/go-libfuzzer/fuzzer+0x4fd85) (BuildId: 8bee81a7b79ed6c785cc5a5e2c197742e5841f42)
    #6 0x60197965d585 in fuzzer::FuzzerDriver(int*, char***, int (*)(unsigned char const*, unsigned long)) (/home/raminfp/Projects/go-libfuzzer/fuzzer+0x3c585) (BuildId: 8bee81a7b79ed6c785cc5a5e2c197742e5841f42)
    #7 0x601979689466 in main (/home/raminfp/Projects/go-libfuzzer/fuzzer+0x68466) (BuildId: 8bee81a7b79ed6c785cc5a5e2c197742e5841f42)
    #8 0x7ba26ec2a3b7 in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #9 0x7ba26ec2a47a in __libc_start_main csu/../csu/libc-start.c:360:3
    #10 0x6019796519a4 in _start (/home/raminfp/Projects/go-libfuzzer/fuzzer+0x309a4) (BuildId: 8bee81a7b79ed6c785cc5a5e2c197742e5841f42)

==10095==Register values:
rax = 0x0000000000000000  rbx = 0x0000519000000080  rcx = 0x0000000000000000  rdx = 0x00006019797b1400  
rdi = 0x0000000000000001  rsi = 0x00000000000013a8  rbp = 0x00007fffe84581a0  rsp = 0x00007fffe8458100  
 r8 = 0x00000000000013a0   r9 = 0x0000000000000000  r10 = 0x00000c032f2f61d6  r11 = 0x00000c03af2ee1d0  
r12 = 0x0000521000000100  r13 = 0x00006019797b1400  r14 = 0x00005020019b20b0  r15 = 0x0000000000000008  
AddressSanitizer can not provide additional info.
SUMMARY: AddressSanitizer: SEGV /home/raminfp/Projects/go-libfuzzer/target.c:14:16 in process_buffer
==10095==ABORTING
MS: 2 InsertByte-CopyPart-; base unit: de3a753d4f1def197604865d76dba888d6aefc71
0x46,0x55,0x5a,0x5a,0x58,0x0,0x58,0x0,
FUZZX\000X\000
artifact_prefix='./'; Test unit written to ./crash-39bd23e8afbd036ef4376233d0cda22328e93734
Base64: RlVaWlgAWAA=

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

## Tips

- Start with small test cases
- Test edge cases (NULL, empty strings, large numbers)
- Check memory handling
- Verify type conversions



// fuzzing C code with libFuzzer through CGo.

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

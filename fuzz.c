#include <stdint.h>
#include <stdlib.h>
#include "target.h"

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    return process_buffer(data, size);
}

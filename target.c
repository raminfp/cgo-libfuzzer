#include "target.h"

int process_buffer(const uint8_t* data, size_t size) {
    if (size < 4) return 0;
    
    if (data[0] == 'F' && 
        data[1] == 'U' && 
        data[2] == 'Z' && 
        data[3] == 'Z') {
            
        if (size > 4 && data[4] == 'X') {
            // Trigger a crash for demonstration
            char* p = NULL;
            *p = 1;  // NULL pointer dereference
        }
        
        return 1;
    }
    
    return 0;
}

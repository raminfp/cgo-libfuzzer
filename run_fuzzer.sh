#!/bin/bash

# Set sanitizer options
export ASAN_OPTIONS="detect_leaks=1:symbolize=1"

# Run the fuzzer
./fuzzer -max_len=4096 corpus/

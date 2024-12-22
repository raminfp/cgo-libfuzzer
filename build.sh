#!/bin/bash

# Ensure required tools are installed
if ! command -v clang &> /dev/null; then
    echo "clang is not installed. Please install clang first."
    exit 1
fi

if ! command -v go &> /dev/null; then
    echo "go is not installed. Please install Go first."
    exit 1
fi

# Set environment variables
export CC=clang
export CXX=clang++
export CFLAGS="-g -fsanitize=fuzzer,address"
export CXXFLAGS="-g -fsanitize=fuzzer,address"

# Build Go code
go build -buildmode=c-archive -o libfuzz.a fuzz.go

# Build the fuzzer
clang $CFLAGS -o fuzzer target.c fuzz.c libfuzz.a

# Create corpus directory
mkdir -p corpus

# Create seed file
echo "FUZZ" > corpus/seed1

echo "Build completed. Run the fuzzer with: ./fuzzer corpus/"

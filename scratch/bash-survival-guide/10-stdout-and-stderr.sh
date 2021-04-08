#!/usr/bin/env bash

echo "Hello, stdout"
echo "Hello, stderr" > /dev/stderr

# for _ in {1..10}; do
#   echo "Generating random number..." > /dev/stderr
#   sleep 0.1
#   echo "$RANDOM"
# done

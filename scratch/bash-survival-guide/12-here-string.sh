#!/usr/bin/env bash

# Piping into stdin (2 processes: echo and jq)
echo '{"one": 1, "two": 2}' | jq '.'

# Here string (1 process: jq)
# jq '.' <<< '{"one": 1, "two": 2}'

#!/usr/bin/env bash

# Piping output into a file, operating on the file
echo '{"one": 1, "two": 2}' > /tmp/data.json
jq '.' /tmp/data.json

# Process substitution:
# jq '.' <(echo '{"one": 1, "two": 2}')

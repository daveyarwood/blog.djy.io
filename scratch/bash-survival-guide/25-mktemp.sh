#!/usr/bin/env bash

tempfile="$(mktemp)"

echo "tempfile: $tempfile"

for _ in {1..10}; do
  uuidgen >> "$tempfile"
done

echo "UUIDs:"
cat "$tempfile"

################################################################################

tempdir="$(mktemp -d)"

echo "tempdir: $tempdir"

f="$tempdir/hello.txt"

echo "oh, hello" > "$f"

cat "$f"

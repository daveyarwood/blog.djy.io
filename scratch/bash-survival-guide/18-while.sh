#!/usr/bin/env bash

function greet() {
  local whom="$1"
  echo "Hello, $whom!"
}

while read -r name; do
  greet "$name"
done <<EOF
August
Beatrice
Clara
Dennis
Edith
EOF

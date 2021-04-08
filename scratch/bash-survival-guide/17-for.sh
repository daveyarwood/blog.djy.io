#!/usr/bin/env bash

function greet() {
  local whom="$1"
  echo "Hello, $whom!"
}

for name in August Beatrice Clara Dennis Edith; do
  greet "$name"
done

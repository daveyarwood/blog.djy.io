#!/usr/bin/env bash

# Bash arithmetic expansion

x=2

echo "x is $x"

x=$((x*8))

echo "now, x is $x"

((x+=7))

echo "now, x is $x"

((x++))

echo "now, x is $x"

# bc

bc <<< "$x + (3 * 5.2 + 7/8)"

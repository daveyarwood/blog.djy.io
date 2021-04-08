#!/usr/bin/env bash

set -eo pipefail

echo "Hello!"

ls --totally-unsupported /tmp | rev

echo "We'll never get this far."

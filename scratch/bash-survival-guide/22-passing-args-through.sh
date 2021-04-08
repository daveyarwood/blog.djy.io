#!/usr/bin/env bash

function ls_wrapper() {
  echo "Calling ls with args:" "$@"
  ls "$@"
}

ls_wrapper "$@"

#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 YOUR_FAVORITE_COLOR"
  exit 1
fi

favorite_color="$1"

case "$favorite_color" in
  red)
    echo "red's pretty cool"
    ;;
  blue|green)
    echo "can't go wrong with blue or green"
    ;;
  dark*)
    echo "dark colors are nice"
    ;;
  *)
    echo "$favorite_color is fine, too"
    ;;
esac

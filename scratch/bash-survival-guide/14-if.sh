#!/usr/bin/env bash

cupcakes=""

if [[ -z "$cupcakes" ]]; then
  echo '$cupcakes is empty'
else
  echo '$cupcakes is NOT empty'
fi

# if [[ -n "$cupcakes" ]]; then
#   echo '$cupcakes is non-empty'
# else
#   echo '$cupcakes is empty'
# fi

# # `test ...` is equivalent to `[[ ... ]]`
# if test -z "$cupcakes"; then
#   echo '$cupcakes is empty'
# fi

################################################################################
# Mathematical comparison
################################################################################

# if [[ 1 -eq 1 ]]; then
#   echo "Math still works, phew!"
# fi

# if [[ 1 -gt 0 ]]; then
#   echo "This better print"
# fi

# if [[ 1 -lt 2 ]]; then
#   echo "This better print, too"
# fi

################################################################################
# String comparison
################################################################################

x="foo"

# if [[ "$x" == "foo" ]]; then
#   echo "Of course, that's what I set it to!"
# elif [[ "$x" == "bar" ]]; then
#   echo "Why would it be bar?"
# else
#   echo "Expected foo, but for some weird reason, got $x"
# fi

# if [[ "$x" != "foo" ]]; then
#   echo "This better not print"
# fi

################################################################################
# When NOT to use [[ ... ]]
################################################################################

# grep "oo" <(echo "foo")

# grep -q "oo" <(echo "foo")
# echo $?

# if echo "foo" | grep -q "oo"; then
#   echo "found oo"
# else
#   echo "no oo here"
# fi

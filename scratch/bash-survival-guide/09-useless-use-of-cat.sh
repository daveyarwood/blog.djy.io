#!/usr/bin/env bash

echo -e "one\ntwo\nthree" > /tmp/numbers.txt

################################################################################

# OK:
cat /tmp/numbers.txt | grep two

# Better:
# grep two /tmp/numbers.txt

################################################################################

# OK:
# cat /tmp/numbers.txt | sed 's/e/E/g'

# Better:
# sed 's/e/E/g' /tmp/numbers.txt

################################################################################

# OK:
# cat /tmp/numbers.txt | wc -l

# Better, but not quite what we want:
# wc -l /tmp/numbers.txt

# Problem solved!
# wc -l < /tmp/numbers.txt

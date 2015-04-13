#!/bin/bash

# Grep for non-ASCII lines.

set -e
set -u

for f in "$@"; do
    # http://stackoverflow.com/a/7804901
    perl -ane '{ if(m/[[:^ascii:]]/) { print  } }' $f
done

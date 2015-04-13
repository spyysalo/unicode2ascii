#!/bin/bash

# Run unicode2ascii on a tar.gz and re-pack the result.

set -e
set -u

# http://stackoverflow.com/a/246128
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

TMPDIR1=`mktemp -d u2a-unpack-XXX`
TMPDIR2=`mktemp -d u2a-output-XXX`

function cleanup {
    rm -rf "$TMPDIR1"
    rm -rf "$TMPDIR2"
}
trap cleanup EXIT

if [[ $# < 1 ]]; then
    echo "Usage: $0 TGZ [TGZ [...]]"
    exit 1
fi

for f in "$@"; do
    echo -n "Extracting $f ... " >&2
    tar xzf "$f" -C "$TMPDIR1"
    echo "done." >&2

    echo -n "Running unicode2ascii ... " >&2
    # for all directories in the unpacked data ...
    for d in `find "$TMPDIR1" -type d`; do
	# if it's a subdirectory, create corresponding one
	s=${d/$TMPDIR1}; s=${s#/}; o="$TMPDIR2/$s"
	if [ ! -z "$s" ]; then
	    mkdir -p "$o"
	fi
	# convert all files in the directory
	find "$d" -type f -d 1 | xargs python "$SCRIPTDIR/../unicode2ascii.py" -d "$o"
    done
    echo "done." >&2
	
    t=`basename $f .tar.gz`
    t="${t%.xml}.tar.gz"
    if [[ -e "$t" ]]; then
	echo "Error: $t exists already, won't clobber."
	exit 1
    fi

    echo -n "Packing to $t ... " >&2
    tar czf "$t" -C "$TMPDIR2" .
    echo "done." >&2

    echo -n "Cleaning up ... " >&2
    rm -rf "$TMPDIR1"
    rm -rf "$TMPDIR2"
    mkdir "$TMPDIR1"
    mkdir "$TMPDIR2"
    echo "done." >&2
done

#!/bin/sh

set -eu

error() {
    echo "$1" >&2
}

usage() {
    error "usage: $0 <functions in crate>"
    exit 1
}

case "${1:-}" in
    "") functions=0;;
    *[!0-9]*) usage;;
    *) functions=$1;;
esac

echo "Adding $functions functions to each crate"
for lib in deps/crate*/src/lib.rs; do
    # Overwrite any existing code
    echo "#![allow(dead_code)]"> $lib
    ( for f in `seq 1 $functions`; do
        echo "fn foo$f() {}" >> $lib
    done ) &
done

wait

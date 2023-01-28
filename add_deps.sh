#!/bin/sh
set -eu

usage() {
    echo "usage: $0 <number of crates> [functions in crate]" >&2
    exit 1
}

bare_cargo_toml() {
    name=$1
    path=$2
    echo '[package]
name = "'"$name"'"
version = "0.1.0"
edition = "2021"

[dependencies]' > "$path"
}

cargo_new() {
    mkdir -p "$1"
    bare_cargo_toml $(basename "$1") "$1/Cargo.toml"
    mkdir "$1/src"
    touch "$1/src/lib.rs"
}

case "${1:-}" in
    ""|*[!0-9]*) usage;;
    *) ;;
esac

case "${2:-}" in
    "") functions=0;;
    *[!0-9]*) usage;;
    *) functions=$2;;
esac

rm -rf deps
mkdir -p deps

# Overwrite any existing deps
bare_cargo_toml example Cargo.toml
> src/lib.rs

# cargo-add annoyingly requires that all crates exist or it gives an error that Cargo.toml isn't found
echo "Creating $1 crates"
cargo=$(rustup which cargo)
for c in `seq 1 $1`; do
    crate=deps/crate$c
    cargo_new $crate
    echo "crate$c = { version = '0.1.0', path = 'deps/crate$c' }" >> Cargo.toml
    echo "extern crate crate$c;" >> src/lib.rs
done

./add_functions.sh $functions

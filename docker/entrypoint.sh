#!/bin/sh
# Usage: entrypoint.sh <input.js>[:output.bin] [input2.js[:output2.bin] ...]
# Compiles one or more Bruce .js/.bjs scripts into mquickjs bytecode for ESP32
# (32-bit, little-endian). Each arg is INPUT or INPUT:OUTPUT; when OUTPUT is
# omitted it defaults to INPUT with its extension replaced by .bin.
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <input.js>[:output.bin] [input2.js[:output2.bin] ...]" >&2
    exit 1
fi

for ARG in "$@"; do
    IN="${ARG%%:*}"
    if [ "$ARG" = "$IN" ]; then
        OUT="${IN%.*}.bin"
    else
        OUT="${ARG#*:}"
    fi

    /opt/mquickjs/mqjs -m32 --no-column -o "$OUT" "$IN"
done

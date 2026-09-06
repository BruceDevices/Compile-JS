#!/bin/sh
# Usage: entrypoint.sh <input.js> [output.bin]
# Compiles a Bruce .js script into mquickjs bytecode for ESP32 (32-bit, little-endian).
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <input.js> [output.bin]" >&2
    exit 1
fi

IN="$1"
OUT="${2:-${IN%.js}.bin}"

exec /opt/mquickjs/mqjs -m32 --no-column -o "$OUT" "$IN"

# Bruce Compile JS (for mquickjs)

Compiles a Bruce `.js`/`.bjs` script into mquickjs bytecode (`.bin`) that the
firmware can load directly via `JS_LoadBytecode`, skipping on-device parsing.

```sh
docker run --rm -v "$(pwd):/work" -w /work compile-js \
  <input.js>[:output.bin] [input2.js[:output2.bin] ...]
```

Each argument is a script to compile. Add `:output.bin` to give it an
explicit output path; omit it and the output defaults to the input path with
its extension replaced by `.bin`. Pass multiple arguments to compile several
scripts in one container run.

## Use in your own workflow

Other repos can pull the published image and run it directly in their own
CI, without needing mquickjs locally. Pin to a release tag (`vX.X.X`) rather
than `latest` for reproducible bytecode - see the mquickjs version-pinning
note below; the same reasoning applies here.

**Single file, default output** (`scripts/myscript.js` → `scripts/myscript.bin`):

```yaml
- run: |
    docker run --rm -v "$GITHUB_WORKSPACE:/work" -w /work \
      ghcr.io/brucedevices/compile-js:vX.X.X \
      scripts/myscript.js
```

**Single file, explicit output name**:

```yaml
- run: |
    docker run --rm -v "$GITHUB_WORKSPACE:/work" -w /work \
      ghcr.io/brucedevices/compile-js:vX.X.X \
      scripts/myscript.js:scripts/renamed.bin
```

**Multiple files, default outputs**:

```yaml
- run: |
    docker run --rm -v "$GITHUB_WORKSPACE:/work" -w /work \
      ghcr.io/brucedevices/compile-js:vX.X.X \
      scripts/a.js scripts/b.js scripts/c.js
```

**Multiple files, explicit outputs** (mix and match - any arg can omit its
own `:output`):

```yaml
- run: |
    docker run --rm -v "$GITHUB_WORKSPACE:/work" -w /work \
      ghcr.io/brucedevices/compile-js:vX.X.X \
      scripts/a.js:scripts/a-out.bin \
      scripts/b.js:scripts/b-out.bin \
      scripts/c.js
```

## Build

```sh
docker build -t compile-js docker
```

## Compile a script

```sh
docker run --rm -v "$(pwd):/work" -w /work compile-js scripts/myscript.js:scripts/myscript.bin
```

Each argument is `input.js` or `input.js:output.bin` - pass multiple to
compile several scripts in one run:

```sh
docker run --rm -v "$(pwd):/work" -w /work compile-js scripts/a.js scripts/b.js:scripts/b-out.bin
```

If the output path is omitted, it defaults to the input path with its
extension replaced by `.bin`.

## Notes

- Output is 32-bit, little-endian bytecode (`-m32`), matching all ESP32
  variants (Xtensa and RISC-V).
- `--no-column` strips debug column info to keep the file small.
- The mquickjs ref built into this image (`MQUICKJS_REF` build arg in the
  Dockerfile, default `0.0.6`) must match the `mquickjs=...#<ref>` pin in
  `platformio.ini` - mismatched versions can produce bytecode the firmware
  rejects or mis-executes.
- Bytecode is not verified before execution (same trust model as running a
  plain `.js` file from storage) - only load `.bin` files you compiled
  yourself or trust.

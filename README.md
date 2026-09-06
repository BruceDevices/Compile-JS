# Bruce Compile JS (for mquickjs)

Compiles a Bruce `.js`/`.bjs` script into mquickjs bytecode (`.bin`) that the
firmware can load directly via `JS_LoadBytecode`, skipping on-device parsing.

## Build

```sh
docker build -t compile-js docker/js-compiler
```

## Compile a script

```sh
docker run --rm -v "$(pwd):/work" -w /work compile-js scripts/myscript.js scripts/myscript.bin
```

If the output path is omitted, it defaults to the input path with its
extension replaced by `.bin`.

## Notes

- Output is 32-bit, little-endian bytecode (`-m32`), matching all ESP32
  variants (Xtensa and RISC-V).
- `--no-column` strips debug column info to keep the file small.
- The mquickjs ref built into this image (`MQUICKJS_REF` build arg in the
  Dockerfile, default `0.0.6`) must match the `mquickjs=...#<ref>` pin in
  `platformio.ini` — mismatched versions can produce bytecode the firmware
  rejects or mis-executes.
- Bytecode is not verified before execution (same trust model as running a
  plain `.js` file from storage) — only load `.bin` files you compiled
  yourself or trust.

## Published image

On every GitHub Release, `.github/workflows/publish.yml` builds and pushes
this image to `ghcr.io/brucedevices/compile-js`, tagged with the
release version and `latest`. `workflow_dispatch` triggers a manual build
tagged by commit SHA.

**One-time setup**: after the first publish, set the package visibility to
**public** in the GHCR package settings (repo → Packages → this package →
Package settings → Change visibility). Otherwise other repos' default
`GITHUB_TOKEN` can't pull the image.

## Use in your own workflow

Other repos can compile a script to `.bin` in CI via the reusable workflow,
without needing Docker/mquickjs locally:

```yaml
jobs:
  compile:
    uses: BruceDevices/compile-js/.github/workflows/compile.yml@v1
    with:
      input-file: scripts/myscript.js
      # output-file: scripts/myscript.bin   # optional, defaults to input with .bin extension
      # image-tag: v1.2.3                   # optional, defaults to latest
```

Pin to a release tag (`@v1`) rather than `@main` for reproducible bytecode —
see the mquickjs version-pinning note above; the same reasoning applies here.

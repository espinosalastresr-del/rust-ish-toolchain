# rust-ish-toolchain

Experimental build pipeline for a reduced Rust host toolchain intended to be
tested on iSH/x86 (32-bit).

## Important

This repository does not claim that the generated compiler is compatible with
iSH until the resulting artifact has been tested on an actual iSH installation.

The pipeline:

1. Builds Rust in an i386 Alpine 3.24 container.
2. Requests an i586 host/target.
3. Builds rustc, Cargo, rustdoc and rustfmt.
4. Removes debug information from suitable ELF files.
5. Runs an offline Hello World build inside the build environment.
6. Produces a `.tar.xz` artifact and SHA-256 checksum.

## GitHub Actions

Run:

Actions → Build Rust toolchain for iSH x86 → Run workflow

The default Rust version is configurable through the workflow input.

## iSH installation

Do not overwrite the existing Rust installation until the artifact has been
verified manually. Extract the archive into an isolated directory first and
test the resulting `rustc` binary.

## Why i586?

The intended environment is 32-bit x86. A conservative CPU baseline is used
to reduce the chance of unsupported x86 instructions on an emulator.

## Limitations

A Linux i386 build succeeding in GitHub Actions does not prove that the
resulting binaries will execute under iSH. iSH has its own syscall and CPU
emulation constraints.

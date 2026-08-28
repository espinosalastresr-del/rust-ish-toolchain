#!/bin/bash
set -euo pipefail

: "${RUST_VERSION:?RUST_VERSION is required}"
: "${TARGET_CPU:?TARGET_CPU is required}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${ROOT}/work"
SRC="${WORK}/rust"
PREFIX="${WORK}/stage/usr/local/rust"
TARGET="i586-unknown-linux-musl"

rm -rf "${WORK}"
mkdir -p "${WORK}" "${PREFIX}"

cd "${WORK}"
curl -fL --retry 5 --retry-delay 2 \
  "https://static.rust-lang.org/dist/rust-${RUST_VERSION}-src.tar.xz" \
  -o rust-src.tar.xz
tar -xJf rust-src.tar.xz
mv "rust-${RUST_VERSION}" "${SRC}"

cd "${SRC}"

cp "${ROOT}/config/config.toml" config.toml

# Rust bootstrap requires a stage0 compiler. Fetch the matching official
# source distribution metadata and bootstrap compiler for this architecture.
./x.py build \
  --stage 2 \
  --host i586-unknown-linux-musl \
  --target i586-unknown-linux-musl \
  library/std \
  compiler/rustc \
  src/tools/cargo \
  src/tools/rustfmt \
  src/tools/rustdoc

# Install the produced components into a self-contained prefix.
./x.py install \
  --stage 2 \
  --host i586-unknown-linux-musl \
  --target i586-unknown-linux-musl \
  --prefix "${PREFIX}" \
  library/std \
  compiler/rustc \
  src/tools/cargo \
  src/tools/rustfmt \
  src/tools/rustdoc

# Record requested CPU baseline for later verification.
printf '%s\n' "${TARGET_CPU}" > "${PREFIX}/TARGET_CPU"
printf '%s\n' "${TARGET}" > "${PREFIX}/TARGET"
printf '%s\n' "${RUST_VERSION}" > "${PREFIX}/RUST_VERSION"

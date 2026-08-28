#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${ROOT}/work/stage/usr/local/rust"
DIST="${ROOT}/dist"

[ -d "${PREFIX}" ] || { echo "Missing staged toolchain" >&2; exit 1; }

rm -rf "${DIST}"
mkdir -p "${DIST}"

VERSION="$(cat "${PREFIX}/RUST_VERSION")"
ARCHIVE="${DIST}/rust-ish-${VERSION}-i586-musl.tar.xz"

tar -C "${ROOT}/work/stage" -cJf "${ARCHIVE}" usr/local/rust

sha256sum "${ARCHIVE}" > "${ARCHIVE}.sha256"

cat > "${DIST}/build-info.txt" <<EOF
Rust version: ${VERSION}
Target: $(cat "${PREFIX}/TARGET")
CPU baseline: $(cat "${PREFIX}/TARGET_CPU")
Builder: Alpine 3.24 i386
EOF

ls -lh "${DIST}"

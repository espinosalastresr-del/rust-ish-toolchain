#!/bin/bash
set -euo pipefail

: "${RUST_VERSION:?RUST_VERSION is required}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${ROOT}/work"
SRC="${WORK}/rust"
STAGE="${WORK}/stage"
PREFIX="${STAGE}/usr/local/rust"

HOST="i586-alpine-linux-musl"

rm -rf "${WORK}"
mkdir -p "${WORK}" "${STAGE}" "${PREFIX}"

echo "========================================"
echo "Rust iSH Toolchain Builder"
echo "========================================"
echo "Rust version : ${RUST_VERSION}"
echo "Host         : ${HOST}"
echo "CPU baseline : pentium"
echo "========================================"

echo
echo "[1/7] Installing Alpine bootstrap Rust..."

apk add --no-cache \
    rust \
    cargo \
    rust-src \
    rust-stdlib \
    gcc \
    g++ \
    musl-dev \
    binutils \
    make \
    cmake \
    clang \
    llvm \
    linux-headers \
    llvm-dev \
    python3 \
    perl \
    curl \
    git \
    file \
    tar \
    xz \
    ninja

echo
echo "[2/7] Checking bootstrap compiler..."

rustc --version
cargo --version
rustc --version --verbose

BOOTSTRAP_HOST="$(rustc --version --verbose | awk '/^host:/ {print $2}')"

if [ "${BOOTSTRAP_HOST}" != "${HOST}" ]; then
    echo "ERROR: Bootstrap compiler host is:"
    echo "  ${BOOTSTRAP_HOST}"
    echo
    echo "Expected:"
    echo "  ${HOST}"
    exit 1
fi

echo
echo "[3/7] Downloading Rust source..."

cd "${WORK}"

SOURCE_ARCHIVE="rustc-${RUST_VERSION}-src.tar.xz"
SOURCE_URL="https://static.rust-lang.org/dist/${SOURCE_ARCHIVE}"

echo "Downloading:"
echo "${SOURCE_URL}"

curl \
    --fail \
    --location \
    --retry 5 \
    --retry-delay 3 \
    --retry-all-errors \
    --output "${SOURCE_ARCHIVE}" \
    "${SOURCE_URL}"

echo
echo "[4/7] Extracting source..."

tar -xJf "${SOURCE_ARCHIVE}"

mv "rustc-${RUST_VERSION}-src" "${SRC}"

cd "${SRC}"

echo
echo "[5/7] Preparing bootstrap configuration..."

cp "${ROOT}/config/config.toml" config.toml

echo
echo "Bootstrap compiler:"
rustc --version

echo
echo "Target list:"
rustc --print target-list | grep -E 'i586.*alpine.*musl|i686.*alpine.*musl' || true

echo
echo "[6/7] Building Rust..."

./x.py build \
    --stage 2 \
    --jobs 4 \
    library/std \
    compiler/rustc \
    src/tools/cargo \
    src/tools/rustfmt \
    src/tools/clippy \
    src/tools/rustdoc

echo
echo "[7/7] Installing toolchain..."

./x.py install \
    --stage 2 \
    --prefix "${PREFIX}" \
    library/std \
    compiler/rustc \
    src/tools/cargo \
    src/tools/rustfmt \
    src/tools/rustdoc

echo "${RUST_VERSION}" > "${PREFIX}/RUST_VERSION"
echo "${HOST}" > "${PREFIX}/TARGET"
echo "pentium" > "${PREFIX}/TARGET_CPU"

echo
echo "Build completed."
echo
echo "Installed files:"
find "${PREFIX}/bin" -maxdepth 1 -type f -print 2>/dev/null || true

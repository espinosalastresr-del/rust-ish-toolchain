#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${ROOT}/work/stage/usr/local/rust"
TARGET="$(cat "${PREFIX}/TARGET")"

for tool in rustc cargo rustfmt rustdoc; do
  test -x "${PREFIX}/bin/${tool}" || {
    echo "Missing executable: ${tool}" >&2
    exit 1
  }
done

echo "=== ELF information ==="
file "${PREFIX}/bin/rustc" "${PREFIX}/bin/cargo"

echo "=== Dependencies ==="
ldd "${PREFIX}/bin/rustc" || true
ldd "${PREFIX}/bin/cargo" || true

echo "=== Toolchain metadata ==="
"${PREFIX}/bin/rustc" --version --verbose
"${PREFIX}/bin/cargo" --version
"${PREFIX}/bin/rustfmt" --version

echo "=== Target ==="
echo "${TARGET}"

TEST="${ROOT}/work/hello"
rm -rf "${TEST}"
mkdir -p "${TEST}/src"

cat > "${TEST}/Cargo.toml" <<'EOF'
[package]
name = "hello-ish"
version = "0.1.0"
edition = "2021"

[dependencies]
EOF

cat > "${TEST}/src/main.rs" <<'EOF'
fn main() {
    println!("Hello from Rust on iSH!");
}
EOF

export PATH="${PREFIX}/bin:${PATH}"
export RUSTFLAGS="-C target-cpu=${TARGET_CPU:-pentium}"

cd "${TEST}"
cargo build --release --offline

test -x target/release/hello-ish
file target/release/hello-ish

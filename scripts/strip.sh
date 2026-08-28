#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${ROOT}/work/stage/usr/local/rust"

[ -d "${PREFIX}" ] || { echo "Missing staged toolchain: ${PREFIX}" >&2; exit 1; }

find "${PREFIX}" -type f -perm -0100 -print0 |
while IFS= read -r -d '' f; do
  if file -b "${f}" | grep -qE 'ELF .* (executable|shared object)'; then
    strip --strip-debug "${f}" || true
  fi
done

find "${PREFIX}" -type f -name '*.so' -print0 |
while IFS= read -r -d '' f; do
  strip --strip-debug "${f}" || true
done

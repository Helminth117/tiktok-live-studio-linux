#!/usr/bin/env bash
# Compila mmdevapi.dll (x86_64) de GE-Proton11-11 con
# mmdevapi-device-topology.patch y la deja en la raíz del proyecto,
# lista para cargarse como DLL nativa desde el prefijo.
#
# Requiere el árbol de tools/prepare-wine.sh.
# Uso: build-mmdevapi.sh [DIRECTORIO]   (por defecto ~/Projects/wine-ge)
set -euo pipefail

PROJECT=$(cd "$(dirname "$0")/.." && pwd)
DIR="${1:-$HOME/Projects/wine-ge}"
WINE="$DIR/proton-ge-custom/wine"
BUILD="$DIR/build64"

cd "$WINE"
if ! patch -Rp1 --dry-run -s < "$PROJECT/mmdevapi-device-topology.patch" >/dev/null; then
    patch -Np1 < "$PROJECT/mmdevapi-device-topology.patch"
fi

mkdir -p "$BUILD"
cd "$BUILD"
[[ -f Makefile ]] ||
    "$WINE/configure" --enable-win64 --without-x --without-freetype --without-wayland --disable-tests
make -j"$(nproc)" dlls/mmdevapi/x86_64-windows/mmdevapi.dll

# Sin la marca "Wine builtin DLL", Wine la carga desde system32 en vez de
# sustituirla por la de Proton.
python3 -I - dlls/mmdevapi/x86_64-windows/mmdevapi.dll "$PROJECT/mmdevapi.dll" <<'EOF'
import sys
d = bytearray(open(sys.argv[1], 'rb').read())
assert d[0x40:0x50] == b'Wine builtin DLL'
d[0x40:0x50] = bytes(16)
open(sys.argv[2], 'wb').write(d)
EOF
echo "mmdevapi.dll -> $PROJECT/mmdevapi.dll"

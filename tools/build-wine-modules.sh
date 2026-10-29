#!/usr/bin/env bash
# Compila los módulos de Wine (GE-Proton11-11) que el paquete reemplaza y los
# deja en la raíz del proyecto:
#   mmdevapi.dll  con mmdevapi-device-topology.patch (dispositivos de audio),
#                 lista para cargarse como DLL nativa desde el prefijo
#   winex11.so    con winex11-screen-capture.patch (captura de pantalla)
#
# Requiere el árbol de tools/prepare-wine.sh.
# Uso: build-wine-modules.sh [DIRECTORIO]   (por defecto ~/Projects/wine-ge)
set -euo pipefail

PROJECT=$(cd "$(dirname "$0")/.." && pwd)
DIR="${1:-$HOME/Projects/wine-ge}"
WINE="$DIR/proton-ge-custom/wine"
BUILD="$DIR/build64"

cd "$WINE"
for patch in mmdevapi-device-topology.patch winex11-screen-capture.patch; do
    if ! patch -Rp1 --dry-run -s < "$PROJECT/$patch" >/dev/null; then
        patch -Np1 < "$PROJECT/$patch"
    fi
done

mkdir -p "$BUILD"
cd "$BUILD"
[[ -f Makefile ]] ||
    "$WINE/configure" --enable-win64 --without-freetype --without-wayland --disable-tests
make -j"$(nproc)" dlls/mmdevapi/x86_64-windows/mmdevapi.dll dlls/winex11.drv/winex11.so

# Sin la marca "Wine builtin DLL", Wine la carga desde system32 en vez de
# sustituirla por la de Proton.
python3 -I - dlls/mmdevapi/x86_64-windows/mmdevapi.dll "$PROJECT/mmdevapi.dll" <<'EOF'
import sys
d = bytearray(open(sys.argv[1], 'rb').read())
assert d[0x40:0x50] == b'Wine builtin DLL'
d[0x40:0x50] = bytes(16)
open(sys.argv[2], 'wb').write(d)
EOF
strip --strip-debug -o "$PROJECT/winex11.so" dlls/winex11.drv/winex11.so
echo "mmdevapi.dll, winex11.so -> $PROJECT"

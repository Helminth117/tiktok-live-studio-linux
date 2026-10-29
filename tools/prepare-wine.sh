#!/usr/bin/env bash
# Reproduce el árbol de Wine parcheado de GE-Proton11-11 (solo la sección
# "(2) WINE PATCHING" de protonprep-valve-staging.sh), para compilar módulos
# sueltos compatibles con esa versión de Proton.
#
# Uso: prepare-wine.sh [DIRECTORIO]   (por defecto ~/Projects/wine-ge)
set -euo pipefail

GE_TAG=GE-Proton11-11
WINE_SHA=c53678ab22a85f0fad3588dd34f0452a463bd015
STAGING_SHA=6cc805ea57132eeaf44764e9213823c9b8d0d300
# protonprep revierte este commit para recuperar los archivos de configure.
REVERT_SHA=e813ca5771658b00875924ab88d525322e50d39f

DIR="${1:-$HOME/Projects/wine-ge}"
mkdir -p "$DIR"
cd "$DIR"

[[ -d proton-ge-custom/.git ]] ||
    git clone --depth 1 --branch "$GE_TAG" https://github.com/GloriousEggroll/proton-ge-custom
cd proton-ge-custom

fetch_at() {
    local dir=$1 url=$2 sha=$3
    if [[ ! -d "$dir/.git" ]]; then
        rm -rf "$dir"
        git init -q "$dir"
        git -C "$dir" remote add origin "$url"
    fi
    git -C "$dir" fetch --depth 1 origin "$sha"
    git -C "$dir" checkout -q "$sha"
}

fetch_at wine https://github.com/ValveSoftware/wine "$WINE_SHA"
git -C wine fetch --depth 2 origin "$REVERT_SHA"
fetch_at wine-staging https://github.com/wine-staging/wine-staging "$STAGING_SHA"

prep=$(mktemp)
trap 'rm -f "$prep"' EXIT
{
    echo '#!/bin/bash'
    sed -n '/^apply_patch()/,/^}/p; /^apply_all_in_dir()/,/^}/p' patches/protonprep-valve-staging.sh
    sed -n '/^### (2) WINE PATCHING ###/,$p' patches/protonprep-valve-staging.sh
} > "$prep"
bash "$prep"

# Archivos que el Makefile de Proton genera antes de compilar Wine.
cd wine
dlls/winevulkan/make_vulkan -x vk.xml -X video.xml
tools/make_specfiles

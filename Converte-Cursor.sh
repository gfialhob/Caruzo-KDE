#!/usr/bin/env bash
# Converte SVG -> Xcursor com kcursorgen e cria os symlinks
set -euo pipefail

SCRIPT_DIR="${1:-$HOME/.local/share/icons/Caruzo-Cursor}"
SVG_DIR="$SCRIPT_DIR/cursors_scalable"
XCURSOR_DIR="$SCRIPT_DIR/cursors"
THEME="Caruzo"
SIZES="24"
SCALES="0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5,2.75,3"

# ── 1. Conversão SVG -> Xcursor ──────────────────────────────
echo "▸ Convertendo SVGs com kcursorgen..."
kcursorgen \
  --svg-theme-to-xcursor \
  --svg-dir="$SVG_DIR" \
  --xcursor-dir="$XCURSOR_DIR" \
  --sizes="$SIZES" \
  --scales="$SCALES"

# ── 2. index.theme (verifica e cria somente se não existir) ──
if [[ ! -f "$SCRIPT_DIR/index.theme" ]]; then
  echo "▸ index.theme não encontrado — criando..."
  cat > "$SCRIPT_DIR/index.theme" <<EOF
[Icon Theme]
Name=$THEME
Comment=Tema escuro/verde para KDE Plasma
Inherits=hicolor
EOF
else
  echo "  index.theme existente — mantido sem alterações."
fi

echo "✔ Build concluído: $XCURSOR_DIR/ pronto para instalação."
echo "  Instale com:  cp -a $XCURSOR_DIR $SCRIPT_DIR/index.theme ~/.local/share/icons/$THEME/"

#!/usr/bin/env bash
#
# install.sh - instala o tema Ozurac (Plasma Style, Aurorae, SDDM, Konsole,
# icones/cursor e esquema de cores) no sistema.
#
# Uso:
#   ./install.sh              instala tudo que existir no repositorio
#   ./install.sh --dry-run    so mostra o que seria feito, sem copiar nada
#   ./install.sh -n
#
# O script espera ser executado de dentro do repositorio clonado (ou via
# caminho completo) - ele descobre sozinho onde estao os arquivos, entao
# funciona em qualquer maquina/instalacao nova do zero.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
[[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]] && DRY_RUN=1

# Reexecuta com sudo automaticamente se precisar (e nao estiver em --dry-run)
if [[ "$DRY_RUN" -eq 0 && "$EUID" -ne 0 ]]; then
    echo "Precisa de privilegios de root pra escrever em /usr/share e /etc - pedindo sudo..."
    exec sudo "$0" "$@"
fi

# pasta-fonte (dentro do repo) -> raiz de destino no sistema
declare -A TARGETS=(
    ["aurorae"]="/usr/share/aurorae"
    ["color-schemes"]="/usr/share/color-schemes"
    ["icons"]="/usr/share/icons"
    ["konsole"]="~/.local/share/konsole/*"
    ["plasma"]="/usr/share/plasma"
    ["sddm"]="/usr/share/sddm"
    ["sddm.conf.d"]="/etc/sddm.conf.d"
)

echo "Repositorio: $SCRIPT_DIR"
[[ "$DRY_RUN" -eq 1 ]] && echo "(modo --dry-run: nada sera copiado de verdade)"
echo

installed_any=0

for src_name in "${!TARGETS[@]}"; do
    src="$SCRIPT_DIR/$src_name"
    dest="${TARGETS[$src_name]}"

    if [[ ! -d "$src" ]]; then
        echo "  [pular]  $src_name/  (ainda nao existe no repositorio)"
        continue
    fi

    echo "  [copiar] $src_name/  ->  $dest/"
    if [[ "$DRY_RUN" -eq 0 ]]; then
        mkdir -p "$dest"
        cp -r "$src/." "$dest/"
    fi
    installed_any=1
done

echo

if [[ "$installed_any" -eq 0 ]]; then
    echo "Nenhuma das pastas esperadas foi encontrada em $SCRIPT_DIR - confere se voce"
    echo "esta rodando o script de dentro da raiz do repositorio."
    exit 1
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Simulacao concluida. Rode sem --dry-run pra instalar de verdade."
    exit 0
fi

# Atualiza o cache de configuracao do KDE, pra tudo aparecer sem precisar
# deslogar (nao falha o script se o comando nao existir)
if command -v kbuildsycoca6 >/dev/null; then
    kbuildsycoca6 --noincremental || true
elif command -v kbuildsycoca5 >/dev/null; then
    kbuildsycoca5 --noincremental || true
fi

cat << 'MSG'
Instalado.

Pra aplicar sem deslogar (rode como seu usuario normal, sem sudo):
  plasma-apply-desktoptheme Caruzo
  plasma-apply-colorscheme Caruzo
  plasma-apply-cursortheme Caruzo-Cursor      # se o pack de cursor estiver em icons/
  Configuracoes -> Aparencia -> Decoracao de Janelas -> Caruzo

Konsole: o perfil "Caruzo" ja aparece no menu de perfis.

SDDM: confira se /etc/sddm.conf.d/ tem so um arquivo com "Current=" -
  grep -r Current /etc/sddm.conf.d/
Teste antes de valer:
  sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/Caruzo
MSG

#!/bin/bash
# =============================================================================
# FREEZE SCRIPT - Dateien/Ordner einfrieren
# =============================================================================
# Verwendung: ./freeze.sh <pfad> [grund]
# Beispiel:   ./freeze.sh 04_HTML_Forms/forms3/css/style.css "Layout eingefroren"
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FREEZE_FILE="$PROJECT_ROOT/claude.freeze.json"

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Pruefe Parameter
if [ -z "$1" ]; then
    echo -e "${RED}FEHLER: Kein Pfad angegeben!${NC}"
    echo "Verwendung: ./freeze.sh <pfad> [grund]"
    exit 1
fi

TARGET_PATH="$1"
REASON="${2:-Manuell eingefroren}"
FROZEN_DATE=$(date +%Y-%m-%d)
FROZEN_BY="${USER:-System}"

# Pruefe ob Datei/Ordner existiert
FULL_PATH="$PROJECT_ROOT/$TARGET_PATH"
if [ ! -e "$FULL_PATH" ]; then
    echo -e "${RED}FEHLER: Pfad existiert nicht: $FULL_PATH${NC}"
    exit 1
fi

# Pruefe ob bereits eingefroren
if grep -q "\"path\": \"$TARGET_PATH\"" "$FREEZE_FILE" 2>/dev/null; then
    echo -e "${YELLOW}WARNUNG: $TARGET_PATH ist bereits eingefroren!${NC}"
    exit 0
fi

echo -e "${BLUE}=== FREEZE VORGANG ===${NC}"
echo -e "Pfad:   ${GREEN}$TARGET_PATH${NC}"
echo -e "Grund:  ${GREEN}$REASON${NC}"
echo -e "Datum:  ${GREEN}$FROZEN_DATE${NC}"
echo -e "Von:    ${GREEN}$FROZEN_BY${NC}"

# Setze Read-Only (Linux)
if [ -f "$FULL_PATH" ]; then
    chmod a-w "$FULL_PATH"
    echo -e "${GREEN}Read-Only gesetzt fuer Datei${NC}"
elif [ -d "$FULL_PATH" ]; then
    chmod -R a-w "$FULL_PATH"
    echo -e "${GREEN}Read-Only gesetzt fuer Verzeichnis (rekursiv)${NC}"
fi

# Backup der freeze.json
cp "$FREEZE_FILE" "$FREEZE_FILE.bak"

# Neuen Eintrag zur freeze.json hinzufuegen (mit jq falls vorhanden, sonst manuell)
if command -v jq &> /dev/null; then
    # Mit jq (sauber)
    TMP_FILE=$(mktemp)
    jq --arg path "$TARGET_PATH" \
       --arg reason "$REASON" \
       --arg date "$FROZEN_DATE" \
       --arg by "$FROZEN_BY" \
       '.frozenFiles += [{"path": $path, "reason": $reason, "frozenAt": $date, "frozenBy": $by}]' \
       "$FREEZE_FILE" > "$TMP_FILE"
    mv "$TMP_FILE" "$FREEZE_FILE"
else
    # Ohne jq (einfaches Append)
    echo -e "${YELLOW}HINWEIS: jq nicht installiert - manueller Eintrag erforderlich${NC}"
    echo ""
    echo "Bitte folgenden Eintrag in claude.freeze.json unter 'frozenFiles' hinzufuegen:"
    echo ""
    echo "    {"
    echo "      \"path\": \"$TARGET_PATH\","
    echo "      \"reason\": \"$REASON\","
    echo "      \"frozenAt\": \"$FROZEN_DATE\","
    echo "      \"frozenBy\": \"$FROZEN_BY\""
    echo "    }"
fi

echo ""
echo -e "${GREEN}=== EINGEFROREN ===${NC}"
echo -e "${BLUE}$TARGET_PATH ist jetzt geschuetzt!${NC}"

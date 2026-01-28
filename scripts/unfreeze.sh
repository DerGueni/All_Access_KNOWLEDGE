#!/bin/bash
# =============================================================================
# UNFREEZE SCRIPT - Dateien/Ordner auftauen
# =============================================================================
# Verwendung: ./unfreeze.sh <pfad>
# Beispiel:   ./unfreeze.sh 04_HTML_Forms/forms3/css/style.css
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
    echo "Verwendung: ./unfreeze.sh <pfad>"
    exit 1
fi

TARGET_PATH="$1"
FULL_PATH="$PROJECT_ROOT/$TARGET_PATH"

# Pruefe ob eingefroren
if ! grep -q "\"path\": \"$TARGET_PATH\"" "$FREEZE_FILE" 2>/dev/null; then
    echo -e "${YELLOW}HINWEIS: $TARGET_PATH ist nicht eingefroren${NC}"
fi

echo -e "${BLUE}=== UNFREEZE VORGANG ===${NC}"
echo -e "${YELLOW}WARNUNG: Du bist dabei, den Schutz zu entfernen fuer:${NC}"
echo -e "Pfad: ${RED}$TARGET_PATH${NC}"
echo ""
read -p "Bist du sicher? (ja/nein): " CONFIRM

if [ "$CONFIRM" != "ja" ]; then
    echo -e "${BLUE}Abgebrochen.${NC}"
    exit 0
fi

# Entferne Read-Only (Linux)
if [ -e "$FULL_PATH" ]; then
    if [ -f "$FULL_PATH" ]; then
        chmod u+w "$FULL_PATH"
        echo -e "${GREEN}Schreibrechte wiederhergestellt fuer Datei${NC}"
    elif [ -d "$FULL_PATH" ]; then
        chmod -R u+w "$FULL_PATH"
        echo -e "${GREEN}Schreibrechte wiederhergestellt fuer Verzeichnis (rekursiv)${NC}"
    fi
else
    echo -e "${YELLOW}HINWEIS: Pfad existiert nicht mehr: $FULL_PATH${NC}"
fi

# Eintrag aus freeze.json entfernen (mit jq falls vorhanden)
if command -v jq &> /dev/null; then
    cp "$FREEZE_FILE" "$FREEZE_FILE.bak"
    TMP_FILE=$(mktemp)
    jq --arg path "$TARGET_PATH" \
       '.frozenFiles = [.frozenFiles[] | select(.path != $path)]' \
       "$FREEZE_FILE" > "$TMP_FILE"
    mv "$TMP_FILE" "$FREEZE_FILE"
    echo -e "${GREEN}Eintrag aus claude.freeze.json entfernt${NC}"
else
    echo -e "${YELLOW}HINWEIS: jq nicht installiert - bitte manuell aus claude.freeze.json entfernen${NC}"
fi

echo ""
echo -e "${GREEN}=== AUFGETAUT ===${NC}"
echo -e "${YELLOW}$TARGET_PATH kann jetzt wieder bearbeitet werden.${NC}"
echo -e "${RED}ACHTUNG: Denke daran, nach Aenderungen wieder einzufrieren!${NC}"

#!/bin/bash
# =============================================================================
# FREEZE CHECK SCRIPT - Prueft ob ein Pfad eingefroren ist
# =============================================================================
# Verwendung: ./freeze-check.sh <pfad>
# Exit-Codes: 0 = nicht eingefroren, 1 = eingefroren, 2 = Fehler
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

if [ -z "$1" ]; then
    echo -e "${RED}FEHLER: Kein Pfad angegeben!${NC}"
    exit 2
fi

TARGET_PATH="$1"

# Pruefe in frozenFiles
if grep -q "\"path\": \"$TARGET_PATH\"" "$FREEZE_FILE" 2>/dev/null; then
    REASON=$(grep -A1 "\"path\": \"$TARGET_PATH\"" "$FREEZE_FILE" | grep "reason" | sed 's/.*"reason": "\([^"]*\)".*/\1/')
    echo -e "${RED}=== EINGEFROREN ===${NC}"
    echo -e "Pfad:  ${RED}$TARGET_PATH${NC}"
    echo -e "Grund: ${YELLOW}$REASON${NC}"
    echo ""
    echo -e "${RED}STOPP! Keine Aenderung ohne explizite Freigabe!${NC}"
    exit 1
fi

# Pruefe Patterns mit einfachem Matching
PATTERNS=$(grep -o '"pattern": "[^"]*"' "$FREEZE_FILE" 2>/dev/null | sed 's/"pattern": "\([^"]*\)"/\1/')

for PATTERN in $PATTERNS; do
    # Konvertiere Glob zu Regex fuer einfaches Matching
    REGEX=$(echo "$PATTERN" | sed 's/\*\*/.*/' | sed 's/\*/.*/g')
    if echo "$TARGET_PATH" | grep -qE "^$REGEX$"; then
        echo -e "${RED}=== EINGEFROREN (Pattern) ===${NC}"
        echo -e "Pfad:    ${RED}$TARGET_PATH${NC}"
        echo -e "Pattern: ${YELLOW}$PATTERN${NC}"
        echo ""
        echo -e "${RED}STOPP! Keine Aenderung ohne explizite Freigabe!${NC}"
        exit 1
    fi
done

echo -e "${GREEN}=== NICHT EINGEFROREN ===${NC}"
echo -e "Pfad: ${GREEN}$TARGET_PATH${NC}"
echo -e "Aenderungen sind erlaubt."
exit 0

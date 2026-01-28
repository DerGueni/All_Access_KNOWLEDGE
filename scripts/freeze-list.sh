#!/bin/bash
# =============================================================================
# FREEZE LIST SCRIPT - Zeigt alle eingefrorenen Dateien
# =============================================================================
# Verwendung: ./freeze-list.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FREEZE_FILE="$PROJECT_ROOT/claude.freeze.json"

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           CLAUDE CODE FREEZE STATUS                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ ! -f "$FREEZE_FILE" ]; then
    echo -e "${RED}FEHLER: claude.freeze.json nicht gefunden!${NC}"
    exit 1
fi

echo -e "${CYAN}=== EINGEFRORENE DATEIEN ===${NC}"
echo ""
if command -v jq &> /dev/null; then
    jq -r '.frozenFiles[] | "  \(.frozenAt) | \(.path)\n            └─ \(.reason)"' "$FREEZE_FILE" 2>/dev/null || \
    echo "  (keine)"
else
    grep -A3 '"path":' "$FREEZE_FILE" | grep -E '(path|reason)' | \
    sed 's/.*"path": "\([^"]*\)".*/  Pfad: \1/' | \
    sed 's/.*"reason": "\([^"]*\)".*/       Grund: \1/'
fi

echo ""
echo -e "${CYAN}=== EINGEFRORENE PATTERNS ===${NC}"
echo ""
if command -v jq &> /dev/null; then
    jq -r '.frozenPatterns[] | "  \(.pattern)\n            └─ \(.reason)"' "$FREEZE_FILE" 2>/dev/null || \
    echo "  (keine)"
else
    grep -A1 '"pattern":' "$FREEZE_FILE" | grep -E '(pattern|reason)' | \
    sed 's/.*"pattern": "\([^"]*\)".*/  Pattern: \1/' | \
    sed 's/.*"reason": "\([^"]*\)".*/       Grund: \1/'
fi

echo ""
echo -e "${CYAN}=== GESCHUETZTE BLOECKE ===${NC}"
echo ""
if command -v jq &> /dev/null; then
    jq -r '.protectedBlocks[] | "  \(.file)\n            └─ \(.startMarker) ... \(.endMarker)"' "$FREEZE_FILE" 2>/dev/null || \
    echo "  (keine)"
else
    echo "  (jq nicht installiert - bitte claude.freeze.json manuell pruefen)"
fi

echo ""
echo -e "${CYAN}=== GESCHUETZTE API ENDPOINTS ===${NC}"
echo ""
if command -v jq &> /dev/null; then
    jq -r '.protectedEndpoints[]' "$FREEZE_FILE" 2>/dev/null | sed 's/^/  /' || \
    echo "  (keine)"
fi

echo ""
echo -e "${CYAN}=== GESCHUETZTE VBA BUTTONS ===${NC}"
echo ""
if command -v jq &> /dev/null; then
    jq -r '.protectedVBAButtons[]' "$FREEZE_FILE" 2>/dev/null | sed 's/^/  /' || \
    echo "  (keine)"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "Freeze-Datei: ${GREEN}$FREEZE_FILE${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"

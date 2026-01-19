# CONSYS Token-Optimierung Guide
## Für Claude Code & Claude Desktop

---

## 🎯 Ziel: 50-70% Token-Ersparnis

### 1. CLAUDE.md Optimierung (Lazy Loading)

**Vorher (Schlecht):**
```markdown
# Alle Details sofort laden
- Komplette API-Dokumentation
- Alle VBA-Funktionen erklärt  
- Jede Formular-Struktur beschrieben
```

**Nachher (Gut):**
```markdown
# Nur Trigger-Keywords
Für API-Details → Skill("api-docs") laden
Für VBA-Hilfe → Skill("vba-reference") laden
Für Form-Struktur → INVENTORY_controls.json lesen
```

---

### 2. Praktische Befehle

| Befehl | Wann nutzen | Ersparnis |
|--------|-------------|-----------|
| `/compact` | Bei 70% Kontext | 30-40% |
| `/clear` | Neue Aufgabe | 100% |
| `/cost` | Token-Verbrauch prüfen | - |
| `/context` | MCP-Verbrauch sehen | - |

---

### 3. MCP-Server Token-Verbrauch

Jeder aktive MCP-Server verbraucht ~200-500 Token im System-Prompt!

**Deaktiviere nicht benötigte Server:**
```
/mcp disable github    # Wenn kein Git-Arbeit
/mcp disable sqlite    # Wenn keine DB-Arbeit
```

---

### 4. Datei-Lese-Strategie

**Schlecht:**
```
Lies alle Dateien im forms3-Ordner
```

**Gut:**
```
Lies nur frm_MA_Mitarbeiterstamm.html
Ignoriere: backups/, _audit/, *.bak
```

---

### 5. Prompt-Struktur

**Schlecht (viele Tokens):**
```
Kannst du bitte mal schauen, ob du vielleicht 
die Funktion im Button findest, die nicht 
funktioniert, und sie dann reparieren?
```

**Gut (wenige Tokens):**
```
frm_MA_Mitarbeiterstamm.html
Button "btnSpeichern" reparieren
Fehler: onclick fehlt
```

---

### 6. Nummerierte Schritte

**Warum:** Verhindert unnötiges Datei-Lesen

```
Aufgabe: API-Endpoint hinzufügen

1. Öffne NUR api/server.py
2. Füge Route /api/test hinzu
3. Teste mit curl
4. Keine anderen Dateien ändern
```

---

### 7. Kontext-Reset-Regel

> **Nach 20 Iterationen: /clear und neu starten**

Qualität sinkt nach ~20 Durchläufen drastisch!

---

### 8. Hybrid-Modell-Strategie

| Aufgabe | Modell | Kosten |
|---------|--------|--------|
| Architektur-Planung | Opus | $$$ |
| Code-Implementierung | Sonnet | $$ |
| Syntax-Fixes | Haiku | $ |

Wechsel mit: `/model sonnet` oder `/model haiku`

---

## 📊 Typische Ersparnisse

| Strategie | Token-Reduktion |
|-----------|-----------------|
| CLAUDE.md optimieren | 54-62% |
| Lazy Skill Loading | bis 97% |
| MCP-Server reduzieren | 10-20% |
| Nummerierte Schritte | 20-30% |
| Regelmäßig /compact | 30-40% |

---

## 🔧 Quick-Setup

1. **CLAUDE.md verschlanken** - nur Trigger-Keywords
2. **Skills-Ordner nutzen** - Details auslagern
3. **/compact bei 70%** - automatisch oder manuell
4. **MCP nur bei Bedarf** - /mcp disable wenn nicht gebraucht
5. **Klare Prompts** - direkt, nummeriert, präzise

# CONSEC VBA Bridge

Verbindet HTML-Formulare nahtlos mit Access VBA-Funktionen.

## Schnellstart

**Einmalig ausführen:**
```
SETUP_VBA_BRIDGE.vbs
```
Doppelklicken - fertig! Die VBA Bridge:
- Startet sofort im Hintergrund
- Startet automatisch bei jeder Windows-Anmeldung
- Verbindet HTML mit Access VBA

## So funktioniert's

1. **Access öffnen** (z.B. `0_Consys_FE_Test.accdb`)
2. **HTML-Formular öffnen** (z.B. Schnellauswahl)
3. **Button klicken** (z.B. "Anfragen")
4. → VBA-Code in Access wird ausgeführt!

## Dateien

| Datei | Beschreibung |
|-------|--------------|
| `SETUP_VBA_BRIDGE.vbs` | **Einmal-Setup** - Installiert und startet alles |
| `start_vba_bridge_now.vbs` | Startet VBA Bridge manuell |
| `stop_vba_bridge.vbs` | Stoppt VBA Bridge |
| `vba_bridge.py` | Python-Server (läuft im Hintergrund) |
| `vba_bridge_hidden.vbs` | Versteckter Starter für Autostart |
| `logs/vba_bridge.log` | Log-Datei für Fehlersuche |

## Technische Details

- **Server:** http://localhost:5002/
- **Status prüfen:** http://localhost:5002/api/vba/status
- **Anfragen senden:** POST http://localhost:5002/api/vba/anfragen

## Bei Problemen

1. **Server läuft nicht?**
   - `start_vba_bridge_now.vbs` ausführen
   - Log prüfen: `logs/vba_bridge.log`

2. **Access nicht verbunden?**
   - Access muss geöffnet sein
   - http://localhost:5002/api/vba/status zeigt Status

3. **Python fehlt?**
   - Python installieren: https://www.python.org/downloads/
   - `pip install flask flask-cors pywin32`

## Autostart entfernen

1. Windows-Taste + R
2. `shell:startup` eingeben
3. "CONSEC VBA Bridge" Verknüpfung löschen

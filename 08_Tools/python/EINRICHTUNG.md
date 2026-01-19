# CONSEC VBA Bridge - Einrichtung

## So geht's (einmalig)

### 1. VBA-Modul importieren
1. Access-Frontend öffnen (`0_Consys_FE_Test.accdb`)
2. **Alt+F11** (VBA-Editor)
3. **Datei → Importieren...**
4. Wähle: `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\01_VBA\modules\mod_VBA_Bridge.bas`

### 2. AutoExec-Makro erstellen (oder erweitern)
1. **Erstellen → Makro**
2. Aktion: **AusführenCode**
3. Funktionsname: `StartVBABridge()`
4. Speichern als: **AutoExec**

**ODER** im Startformular (Form_Load):
```vba
Private Sub Form_Load()
    StartVBABridge
End Sub
```

### 3. Fertig!
Ab jetzt startet die VBA Bridge automatisch wenn du Access öffnest.

---

## So funktioniert's dann

1. Du öffnest das Access-Frontend → VBA Bridge startet automatisch
2. Du öffnest das HTML-Formular (Schnellauswahl)
3. Du klickst "Anfragen" 
4. → Access VBA sendet die E-Mails!

Kein manuelles Starten, keine Extra-Fenster.

---

## Testen

Im VBA-Direktfenster (Strg+G):
```vba
? IsVBABridgeRunning()   ' Sollte True zeigen
? StartVBABridge()       ' Manuell starten
```

Oder im Browser: http://localhost:5002/api/vba/status

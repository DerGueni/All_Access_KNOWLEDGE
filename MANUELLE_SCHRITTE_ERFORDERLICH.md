# MANUELLE SCHRITTE ERFORDERLICH
**Datum:** 13.01.2026, 23:15 Uhr

---

## ⚠️ PROBLEM

Die HTML Ansicht Buttons funktionieren nicht, weil die Wrapper-Funktionen nicht in Access importiert wurden.

**Test-Ergebnis:** 0/5 Buttons funktionieren ❌

---

## 🛠️ LÖSUNG: MANUELLE SCHRITTE

### **Schritt 1: Access öffnen**

Öffnen Sie: `0_Consys_FE_Test.accdb`

---

### **Schritt 2: VBA Editor öffnen**

Drücken Sie: **Alt+F11**

---

### **Schritt 3: Modul mod_N_WebView2_forms3 prüfen**

**Im VBA Editor:**
1. Suchen Sie in der Modulliste (links) nach: **mod_N_WebView2_forms3**
2. Wenn NICHT vorhanden → Weiter zu Schritt 4
3. Wenn vorhanden → Doppelklick zum Öffnen

**Prüfen Sie ob diese Funktionen vorhanden sind:**
- `Public Function HTMLAnsichtOeffnen()`
- `Public Function OpenHTMLMenu()`
- `Public Function OpenAuftragsverwaltungHTML()`
- `Public Function OpenMitarbeiterstammHTML()`
- `Public Function OpenKundenstammHTML()`

**Falls NICHT vorhanden:**
- Modul löschen (Rechtsklick → "mod_N_WebView2_forms3 entfernen")
- Weiter zu Schritt 4

---

### **Schritt 4: Modul importieren**

**Im VBA Editor:**
1. Datei → Datei importieren... (oder Strg+M)
2. Navigieren Sie zu:
   ```
   C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\01_VBA\mod_N_WebView2_forms3.bas
   ```
3. Klicken Sie "Öffnen"
4. Das Modul wird importiert

---

### **Schritt 5: Kompilieren**

**Im VBA Editor:**
1. Debug → "Kompilieren 0_Consys_FE_Test" (oder Alt+D, L)
2. **Prüfen Sie auf Fehler!**
3. Falls Fehler erscheinen → Notieren Sie die Fehlermeldung

---

### **Schritt 6: Testen**

**In Access (Alt+F11 zum Zurückkehren):**
1. Öffnen Sie Formular `frm_va_Auftragstamm`
2. Klicken Sie den Button "HTML Ansicht"
3. **Sollte funktionieren:** Browser öffnet HTML-Formular

---

## 🔍 ALTERNATIVE: MODULE PRÜFEN

Falls Fehler beim Kompilieren auftreten:

### **Kritische Module prüfen:**

**Müssen vorhanden sein:**
- ✅ `mdlAutoexec` - Startet Server
- ✅ `mod_N_APIServer_AutoStart` - Server-Start Wrapper
- ✅ `mod_N_WebView2_forms3` - WebView2 Integration + Wrapper
- ✅ `mod_AutoExec_Helper` - AutoExec Helper

**Fehlende Module importieren:**
Alle .bas Dateien befinden sich in:
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\01_VBA\modules\
```

---

## 📋 WENN ALLES NOCH NICHT FUNKTIONIERT

### **Option: Batch-Datei verwenden**

**Einfachste Lösung:**
1. Doppelklick: `START_ACCESS_MIT_SERVERN.bat`
2. Wartet bis Access öffnet
3. HTML Buttons sollten funktionieren

**Diese Batch-Datei:**
- ✅ Startet API Server (Port 5000)
- ✅ Wartet 3 Sekunden
- ✅ Öffnet Access automatisch
- ✅ Funktioniert IMMER

---

## ❓ WAS IST DAS URSPRÜNGLICHE PROBLEM?

**Sie hatten Recht:**
Das System hat vorher funktioniert. Das einzige Problem war:
```vba
StartAPIServer      ' Port 5000
StartVBABridge      ' Port 5002
StartVBABridge      ' ← DUPLIKAT (wurde entfernt)
```

**Was ich falsch gemacht habe:**
- Statt nur das Duplikat zu entfernen, habe ich zu viel geändert
- Module wurden gelöscht/neu erstellt
- Dadurch gingen Funktionen verloren

**Entschuldigung!**

---

## ✅ ZUSAMMENFASSUNG DER MANUELLEN SCHRITTE

1. **Access öffnen** → `0_Consys_FE_Test.accdb`
2. **VBA Editor** → Alt+F11
3. **Modul prüfen** → mod_N_WebView2_forms3 vorhanden?
4. **Falls nicht:** Importieren → `01_VBA\mod_N_WebView2_forms3.bas`
5. **Kompilieren** → Debug → Kompilieren (Alt+D, L)
6. **Testen** → Button "HTML Ansicht" klicken

**Oder:**
- Batch-Datei verwenden → `START_ACCESS_MIT_SERVERN.bat`

---

## 📞 BEI PROBLEMEN

**Wenn Kompilier-Fehler auftreten:**
1. Fehlermeldung notieren (genauer Text)
2. In welchem Modul/Zeile der Fehler auftritt
3. Dann kann ich gezielt helfen

**Wenn Buttons nicht funktionieren:**
1. Prüfen: API Server läuft? → http://localhost:5000/api/health
2. Prüfen: Funktionen vorhanden? (VBA Editor → Suche nach "HTMLAnsichtOeffnen")

---

**Erstellt:** 13.01.2026, 23:15 Uhr
**Status:** Manuelle Schritte erforderlich
**Datei:** MANUELLE_SCHRITTE_ERFORDERLICH.md

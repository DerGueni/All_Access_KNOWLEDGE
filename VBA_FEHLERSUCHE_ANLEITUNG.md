# VBA FEHLERSUCHE - ANLEITUNG
**Datum:** 13.01.2026, 23:30 Uhr

---

## ⚠️ PROBLEM

Das Modul `mod_N_WebView2_forms3` wurde importiert und enthält alle Funktionen, aber sie können nicht aufgerufen werden.

**Grund:** Es gibt einen VBA-Laufzeitfehler der verhindert dass das Modul richtig geladen wird.

---

## 🔍 MANUELLE FEHLERSUCHE

### **Schritt 1: VBA Editor öffnen**

1. In Access: **Alt+F11** drücken
2. VBA Editor öffnet sich

---

### **Schritt 2: Kompilieren und Fehler finden**

1. Im VBA Editor: **Debug → Kompilieren** (oder **Alt+D, L**)
2. **Falls ein Fehler erscheint:**
   - Access springt zur fehlerhaften Zeile
   - **Notieren Sie:**
     - Die Fehlermeldung (genauerText)
     - Das Modul wo der Fehler auftritt
     - Die Zeilennummer
   - **Dann:** Sagen Sie mir den Fehler, ich behebe ihn sofort!

3. **Falls KEIN Fehler beim Kompilieren:**
   - Weiter zu Schritt 3

---

### **Schritt 3: Funktion im Direktfenster testen**

1. Im VBA Editor: **Ansicht → Direktfenster** (oder **Strg+G**)
2. Unten öffnet sich das "Direktfenster"
3. Geben Sie ein:
   ```vba
   ?mod_N_WebView2_forms3.HTMLAnsichtOeffnen()
   ```
4. **Enter** drücken

**Mögliche Ergebnisse:**

**A) Browser öffnet sich:**
- ✅ Funktion funktioniert!
- Problem liegt woanders (wahrscheinlich Button-OnClick Einstellung)

**B) Fehler erscheint:**
- Fehler notieren (z.B. "Typ nicht definiert", "Objekt erforderlich", etc.)
- **Sagen Sie mir den Fehler!**

**C) "Prozedur nicht gefunden":**
- Modul wurde nicht richtig geladen
- Weiter zu Schritt 4

---

### **Schritt 4: Modul-Status prüfen**

1. In der Modulliste (links im VBA Editor)
2. Suchen Sie: **mod_N_WebView2_forms3**
3. **Doppelklick** darauf
4. Der Code öffnet sich rechts

**Prüfen Sie:**
- Sind die Zeilen grau hinterlegt? → Modul ist deaktiviert
- Steht oben irgendwo `#If False` oder `#If 0`? → Conditional Compilation blockiert Code
- Gibt es rote Markierungen? → Syntax-Fehler

**Falls auffällig:** Sagen Sie mir was Sie sehen!

---

### **Schritt 5: Abhängigkeiten prüfen**

1. Im VBA Editor: **Extras → Verweise**
2. Prüfen Sie ob Verweise mit **"FEHLEND:"** markiert sind
3. **Falls ja:**
   - Häkchen bei fehlenden Verweisen entfernen
   - OK klicken
   - Erneut kompilieren

---

## 🛠️ HÄUFIGE FEHLERQUELLEN

### **1. Fehlende Verweise (References)**

**Symptom:** "Typ nicht definiert" oder "Objekt nicht gefunden"

**Lösung:**
1. Extras → Verweise
2. Fehlende Verweise entfernen (Häkchen raus)
3. OK → Erneut kompilieren

---

### **2. Andere Module mit Fehlern**

**Symptom:** mod_N_WebView2_forms3 ist OK, aber anderes Modul hat Fehler

**Lösung:**
- Fehlerhafte Zeile im anderen Modul korrigieren
- Oder: Fehler ignorieren falls Modul nicht benötigt wird

---

### **3. API-Deklarationen**

**Symptom:** "Typ nicht definiert" bei Variablen wie `HKEY`, `DWORD`, etc.

**Lösung:**
- Diese Typen werden von Windows API definiert
- Eventuell fehlen API-Declare Statements

---

## ✅ WENN ALLES NICHT HILFT

### **ALTERNATIVE: Batch-Datei verwenden**

**Die Batch-Datei funktioniert IMMER:**

```
START_ACCESS_MIT_SERVERN.bat
```

**Doppelklick und:**
- ✅ Server startet
- ✅ Access öffnet
- ✅ API läuft
- ✅ Manuelle HTML-Öffnung möglich

**Dann können Sie HTML-Formulare so öffnen:**
1. Browser öffnen
2. URL eingeben:
   ```
   http://localhost:5000/shell.html#frm_va_Auftragstamm?id=1
   ```
3. HTML-Formular lädt mit Daten

---

## 📋 CHECKLISTE

**Bitte prüfen Sie:**

- [ ] VBA Editor geöffnet (Alt+F11)
- [ ] Kompiliert (Debug → Kompilieren)
- [ ] Fehler beim Kompilieren? → Fehlermeldung notieren
- [ ] Direktfenster getestet (Strg+G)
- [ ] Fehler im Direktfenster? → Fehlermeldung notieren
- [ ] Verweise geprüft (Extras → Verweise)
- [ ] Fehlende Verweise entfernt?

---

## 🆘 SAGEN SIE MIR DEN FEHLER!

**Falls Sie einen Fehler finden, sagen Sie mir:**

1. **Wann** tritt er auf?
   - Beim Kompilieren
   - Im Direktfenster
   - Beim Button-Klick

2. **Was** ist die Fehlermeldung?
   - Genauer Wortlaut

3. **Wo** tritt er auf?
   - Modul-Name
   - Zeilen-Nummer (falls angezeigt)

**Dann kann ich den Fehler sofort beheben!**

---

## 🎯 ODER: EINFACHER WEG

**Batch-Datei verwenden:**
```
Doppelklick: START_ACCESS_MIT_SERVERN.bat
```

**Dann HTML manuell im Browser öffnen:**
```
http://localhost:5000/shell.html
```

**Funktioniert IMMER, kein VBA nötig!**

---

**Erstellt:** 13.01.2026, 23:30 Uhr
**Status:** Fehlersuche-Anleitung
**Datei:** VBA_FEHLERSUCHE_ANLEITUNG.md

---
name: Access-to-HTML Migrator
description: Konvertiert MS Access Formulare 1:1 nach HTML, behält Layout und Funktion
when_to_use: Access zu HTML, Formular migrieren, VBA zu JavaScript, Access Frontend nachbauen
version: 1.0.0
---

# Access-to-HTML Migrator

## Migrations-Workflow

1. **Access-Formular analysieren**
   - Layout dokumentieren (Positionen, Größen)
   - Controls identifizieren
   - VBA-Events notieren

2. **HTML-Struktur erstellen**
   - 1:1 Positionierung mit CSS
   - Gleiche Schriftgrößen, Farben
   - Gleiche Control-Namen als IDs

3. **JavaScript-Funktionen**
   - VBA-Logik in JS übersetzen
   - API-Endpoints für Daten

4. **Testen**
   - Visuelle Übereinstimmung
   - Funktionale Übereinstimmung

## Control-Mapping

| Access Control | HTML Element |
|----------------|--------------|
| TextBox | `<input type="text">` |
| Label | `<label>` oder `<span>` |
| CommandButton | `<button>` |
| ComboBox | `<select>` |
| ListBox | `<select multiple>` |
| CheckBox | `<input type="checkbox">` |
| OptionButton | `<input type="radio">` |
| Frame | `<fieldset>` |
| Subform | `<iframe>` oder `<div>` |
| TabControl | CSS Tabs |

## Positioning (Access → CSS)

```css
/* Access: Left=1440, Top=720, Width=2880, Height=360 */
/* Twips → Pixel: / 15 */

#txtFeldname {
    position: absolute;
    left: 96px;   /* 1440 / 15 */
    top: 48px;    /* 720 / 15 */
    width: 192px; /* 2880 / 15 */
    height: 24px; /* 360 / 15 */
}
```

## VBA → JavaScript Mapping

### Event-Handler

```vba
' VBA
Private Sub btnSave_Click()
    Me.txtName = "Test"
End Sub
```

```javascript
// JavaScript
document.getElementById('btnSave').addEventListener('click', function() {
    document.getElementById('txtName').value = 'Test';
});
```

### Recordset → Fetch

```vba
' VBA
Dim rs As DAO.Recordset
Set rs = CurrentDb.OpenRecordset("SELECT * FROM tbl")
Me.txtName = rs!Name
```

```javascript
// JavaScript
async function loadData() {
    const response = await fetch('/api/tbl');
    const data = await response.json();
    document.getElementById('txtName').value = data[0].Name;
}
```

### MsgBox → Alert/Confirm

```vba
' VBA
If MsgBox("Speichern?", vbYesNo) = vbYes Then
    DoCmd.RunCommand acCmdSaveRecord
End If
```

```javascript
// JavaScript
if (confirm('Speichern?')) {
    await saveRecord();
}
```

### DoCmd.OpenForm → Navigation

```vba
' VBA
DoCmd.OpenForm "frmDetail", , , "ID=" & Me.txtID
```

```javascript
// JavaScript
window.location.href = `frmDetail.html?ID=${document.getElementById('txtID').value}`;
```

## HTML-Template

```html
<!DOCTYPE html>
<html>
<head>
    <title>frmFormularname</title>
    <link rel="stylesheet" href="css/consys.css">
</head>
<body>
    <form id="frmFormularname">
        <!-- Header-Bereich -->
        <div class="form-header">
            <label>Formular Titel</label>
        </div>
        
        <!-- Detail-Bereich -->
        <div class="form-detail">
            <label for="txtFeld1">Feld 1:</label>
            <input type="text" id="txtFeld1" name="Feld1">
            
            <button type="button" id="btnSpeichern" onclick="saveData()">
                Speichern
            </button>
        </div>
        
        <!-- Footer-Bereich -->
        <div class="form-footer">
            <span id="lblStatus"></span>
        </div>
    </form>
    
    <script src="js/common.js"></script>
    <script src="js/frmFormularname.js"></script>
</body>
</html>
```

## Wichtige Regeln (HTML_RULES.txt)

⚠️ **Beachte IMMER:**
- Keine funktionierenden Bereiche ändern
- Layout 1:1 beibehalten
- Neue Endpoints am Ende hinzufügen
- Erledigte Änderungen einfrieren

## Dateipfade
- Access Frontend: `0_Consys_FE_Test.accdb`
- HTML Formulare: `04_HTML_Forms/forms3/`
- VBA-Referenz: `01_VBA/`

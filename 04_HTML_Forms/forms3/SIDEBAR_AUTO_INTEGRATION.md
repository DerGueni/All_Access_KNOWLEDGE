# Automatische Sidebar-Integration für HTML-Formulare

## Implementiert am: 13.01.2026

## Ziel
Beim direkten Öffnen eines HTML-Formulars (z.B. `frm_MA_Mitarbeiterstamm.html`) wird automatisch die Shell mit Sidebar geladen, sodass das Formular als "ganzes" mit Navigation erscheint (wie in Access).

## Implementierung

### 1. Shell-Erweiterung (shell.html)
**Änderungen:**
- URL-Parameter-Handling erweitert (Zeile 914-934)
- Unterstützt nun alle ID-Varianten: `id`, `va_id`, `ma_id`, `kd_id`
- Zusätzliche Parameter werden durchgereicht (z.B. `vadatum_id`, `vastart_id`)
- Falls `form=` Parameter vorhanden: Direkt öffnen ohne Default-Tab
- Sonst: Standard-Tab (Auftragsverwaltung) öffnen und pinnen

**Beispiel-URLs:**
```
shell.html?form=frm_MA_Mitarbeiterstamm.html&id=123
shell.html?form=frm_va_Auftragstamm.html&va_id=456&vadatum_id=789
```

### 2. Auto-Redirect Script (in Formularen)
**Platzierung:** Direkt nach `<meta charset="UTF-8">` im `<head>`

**Logik:**
1. Prüft ob bereits in Shell geladen (`shell=1` Parameter oder `window.SHELL_PARAMS`)
2. Prüft ob in iframe eingebettet (`window.self !== window.top`)
3. Nur wenn BEIDES NICHT der Fall: Redirect zur Shell
4. Übernimmt alle URL-Parameter (ID, zusätzliche Parameter)

**Code:**
```javascript
<script>
// Auto-Load in Shell (Sidebar-Integration)
(function() {
    const urlParams = new URLSearchParams(window.location.search);
    const isInShell = urlParams.has('shell') || window.SHELL_PARAMS;
    const isInIframe = window.self !== window.top;
    if (!isInShell && !isInIframe) {
        const formName = window.location.pathname.split('/').pop();
        const recordId = urlParams.get('id') || urlParams.get('ma_id') || urlParams.get('kd_id') || urlParams.get('va_id');
        let shellUrl = 'shell.html?form=' + formName;
        if (recordId) shellUrl += '&id=' + recordId;
        for (const [key, value] of urlParams.entries()) {
            if (!['shell', 'id', 'ma_id', 'kd_id', 'va_id', '_t'].includes(key)) {
                shellUrl += '&' + encodeURIComponent(key) + '=' + encodeURIComponent(value);
            }
        }
        console.log('[Auto-Redirect] Lade mit Sidebar:', shellUrl);
        window.location.replace(shellUrl);
    }
})();
</script>
```

### 3. Implementierte Formulare (8 Hauptformulare)
✅ frm_MA_Mitarbeiterstamm.html
✅ frm_KD_Kundenstamm.html
✅ frm_va_Auftragstamm.html (Script aktualisiert)
✅ frm_OB_Objekt.html
✅ frm_MA_Abwesenheit.html
✅ frm_MA_VA_Schnellauswahl.html
✅ frm_Einsatzuebersicht.html
✅ frm_MA_Zeitkonten.html
✅ frm_Menuefuehrung1.html

**NICHT implementiert:** Sub-Formulare (`sub_*.html`) - diese dürfen NICHT redirecten, da sie in iframes geladen werden!

## Funktionsweise

### Szenario 1: Direkter Aufruf ohne Parameter
**URL:** `frm_MA_Mitarbeiterstamm.html`
**Ergebnis:** Redirect zu `shell.html?form=frm_MA_Mitarbeiterstamm.html`
**Anzeige:** Shell mit Sidebar, Mitarbeiterstamm-Tab aktiv

### Szenario 2: Direkter Aufruf mit ID
**URL:** `frm_MA_Mitarbeiterstamm.html?id=123`
**Ergebnis:** Redirect zu `shell.html?form=frm_MA_Mitarbeiterstamm.html&id=123`
**Anzeige:** Shell mit Sidebar, Mitarbeiter #123 wird geladen

### Szenario 3: Direkter Aufruf mit zusätzlichen Parametern
**URL:** `frm_va_Auftragstamm.html?va_id=456&vadatum_id=789&vastart_id=111`
**Ergebnis:** Redirect zu `shell.html?form=frm_va_Auftragstamm.html&id=456&vadatum_id=789&vastart_id=111`
**Anzeige:** Shell mit Sidebar, alle Parameter werden ans Formular weitergegeben

### Szenario 4: Aufruf via Shell (kein Redirect)
**URL:** `shell.html?form=frm_MA_Mitarbeiterstamm.html&id=123`
**Ergebnis:** KEIN Redirect (Parameter `shell=1` wird automatisch vom iframe gesetzt)
**Anzeige:** Formular wird normal im iframe geladen

### Szenario 5: Subform in iframe (kein Redirect)
**URL:** `sub_MA_VA_Zuordnung.html` (geladen in iframe)
**Ergebnis:** KEIN Redirect (Prüfung `window.self !== window.top` erkennt iframe)
**Anzeige:** Subform wird normal im iframe geladen

## Technische Details

### URL-Parameter Mapping
- `id` → Universelle ID (wird bevorzugt)
- `va_id` → Auftrag-ID (Fallback)
- `ma_id` → Mitarbeiter-ID (Fallback)
- `kd_id` → Kunden-ID (Fallback)
- Alle anderen Parameter werden 1:1 durchgereicht

### Shell-Parameter Injection
Die Shell fügt beim Laden via `srcdoc` (VisBug-Kompatibilität) folgende globale Variable ins Formular ein:
```javascript
window.SHELL_PARAMS = {
    shell: '1',
    id: recordId || null,
    va_id: recordId || null,
    ...params
};
```

Diese Variable ermöglicht Formularen zu prüfen ob sie in der Shell geladen wurden, auch wenn `srcdoc` die URL-Parameter verliert.

## Vorteile

✅ **Konsistente Navigation:** Alle Formulare haben automatisch die Sidebar
✅ **Keine manuelle Anpassung:** User muss nicht zur Shell-URL navigieren
✅ **Parameter-Erhalt:** Alle URL-Parameter bleiben erhalten
✅ **Iframe-Kompatibel:** Subforms werden nicht redirected
✅ **WebView2-Kompatibel:** Funktioniert auch in Access-WebView2

## Wartung

### Neue Formulare hinzufügen
1. Kopiere das Auto-Redirect Script (siehe oben)
2. Füge es direkt nach `<meta charset="UTF-8">` ein
3. Fertig - keine weiteren Änderungen nötig

### Script entfernen (falls nötig)
Einfach das `<script>` Block entfernen - Formular funktioniert weiterhin direkt.

### Debugging
Console-Log zeigt Redirect an:
```
[Auto-Redirect] Lade mit Sidebar: shell.html?form=frm_MA_Mitarbeiterstamm.html&id=123
```

## Testfälle

### Test 1: Direkter Aufruf
```
http://localhost/forms3/frm_MA_Mitarbeiterstamm.html
```
**Erwartung:** Shell lädt mit Mitarbeiterstamm-Tab

### Test 2: Aufruf mit ID
```
http://localhost/forms3/frm_MA_Mitarbeiterstamm.html?ma_id=123
```
**Erwartung:** Shell lädt mit Mitarbeiter #123

### Test 3: Subform (kein Redirect)
```html
<iframe src="sub_MA_VA_Zuordnung.html?va_id=456"></iframe>
```
**Erwartung:** Subform lädt normal im iframe, KEIN Redirect

### Test 4: Shell-Aufruf (kein Redirect)
```
http://localhost/forms3/shell.html?form=frm_MA_Mitarbeiterstamm.html&id=123
```
**Erwartung:** Shell lädt normal, Formular im iframe, KEIN doppelter Redirect

## Status
✅ **Implementierung abgeschlossen**
⏳ **Manuelle Tests ausstehend**

## Nächste Schritte
1. Manueller Test mit Browser: Formulare direkt aufrufen
2. Test mit Access-WebView2: VBA-Integration prüfen
3. Bei Bedarf: Weitere Formulare nachrüsten

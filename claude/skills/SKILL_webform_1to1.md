# SKILL: WebForm 1-zu-1 Port (Access -> HTML)

## Ziel
Ein HTML-Formular soll dem Access-Original entsprechen (Layout, Controls, Events, Datenbindung) und über frm_WebHost genutzt werden.

## Inputs
- JSON-Export des Formulars
- (optional) DependencyLinks/Objects
- Bestand in `<ZIP_EXTRACT_PATH>\0006_All_Access_KNOWLEDGE\04_HTML_Forms` (falls bereits HTML/Logic existiert)

## Vorgehen (Etappen)
1) Scaffold (HTML DOM + IDs)
2) Binding über `window.Bridge`
3) Event Mapping
4) Validierung + Fehlermeldungen
5) Smoke-Test
6) Pattern sichern

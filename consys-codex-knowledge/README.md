# consys-codex-knowledge

Dieses Repo ist der **kuratierte Knowledge-Layer** für Codex/AI, um dein **Access-Frontend** zu verstehen und **HTML/React-Formulare** sauber mit dem Backend zu verbinden – ohne dass du 22.000 Projektdateien hochladen musst.

## Wie du das benutzt (du als Mensch)

1) Dieses Repo nach GitHub pushen (public oder privat).
2) In Codex/ChatGPT als Kontext/Repo hinzufügen.
3) Bei jeder Aufgabe Codex auf diese Dateien verweisen:
   - `CODEX_CONSYS_ACCESS_WEB_KNOWLEDGE.md`
   - `FORM_MAP_INDEX.json`
   - `RULES/*`

## Wie Codex arbeiten soll (Arbeitsvertrag)

- **Access ist Referenz**, Web-Form ist Ziel.
- **Neue Forms**:
  - Standalone HTML nach `04_HTML_Forms/forms/<FORM>.html`
  - Logik nach `04_HTML_Forms/forms/logic/<FORM>.logic.js`
  - API Calls bevorzugt über `04_HTML_Forms/api/bridgeClient.js` (Port 5000 / Flask)
- **React Components** nach `07_Web_Client/src/components/<Name>.jsx`
- **RecordSource / Controls / Subforms** aus `exports/forms/<FORM>/` ziehen.
- **Subforms** immer über Master/Child-Links aus `subforms.json` verbinden.

## Nächste Schritte (empfohlen)

- `SCRIPTS/build_form_index.py` ausführen, wenn du Exporte aktualisiert hast.
- Mit `CODEX_PROMPT_TEMPLATE.md` arbeiten (Copy/Paste Prompt).


# Quickstart

1) Entpacke diesen Workspace an einen beliebigen Ort.
2) Kopiere den Ordnerinhalt nach `C:\users\guenther.siegert\documents` oder passe `ProjectRoot` in deiner Excel an.
3) In PowerShell:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tools\setup_from_excel.ps1 -ConfigXlsx .\Consys_ClaudeCode_ConfigTemplate_prefilled_from_zip.xlsx
   ```
4) Öffne `C:\users\guenther.siegert\documents` in Claude Code.
5) Starte mit einem Formular: wähle in `FORMS` ein Formular und arbeite Etappen A→F aus `claude/workflow.md`.

Hinweis: Filesystem MCP Install Command enthält in Excel einen Platzhalter – erst konkretisieren, dann aktivieren.

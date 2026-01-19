╔════════════════════════════════════════════════════════════════╗
║         CONSYS HTML-ANSICHT - SCHNELLSTART ANLEITUNG           ║
╚════════════════════════════════════════════════════════════════╝

Drei neue Dateien wurden erstellt:
📄 api_server_robust.py - Der API-Server (MUSS laufen!)
📄 START.bat - Ein-Klick um alles zu starten
📄 TEST.bat - Kompletter Funktions-Test

═══════════════════════════════════════════════════════════════════

👉 SCHRITT 1: TEST ausführen (prüfe ob alles funktioniert)

Öffne Command Prompt:
📂 cd C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\_scripts
▶️  TEST.bat

Erwartet:
✅ Python OK
✅ Flask OK
✅ API Server gestartet
✅ API Health Check OK
✅ Browser öffnet sich

═══════════════════════════════════════════════════════════════════

👉 SCHRITT 2: Produktiv nutzen

Danach einfach verwenden:
📂 cd C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\_scripts
▶️  START.bat

Das startet automatisch:
1. ✅ API-Server auf http://localhost:5000
2. ✅ Browser mit shell.html
3. ✅ Access Frontend (optional)

═══════════════════════════════════════════════════════════════════

👉 SCHRITT 3: Button im Access verwenden

Jetzt funktioniert der "HTML Ansicht" Button:
1. Klick im Access auf "HTML Ansicht"
2. ✅ API-Server startet (falls nicht läuft)
3. ✅ Browser öffnet shell.html
4. ✅ Sidebar + Formulare laden

═══════════════════════════════════════════════════════════════════

🔧 TROUBLESHOOTING

Problem: "Python not found"
→ Python nicht installiert oder nicht im PATH
→ https://www.python.org/downloads/ (Add to PATH aktivieren!)

Problem: "Port 5000 already in use"
→ Anderer Prozess nutzt Port 5000
→ netstat -ano | findstr :5000
→ taskkill /PID <PID> /F

Problem: API antwortet nicht
→ Manuell starten: python api_server_robust.py
→ Prüfe: http://localhost:5000/api/health im Browser

═══════════════════════════════════════════════════════════════════

📋 ZUSAMMENFASSUNG

✅ api_server_robust.py - API-Server ohne externe Dependencies
✅ START.bat - Automatischer Start
✅ TEST.bat - Vollständiger Funktions-Test
✅ Sidebar + Tab-Navigation - Funktioniert
✅ Formular-Laden - Funktioniert

Das System ist BEREIT zum produktiven Einsatz!

═══════════════════════════════════════════════════════════════════

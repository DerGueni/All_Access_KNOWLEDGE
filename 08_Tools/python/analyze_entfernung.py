"""
Analysiert das Entfernungsfeature im Formular frm_MA_VA_Schnellauswahl
und exportiert alle benötigten Komponenten
"""
from access_bridge_ultimate import AccessBridge
import os

def main():
    print("\n" + "=" * 60)
    print("ENTFERNUNGSFEATURE ANALYSE")
    print("=" * 60 + "\n")

    with AccessBridge() as bridge:
        # 1. Formular-Code auslesen
        print("--- Formular-Code auslesen ---")
        try:
            vbe = bridge.access_app.VBE
            proj = vbe.ActiveVBProject

            # Suche Formular-Modul
            for comp in proj.VBComponents:
                if comp.Name == "Form_frm_MA_VA_Schnellauswahl":
                    code_module = comp.CodeModule
                    if code_module.CountOfLines > 0:
                        code = code_module.Lines(1, code_module.CountOfLines)
                        print(f"[OK] Formular-Code gefunden ({code_module.CountOfLines} Zeilen)")

                        # Suche nach cmdListMA_Entfernung_Click
                        if "cmdListMA_Entfernung" in code:
                            print("[OK] cmdListMA_Entfernung_Click gefunden")

                            # Zeige relevanten Code
                            lines = code.split('\n')
                            in_function = False
                            function_code = []
                            for line in lines:
                                if "cmdListMA_Entfernung_Click" in line or "Sub cmdListMA_Entfernung" in line:
                                    in_function = True
                                if in_function:
                                    function_code.append(line)
                                    if line.strip() == "End Sub":
                                        break

                            print("\nRelevanter Code:")
                            print("-" * 40)
                            for l in function_code[:30]:
                                print(l)
                            if len(function_code) > 30:
                                print(f"... ({len(function_code) - 30} weitere Zeilen)")
                    break

        except Exception as e:
            print(f"[!] Fehler: {e}")

        # 2. Alle Module auflisten die "Entfernung" enthalten
        print("\n--- Module mit 'Entfernung' suchen ---")
        for comp in proj.VBComponents:
            try:
                code_module = comp.CodeModule
                if code_module.CountOfLines > 0:
                    code = code_module.Lines(1, code_module.CountOfLines)
                    if "Entfernung" in code or "entfernung" in code.lower():
                        print(f"  - {comp.Name} (Type: {comp.Type})")
            except:
                pass

        # 3. Abfragen mit "Entfernung" suchen
        print("\n--- Abfragen mit 'Entfernung' suchen ---")
        for qdef in bridge.current_db.QueryDefs:
            if "Entfernung" in qdef.Name or "entfernung" in qdef.Name.lower():
                print(f"  - {qdef.Name}")

        print("\n" + "=" * 60)


if __name__ == "__main__":
    main()

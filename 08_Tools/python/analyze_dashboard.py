"""
Analysiert das aktuelle Dashboard VBA-Modul
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge

print("=" * 70)
print("DASHBOARD ANALYSE")
print("=" * 70)

try:
    with AccessBridge() as bridge:
        # 1. Alle Module auflisten
        modules = bridge.list_modules()
        print(f"\nVBA Module ({len(modules)}):")
        for m in modules:
            if 'DP' in m or 'Dashboard' in m:
                print(f"  -> {m} (Dashboard-relevant)")

        # 2. Alle Dashboard-Formulare auflisten
        forms = bridge.list_forms()
        print(f"\nFormulare ({len(forms)}):")
        dashboard_forms = [f for f in forms if 'DP' in f or 'Dashboard' in f]
        for f in dashboard_forms:
            print(f"  -> {f}")

        # 3. Alle Dashboard-Abfragen auflisten
        queries = bridge.list_queries()
        print(f"\nAbfragen ({len(queries)}):")
        dashboard_queries = [q for q in queries if 'DP' in q or 'Dashboard' in q]
        for q in dashboard_queries:
            print(f"  -> {q}")

        # 4. VBA-Code exportieren
        print("\n" + "=" * 70)
        print("VBA MODULE EXPORTIEREN")
        print("=" * 70)

        vbe = bridge.access_app.VBE
        proj = vbe.ActiveVBProject

        for comp in proj.VBComponents:
            if 'DP' in comp.Name or 'Dashboard' in comp.Name:
                print(f"\n--- {comp.Name} ---")
                code_module = comp.CodeModule
                if code_module.CountOfLines > 0:
                    code = code_module.Lines(1, code_module.CountOfLines)
                    print(code[:5000] if len(code) > 5000 else code)

                    # Auch in Datei speichern
                    with open(f'C:/Users/guenther.siegert/Documents/Access Bridge/exports/{comp.Name}.bas', 'w', encoding='utf-8') as f:
                        f.write(code)
                    print(f"\n[Exportiert nach exports/{comp.Name}.bas]")
                else:
                    print("(Leer)")

        # 5. Formular-Eigenschaften pruefen
        print("\n" + "=" * 70)
        print("FORMULAR-EIGENSCHAFTEN")
        print("=" * 70)

        for form_name in dashboard_forms:
            try:
                # Formular in Design-Ansicht oeffnen
                bridge.access_app.DoCmd.OpenForm(form_name, 1)  # acDesign
                frm = bridge.access_app.Forms(form_name)

                print(f"\n--- {form_name} ---")
                print(f"  RecordSource: {frm.RecordSource}")
                print(f"  AllowEdits: {frm.AllowEdits}")
                print(f"  AllowAdditions: {frm.AllowAdditions}")
                print(f"  AllowDeletions: {frm.AllowDeletions}")

                # Controls auflisten
                print(f"  Controls:")
                for i in range(frm.Controls.Count):
                    ctl = frm.Controls(i)
                    try:
                        ctl_type = ctl.ControlType
                        if ctl_type == 112:  # Subform
                            print(f"    [{ctl.Name}] Subform -> {ctl.SourceObject}")
                        elif ctl_type == 104:  # Button
                            print(f"    [{ctl.Name}] Button -> OnClick: {getattr(ctl, 'OnClick', 'N/A')}")
                    except:
                        pass

                bridge.access_app.DoCmd.Close(2, form_name, 2)  # acForm, acSaveNo
            except Exception as e:
                print(f"  Fehler: {e}")
                try:
                    bridge.access_app.DoCmd.Close(2, form_name, 2)
                except:
                    pass

except Exception as e:
    print(f"FEHLER: {e}")
    import traceback
    traceback.print_exc()

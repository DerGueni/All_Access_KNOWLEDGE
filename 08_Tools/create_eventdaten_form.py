"""
Script zur Erstellung von Tabelle und Subformular für VA EventDaten
Verwendet Access Bridge zur Automatisierung
"""

import sys
sys.path.append(r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge

def create_eventdaten_table_and_form():
    """Erstellt Tabelle tbl_N_VA_EventDaten und Subformular sub_N_VA_EventDaten"""

    with AccessBridge() as bridge:
        print("=== EventDaten Komponenten erstellen ===\n")

        # 1. Tabelle erstellen (wenn nicht existiert)
        print("1. Erstelle Tabelle tbl_N_VA_EventDaten...")
        create_table_sql = """
        CREATE TABLE tbl_N_VA_EventDaten (
            ID AUTOINCREMENT PRIMARY KEY,
            VA_ID LONG,
            Einlass TEXT(50),
            Beginn TEXT(50),
            Ende TEXT(50),
            Infos MEMO,
            WebLink TEXT(255),
            LetzteAktualisierung DATETIME
        )
        """

        try:
            bridge.execute_sql(create_table_sql)
            print("   ✓ Tabelle tbl_N_VA_EventDaten erstellt")
        except Exception as e:
            if "already exists" in str(e).lower():
                print("   → Tabelle existiert bereits")
            else:
                print(f"   ! Fehler: {e}")

        # 2. Query für RecordSource erstellen
        print("\n2. Erstelle Query qry_N_VA_EventDaten_Src...")
        query_sql = """
        SELECT
            e.ID,
            e.VA_ID,
            e.Einlass,
            e.Beginn,
            e.Ende,
            e.Infos,
            e.WebLink,
            e.LetzteAktualisierung
        FROM tbl_N_VA_EventDaten AS e
        WHERE e.VA_ID = [Forms]![frm_VA_Auftragstamm]![ID]
        """

        bridge.create_query("N_VA_EventDaten_Src", query_sql, auto_prefix=True)
        print("   ✓ Query qry_N_VA_EventDaten_Src erstellt")

        # 3. Subformular erstellen
        print("\n3. Erstelle Subformular sub_N_VA_EventDaten...")

        # Formular erstellen (Einzelformular-Ansicht, editierbar)
        bridge.create_form(
            name="sub_N_VA_EventDaten",
            record_source="qry_N_VA_EventDaten_Src",
            default_view=0,  # 0 = Single Form
            allow_edits=True,
            auto_prefix=True
        )
        print("   ✓ Formular sub_N_VA_EventDaten erstellt")

        # 4. Controls hinzufügen
        print("\n4. Füge Controls hinzu...")

        # Layout-Konstanten
        LEFT_MARGIN = 100
        TOP_START = 200
        LABEL_WIDTH = 1500
        CONTROL_WIDTH = 4000
        ROW_HEIGHT = 350
        LABEL_CONTROL_GAP = 100

        # Helper function
        def add_field(bridge, form_name, field_name, caption, top, height=300, is_memo=False, is_hyperlink=False):
            """Fügt Label + Control hinzu"""
            # Label
            bridge.add_control_to_form(
                form_name=form_name,
                control_type=100,  # Label
                section=0,  # Detail
                left=LEFT_MARGIN,
                top=top,
                width=LABEL_WIDTH,
                height=height,
                Name=f"lbl{field_name}",
                Caption=caption,
                FontSize=10,
                FontBold=True
            )

            # Control
            control_left = LEFT_MARGIN + LABEL_WIDTH + LABEL_CONTROL_GAP

            if is_hyperlink:
                # Hyperlink als Label mit Hyperlink-Property
                bridge.add_control_to_form(
                    form_name=form_name,
                    control_type=100,  # Label
                    section=0,
                    left=control_left,
                    top=top,
                    width=CONTROL_WIDTH,
                    height=height,
                    Name=f"txt{field_name}",
                    ControlSource=field_name,
                    HyperlinkAddress="",
                    FontSize=10,
                    ForeColor=0xFF0000  # Blau
                )
            else:
                bridge.add_control_to_form(
                    form_name=form_name,
                    control_type=109,  # TextBox
                    section=0,
                    left=control_left,
                    top=top,
                    width=CONTROL_WIDTH,
                    height=height,
                    Name=f"txt{field_name}",
                    ControlSource=field_name,
                    FontSize=10,
                    Locked=False if field_name in ['Einlass', 'Beginn', 'Ende', 'Infos', 'WebLink'] else True
                )

        form_name = "sub_N_VA_EventDaten"
        current_top = TOP_START

        # Felder aus Hauptformular (read-only)
        print("   → Hauptformular-Felder (read-only)...")
        add_field(bridge, form_name, "Datum", "Datum:", current_top)
        current_top += ROW_HEIGHT

        add_field(bridge, form_name, "Auftrag", "Auftrag:", current_top)
        current_top += ROW_HEIGHT

        add_field(bridge, form_name, "Ort", "Ort:", current_top)
        current_top += ROW_HEIGHT

        add_field(bridge, form_name, "Objekt", "Objekt:", current_top)
        current_top += ROW_HEIGHT

        add_field(bridge, form_name, "Adresse", "Adresse:", current_top)
        current_top += ROW_HEIGHT

        # Trennlinie
        current_top += 200

        # Event-Daten (editierbar)
        print("   → Event-Daten (editierbar)...")
        add_field(bridge, form_name, "Einlass", "Einlass:", current_top)
        current_top += ROW_HEIGHT

        add_field(bridge, form_name, "Beginn", "Beginn:", current_top)
        current_top += ROW_HEIGHT

        add_field(bridge, form_name, "Ende", "Ende:", current_top)
        current_top += ROW_HEIGHT

        add_field(bridge, form_name, "Infos", "Infos:", current_top, height=900, is_memo=True)
        current_top += 1100

        add_field(bridge, form_name, "WebLink", "WebLink:", current_top, is_hyperlink=True)
        current_top += ROW_HEIGHT

        add_field(bridge, form_name, "LetzteAktualisierung", "Letzte Aktualisierung:", current_top)
        current_top += ROW_HEIGHT

        # Button "Daten aktualisieren"
        print("   → Button 'Daten aktualisieren'...")
        bridge.add_control_to_form(
            form_name=form_name,
            control_type=104,  # CommandButton
            section=0,
            left=LEFT_MARGIN,
            top=current_top + 200,
            width=2500,
            height=400,
            Name="btnAktualisieren",
            Caption="Daten aktualisieren",
            FontSize=10,
            OnClick="=mod_N_EventDaten.HoleEventDatenAusWeb([Forms]![frm_VA_Auftragstamm]![ID])"
        )

        print("   ✓ Controls hinzugefügt")

        # 5. VBA Event-Handler hinzufügen
        print("\n5. Füge VBA Event-Handler hinzu...")
        vba_code = """
Private Sub Form_Open(Cancel As Integer)
    ' Prüft ob bereits Daten vorhanden, sonst automatisch laden
    On Error GoTo Err_Handler

    Dim VA_ID As Long
    Dim rs As DAO.Recordset

    ' VA_ID aus Hauptformular holen
    If Not IsNull(Me.Parent!ID) Then
        VA_ID = Me.Parent!ID

        ' Prüfen ob Daten existieren
        Set rs = CurrentDb.OpenRecordset( _
            "SELECT COUNT(*) AS Anzahl FROM tbl_N_VA_EventDaten WHERE VA_ID = " & VA_ID)

        If rs!Anzahl = 0 Then
            ' Keine Daten -> automatisch laden
            Call mod_N_EventDaten.HoleEventDatenAusWeb(VA_ID)
            Me.Requery
        End If

        rs.Close
        Set rs = Nothing
    End If

Exit_Handler:
    Exit Sub

Err_Handler:
    MsgBox "Fehler beim Laden der EventDaten: " & Err.Description, vbExclamation
    Resume Exit_Handler
End Sub

Private Sub Form_Current()
    ' Zeigt "Keine Infos verfügbar" wenn kein Datensatz
    On Error Resume Next

    If Me.Recordset.RecordCount = 0 Then
        Me.txtInfos = "Keine Event-Informationen verfügbar"
        Me.txtInfos.Locked = True
    Else
        Me.txtInfos.Locked = False
    End If
End Sub
"""

        # VBA Code direkt in Formular-Modul einfügen
        bridge.execute_vba(f"""
Dim frm As Form
Set frm = Forms("sub_N_VA_EventDaten")
frm.Module.InsertText "{vba_code.replace('"', '""')}"
DoCmd.Close acForm, "sub_N_VA_EventDaten", acSaveYes
""")

        print("   ✓ VBA Event-Handler hinzugefügt")

        # 6. Zusammenfassung
        print("\n" + "="*50)
        print("ERFOLGREICH ERSTELLT:")
        print("  • Tabelle: tbl_N_VA_EventDaten")
        print("  • Query: qry_N_VA_EventDaten_Src")
        print("  • Subformular: sub_N_VA_EventDaten")
        print("  • Controls: Labels, TextBoxen, Button")
        print("  • VBA: Form_Open, Form_Current")
        print("\nNächster Schritt:")
        print("  → Subformular in frm_VA_Auftragstamm einbetten")
        print("  → mod_N_EventDaten.bas mit HoleEventDatenAusWeb() erstellen")
        print("="*50)

if __name__ == "__main__":
    try:
        create_eventdaten_table_and_form()
    except Exception as e:
        print(f"\n! FEHLER: {e}")
        import traceback
        traceback.print_exc()

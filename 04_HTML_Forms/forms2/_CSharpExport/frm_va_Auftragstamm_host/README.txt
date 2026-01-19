C# Access Host for frm_va_Auftragstamm

This WinForms app opens Access and shows the original form. All logic runs inside Access,
so behavior matches the Access frontend.

1) Edit config.json to point to your ACCDB path if needed.
2) Build with Visual Studio (.NET Framework 4.8).
3) Run the exe. The app starts Access and opens frm_va_Auftragstamm automatically.

Notes:
- Requires Microsoft Access installed on the machine.
- This host does not reimplement VBA logic; it runs the Access form directly.

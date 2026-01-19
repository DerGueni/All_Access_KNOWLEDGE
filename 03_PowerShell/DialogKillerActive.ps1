Add-Type -AssemblyName System.Windows.Forms
$lastKill = Get-Date

while ($true) {
    try {
        # Access Dialoge finden und schließen
        $accessWindows = Get-Process | Where-Object { $_.MainWindowTitle -like "*Microsoft Access*" -or $_.MainWindowTitle -like "*Speichern*" -or $_.MainWindowTitle -like "*löschen*" }
        
        # SendKeys für Escape/Enter bei Dialogen
        $shell = New-Object -ComObject WScript.Shell
        
        # Finde modale Dialoge
        Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count);
    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr hWnd, uint Msg, int wParam, int lParam);
    public const uint WM_CLOSE = 0x0010;
    public const uint WM_KEYDOWN = 0x0100;
    public const int VK_RETURN = 0x0D;
    public const int VK_ESCAPE = 0x1B;
}
"@
        
        $hwnd = [Win32]::GetForegroundWindow()
        $title = New-Object System.Text.StringBuilder 256
        [Win32]::GetWindowText($hwnd, $title, 256) | Out-Null
        $windowTitle = $title.ToString()
        
        # Schließe bekannte Dialoge
        if ($windowTitle -match "Speichern|löschen|Änderungen|Microsoft Access|Warnung|Fehler|Bestätigen") {
            if ($windowTitle -notmatch "Consys_FE") {
                [Win32]::PostMessage($hwnd, [Win32]::WM_KEYDOWN, [Win32]::VK_RETURN, 0)
                Start-Sleep -Milliseconds 100
            }
        }
    } catch {}
    
    Start-Sleep -Milliseconds 500
}

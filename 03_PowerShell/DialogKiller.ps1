# ═══════════════════════════════════════════════════════════════════
# DIALOG KILLER - Schließt ALLE Access-Dialoge automatisch
# Läuft im Hintergrund während Access-Operationen
# ═══════════════════════════════════════════════════════════════════

param(
    [int]$DurationSeconds = 300,
    [int]$IntervalMs = 100,
    [string]$LogFile = ""
)

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public class DialogKiller {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);
    
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    
    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);
    
    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);
    
    [DllImport("user32.dll")]
    public static extern int GetWindowTextLength(IntPtr hWnd);
    
    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    
    [DllImport("user32.dll")]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    
    public const uint WM_CLOSE = 0x0010;
    public const uint BM_CLICK = 0x00F5;
    public const uint WM_KEYDOWN = 0x0100;
    public const uint VK_RETURN = 0x0D;
    public const uint VK_ESCAPE = 0x1B;
}
"@

$dialogPatterns = @(
    "*Microsoft Access*",
    "*Warnung*",
    "*Warning*",
    "*Fehler*",
    "*Error*",
    "*Speichern*",
    "*Save*",
    "*Bestätigung*",
    "*Confirm*",
    "*Hinweis*",
    "*Notice*",
    "*Information*",
    "*Sicherheit*",
    "*Security*"
)

$buttonPatterns = @(
    "OK", "Ja", "Yes", "Nein", "No", "Abbrechen", "Cancel",
    "Schließen", "Close", "Ignorieren", "Ignore", "Weiter", "Continue",
    "Nicht speichern", "Don't Save", "Verwerfen", "Discard"
)

$killedCount = 0
$startTime = Get-Date
$endTime = $startTime.AddSeconds($DurationSeconds)

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMsg = "[$timestamp] $Message"
    if ($LogFile) {
        Add-Content -Path $LogFile -Value $logMsg -ErrorAction SilentlyContinue
    }
}

Write-Log "Dialog Killer gestartet (Dauer: $DurationSeconds Sekunden)"

while ((Get-Date) -lt $endTime) {
    try {
        # Alle sichtbaren Fenster durchgehen
        $windows = @()
        $callback = [DialogKiller+EnumWindowsProc]{
            param($hWnd, $lParam)
            if ([DialogKiller]::IsWindowVisible($hWnd)) {
                $length = [DialogKiller]::GetWindowTextLength($hWnd)
                if ($length -gt 0) {
                    $sb = New-Object System.Text.StringBuilder($length + 1)
                    [DialogKiller]::GetWindowText($hWnd, $sb, $sb.Capacity) | Out-Null
                    $title = $sb.ToString()
                    
                    foreach ($pattern in $dialogPatterns) {
                        if ($title -like $pattern) {
                            # Dialog gefunden - versuche zu schließen
                            
                            # 1. Versuche Button zu finden und klicken
                            foreach ($btnText in $buttonPatterns) {
                                $btn = [DialogKiller]::FindWindowEx($hWnd, [IntPtr]::Zero, "Button", $btnText)
                                if ($btn -ne [IntPtr]::Zero) {
                                    [DialogKiller]::SendMessage($btn, [DialogKiller]::BM_CLICK, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null
                                    $script:killedCount++
                                    Write-Log "Dialog geschlossen: '$title' (Button: $btnText)"
                                    return $true
                                }
                            }
                            
                            # 2. Versuche ENTER zu senden
                            [DialogKiller]::SetForegroundWindow($hWnd) | Out-Null
                            [DialogKiller]::PostMessage($hWnd, [DialogKiller]::WM_KEYDOWN, [IntPtr][DialogKiller]::VK_RETURN, [IntPtr]::Zero) | Out-Null
                            $script:killedCount++
                            Write-Log "Dialog geschlossen: '$title' (ENTER)"
                            return $true
                        }
                    }
                }
            }
            return $true
        }
        
        [DialogKiller]::EnumWindows($callback, [IntPtr]::Zero) | Out-Null
        
    } catch {
        # Fehler ignorieren
    }
    
    Start-Sleep -Milliseconds $IntervalMs
}

Write-Log "Dialog Killer beendet. $killedCount Dialoge geschlossen."
Write-Output $killedCount

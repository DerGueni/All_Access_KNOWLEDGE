# ===================================================================
# DIALOG KILLER ULTIMATE - Permanent im Hintergrund
# Schliesst ALLE Access/VBA Dialoge automatisch inkl. Speicherdialoge
# Loggt alle Aktionen fuer die Bridge
# ===================================================================

param(
    [int]$Minutes = 60,
    [int]$IntervalMs = 50
)

# Log-Datei im Bridge-Verzeichnis
$logFile = "C:\Users\guenther.siegert\Documents\Access Bridge\dialog_killer.log"
$jsonLogFile = "C:\Users\guenther.siegert\Documents\Access Bridge\dialog_killer_events.json"

# Alte Logs loeschen beim Start
Remove-Item $logFile -ErrorAction SilentlyContinue
Remove-Item $jsonLogFile -ErrorAction SilentlyContinue

# Fenster verstecken
Add-Type -Name Win -Namespace Native -MemberDefinition '
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
'
[Native.Win]::ShowWindow([Native.Win]::GetConsoleWindow(), 0) | Out-Null

# Win32 API
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
using System.Collections.Generic;

public class DialogKillerAPI {
    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll")]
    public static extern int GetWindowTextLength(IntPtr hWnd);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

    [DllImport("user32.dll")]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);

    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    public const uint WM_CLOSE = 0x0010;
    public const uint BM_CLICK = 0x00F5;
    public const uint WM_KEYDOWN = 0x0100;
    public const uint WM_KEYUP = 0x0101;
    public const uint VK_RETURN = 0x0D;
    public const uint VK_ESCAPE = 0x1B;

    public static string GetWindowTitle(IntPtr hWnd) {
        int length = GetWindowTextLength(hWnd);
        if (length > 0 && length < 500) {
            StringBuilder sb = new StringBuilder(length + 1);
            GetWindowText(hWnd, sb, sb.Capacity);
            return sb.ToString();
        }
        return "";
    }

    public static string GetWindowClassName(IntPtr hWnd) {
        StringBuilder sb = new StringBuilder(256);
        GetClassName(hWnd, sb, 256);
        return sb.ToString();
    }

    public static bool ClickButton(IntPtr dialogHwnd, string buttonText) {
        IntPtr btn = FindWindowEx(dialogHwnd, IntPtr.Zero, "Button", buttonText);
        if (btn != IntPtr.Zero) {
            SendMessage(btn, BM_CLICK, IntPtr.Zero, IntPtr.Zero);
            return true;
        }
        return false;
    }

    public static void SendEnter(IntPtr hWnd) {
        SetForegroundWindow(hWnd);
        System.Threading.Thread.Sleep(50);
        PostMessage(hWnd, WM_KEYDOWN, (IntPtr)VK_RETURN, IntPtr.Zero);
        System.Threading.Thread.Sleep(50);
        PostMessage(hWnd, WM_KEYUP, (IntPtr)VK_RETURN, IntPtr.Zero);
    }
}
"@

# Dialog-Titel die geschlossen werden sollen (exakt)
$exactDialogTitles = @(
    "Microsoft Access",
    "Microsoft Visual Basic",
    "Microsoft Visual Basic for Applications",
    "Warnung",
    "Warning",
    "Fehler",
    "Error",
    "Hinweis",
    "Information",
    "Bestaetigung",
    "Confirmation",
    "Meldung",
    "Message",
    "Laufzeitfehler",
    "Runtime Error"
)

# Teilstrings im Titel die auf Dialoge hinweisen
$containsDialogTitles = @(
    "Speichern",
    "Save",
    "Aenderungen",
    "Changes",
    "moechten Sie",
    "Do you want",
    "Wollen Sie",
    "Are you sure",
    "Sicher",
    "Confirm",
    "Kompilierungsfehler",
    "Compile error",
    "Laufzeitfehler",
    "Runtime error",
    "Syntaxfehler",
    "Syntax error",
    "Debuggen",
    "Debug",
    "Objektvariable",
    "Object variable",
    "nicht gefunden",
    "not found",
    "bereits vorhanden",
    "already exists",
    "Zugriff verweigert",
    "Access denied",
    "Datensatz",
    "Record",
    "Fehler 53",
    "Error 53",
    "nicht definiert",
    "not defined",
    "Datei nicht gefunden",
    "File not found"
)

# Button-Texte zum Klicken (in Prioritaetsreihenfolge)
$buttonTexts = @(
    "OK",
    "Ja",
    "Yes",
    "Nein",
    "No",
    "Abbrechen",
    "Cancel",
    "Schliessen",
    "Close",
    "Ende",
    "End",
    "Beenden",
    "Ignorieren",
    "Ignore",
    "Weiter",
    "Continue"
)

# Klassen die auf Dialoge hinweisen
$dialogClasses = @(
    "#32770",
    "ThunderDFrame"
)

$killedCount = 0
$endTime = (Get-Date).AddMinutes($Minutes)

# Log-Funktion
function Write-Log {
    param($msg, $level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logEntry = "[$ts] [$level] $msg"
    Add-Content $logFile $logEntry -ErrorAction SilentlyContinue
}

# Funktion um zu pruefen ob es ein Access/Office-Prozess ist
function Is-OfficeProcess {
    param($hWnd)
    $processId = 0
    [DialogKillerAPI]::GetWindowThreadProcessId($hWnd, [ref]$processId) | Out-Null
    try {
        $proc = Get-Process -Id $processId -ErrorAction SilentlyContinue
        if ($proc -and ($proc.ProcessName -match "MSACCESS|EXCEL|WINWORD|OUTLOOK|POWERPNT")) {
            return $true
        }
    } catch {}
    return $false
}

# Funktion um Button zu klicken
function Click-DialogButton {
    param($hWnd)

    # Versuche alle Button-Texte
    foreach ($btnText in $buttonTexts) {
        if ([DialogKillerAPI]::ClickButton($hWnd, $btnText)) {
            return $btnText
        }
    }

    # Fallback: Enter-Taste senden
    [DialogKillerAPI]::SendEnter($hWnd)
    return "VK_RETURN"
}

Write-Log "Dialog Killer ULTIMATE gestartet - Laufzeit: $Minutes Min, Intervall: $IntervalMs ms" "START"

while ((Get-Date) -lt $endTime) {
    try {
        [DialogKillerAPI]::EnumWindows({
            param($hWnd, $lParam)

            if ([DialogKillerAPI]::IsWindowVisible($hWnd)) {
                $title = [DialogKillerAPI]::GetWindowTitle($hWnd)
                $class = [DialogKillerAPI]::GetWindowClassName($hWnd)

                if ($title.Length -gt 0) {
                    $isDialog = $false
                    $reason = ""

                    # Pruefe auf exakten Titel-Match
                    foreach ($dt in $exactDialogTitles) {
                        if ($title -eq $dt) {
                            $isDialog = $true
                            $reason = "ExactTitle:$dt"
                            break
                        }
                    }

                    # Pruefe auf Teilstring im Titel
                    if (-not $isDialog) {
                        foreach ($ct in $containsDialogTitles) {
                            if ($title -like "*$ct*") {
                                $isDialog = $true
                                $reason = "ContainsTitle:$ct"
                                break
                            }
                        }
                    }

                    # Pruefe auf Dialog-Klasse (nur fuer Office-Prozesse)
                    if (-not $isDialog) {
                        foreach ($dc in $dialogClasses) {
                            if ($class -eq $dc) {
                                if (Is-OfficeProcess $hWnd) {
                                    $isDialog = $true
                                    $reason = "DialogClass:$dc"
                                }
                                break
                            }
                        }
                    }

                    if ($isDialog) {
                        # Button klicken
                        $clickedBtn = Click-DialogButton $hWnd
                        $script:killedCount++

                        # Loggen
                        $logMsg = "DIALOG: Titel='$title' Klasse='$class' Grund='$reason' Geklickt='$clickedBtn'"
                        Write-Log $logMsg "DIALOG"

                        Start-Sleep -Milliseconds 100
                    }
                }
            }
            return $true
        }, [IntPtr]::Zero) | Out-Null
    } catch {
        # Fehler ignorieren - nicht loggen um Spam zu vermeiden
    }

    Start-Sleep -Milliseconds $IntervalMs
}

Write-Log "Dialog Killer beendet - $killedCount Dialoge geschlossen" "END"

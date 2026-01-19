Add-Type -AssemblyName System.Windows.Forms
$img = [System.Windows.Forms.Clipboard]::GetImage()
if ($img) {
    $path = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\temp_screenshot.png"
    $img.Save($path)
    Write-Host "OK: $path"
} else {
    Write-Host "FEHLER: Kein Bild in Zwischenablage"
    exit 1
}

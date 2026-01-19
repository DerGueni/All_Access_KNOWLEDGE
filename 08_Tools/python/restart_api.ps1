# Restart API Server
Write-Host "Stopping existing Python processes..."
Get-Process python -ErrorAction SilentlyContinue | Stop-Process -Force

Start-Sleep -Seconds 2

Write-Host "Starting API Server..."
Set-Location "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
Start-Process -FilePath "python" -ArgumentList "api_server.py" -WindowStyle Normal

Write-Host "API Server started. Please wait 5 seconds..."
Start-Sleep -Seconds 5
Write-Host "Done!"

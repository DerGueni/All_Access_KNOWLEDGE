Get-WinEvent -LogName Application -MaxEvents 20 -ErrorAction SilentlyContinue |
    Where-Object { $_.TimeCreated -gt (Get-Date).AddMinutes(-10) } |
    Format-List TimeCreated, ProviderName, Message

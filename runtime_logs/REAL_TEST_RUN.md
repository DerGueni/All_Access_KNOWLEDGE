# REAL_TEST_RUN
Date: 2025-12-29T12:55:23+01:00

Attempted from WSL. Windows binaries (powershell.exe/cmd.exe) not executable: Permission denied.

Commands attempted:
- /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command ""
- /mnt/c/Windows/System32/cmd.exe /C "echo hi"

Result: Real UI/E2E tests could not run from WSL.
Next step: run AUTO_RUNNER.ps1 in Windows PowerShell to perform real UI tests.

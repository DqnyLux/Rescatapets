@echo off
echo Limpiando historial de Git...
cd /d "C:\Users\DqnyLuxxx\Desktop\RescataPet EC\Rescatapets"

REM Forzar borrado del backup previo si existiera
git update-ref -d refs/original/refs/heads/main 2>nul
git for-each-ref --format="%(refname)" refs/original/ | %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "$input | ForEach-Object { git update-ref -d $_ }"

REM Reescribir la historia sin la línea de Claude, forzando la sobreescritura de backups
git filter-branch -f --msg-filter "sed '/Co-Authored-By: Claude/d'" -- --all

echo.
echo Subiendo forzadamente a GitHub...
git push origin main --force

echo.
echo ¡Listo! Historial limpio.

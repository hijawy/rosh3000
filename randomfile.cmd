@echo off
if "%~1"=="" (
    echo Usage: %~nx0 ^<filename.json^>
    exit /b 1
)
set "filename=%~1"
:: Read the JSON data using PowerShell and shuffle the array
powershell -Command "$json = Get-Content -Path '%filename%' -Raw | ConvertFrom-Json; $json.generatedQuestions = $json.generatedQuestions | Get-Random -Count ($json.generatedQuestions).Count; $json | ConvertTo-Json -Compress | Set-Content -Path '%filename%'"
echo The generatedQuestions array has been randomized.
pause

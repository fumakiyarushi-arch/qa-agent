@echo off
if /I "%~1"=="testing" (
    echo [CLI] Starting QA Agentic Flow...
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0scripts\run-qa-with-linear.ps1"
) else (
    echo [CLI] Unknown command: %*
    echo [CLI] Did you mean 'start my testing'?
)

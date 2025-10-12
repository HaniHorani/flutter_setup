# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    $commandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    Start-Process -FilePath PowerShell.exe -Verb RunAs -ArgumentList $commandLine
    exit
}
#  add check for existing flutter installation and back it up
# Set execution policy for current process
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Script path and log file
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$logFile = Join-Path $scriptPath "setup_log.txt"
$global:HasError = $false

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$IsError
    )
    $time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $entry = "$time - $Message"
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $logFile -Value $entry
    if ($IsError) { $global:HasError = $true }
}

# Start log
"========== Script started ==========" | Out-File -FilePath $logFile -Encoding utf8

try {
    # Add a check for PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Log "`u{274C} PowerShell version 5 or higher is required." "Red" -IsError
        throw
    }

    # Add a check for script execution policy
    $executionPolicy = Get-ExecutionPolicy
    if ($executionPolicy -eq "Restricted") {
        Write-Log "`u{274C} Script execution is restricted. Please change the execution policy using 'Set-ExecutionPolicy RemoteSigned' as Administrator." "Red" -IsError
        throw
    }

    # Files (must exist in the same directory as this script)
    $flutterRar = Join-Path $scriptPath "flutter.rar"
    $gradleRar = Join-Path $scriptPath ".gradle.rar"

    # Add a check for required files
    if (-not (Test-Path $flutterRar)) {
        Write-Log "`u{274C} flutter.rar not found in: $scriptPath" "Red" -IsError
        throw
    }
    if (-not (Test-Path $gradleRar)) {
        Write-Log "`u{274C} .gradle.rar not found in: $scriptPath" "Red" -IsError
        throw
    }

    # Find WinRAR
    $winrar = (Get-Command "rar.exe" -ErrorAction SilentlyContinue).Source
    if (-not $winrar) {
        $possiblePaths = @(
            "C:\Program Files\WinRAR\rar.exe",
            "C:\Program Files (x86)\WinRAR\rar.exe"
        )
        foreach ($path in $possiblePaths) {
            if (Test-Path $path) {
                $winrar = $path
                break
            }
        }
    }

    # Add a check for WinRAR installation
    if (-not $winrar) {
        Write-Log "WinRAR not found. Please install it first." "Red" -IsError
        throw
    }

    Write-Log "`u{2714} WinRAR found at: $winrar" "Green"

    # Extraction paths
    $flutterDest = "C:\dev"
    $gradleDest = "C:\Users\$env:USERNAME"

    # Add a check for write permissions in destination directories
    if (-not (Test-Path $flutterDest)) {
        try {
            New-Item -ItemType Directory -Force -Path $flutterDest | Out-Null
        }
        catch {
            Write-Log "`u{274C} Cannot create directory at $flutterDest. Check permissions." "Red" -IsError
            throw
        }
    }
    if (-not (Test-Path $gradleDest)) {
        try {
            New-Item -ItemType Directory -Force -Path $gradleDest | Out-Null
        }
        catch {
            Write-Log "`u{274C} Cannot create directory at $gradleDest. Check permissions." "Red" -IsError
            throw
        }
    }

    # Extract flutter
    Write-Log "Extracting flutter.rar..."
    New-Item -ItemType Directory -Force -Path $flutterDest | Out-Null
    & $winrar x -y $flutterRar "$flutterDest\" | Out-Null

    # Extract gradle
    Write-Log "Extracting .gradle.rar..."
    New-Item -ItemType Directory -Force -Path $gradleDest | Out-Null
    & $winrar x -y $gradleRar "$gradleDest\" | Out-Null

    # Update PATH (add flutter/bin only)
    $flutterBin = Join-Path $flutterDest "flutter\bin"
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

    if ($currentPath -notlike "*$flutterBin*") {
        $newPath = "$currentPath;$flutterBin"
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Write-Log "`u{2714} Added $flutterBin to PATH" "Green"
    }
    else {
        Write-Log "flutter/bin already exists in PATH" "Yellow"
    }

    Write-Log "Extraction and PATH update completed successfully." "Green"
    Write-Log "Restart PowerShell or your PC to apply PATH changes." "Yellow"
}
catch {
    Write-Log "`u{203C} An error occurred during execution. Check log for details." "Red" -IsError
}
finally {
    "========== Script finished ==========" | Add-Content -Path $logFile -Encoding utf8

    if (-not $global:HasError) {
        # Delete log file if everything went fine
        Remove-Item $logFile -Force
        Write-Host "`u{1F5D1} Log file deleted (no errors)." -ForegroundColor Cyan
        
        # Fun welcome message
        Write-Host "`n" -ForegroundColor Cyan
        Write-Host "🎉 Welcome to the Exciting World of Flutter! 🎉" -ForegroundColor Magenta
        Write-Host "Hani welcomes you to the thrilling journey of Errors 😅" -ForegroundColor Yellow
        Write-Host "Remember: Every Error is a new friend on your learning path! 🚀" -ForegroundColor Green
        Write-Host "Get ready for the adventure... Errors are waiting for you! 🎮" -ForegroundColor Cyan
        Write-Host "`n" -ForegroundColor Cyan
    }
    else {
        Write-Host "`u{1F4C4} Log file kept at: $logFile" -ForegroundColor Yellow
    }
}

Write-Host "Press Enter to exit..." -ForegroundColor Cyan
Read-Host

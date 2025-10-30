# Self-elevate the script if required
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {

    # script path
    $script = $MyInvocation.MyCommand.Path

    # pass any arguments that exist when running
    $args = $MyInvocation.UnboundArguments -join ' '

    # set PowerShell options to work in a new window with Admin permissions
    $psArgs = "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$script`" $args"

    # start the new process with Admin permissions
    Start-Process -FilePath "powershell.exe" -ArgumentList $psArgs -Verb RunAs

    # stop the current script
    exit
}
#  add check for existing flutter installation and back it up
# Set execution policy for current process
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

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

    # Find Flutter archive (supports any name starting with "flutter" and any compression format)
    $flutterArchive = $null
    $gradleArchive = $null
    
    # Look for Flutter archive with any name starting with "flutter" and any extension
    $flutterPatterns = @("flutter*.rar", "flutter*.zip", "flutter*.7z", "flutter*.tar.gz")
    $allFlutterFiles = @()
    
    foreach ($pattern in $flutterPatterns) {
        $found = Get-ChildItem -Path $scriptPath -Name $pattern -ErrorAction SilentlyContinue
        if ($found) {
            $allFlutterFiles += $found
        }
    }
    
    if ($allFlutterFiles.Count -gt 1) {
        Write-Log "`u{26A0} Multiple Flutter archives found:" "Yellow"
        foreach ($file in $allFlutterFiles) {
            Write-Log "`u{2022} $file" "Yellow"
        }
        Write-Log "`u{26A0} Using the first one: $($allFlutterFiles[0])" "Yellow"
        Write-Log "`u{26A0} To use a different version, rename or move other Flutter archives" "Yellow"
    }
    
    if ($allFlutterFiles.Count -gt 0) {
        $flutterArchive = Join-Path $scriptPath $allFlutterFiles[0]
        Write-Log "`u{2714} Selected Flutter archive: $($allFlutterFiles[0])" "Green"
    }
    
    # Look for Gradle archive with any name starting with ".gradle" and any extension
    $gradlePatterns = @(".gradle*.rar", ".gradle*.zip", ".gradle*.7z", ".gradle*.tar.gz")
    $allGradleFiles = @()
    
    foreach ($pattern in $gradlePatterns) {
        $found = Get-ChildItem -Path $scriptPath -Name $pattern -ErrorAction SilentlyContinue
        if ($found) {
            $allGradleFiles += $found
        }
    }
    
    if ($allGradleFiles.Count -gt 1) {
        Write-Log "`u{26A0} Multiple Gradle archives found:" "Yellow"
        foreach ($file in $allGradleFiles) {
            Write-Log "`u{2022} $file" "Yellow"
        }
        Write-Log "`u{26A0} Using the first one: $($allGradleFiles[0])" "Yellow"
        Write-Log "`u{26A0} To use a different version, rename or move other Gradle archives" "Yellow"
    }
    
    if ($allGradleFiles.Count -gt 0) {
        $gradleArchive = Join-Path $scriptPath $allGradleFiles[0]
        Write-Log "`u{2714} Selected Gradle archive: $($allGradleFiles[0])" "Green"
    }

    # Add a check for required files
    if (-not $flutterArchive) {
        Write-Log "`u{274C} No Flutter archive found. Looking for files starting with 'flutter' (rar, zip, 7z, tar.gz)" "Red" -IsError
        throw
    }
    
    # Gradle archive is optional
    if (-not $gradleArchive) {
        Write-Log "`u{26A0} No Gradle archive found. Gradle dependencies will be downloaded automatically on first Flutter build." "Yellow"
        Write-Log "`u{26A0} This may take longer on first run but is perfectly normal." "Yellow"
    }

    # Find extraction tool based on archive type
    $extractionTool = $null
    $extractionCommand = $null
    $archiveExtension = [System.IO.Path]::GetExtension($flutterArchive).ToLower()
    
    switch ($archiveExtension) {
        ".rar" {
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
            if ($winrar) {
                $extractionTool = $winrar
                $extractionCommand = "x -y"
                Write-Log "`u{2714} WinRAR found at: $winrar" "Green"
            }
        }
        ".zip" {
            # Use PowerShell built-in Expand-Archive
            $extractionTool = "PowerShell"
            $extractionCommand = "Expand-Archive"
            Write-Log "`u{2714} Using PowerShell built-in ZIP extraction" "Green"
        }
        ".7z" {
            # Find 7-Zip
            $sevenzip = (Get-Command "7z.exe" -ErrorAction SilentlyContinue).Source
            if (-not $sevenzip) {
                $possiblePaths = @(
                    "C:\Program Files\7-Zip\7z.exe",
                    "C:\Program Files (x86)\7-Zip\7z.exe"
                )
                foreach ($path in $possiblePaths) {
                    if (Test-Path $path) {
                        $sevenzip = $path
                        break
                    }
                }
            }
            if ($sevenzip) {
                $extractionTool = $sevenzip
                $extractionCommand = "x -y"
                Write-Log "`u{2714} 7-Zip found at: $sevenzip" "Green"
            }
        }
        ".gz" {
            # For tar.gz files, try to find tar or 7-Zip
            $tar = (Get-Command "tar.exe" -ErrorAction SilentlyContinue).Source
            if ($tar) {
                $extractionTool = $tar
                $extractionCommand = "-xzf"
                Write-Log "`u{2714} tar found at: $tar" "Green"
            } else {
                # Try 7-Zip as fallback
                $sevenzip = (Get-Command "7z.exe" -ErrorAction SilentlyContinue).Source
                if (-not $sevenzip) {
                    $possiblePaths = @(
                        "C:\Program Files\7-Zip\7z.exe",
                        "C:\Program Files (x86)\7-Zip\7z.exe"
                    )
                    foreach ($path in $possiblePaths) {
                        if (Test-Path $path) {
                            $sevenzip = $path
                            break
                        }
                    }
                }
                if ($sevenzip) {
                    $extractionTool = $sevenzip
                    $extractionCommand = "x -y"
                    Write-Log "`u{2714} 7-Zip found at: $sevenzip (for tar.gz)" "Green"
                }
            }
        }
    }

    # Add a check for extraction tool installation
    if (-not $extractionTool) {
        Write-Log "`u{274C} No suitable extraction tool found for $archiveExtension files. Please install WinRAR, 7-Zip, or ensure tar is available." "Red" -IsError
        throw
    }

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
    Write-Log "Extracting Flutter archive..."
    New-Item -ItemType Directory -Force -Path $flutterDest | Out-Null
    
    if ($extractionTool -eq "PowerShell") {
        # Use PowerShell Expand-Archive for ZIP files
        Expand-Archive -Path $flutterArchive -DestinationPath $flutterDest -Force
    } else {
        # Use external tool (WinRAR, 7-Zip, tar)
        if ($extractionCommand -eq "-xzf") {
            # tar command
            & $extractionTool $extractionCommand $flutterArchive -C $flutterDest
        } else {
            # WinRAR or 7-Zip command
            & $extractionTool x -y ""$flutterArchive"" ""$flutterDest`\""
        }
    }

    # Extract gradle (only if archive exists)
    if ($gradleArchive) {
        Write-Log "Extracting Gradle archive..."
        New-Item -ItemType Directory -Force -Path $gradleDest | Out-Null
        
        $gradleExtension = [System.IO.Path]::GetExtension($gradleArchive).ToLower()
        if ($gradleExtension -eq ".zip") {
            # Use PowerShell Expand-Archive for ZIP files
            Expand-Archive -Path $gradleArchive -DestinationPath $gradleDest -Force
        } else {
            # Use external tool (WinRAR, 7-Zip, tar)
            if ($extractionCommand -eq "-xzf") {
                # tar command
                & $extractionTool $extractionCommand $gradleArchive -C $gradleDest
            } else {
                # WinRAR or 7-Zip command
                & $extractionTool $extractionCommand $gradleArchive "$gradleDest\"
            }
        }
        Write-Log "`u{2714} Gradle dependencies extracted successfully" "Green"
    } else {
        Write-Log "`u{26A0} Skipping Gradle extraction - will be downloaded automatically" "Yellow"
    }

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

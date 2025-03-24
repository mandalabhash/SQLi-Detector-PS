param (
    [string]$LogDirectory = "C:\inetpub\logs\LogFiles\W3SVC2"
)

# Load required module
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    try {
        Install-Module BurntToast -Force -AllowClobber -ErrorAction Stop
    }
    catch {
        Write-Host "Failed to install BurntToast: $_" -ForegroundColor Red
        exit 1
    }
}
Import-Module BurntToast

# Initialize CSV log file
$csvLogPath = Join-Path $PWD "sqli_alerts.csv"
if (-not (Test-Path $csvLogPath)) {
    "Date,Time,IP Address,Payload" | Out-File $csvLogPath -Encoding UTF8
}

# Regex pattern to extract the source IP (second IP in log)
$ipRegex = '(?<=^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\s)(?<ClientIP>\S+).*?\s(?<SourceIP>\S+)(?=\s+Mozilla)'

# Core SQLi detection patterns
$sqliPatterns = @(
    "(?i)(\%27)|(')|(--)|(%23)|(#)",
    "(?i)(\bOR\b|\bAND\b).*?(=|LIKE|<|>|!=)",
    "(?i)UNION(\s+ALL)?\s+SELECT",
    "(?i)SELECT\s.+FROM",
    "(?i)INSERT\s+INTO",
    "(?i)UPDATE\s+.+\s+SET",
    "(?i)DELETE\s+FROM",
    "(?i)(\%27)|(').*?(\%6F|o|O)(\%72|r|R)",
    "(?i)(\%27)|(').*?(\%61|a|A)(\%6E|n|N)(\%64|d|D)",
    "(?i)WAITFOR\s+DELAY",
    "(?i)SLEEP\s*\([0-9]+\)",
    "(?i)CAST\s*\(",
    "(?i)EXEC\s*\(|EXECUTE\s*\(|EXEC\s+[A-Za-z]",
    "(?i)DECLARE\s+@"
)

function Get-CurrentLogFile {
    $expectedFileName = "u_ex$(Get-Date -Format 'yyMMdd').log"
    $logFile = Join-Path $LogDirectory $expectedFileName
    
    if (Test-Path $logFile) {
        return $logFile
    }
    else {
        Write-Host "Current log file not found: $expectedFileName" -ForegroundColor Yellow
        $latestLog = Get-ChildItem -Path $LogDirectory -Filter "u_ex*.log" | 
                    Sort-Object LastWriteTime -Descending | 
                    Select-Object -First 1
        return $latestLog.FullName
    }
}

function ConvertFrom-UrlEncodedString {
    param ($inputString)
    try {
        return [System.Uri]::UnescapeDataString($inputString)
    }
    catch {
        Write-Host "URL decode failed: $_" -ForegroundColor Yellow
        return $inputString
    }
}

function Log-AlertToCSV {
    param (
        [string]$ipAddress,
        [string]$payload
    )
    $date = Get-Date -Format "yyyy-MM-dd"
    $time = Get-Date -Format "HH:mm:ss"
    
    # Escape payload for CSV (replace " with "")
    $escapedPayload = $payload -replace '"', '""'
    
    # Create CSV line
    $csvLine = """$date"",""$time"",""$ipAddress"",""$escapedPayload"""
    
    try {
        Add-Content -Path $csvLogPath -Value $csvLine -Encoding UTF8
    }
    catch {
        Write-Host "Failed to log alert: $_" -ForegroundColor Yellow
    }
}

function Invoke-Alert {
    param (
        [string]$sourceIP,
        [string]$payload
    )
    
    try {
        # Show toast notification
        New-BurntToastNotification -Text "SQL Injection Attempt!", "From IP: $sourceIP" `
            -AppLogo "C:\Windows\System32\SecurityAndMaintenance.png" `
            -Sound 'Alarm2'
        
        # Console output
        Write-Host "`n[!] SQLi Alert [!]" -ForegroundColor Red
        Write-Host "Source IP: $sourceIP" -ForegroundColor Cyan
        Write-Host "Payload: $payload" -ForegroundColor Yellow
        Write-Host "Time: $(Get-Date -Format 'HH:mm:ss')`n" -ForegroundColor Gray
        
        # Log to CSV
        Log-AlertToCSV -ipAddress $sourceIP -payload $payload
    }
    catch {
        Write-Host "Alert failed: $_" -ForegroundColor Yellow
    }
}

# Main monitoring
try {
    $currentLogFile = Get-CurrentLogFile
    Write-Host "Monitoring: $currentLogFile" -ForegroundColor Green
    Write-Host "Alerts will be logged to: $csvLogPath" -ForegroundColor Cyan
    
    Get-Content -Path $currentLogFile -Wait -Tail 0 | ForEach-Object {
        $logEntry = $_
        
        if ($logEntry -notmatch '^#') {
            # Extract source IP using regex
            if ($logEntry -match $ipRegex) {
                $sourceIP = $matches['SourceIP']
                $urlPart = ($logEntry -split '\s+')[4..5] -join ' '
                $decodedURL = ConvertFrom-UrlEncodedString($urlPart)
                
                # Check for SQLi patterns
                foreach ($pattern in $sqliPatterns) {
                    if ($decodedURL -match $pattern) {
                        Invoke-Alert -sourceIP $sourceIP -payload $decodedURL
                        break
                    }
                }
            }
        }
    }
}
catch {
    Write-Host "Monitoring error: $_" -ForegroundColor Red
    exit 1
}

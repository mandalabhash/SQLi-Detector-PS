# InputModule.ps1

function Get-LogFiles {
    param (
        [string]$LogDirectory,
        [int]$TimeRangeMinutes
    )
    $endTime = Get-Date
    $startTime = $endTime.AddMinutes(-$TimeRangeMinutes)

    return Get-ChildItem -Path $LogDirectory -Recurse -Include *.log | Where-Object {
        $_.LastWriteTime -ge $startTime -and $_.LastWriteTime -le $endTime
    }
}

function Test-LogFiles {
    param (
        [string]$LogFile
    )
    if (-Not (Test-Path $LogFile)) {
        throw "Log file not found: $LogFile"
    }
}

function Read-LogFiles {
    param (
        [string]$LogFile
    )
    return Get-Content -Path $LogFile
}
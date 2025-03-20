function Export-CSVReport {
    param (
        [array]$Results
    )
    return $Results | Select-Object LogEntry, Status | ConvertTo-Csv -NoTypeInformation
}

function Save-CSVReport {
    param (
        [string]$Report,
        [string]$OutputDirectory
    )
    $outputFile = Join-Path -Path $OutputDirectory -ChildPath "sqli_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $Report | Out-File -FilePath $outputFile
    Write-Host "Report saved to: $outputFile"
}

function Invoke-Alert {
    param (
        [string]$Message
    )
    Write-Host "ALERT: $Message" -ForegroundColor Red
}
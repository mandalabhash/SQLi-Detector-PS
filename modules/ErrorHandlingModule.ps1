function Export-Error {
    param (
        [string]$ErrorMessage
    )
    $errorLogFile = Join-Path -Path $PSScriptRoot -ChildPath "error_log.txt"
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $ErrorMessage" | Out-File -FilePath $errorLogFile -Append
}

function Start-HandleException {
    param (
        [string]$ErrorMessage
    )
    Write-Host "ERROR: $ErrorMessage" -ForegroundColor Red
    Log-Error -ErrorMessage $ErrorMessage
}
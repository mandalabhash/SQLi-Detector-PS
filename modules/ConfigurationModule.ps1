# ConfigurationModule.ps1

function Import-Config {
    param (
        [string]$ConfigFile
    )
    return Get-Content -Path $ConfigFile | ConvertFrom-Json
}

function Set-Config {
    param (
        [string]$ConfigFile,
        [hashtable]$Settings
    )
    $Settings | ConvertTo-Json | Out-File -FilePath $ConfigFile
}

function Save-Config {
    param (
        [string]$ConfigFile,
        [hashtable]$Settings
    )
    $Settings | ConvertTo-Json | Out-File -FilePath $ConfigFile
}
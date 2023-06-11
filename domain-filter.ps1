$domain = $args[0]
# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    write-host "This script requires administrative privileges."
    write-host "running new terminal as Administrative."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" `"$domain`" " -Verb RunAs
    EXIT
}

function Get-DomainFromURL {
    param ([Parameter(Mandatory = $true, Position = 0)][string]$URL)
    try{
        $uri = New-Object System.Uri($URL)
        $domain = $uri.Host
        return $domain
    }catch{
        return $domain
    }
}


function Get-Usage{
    write-host "Usage: powershell domain-filter.ps1  <domain or url>:<block or unblock>"
    write-host ""
    write-host " --inside of terminal powershell"
    write-host "    domain-filter.ps1 example.com:block"
    write-host ""
    write-host " --on cmd"
    write-host "    powershell .\domain-filter.ps1 example.com:unblock"
}

$hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"
$content = Get-Content -Path $hostsFilePath -Raw

function blockHost{
    param($dom)
    $match = select-string -path $hostsFilePath -pattern "0.0.0.0`t$dom"
    if($match){
        Write-Host "Domain '$dom' is already blocked."
    }else{
        Add-Content -Path $hostsFilePath -Value "`n0.0.0.0`t$dom"
        Write-Host "Domain '$dom' blocked successfully."
    }
}

function unblockHost{
    param($dom)
    $match = select-string -path $hostsFilePath -pattern "0.0.0.0`t$dom"
    
    if($match){
        $content = $content -replace "`n0.0.0.0`t$dom",""
        Set-Content -Path $hostsFilePath -value $content
        Write-Host "Domain '$dom' unblocked successfully."
    }else{
        Write-Host "Domain '$dom' is already unblocked."
    }
}

try{
    $arg = $domain.split(":")
    $domain = Get-DomainFromURL -url $domain
    if($arg[$arg.length-1] -eq "block"){
        blockHost($domain)
        ipconfig /flushdns
    }elseif ($arg[$arg.length-1] -eq "unblock") {
        unblockHost($domain)
        ipconfig /flushdns
    }else{
        Get-Usage
        exit
    }
}catch{
    Get-Usage
    exit
}

cmd /c pause


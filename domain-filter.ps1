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
        $domain = $domain -replace '^[^.]+\.',''
        return $domain
    }catch{
        return $domain
    }
}

function Get-Usage{
    write-host "Usage: powershell domain-filter.ps1  <domain or url>:<block or unblock>"
    write-host ""
    write-host " --inside of terminal powershell"
    write-host " domain-filter.ps1 example.com:block"
    write-host ""
    write-host " --on cmd"
    write-host " powershell c:\domain-filter.ps1 example.com:unblock"
    write-host ""
    write-host " --when url use double quoit `"`""
}

$hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"
$content = Get-Content -Path $hostsFilePath -Raw

function blockHost{
    param($dom)
    $match = select-string -path $hostsFilePath -pattern "0.0.0.0`t$dom"
    if($match){
        Write-Host "Domain '$dom' is already blocked."
    }else{
        Add-Content -Path $hostsFilePath -Value "0.0.0.0`t$dom"
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

$args = $domain.split(":")
$domain = Get-DomainFromURL -url $args[0]
if($args.length -eq 2){
    if($args[1] -eq "block"){
        blockHost($args[0])
    }elseif ($args[1] -eq "unblock") {
        unblockHost($args[0])
    }else{
        Get-Usage
        EXIT
    }
}elseif($args.length -eq 1){

}else{
    Get-Usage
    EXIT
}



ipconfig /flushdns
cmd /c pause


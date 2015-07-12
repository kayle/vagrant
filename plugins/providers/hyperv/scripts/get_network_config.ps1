Param(
    [Parameter(Mandatory=$true)]
    [string]$VmId
 )

# Include the following modules
$Dir = Split-Path $script:MyInvocation.MyCommand.Path
. ([System.IO.Path]::Combine($Dir, "utils\write_messages.ps1"))

$remote_config = (Get-Content -Raw -Path $env:VAGRANT_HYPERV_REMOTE_CONFIG) | ConvertFrom-Json 
$securePassword = $remote_config.user | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($remote_config.user, $securePassword)
$session = New-PSSession -ComputerName  $remote_config.hostname -Credential $cred

$network = Invoke-Command -Session $session -ScriptBlock  ([scriptblock]::Create(" Get-VM -Id $VmId | Get-VMNetworkAdapter ")) -ErrorAction "stop"
write-host $network
$ip_address = $network.IpAddresses[0]
$resultHash = @{
    ip = "$ip_address"
}
$result = ConvertTo-Json $resultHash
Write-Output-Message $result

Remove-PSSession $session
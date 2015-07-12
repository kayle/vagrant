Param(
    [Parameter(Mandatory=$true)]
    [string]$VmId
)

$remote_config = (Get-Content -Raw -Path $env:VAGRANT_HYPERV_REMOTE_CONFIG) | ConvertFrom-Json 
$securePassword = $remote_config.user | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($remote_config.user, $securePassword)
$session = New-PSSession -ComputerName  $remote_config.hostname -Credential $cred

Invoke-Command -Session $session -ScriptBlock  ([scriptblock]::Create(" Get-VM -Id $VmId | Suspend-VM ")) -ErrorAction "stop"

Remove-PSSession $session
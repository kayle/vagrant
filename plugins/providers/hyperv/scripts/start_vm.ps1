param (
    [string]$VmId = $(throw "-VmId is required.")
 )

# Include the following modules
$Dir = Split-Path $script:MyInvocation.MyCommand.Path
. ([System.IO.Path]::Combine($Dir, "utils\write_messages.ps1"))

$remote_config = (Get-Content -Raw -Path $env:VAGRANT_HYPERV_REMOTE_CONFIG) | ConvertFrom-Json 
$securePassword = $remote_config.user | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($remote_config.user, $securePassword)
$session = New-PSSession -ComputerName  $remote_config.hostname -Credential $cred

try {
  $vm = Invoke-Command -Session $session -ScriptBlock  ([scriptblock]::Create(" Get-VM -Id $VmId | Start-VM -Passthru ")) -ErrorAction "stop"
  $state = $vm.state
  $status = $vm.status
  $name = $vm.name
  $resultHash = @{
    state = "$state"
    status = "$status"
    name = "$name"
  }
  $result = ConvertTo-Json $resultHash
  Write-Output-Message $result
}
catch {
  Write-Error-Message "Failed to start a VM $_"
}


Remove-PSSession $session
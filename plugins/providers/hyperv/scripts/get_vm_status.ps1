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

# Get the VM with the given name
function Get-Status (    [Parameter(Mandatory=$true)]    [string]$VmId) {
    try {
        $VM = Get-VM -Id $VmId -ErrorAction "Stop"
        $State = $VM.state
        $Status = $VM.status
    } catch [Microsoft.HyperV.PowerShell.VirtualizationOperationFailedException] {
        $State = "not_created"
        $Status = $State
    }

    $resultHash = @{
        state = "$State"
        status = "$Status"
    }
    $result = ConvertTo-Json $resultHash
    return $result
}

$result =  Invoke-Command -Session $session -ScriptBlock  ${function:Get-Status} -ArgumentList $VmId

Write-Output-Message $result

Remove-PSSession $session

#try {
#    $vm = Invoke-Command -Session $session -ScriptBlock  ([scriptblock]::Create(" Get-VM -Id $VmId ")) -ErrorAction "stop"
# 
#    #$VM = Get-VM -Id $VmId -ErrorAction "Stop"
#    $State = $VM.state
#    $Status = $VM.status
#} catch [Microsoft.HyperV.PowerShell.VirtualizationOperationFailedException] {
#    $State = "not_created"
#    $Status = $State
#}
#
#$resultHash = @{
#    state = "$State"
#    status = "$Status"
#}
#$result = ConvertTo-Json $resultHash

# This will have a SwitchType property. As far as I know the values are:
#
#   0 - Private
#   1 - Internal
#
# Include the following modules
$Dir = Split-Path $script:MyInvocation.MyCommand.Path
. ([System.IO.Path]::Combine($Dir, "utils\write_messages.ps1"))

$remote_config = (Get-Content -Raw -Path $env:VAGRANT_HYPERV_REMOTE_CONFIG) | ConvertFrom-Json 

$securePassword = $remote_config.user | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($remote_config.user, $securePassword)

#$remote = New-PSSession -ComputerName  $remote_config.hostname -Credential $cred

#Invoke-Command -Session $remote -FilePath  $scriptPath
#Remove-PSSession $remote
   
$command = { Get-VMSwitch | Select-Object Name,SwitchType,NetAdapterInterfaceDescription }

$Switches = Invoke-Command -ScriptBlock $command -ComputerName $remote_config.hostname -Credential $cred
Write-Output-Message $(ConvertTo-JSON @($Switches))

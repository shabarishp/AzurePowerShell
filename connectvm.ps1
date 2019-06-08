Param(
[parameter(mandatory=$true)]$WorkspaceName,
[parameter(mandatory=$true)]$VM,
[parameter(mandatory=$true)]$VM1
)
#Checking Azure connection..
Import-Module AzureRM
If (-not (Get-Module AzureRM)) {Write-Host;Write-Host -ForegroundColor Yellow "AzureRM module wasn’t found on the current server, the installation will start (wait for the completion, some confirmation will be required)"; Install-Module AzureRM}
if (Get-AzureRMContext) {write-host;write-host "You are connect to the following Microsoft Azure subscription: " (Get-AzureRmContext).SubscriptionName} Else { Write-host -ForegroundColor Yellow "You are not connected, please connect."; Connect-AzureRmAccount}
#Parameter validation...
If (-not $VM) {Write-Host -ForegroundColor Yellow "You must specific a VM in the -VM parameter"; return}
If (-not $WorkspaceName) {Write-Host -ForegroundColor Yellow "You must specific a Workspace in the -VM parameter"; return}
#Parameter data validation...
$vVM = Get-AzureRmResource -Name $VM -ErrorAction:SilentlyContinue
Write-Host "The Azure vm resource name is $vVM";
$vVM1 = Get-AzureRmResource -Name $VM1 -ErrorAction:SilentlyContinue
Write-Host "The Azure vm1 resource name is $vVM1";
If (-not $vVM) {Write-Host -ForegroundColor Yellow "The " $VM " wasn’t found in the current subscription."; return}
$vWorkspace = Get-AzureRmResource -Name $WorkspaceName
Write-Host "The Azure workspace resource name is $vworkspace";
If (-not $WorkspaceName) {Write-Host -ForegroundColor Yellow "Workspace " $WorkspaceName " wasn’t found in the current subscription."; return}
$vWorkSpace = Get-AzureRmOperationalInsightsWorkspace -Name $vWorkspace.Name -ResourceGroupName $vWorkspace.ResourceGroupName
Write-Host "The workspace usage is $vWorkSpace";
$vWorkspaceID = $vWorkspace.CustomerID
Write-Host "The workspace ID is $vWorkspaceID"
$vworkspaceKey = (Get-AzureRmOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $vworkspace.ResourceGroupName -Name $vworkspace.Name).PrimarySharedKey
Write-Host "The workspacekey is $vworkspaceKey"
Set-AzureRmVMExtension -ResourceGroupName $vVM.ResourceGroupName -VMName $vVM.Name -Name 'MicrosoftMonitoringAgent' -Publisher 'Microsoft.EnterpriseCloud.Monitoring' -ExtensionType 'MicrosoftMonitoringAgent' -TypeHandlerVersion '1.0' -Location $vVM.Location -SettingString "{'workspaceId': '$vWorkspaceID'}" -ProtectedSettingString "{'workspaceKey': '$vworkspaceKey'}"
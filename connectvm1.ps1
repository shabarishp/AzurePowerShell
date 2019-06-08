Param(
[parameter(mandatory=$true)]$WorkspaceName,
[Parameter(Mandatory=$True)]
 [string]
 $subscriptionId
)
# sign in
Write-Host "Logging in...";
Login-AzureRmAccount

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

$vWorkspace = Get-AzureRmResource -Name $WorkspaceName;
$vWorkSpace = Get-AzureRmOperationalInsightsWorkspace -Name $vWorkspace.Name -ResourceGroupName $vWorkspace.ResourceGroupName
$vWorkspaceID = $vWorkspace.CustomerID;
$vworkspaceKey = (Get-AzureRmOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $vworkspace.ResourceGroupName -Name $vworkspace.Name).PrimarySharedKey

$vms = Get-content -Path "C:\Azure-Sample-Scripts\vm.txt"
foreach($instancename in $vms) {
    Write-Host "The instance name is $instancename"
    $vVM = Get-AzureRmResource -Name $instancename -ErrorAction:SilentlyContinue;
    Write-Host "The resource name is $vVM"
    Set-AzureRmVMExtension -ResourceGroupName $vVM.ResourceGroupName -VMName $vVM.Name -Name 'MicrosoftMonitoringAgent' -Publisher 'Microsoft.EnterpriseCloud.Monitoring' -ExtensionType 'MicrosoftMonitoringAgent' -TypeHandlerVersion '1.0' -Location $vVM.Location -SettingString "{'workspaceId': '$vWorkspaceID'}" -ProtectedSettingString "{'workspaceKey': '$vworkspaceKey'}"
    Write-Host "The instance $instancename is connected to the workspace $WorkspaceName"
}
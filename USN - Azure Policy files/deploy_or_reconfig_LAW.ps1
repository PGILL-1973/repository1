Connect-AzAccount -environment azureusgovernment

Enable-AzureRmAlias

#https://www.powershellgallery.com/packages/Install-VMInsights/1.9
Install-Script -Name Install-VMInsights

#statically defined right now, but will want to provide some automation. Change these to your given environment
$WkspID = 9604b058-f89b-4650-b0f1-154a114ce67d 
$WkspKey = HyHKT4EtP58TkzujsKquE5j59KOatjIYlRoGgYAa8L/00+hEOAbD0+tKORbnRgId0M/f5ZbM8eDdydJzRlqedw== 
$SubId = a9a0d5d8-f407-4e89-8a61-ebba2c3837ae
#$Rsg = #optional

#run the script as follows - note the path installed may differ
#USE OF -REINSTALL SCRIPT FOR EXISTING 
.\Install-VMInsights.ps1 -WorkspaceRegion usgovvirginia -WorkspaceId $WkspID -WorkspaceKey $WkspKey -SubscriptionId $SubId -ReInstall

#note - once this cmdlet runs, you will NOT be given the cursor back until the VMs connect. 
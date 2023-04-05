if( Get-Module -ListAvailable -Name "Az.Accounts" ) { Out-Null } else { Install-Module -name "Az.Accounts" -Scope CurrentUser } #installs Az.Accounts module if not present

Connect-AzAccount | Out-Null  #connecting to Azure - use login that has access to your Azure Analysis Services
$token = (Get-AzAccessToken -ResourceUrl "https://*.asazure.windows.net").Token  #gererating token with access to AAS
$header = @{authorization = "Bearer $token"}   #creating an API header

$Region = "northeurope" 
$ServerName = "MyServerName" 
$ModelName = "MyModelName"

$AASurl = "https://$Region.asazure.windows.net/servers/$ServerName/models/$ModelName" #creating basic URL for API

$refreshes = Invoke-RestMethod -Uri "$AASurl/refreshes" -Headers $header #generating a list of refreshes

$RefreshInProgress = $refreshes | where { $_.status -eq "inProgress" } #looks for the refresh that's in progress
$refreshid = $RefreshInProgress.refreshID

$faultyrefresh = Invoke-RestMethod -Uri "$AASurl/refreshes/$refreshid" -Headers $header

Invoke-RestMethod -Uri "$AASurl/refreshes/$refreshid" -Headers $header -Method Delete #Sends a DELETE method to stop the refresh
sleep -Seconds 5

"Refresh of those tables and partitions has been cancelled:"
$faultyrefresh.objects

pause

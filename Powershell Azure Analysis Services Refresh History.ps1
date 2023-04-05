#Set-ExecutionPolicy RemoteSigned  #You need to run this if your PC won't let you run PowerShell scripts
if( Get-Module -ListAvailable -Name "Az.Accounts" ) { Out-Null } else { Install-Module -name "Az.Accounts" -Scope CurrentUser } #installs Az.Accounts module if not present

Connect-AzAccount | Out-Null  #connecting to Azure - use login that has access to your Azure Analysis Services
$token = (Get-AzAccessToken -ResourceUrl "https://*.asazure.windows.net").Token  #gererating token with access to AAS
$header = @{authorization = "Bearer $token"}   #creating an API header

#if your AAS addess is asazure://northeurope.asazure.windows.net/ABCServ then Region is northeurope and servername is ABCServ
$Region = "northeurope"
$ServerName = "ServerName"
$ModelName = "ModelName"

$AASurl = "https://$Region.asazure.windows.net/servers/$ServerName/models/$ModelName" #creating basic URL for API

$refreshes = Invoke-RestMethod -Uri "$AASurl/refreshes" -Headers $header #generating a list of refreshes

$failedlist = $refreshes | where {(Get-Date $_.startTime) -ge (Get-Date).AddDays(-1) -AND $_.status -ne "succeeded" } | sort startTime #filters last 24hours and not successful refreshes

#running an API and getting details for each refresh that was not successful
$ListofDetails = foreach ($i in $failedlist) {
    $refreshid = $i.refreshID
    Invoke-RestMethod -Uri "$AASurl/refreshes/$refreshid" -Headers $header
    }

$ListofDetails | Out-File $env:TEMP/log.txt -Encoding ascii  #saving output to a log file in your temp folder

start notepad++ $env:TEMP/log.txt  #opening a log file in notepad++. If you don't have notepad++ you can change it to "notepad".

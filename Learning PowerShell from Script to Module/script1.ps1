Write-Host "This is script 1"
$scriptPath = 'C:\PowerShell\workshop\script2.ps1'
. $scriptPath
#& $scriptPath
#Invoke-Expression -Command "& '$scriptPath'"
#Start-Process powershell -ArgumentList "-noexit -command ""& '$scriptPath'"""


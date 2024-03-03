[CmdletBinding()]
param (

)

#---------------------------------------------------------
# Importing functions and variables.
#---------------------------------------------------------

# import global config, all functions. Exit if fails.
try {
  Import-Module -Name ".\global.psm1"
  Get-ChildItem -Path ".\functions" -Include "*.psm1" -Recurse | Import-Module
}
catch {
  Exit-WithError -ErrorMsg "Unable to import modules."
  Exit
}

#---------------------------------------------------------
# Start Logging
#---------------------------------------------------------

#Define Logfile by TimeStamp-ServerCfg.
$LogFile = "$($Global.LogFolder)\$(Get-TimeStamp)-Monitor.txt"
# Start Logging
Start-Transcript -Path $LogFile -IncludeInvocationHeader
if($Global.Debug) {
  [Console]::ForegroundColor = $Global.ErrorColor
  [Console]::BackgroundColor = $Global.ErrorBgColor
  Write-Host "DEBUG MODE ENABLED"
  [Console]::ResetColor()
}
$NoLogs = $false

#---------------------------------------------------------
# Set Script Directory as Working Directory
#---------------------------------------------------------

#Find the location of the current invocation of main.ps1, remove the filename, set the working directory to that path.
Write-ScriptMsg "Setting Script Directory as Working Directory..."
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path -Path $scriptpath
$dir = Resolve-Path -Path $dir
$null = Set-Location -Path $dir
Write-ScriptMsg "Working Directory : $(Get-Location)"

#---------------------------------------------------------
# Start Monitor
#---------------------------------------------------------

Write-Host -Object "Start Monitor"

class ServerStatus {

  [string]$Name

  [int]$PID

  [bool]$Status

  [string]$StartTime

  [string]$UpTime

  [string]$NextRestart

}

while(true){

  $ServerList = New-Object Collections.Generic.List[ServerStatus]

  foreach ($Entry in (Get-ChildItem -Path ".\configs" -Include "*.psm1" -Recurse)) {
    $ServerList.Add((Get-ServerInfo $Entry.Basename))
  }

  Write-ServerList $ServerList

  Start-Sleep (60 * 5)
}
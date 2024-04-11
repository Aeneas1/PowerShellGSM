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

#---------------------------------------------------------
# Start Monitoring
#---------------------------------------------------------

class ServerStatus {

  [string]$Name

  [int]$PID

  [bool]$Status

  [string]$StartTime

  [string]$UpTime

  [string]$NextRestart

}

$timeSinceCheck = 9999999999

while($true){

  $ServerList = New-Object Collections.Generic.List[ServerStatus]

  foreach ($Entry in (Get-ChildItem -Path ".\configs" -Include "*.psm1" -Recurse)) {
    $ServerList.Add((Get-ServerInfo $Entry.Basename))
  }

  Write-ServerList $ServerList

  Start-Sleep ($Global.RefreshTime)
  $timeSinceCheck = $timeSinceCheck + $Global.RefreshTime

  if (($Global.TaskCheckFrequency * 60) -lt $timeSinceCheck) {
    foreach ($Entry in (Get-ChildItem -Path ".\configs" -Include "*.psm1" -Recurse)) {

      #Check if script is already running
      if (Get-Lock $Entry.Basename) {
        Break
      }

      Lock-Process $Entry.Basename

      $Server = New-Object -TypeName PsObject -Property @{Name = $Entry.Basename }
      Write-ScriptMsg "Check : $($Entry.Basename)"
      $TasksSchedule = (Get-TaskConfig $Entry.Basename)

      if ($Server.AutoRestartOnCrash) {
        if (($TasksSchedule.NextAlive) -le (Get-Date)) {
          Write-ScriptMsg "Checking Alive State"
          if (-not (Get-ServerProcess)) {
            Write-ScriptMsg "Server is Dead, Restarting..."
            Start-Server
            #$FullRunRequired = $true
          }
          else {
            Write-ScriptMsg "Server is Alive"
          }
          Update-TaskConfig -Alive
        }
        else {
          Write-ScriptMsg "Too soon for Alive check"
        }
      }
      else {
        Write-ScriptMsg "Alive check is disabled"
      }
    }

    $timeSinceCheck = 0
  }
}
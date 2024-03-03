function Get-ServerInfo {

  [CmdletBinding()]
  [OutputType([ServerStatus])]
  param (
    [Parameter(Mandatory)]
    [string]$ServerName
  )

  $ServerInfo = [ServerStatus]::new()

  $Server = New-Object -TypeName PsObject -Property @{Name = $ServerName }

  $ServerInfo.Name = $Server.Name
  $ServerInfo.PID = Get-PID $Server.Name
  $ServerInfo.Status = ($null -ne $ServerInfo.PID)
  $ServerInfo.NextRestart = (Get-TaskConfig).NextRestart

  $ServerProcess = Get-Process -ID $ServerInfo.PID -ErrorAction SilentlyContinue
  $ServerInfo.Status = ($null -ne $ServerProcess)
  if ($ServerInfo.Status) {
    $ServerInfo.StartTime = $ServerProcess.StartTime
    $ServerInfo.UpTime = (New-TimeSpan -Start $ServerProcess.StartTime -End (Get-Date)).ToString("dd'd 'hh'h 'mm'm 'ss's'")
  }

  return $ServerInfo

}

Export-ModuleMember -Function Get-ServerInfo
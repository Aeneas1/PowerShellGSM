function Lock-Process {
  [CmdletBinding()]
  [OutputType([boolean])]
  param (
    [string]$ServerName
  )
  try {
    $null = New-Item -Path ".\servers\" -Name "$($ServerName).LOCK" -ItemType "file" -Force -ErrorAction SilentlyContinue
    Set-IniValue -file ".\servers\$($ServerName).LOCK" -category "Lock" -key "TimeStamp" -value ((Get-Date).ToString($Global.DateTimeFormat))
    Write-ScriptMsg "Locking Process."
  }
  catch {
    return $false
  }
  return $true
}
Export-ModuleMember -Function Lock-Process
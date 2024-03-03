function Get-PID {
  [CmdletBinding()]
  [OutputType([Int])]
  param (
    [string]$ServerName
  )

  try {
    #Read the process ID from the PID file named by the UID defined in the server cfg file.
    $ServerPID = Get-Content -Path ".\servers\$($ServerName).PID" -ErrorAction SilentlyContinue
  }
  catch {
    return $null
  }
  return $ServerPID
}
Export-ModuleMember -Function Get-PID
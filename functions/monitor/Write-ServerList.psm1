function Write-ServerList {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [Collections.Generic.List[ServerStatus]]$ServerList
  )

  $ServerList | Sort-Object -Property Status -Descending | Format-Table Name, @{
    Label = "Status";
    Expression = {
      if ($_.Status) {
        $color = "32" # Green
      }
      else {
        $color = "31" # Red
      }
      $e = [char]27
      "$e[${color}m$($_.Status) $e[0m"
    };
  },
  StartTime, UpTime, NextRestart

}

Export-ModuleMember -Function Write-ServerList
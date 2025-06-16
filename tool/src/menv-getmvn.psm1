function Invoke-GetMVN {
    param (
        [Parameter(Mandatory = $true)][object]$config
    )

    $global = $config.global

    # Use command overwrites everything
  if ($global) {
        Write-Output $global
    }
    # No JEnv set
    else {
        # ATTENTION: Parantheses in statement will break the batch
        Write-Output 'No global maven version found. Use menv change to set one'
    }
}
function Invoke-MavenRemove {
    param (
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][bool]$help,
        [Parameter(Mandatory = $true)][string]$name
    )

    if ($help) {
        Write-Host '"mvenv remove <name>"'
        Write-Host 'Removes the Maven version you registered with "mvenv add <name> <path>"'
        return
    }

    # Find target Maven by name
    $target = $config.menv | Where-Object { $_.name -eq $name }
    if (-not $target) {
        Write-Host "No Maven registered with name '$name'."
        return
    }

    # Remove from menv list
    $config.menv = @($config.menv | Where-Object { $_.name -ne $name })

    # If global points to the removed one
    if ($config.global -eq $target.path) {
        $config.global = $null

        # Remove MAVEN_HOME
        [System.Environment]::SetEnvironmentVariable("MAVEN_HOME", $null, "User")

        # Remove old Maven bin from system Path
        try {
            $oldBin = Join-Path $target.path "bin"
            $sysPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
            $newPath = ($sysPath -split ';' | Where-Object { $_ -ne $oldBin -and $_ -ne "" }) -join ';'
            [System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
            Write-Host "Removed MAVEN_HOME and Maven bin path from system PATH."
        }
        catch {
            Write-Warning "Could not modify system PATH. Try running PowerShell as Administrator."
        }
    }

    Write-Host "Maven version '$name' removed successfully."
}

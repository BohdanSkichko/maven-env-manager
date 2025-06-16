function Invoke-MavenChange {
    param(
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][bool]$help,
        [Parameter(Mandatory = $true)][bool]$output,
        [Parameter(Mandatory = $true)][string]$name
    )

    if ($help) {
        Write-Host '"menv change <name>"'
        Write-Host 'Sets MAVEN_HOME and updates system PATH (Machine scope) with selected Maven version.'
        Write-Host '<name> is the alias you assigned via "mvenv add <name> <path>"'
        return
    }

    $maven = $config.menv | Where-Object { $_.name -eq $name }
    if ($null -eq $maven) {
        Write-Host "No Maven version found with name '$name'. Try: mvenv list"
        return
    }

    $newMavenBin = Join-Path $maven.path "bin"
    if (!(Test-Path "$newMavenBin\mvn.cmd")) {
        Write-Host "Maven bin not found at $newMavenBin"
        return
    }

    # Clean up old Maven bin paths from system PATH
    $sysPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $pathEntries = $sysPath -split ';'

    # Remove all entries that look like Apache Maven bins
    $filteredPathEntries = $pathEntries | Where-Object {
        $_ -and ($_ -notmatch '(?i)apache-maven.*\\bin')
    }


    # Prepend new Maven bin path
    $newPathEntries = @($newMavenBin) + $filteredPathEntries
    $newSysPath = ($newPathEntries | Where-Object { $_ -ne "" }) -join ';'
    [System.Environment]::SetEnvironmentVariable("Path", $newSysPath, "User")
    # Set MAVEN_HOME system-wide and for current user
    [System.Environment]::SetEnvironmentVariable("MAVEN_HOME", $maven.path, "User")

         if ($output) {
                Set-Content -path "menv.home.tmp" -value $maven.path # Create temp file so no restart of the active shell is required
                Set-Content -path "menv.path.tmp" -value $newSysPath # Create temp file so no restart of the active shell is required
            }

    $config.global = $maven.path
    $Env:MAVEN_HOME = $maven.path # Set for powershell users
    # Also update the current PowerShell session (does not affect already-running cmd.exe)
    $Env:MAVEN_HOME = $maven.path
    $Env:PATH = "$newMavenBin;" + ($Env:PATH -split ';' | Where-Object { $_ -notmatch '(?i)apache-maven.*\\bin' }) -join ';'

    Write-Host "MAVEN_HOME = $Env:MAVEN_HOME"
    Write-Host "PATH includes: $newMavenBin"
    Write-Host ""
}

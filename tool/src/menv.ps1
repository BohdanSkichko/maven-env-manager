param (
    [string]$command,
    [string]$arg1,
    [string]$arg2
)

$userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)
$systemPath = [System.Environment]::GetEnvironmentVariable("PATH", "MACHINE").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)

Import-Module $PSScriptRoot\menv-add.psm1 -Force
Import-Module $PSScriptRoot\menv-change.psm1 -Force
Import-Module $PSScriptRoot\menv-remove.psm1 -Force
Import-Module $PSScriptRoot\menv-getmvn.psm1 -Force

$mvnPaths = (Get-Command java -All).source
$root = (get-item $PSScriptRoot).parent.fullname
$dummyScript = ("{0}\mvn.bat" -f $root)
if ($mvnPaths.IndexOf($dummyScript) -eq -1) {
    $wrongJavaPaths = $mvnPaths
}
else {
    $wrongJavaPaths = ($mvnPaths | Select-Object -SkipLast ($mvnPaths.Length - $mvnPaths.IndexOf($dummyScript)))
}



$global:MEnvConfigPath = "$PSScriptRoot\..\menv.json"

$path = ($systemPath + $userPath) -join ";"

$Env:PATH = $path # Set for powershell users
if ($output) {
    Set-Content -path "menv.path.tmp" -value $path # Create temp file so no restart of the active shell is required

}

function Get-MEnvConfig {
    if (!(Test-Path $MEnvConfigPath)) {
        return @{ menv = @() }
    }
    return Get-Content $MEnvConfigPath | ConvertFrom-Json
}

function Save-MEnvConfig($config) {
    $config | ConvertTo-Json -Depth 3 | Set-Content $MEnvConfigPath
}

function mvenv {
    param (
        [string]$command,
        [string]$arg1,
        [string]$arg2
    )

    $config = Get-MEnvConfig

    switch ($command) {
        'add' {
            Invoke-MavenAdd -config $config -help:$false -name $arg1 -path $arg2
            Save-MEnvConfig $config
        }

        'list' {
            if ($config.menv.Count -eq 0) {
                Write-Host "No Maven versions registered."
            } else {
                Write-Host " Registered Maven versions:"
                foreach ($m in $config.menv) {
                    Write-Host " - $($m.name) => $($m.path)"
                }
            }
        }

          'remove' {
                Invoke-MavenRemove -config $config -help:$false -name $arg1
                Save-MEnvConfig $config
            }

          'change' {
              Invoke-MavenChange -config $config -help:$false -output:$true -name $arg1
              Save-MEnvConfig $config
          }

          'getmvn' {
             Invoke-GetMVN -config $config

          }

        'help' {
            Write-Host "Maven Environment Manager (menv)"
            Write-Host "Usage:"
            Write-Host "  menv add <name> <path>     # Register a Maven version"
            Write-Host "  menv list                  # List registered versions"
            Write-Host "  menv change <name>             # Switch to a version"
            Write-Host "  menv remove <name>          # Remove from list"
        }
    }
}

# Run command
mvenv $command $arg1 $arg2

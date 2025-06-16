function Invoke-MavenAdd {
    param (
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][string]$name,
        [Parameter(Mandatory = $true)][string]$path
    )

     if ($help) {
        Write-Host '"menv add" <name> <path>'
        Write-Host 'Register a Maven version. Example: menv add 3.8.8 "D:\Tools\Maven\3.8.8"'
        return
    }


    foreach ($maven in $config.menv) {
        if ($maven.name -eq $name) {
            Write-Output "A Maven with the name '$name' already exists. Use another name."
            return
        }
    }

    if (!(Test-Path "$path\bin\mvn.cmd")) {
        Write-Output "$path\bin\mvn.cmd not found. This is not a valid Maven installation."
        return
    }

    $config.menv += [PSCustomObject]@{
        name = $name
        path = $path
    }

    Write-Output " Successfully added Maven version '$name'"
}
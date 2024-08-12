param([string]$Mode="Run")

$PROJECT = "bevy_template"
$EXECUTABLE = "{0}.exe" -f $PROJECT
$ASSETS = "assets"

Write-Output "Preparing..."
$Date = Get-Date -Format "yy-dd-MM-HH-mm"
$Name = $PROJECT
$NameZip = "{0}-(build-{1})-win64" -f ($PROJECT, $Date)
$Root = Split-Path -Parent $PSScriptRoot
$Build = Join-Path -Path $Root -ChildPath "build"
$Target = Join-Path -Path $Root -ChildPath "target"
$Output = Join-Path -Path $Build -ChildPath $Name

if ($Mode -eq "Clean")
{
    Write-Output "Clean..."
    if (Test-Path -Path $Output)
    {
        Remove-Item -Recurse -Force -Path $Output
    }
    return
}

Write-Output "Building..."
if ($Mode -eq "Package")
{
    cargo build --release --features no_console
}
else
{
    cargo build --release
}
$BuildExecutable = Join-Path -Path (Join-Path -Path $Target -ChildPath "release") -ChildPath $EXECUTABLE

Write-Output "Copying Files..."
if (Test-Path -Path $Build)
{
    Remove-Item -Recurse -Force -Path $Build
}
New-Item -Path $Output -ItemType Directory
Copy-Item -Path $BuildExecutable -Destination $Output
Copy-Item -Path (Join-Path -Path $Root -ChildPath $ASSETS) -Destination $Output -Recurse -Force

if ($Mode -eq "Package")
{
    Write-Output "Zipping..."
    Compress-Archive -Path $Output -DestinationPath (Join-Path -Path $Build -ChildPath $NameZip)
    Write-Output "Done"
}

if ($Mode -eq "Run")
{
    $BuildExecutable = Join-Path -Path $Output -ChildPath $EXECUTABLE
    & $BuildExecutable
}


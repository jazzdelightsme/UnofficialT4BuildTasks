
$nugetExe = 'NuGet.exe'
if( !(Get-Command $nugetExe -ErrorAction Ignore) )
{
    throw "This script requires NuGet.exe to be available."
}

pushd "$PSScriptRoot"

if( !(Test-Path "$PSScriptRoot\output") )
{
    $null = New-Item "$PSScriptRoot\output" -itemType Directory
}

& $nugetExe pack -BasePath "$PSScriptRoot\Package" -OutputDirectory "$PSScriptRoot\output" -MinClientVersion 2.8
popd


# Install Raku++ into .rakupp\ beside this script. Does not change the user PATH.
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$dir = Join-Path $here '.rakupp'

& ([scriptblock]::Create((irm https://raw.githubusercontent.com/ash/rakupp/main/tools/install-windows.ps1))) `
    -Dir $dir -NoPath -NoRakuAlias -Yes
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installation failed. rakupp was not installed into $dir." -ForegroundColor Red
    exit 1
}

$exe = Join-Path $dir 'bin\rakupp.exe'
$answer = ''
if (Test-Path -LiteralPath $exe) {
    $answer = (& $exe -e 'say 6 * 7' 2>&1 | Out-String).Trim()
}
if ($LASTEXITCODE -ne 0 -or $answer -ne '42') {
    Write-Host "Installation failed. $exe did not answer 42 (got: $answer)." -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host 'Installation succeeded.' -ForegroundColor Green
Write-Host "rakupp is at $exe"
Write-Host 'Run the project with:'
Write-Host '  .\.rakupp\bin\rakupp.exe .\main.raku'






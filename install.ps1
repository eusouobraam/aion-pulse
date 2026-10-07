$ErrorActionPreference = 'Stop'
$pulseAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$pulseWork = Join-Path $env:TEMP 'AionPulse-Install-2.0.55'
New-Item -ItemType Directory -Path $pulseWork -Force | Out-Null
if (-not $pulseAdmin) {
    $pulseScript = Join-Path $pulseWork 'install.ps1'
    Invoke-WebRequest 'https://raw.githubusercontent.com/eusouobraam/aion-pulse/main/install.ps1' -OutFile $pulseScript -UseBasicParsing
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$pulseScript`"" -Wait
    return
}
$pulsePackage = Join-Path $pulseWork 'Aion-Pulse-2.0.55-x64.msi'
Write-Host 'Baixando Aion Pulse...'
Invoke-WebRequest 'https://github.com/eusouobraam/aion-pulse/releases/download/v2.0.55/Aion-Pulse-2.0.55-x64.msi' -OutFile $pulsePackage -UseBasicParsing
if ((Get-FileHash $pulsePackage -Algorithm SHA256).Hash -ne '66E3EBFEA9EF756F615BCF96D71B103D8AA9A24C96D837C1E1ABC7C6FA7370FE') { throw 'A verificacao do MSI falhou. Instalacao cancelada.' }
Get-Process -Name a2tools-dps-meter -ErrorAction SilentlyContinue | Stop-Process -Force
$pulseInstall = Start-Process msiexec.exe -ArgumentList "/i `"$pulsePackage`" /passive /norestart" -Wait -PassThru
if ($pulseInstall.ExitCode -notin @(0,3010)) { throw "Falha no MSI: $($pulseInstall.ExitCode)" }
if (-not (Test-Path (Join-Path $env:WINDIR 'System32\wpcap.dll'))) {
    Write-Host 'O Npcap precisa ser instalado. Marque WinPcap API-compatible Mode.'
    $pulsePage = Invoke-WebRequest 'https://npcap.com/' -UseBasicParsing
    $pulseMatch = [regex]::Match($pulsePage.Content, 'href="((?:https://npcap\.com)?/dist/npcap-[0-9.]+\.exe)"')
    if (-not $pulseMatch.Success) { Start-Process 'https://npcap.com/#download'; throw 'Baixe e instale o Npcap pelo site oficial, depois abra Aion Pulse.' }
    $pulseNpcapUrl = [Uri]::new([Uri]'https://npcap.com/', $pulseMatch.Groups[1].Value)
    $pulseNpcap = Join-Path $pulseWork 'npcap-installer.exe'
    Invoke-WebRequest $pulseNpcapUrl.AbsoluteUri -OutFile $pulseNpcap -UseBasicParsing
    if ((Get-AuthenticodeSignature $pulseNpcap).Status -ne 'Valid') { throw 'Assinatura do instalador Npcap invalida.' }
    Start-Process -FilePath $pulseNpcap -Wait
    if (-not (Test-Path (Join-Path $env:WINDIR 'System32\wpcap.dll'))) { throw 'Conclua a instalacao do Npcap com WinPcap API-compatible Mode e reabra Aion Pulse.' }
}
$pulseApp = Join-Path $env:ProgramFiles 'Aion Pulse\a2tools-dps-meter.exe'
if (-not (Test-Path $pulseApp)) { throw 'Executavel instalado nao encontrado.' }
if (-not (Get-Process a2tools-dps-meter -ErrorAction SilentlyContinue)) { Start-Process $pulseApp }
Write-Host 'Aion Pulse instalado. A captura Global/ExitLag ainda esta em validacao. Use ALL para testar qualquer alvo.'

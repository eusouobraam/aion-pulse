$ErrorActionPreference = 'Stop'
$pulseAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$pulseWork = Join-Path $env:TEMP 'AionPulse-Install-2.0.59'
New-Item -ItemType Directory -Path $pulseWork -Force | Out-Null
if (-not $pulseAdmin) {
    $pulseScript = Join-Path $pulseWork 'install.ps1'
    Invoke-WebRequest 'https://raw.githubusercontent.com/eusouobraam/aion-pulse/main/install.ps1' -OutFile $pulseScript -UseBasicParsing
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$pulseScript`"" -Wait
    return
}
$pulsePackage = Join-Path $pulseWork 'Aion-Pulse-2.0.59-x64.msi'
Write-Host 'Baixando Aion Pulse...'
Invoke-WebRequest 'https://github.com/eusouobraam/aion-pulse/releases/download/v2.0.59/Aion-Pulse-2.0.59-x64.msi' -OutFile $pulsePackage -UseBasicParsing
if ((Get-FileHash $pulsePackage -Algorithm SHA256).Hash -ne '6DED32359531E27676CB721227A617628E5A5EDC5A11065244C015E64426B62F') { throw 'A verificacao do MSI falhou. Instalacao cancelada.' }
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
if (-not (Get-Process a2tools-dps-meter -ErrorAction SilentlyContinue)) {
    try { Start-Process -FilePath $pulseApp -ErrorAction Stop }
    catch {
        Write-Host 'O MSI foi instalado, mas o Windows bloqueou a abertura do Aion Pulse.' -ForegroundColor Yellow
        Write-Host ('Assinatura do executavel: ' + (Get-AuthenticodeSignature -LiteralPath $pulseApp).Status)
        Write-Host 'Este bloqueio exige uma versao assinada aceita pela politica ou autorizacao do administrador do computador.'
        Write-Host 'Executar novamente como administrador ou usar ExecutionPolicy Bypass nao libera Controle de Aplicativo.'
        Write-Host ('Detalhe do Windows: ' + $_.Exception.Message)
        exit 1
    }
}
Write-Host 'Aion Pulse instalado. A captura Global/ExitLag ainda esta em validacao. Use ALL para testar qualquer alvo.'

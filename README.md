# Aion Pulse

Medidor experimental de dano para AION 2, com overlay Windows e detalhes de habilidades do jogador e invocacoes.

## Instalar pelo CMD

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/eusouobraam/aion-pulse/main/install.ps1 | iex"
```

O script baixa o MSI, verifica SHA-256, solicita administrador e abre a instalacao oficial do Npcap quando necessario. Marque **WinPcap API-compatible Mode**. O Npcap nao e redistribuido no projeto e sua instalacao gratuita e interativa.

## Downloads e fonte correspondente

[Release v2.0.56](https://github.com/eusouobraam/aion-pulse/releases/tag/v2.0.56) contem o MSI e `aion-pulse-source-2.0.56.zip`, com o codigo-fonte completo correspondente, instrucoes de build e licenca GPL-3.0. A pasta `web` contem a landing page; `install.ps1` e o instalador por comando.

## Estado do projeto

30 testes JS e 161 testes Rust passaram. O MSI Windows x64 foi compilado e seu conteudo verificado. **Captura real Global e ExitLag ainda em validacao**, com relato de ausencia de dano sob investigacao. Nao ha garantia de capturar todos os jogadores ou atribuir todas as invocacoes. Os exemplos da pagina sao simulados.

## Creditos

Base: [A2Tools DPS Meter](https://github.com/taengu/A2Tools-DPS-Meter), por taengu e colaboradores, GPL-3.0. Aion Pulse e independente e nao e um produto oficial da NCSoft. Nenhuma credencial e necessaria para usar o aplicativo ou o site.

## Site e acompanhamento

[Landing page na Vercel](https://aion-pulse.vercel.app) e [pagina no GitHub Pages](https://eusouobraam.github.io/aion-pulse/). Visitas podem ser acompanhadas no painel Web Analytics do projeto. O site nao recebe dados de combate do aplicativo.

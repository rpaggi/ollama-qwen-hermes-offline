# setup.ps1 — extrai o opencode.exe e instala a config para Ollama local
# Execute uma vez. Depois use opencode.exe direto na pasta do projeto.

$ErrorActionPreference = "Stop"
$zip  = Join-Path $PSScriptRoot "opencode-windows-x64.zip"
$dest = Join-Path $PSScriptRoot "opencode.exe"

# --- Extrai o binario ---
if (-not (Test-Path $dest)) {
    Write-Host "Extraindo opencode.exe..."
    Expand-Archive -Path $zip -DestinationPath $PSScriptRoot -Force
    Write-Host "Extraido em: $dest"
} else {
    Write-Host "opencode.exe ja existe, pulando extracao."
}

# --- Instala a config ---
$configDir = "$env:USERPROFILE\.config\opencode"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null
Copy-Item -Path (Join-Path $PSScriptRoot "opencode.jsonc") `
          -Destination "$configDir\opencode.jsonc" -Force
Write-Host "Config instalada em: $configDir\opencode.jsonc"

Write-Host ""
Write-Host "Pronto! Para usar:"
Write-Host "  1. Inicie o container:  cd ..\hermes-setup && podman-compose up -d"
Write-Host "  2. Va para o projeto:   cd C:\caminho\do\projeto"
Write-Host "  3. Abra o OpenCode:     $dest"

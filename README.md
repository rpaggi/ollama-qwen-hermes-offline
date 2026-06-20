# Ollama + qwen3-coder + Hermes CLI (imagem offline)

Imagem Docker autossuficiente para usar um agente de código no terminal **sem
internet**:

- **Ollama** (servidor de modelos local)
- **qwen3-coder:30b** — modelo de programação, já embutido na imagem (~19 GB)
- **Hermes CLI** (`hermes-agent` da Nous Research), configurado para falar com o
  Ollama local (`http://localhost:11434/v1`)

## Na máquina COM internet (build + export)

```bash
./build-and-export.sh
```

Isso gera `ollama-qwen-hermes-offline.tar` (~21 GB). O build precisa de internet
só uma vez (baixa o modelo e o instalador do Hermes).

## Na máquina SEM internet (load + uso)

```bash
docker load -i ollama-qwen-hermes-offline.tar
docker run -it --rm ollama-qwen-hermes:offline          # abre a Hermes CLI
```

Outras formas de uso:

```bash
# Só o servidor Ollama (porta 11434) para usar de outras ferramentas:
docker run -d -p 11434:11434 ollama-qwen-hermes:offline ollama serve

# Um shell dentro do container:
docker run -it --rm ollama-qwen-hermes:offline bash

# Pergunta direta ao modelo, sem Hermes:
docker run -it --rm ollama-qwen-hermes:offline ollama run qwen3-coder:30b
```

### Persistir conversas/config do Hermes entre execuções

```bash
docker run -it --rm -v hermes-data:/root/.hermes ollama-qwen-hermes:offline
```

## Usando com docker-compose (Podman no Windows)

A pasta `hermes-setup/` contém um `docker-compose.yml` pronto para uso no Windows
com Podman. Ele monta os arquivos de configuração como volume (sem precisar de rebuild)
e expõe a porta `11434` para o host.

```powershell
cd hermes-setup
copy .env.example .env        # edite o PROJECTS_PATH com o caminho dos seus projetos
podman-compose up
```

## Configurando o GitHub Copilot CLI para usar o Ollama local

Com o container rodando (porta `11434` exposta), configure o Copilot CLI via
variáveis de ambiente antes de iniciá-lo:

**Windows (PowerShell):**
```powershell
$env:COPILOT_PROVIDER_BASE_URL = "http://localhost:11434/v1"
$env:COPILOT_MODEL             = "qwen3-coder:30b"
$env:COPILOT_PROVIDER_API_KEY  = "ollama"
$env:COPILOT_OFFLINE           = "true"   # opcional: bloqueia telemetria para o GitHub
```

**Linux / WSL2 / Mac:**
```bash
export COPILOT_PROVIDER_BASE_URL=http://localhost:11434/v1
export COPILOT_MODEL=qwen3-coder:30b
export COPILOT_PROVIDER_API_KEY=ollama
export COPILOT_OFFLINE=true   # opcional: bloqueia telemetria para o GitHub
```

Depois é só usar o Copilot CLI normalmente — ele vai falar com o modelo local.

> **Atenção:** o `qwen3-coder:30b` suporta tool calling e streaming (requisitos do
> Copilot CLI). O prompt de sistema do Copilot tem ~21k tokens, então o contexto
> de 32k+ do modelo é suficiente.

## Requisitos da máquina offline
- Docker instalado.
- ~21 GB de disco para a imagem + ~20 GB de RAM livres para rodar o modelo
  (qwen3-coder:30b é MoE: ativa só 3B, então roda em CPU, mas carrega o peso todo).

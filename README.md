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

## Requisitos da máquina offline
- Docker instalado.
- ~21 GB de disco para a imagem + ~20 GB de RAM livres para rodar o modelo
  (qwen3-coder:30b é MoE: ativa só 3B, então roda em CPU, mas carrega o peso todo).

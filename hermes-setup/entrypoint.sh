#!/bin/sh
set -e

# Sobe o servidor Ollama em background.
ollama serve >/var/log/ollama.log 2>&1 &

# Espera o Ollama ficar pronto (modelo ja esta embutido na imagem).
echo "Aguardando o Ollama iniciar..."
for i in $(seq 1 60); do
    if ollama list >/dev/null 2>&1; then
        echo "Ollama pronto. Modelos disponiveis:"
        ollama list
        break
    fi
    sleep 1
done

# Pre-aquece o modelo para evitar timeout do Hermes na primeira chamada.
echo "Carregando modelo na memoria..."
ollama run qwen3-coder:30b "ok" >/dev/null 2>&1 || true
echo "Modelo pronto."

# Executa o comando solicitado (default definido no CMD: hermes --tui).
exec "$@"

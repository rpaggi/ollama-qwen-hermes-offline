#!/usr/bin/env bash
# Monta a imagem e exporta para .tar (para uso em maquina sem internet).
set -euo pipefail

IMAGE="ollama-qwen-hermes:offline"
TAR="ollama-qwen-hermes-offline.tar"

cd "$(dirname "$0")"

echo ">> Build da imagem $IMAGE (baixa ~19GB de modelo no primeiro build)..."
docker build -t "$IMAGE" .

echo ">> Exportando para $TAR ..."
docker save "$IMAGE" -o "$TAR"

echo ">> Pronto."
ls -lh "$TAR"
echo
echo "Leve o arquivo $TAR para a maquina offline e rode:"
echo "  docker load -i $TAR"
echo "  docker run -it --rm $IMAGE        # abre a Hermes CLI"

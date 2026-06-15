# Imagem offline: Ollama + qwen3-coder:30b + Hermes CLI
# Base oficial do Ollama (Ubuntu, CPU). O modelo fica embutido na imagem.
FROM ollama/ollama:latest

ENV DEBIAN_FRONTEND=noninteractive \
    OLLAMA_HOST=0.0.0.0:11434 \
    PATH="/usr/local/bin:${PATH}"

# 1) Dependencias de sistema (curl/ca-certificates p/ o instalador do Hermes,
#    git e ripgrep sao uteis para o agente de codigo).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        curl ca-certificates git ripgrep procps \
 && rm -rf /var/lib/apt/lists/*

# 2) Baixa e embute o modelo de codigo (~19GB). Sobe o ollama temporariamente
#    durante o build, baixa o modelo e desliga. Fica gravado em /root/.ollama.
#    OBS: este passo exige internet (so no build). Layer pesado e cacheado.
RUN nohup ollama serve > /tmp/ollama-build.log 2>&1 & \
    for i in $(seq 1 60); do ollama list >/dev/null 2>&1 && break; sleep 1; done; \
    ollama pull qwen3-coder:30b; \
    pkill -f "ollama serve" || true; \
    sleep 2

# 3) Dependencia extra do instalador do Hermes: ele baixa o Node.js como .tar.xz,
#    e a imagem base nao traz o 'xz'. Camada separada para preservar o cache do
#    modelo (passo 2) caso este passo precise mudar.
RUN apt-get update \
 && apt-get install -y --no-install-recommends xz-utils \
 && rm -rf /var/lib/apt/lists/*

# 4) Instala a Hermes CLI (Nous Research) de forma nao-interativa, como root.
#    Como root no Linux o binario vai para /usr/local/bin/hermes (ja no PATH).
RUN curl -fsSL https://hermes-agent.nousresearch.com/install.sh \
    | bash -s -- --skip-setup --skip-browser --non-interactive \
 && command -v hermes

# 4) Configura o Hermes para usar o Ollama LOCAL (endpoint OpenAI-compativel).
#    Assim tudo roda offline, sem chamar nenhum servico externo.
RUN mkdir -p /root/.hermes
COPY hermes-config.yaml /root/.hermes/config.yaml

# 5) Entrypoint: sobe o "ollama serve" em background, espera ficar pronto e
#    executa o comando pedido (default: a propria Hermes CLI).
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 11434
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["hermes"]

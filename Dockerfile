# Usa uma imagem Python mais recente e estável
FROM python:3.11-slim-bullseye

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Instala dependências de sistema necessárias
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libjpeg-dev \
    zlib1g-dev \
    libopenjp2-7-dev \
    libtiff-dev \
    libwebp-dev \
    && rm -rf /var/lib/apt/lists/*

# Copia o arquivo requirements.txt
COPY requirements.txt .

# Instala numpy primeiro (fixando versão do projeto)
RUN pip install --no-cache-dir numpy==1.23.5

# Instala OpenCV sem dependências (para não sobrescrever o numpy)
RUN pip install --no-cache-dir opencv-python==4.10.0.84 --no-deps

# Instala o restante das dependências (ignorando numpy e opencv já instalados)
RUN pip install --no-cache-dir -r <(grep -vE "^(numpy|opencv-python)" requirements.txt)

# Copia o restante do código da aplicação
COPY . .

# Expõe a porta do Django
EXPOSE 8000

# Comando padrão para rodar o servidor
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

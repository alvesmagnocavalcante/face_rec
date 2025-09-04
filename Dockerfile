# Use Python 3.10 para compatibilidade com numpy 1.23.5 e OpenCV 4.10.0.46
FROM python:3.10-slim-bullseye

# Define o diretório de trabalho
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
    python3-dev \
 && rm -rf /var/lib/apt/lists/*

# Atualiza pip
RUN pip install --upgrade pip

# Copia requirements.txt
COPY requirements.txt .

# Instala numpy primeiro
RUN pip install --no-cache-dir numpy==1.23.5

# Instala OpenCV sem instalar dependências (não vai mexer no numpy)
RUN pip install --no-cache-dir opencv-python==4.12.0.88 --no-deps

# Instala o restante das dependências do requirements.txt (exceto numpy e opencv)
RUN pip install --no-cache-dir \
    $(grep -vE "^(numpy|opencv-python)" requirements.txt)

# Copia o código do projeto
COPY . .

# Expõe a porta do Django
EXPOSE 8000

# Comando para rodar o Django
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

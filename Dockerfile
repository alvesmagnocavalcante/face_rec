# Usa Python 3.9 slim
FROM python:3.9-slim-bullseye

# Define o diretório de trabalho
WORKDIR /app

# Instala dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libjpeg-dev \
    zlib1g-dev \
    libopenjp2-7-dev \
    libtiff-dev \
    libwebp-dev \
    && rm -rf /var/lib/apt/lists/*

# Copia requirements.txt
COPY requirements.txt .

# Remove BOM escondido (UTF-8 com BOM)
RUN sed -i '1s/^\xef\xbb\xbf//' requirements.txt

# Instala numpy primeiro (fixando versão que funciona)
RUN pip install --no-cache-dir numpy==1.23.5

# Instala OpenCV sem dependências (não vai mexer no numpy)
RUN pip install --no-cache-dir opencv-python==4.10.0.46 --no-deps

# Instala o restante das dependências (exceto numpy e opencv)
RUN pip install --no-cache-dir -r <(grep -vE "^(numpy|opencv-python)" requirements.txt)

# Copia o resto do código
COPY . .

# Expõe a porta
EXPOSE 8000

# Comando padrão do Django
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

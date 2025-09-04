FROM python:3.11-slim-bullseye

WORKDIR /app

# Dependências de sistema necessárias para OpenCV e outros pacotes
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libjpeg-dev \
    zlib1g-dev \
    libopenjp2-7-dev \
    libtiff-dev \
    libwebp-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copia o requirements.txt
COPY requirements.txt .

# Instala numpy primeiro (evita conflito com opencv)
RUN pip install --no-cache-dir numpy==1.23.5

# Instala OpenCV sem dependências para não sobrescrever o numpy
RUN pip install --no-cache-dir opencv-python==4.10.0.84 --no-deps

# Cria um requirements sem numpy e opencv
RUN grep -vE "^(numpy|opencv-python)" requirements.txt > requirements-no-numpy.txt

# Instala o restante das dependências
RUN pip install --no-cache-dir -r requirements-no-numpy.txt

# Copia o restante do código
COPY . .

# Expõe a porta padrão do Django
EXPOSE 8000

# Comando de inicialização
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

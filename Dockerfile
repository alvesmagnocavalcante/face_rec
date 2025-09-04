FROM python:3.11-slim-bullseye

WORKDIR /app

# Dependências de sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libjpeg-dev \
    zlib1g-dev \
    libopenjp2-7-dev \
    libtiff-dev \
    libwebp-dev \
    && rm -rf /var/lib/apt/lists/*

# Copia o requirements.txt
COPY requirements.txt .

# Instala numpy primeiro
RUN pip install --no-cache-dir numpy==1.23.5

# Instala OpenCV sem dependências (não substitui o numpy já instalado)
RUN pip install --no-cache-dir opencv-python==4.10.0.84 --no-deps

# Cria um novo requirements sem numpy e opencv
RUN grep -vE "^(numpy|opencv-python)" requirements.txt > requirements-no-numpy.txt

# Instala o restante das dependências
RUN pip install --no-cache-dir -r requirements-no-numpy.txt

# Copia o restante do código
COPY . .

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

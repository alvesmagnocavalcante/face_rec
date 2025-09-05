# Base Python 3.10 slim
FROM python:3.10-slim-bullseye

# Define diretório de trabalho
WORKDIR /app

# Instala dependências de sistema necessárias para OpenCV e dlib
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

# Instala numpy primeiro para evitar conflito com OpenCV
RUN pip install --no-cache-dir numpy==1.23.5

# Instala OpenCV sem sobrescrever numpy
RUN pip install --no-cache-dir opencv-python==4.10.0.84 --no-deps

# Instala dlib via dlib-bin (pré-compilado para Linux)
RUN pip install --no-cache-dir dlib-bin==19.24.6

# Instala o restante das dependências (excluindo numpy, opencv e dlib)
RUN grep -vE "^(numpy|opencv-python|dlib|dlib-bin)" requirements.txt > requirements-no-numpy.txt
RUN pip install --no-cache-dir -r requirements-no-numpy.txt

# Copia todo o código da aplicação
COPY . .

# Expõe a porta padrão do Django
EXPOSE 8000

# Comando para rodar o servidor Django
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# Usa uma imagem base do Python
FROM python:3.9-slim-buster

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copia o arquivo requirements.txt para o diretório de trabalho
COPY requirements.txt .

# Instala as dependências do Python
# Note que dlib pode ter dependências de sistema. Instalar gcc e cmake é comum.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir -r requirements.txt

# Copia o restante do código do projeto para o diretório de trabalho
COPY . .

# Expõe a porta em que o Django roda (geralmente 8000)
EXPOSE 8000

# Comando para rodar o servidor Django
# Certifique-se de que seu manage.py está configurado para rodar com 0.0.0.0
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
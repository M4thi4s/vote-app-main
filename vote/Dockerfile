FROM --platform=linux/amd64 python:3.11-slim AS BUILD

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier les fichiers de requirements et installer les dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN apt-get update && apt-get install -y curl

# Healthcheck
HEALTHCHECK CMD curl --fail http://localhost:5000/ || exit 1

# Copier le reste des fichiers du service dans le conteneur
COPY . .

EXPOSE 5000

# Définir le point d'entrée pour notre conteneur
ENTRYPOINT ["python", "app.py"]


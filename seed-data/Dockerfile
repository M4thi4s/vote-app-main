FROM --platform=linux/amd64 python:3.9-slim AS BUILD

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier les fichiers du service de seed dans le répertoire de travail
COPY make-data.py generate-votes.sh /app/

# Installer apache2-utils pour l'utilitaire ab
RUN apt-get update && apt-get install -y apache2-utils

# Génére les fichier posta et postb
RUN python make-data.py

# Envoie des votes (posta ou postb) au service de vote
CMD ["/bin/bash", "generate-votes.sh"]
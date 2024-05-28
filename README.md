# Voting Application - DevOps Deployment Guide

## Description du Projet

Ce projet a pour objectif de déployer une application de vote en utilisant différentes technologies DevOps : Docker Compose, Kubernetes et Ansible. L'application est composée de plusieurs services, chacun déployé dans des conteneurs distincts, orchestrés et gérés par ces technologies.

## Présentation de l'Architecture

| Fichier/Dossier                  | Description                                                         |
|----------------------------------|---------------------------------------------------------------------|
| README.md                        | Documentation du projet                                             |
| deployments/ansible              | Scripts et configurations Ansible                                   |
| deployments/compose.yaml         | Fichier de configuration Docker Compose                             |
| deployments/kub-manifests/ | Déploiement avec Kubernetes |
| healthchecks                     | Scripts de vérification de l'état des services                      |
| nginx                            | Fichiers de configuration et Dockerfile pour Nginx                  |
| result                           | Service Node.js pour afficher les résultats des votes               |
| seed-data                        | Génération de données de vote pour les tests                        |
| vote                             | Service Python (Flask) pour soumettre les votes                     |
| worker                           | Service .NET pour traiter les votes et stocker les résultats        |

### Architecture Ansible

- **inventories** : Fichiers d'inventaire pour les environnements cibles.
- **roles** : Rôles Ansible pour l'installation et la configuration de PostgreSQL.
- **playbooks** : Scripts Ansible pour déployer et gérer les services.
- **backup** : Scripts Ansible pour sauvegarder les bases de données.

### Architecture Kubernetes

- **ansible-k8** : Manifests Kubernetes utilisant Ansible pour la réplication de la base de données.
- **classic-k8** : Manifests Kubernetes sans Ansible et sans réplication de la base de données.

### Docker Compose

- **Dockerfiles créés :**
  - `vote/Dockerfile` : Définit le service de vote basé sur Python Flask.
  - `result/Dockerfile` : Définit le service de résultats basé sur Node.js.
  - `worker/Dockerfile` : Définit le service de worker basé sur .NET.
  - `nginx/Dockerfile` : Définit le service de load balancing basé sur Nginx.
  - `seed-data/Dockerfile` : Définit le service de génération de données de vote.

- **Fichier `docker-compose.yaml` :**
  - Définit plusieurs services (vote, result, worker, redis, db, loadbalancer, seed) avec leurs configurations respectives.
  - Utilise les images Docker depuis un registre GCP et les construit à partir des contextes spécifiés.
  - Définit les réseaux `front-net` et `back-net` pour la communication entre les services.
  - **Health checks intégrés :**
    - **Redis** : Utilise le script `healthchecks/redis.sh` pour vérifier la santé du service. En cas d'échec, le service est redémarré 3 fois maximum avec un interval de 30s entre chaque démarrage.
    - **PostgreSQL** : Utilise le script `healthchecks/postgres.sh` pour vérifier la santé du service. En cas d'échec, le service est redémarré 3 fois maximum avec un interval de 30s entre chaque démarrage.

### Kubernetes

- **Fonctionnalités réalisées :**
  - Déploiement des services dans un cluster Kubernetes en utilisant des Deployments et Services.
  - Utilisation de Jobs pour exécuter des tâches ponctuelles telles que la génération de données de test.

- **Dossier `k8-classic` :**
  - Déploiement classique sans utilisation d'Ansible et sans réplication de la base de données.
  - **Deployments :**
    - `k8-vote-deployment.yaml` : Déploie 3 réplicas du service de vote avec l'image `europe-west9-docker.pkg.dev/vote-app/voting-images/vote`.
    - `k8-result-deployment.yaml` : Déploie 1 réplique du service de résultats avec l'image `europe-west9-docker.pkg.dev/vote-app/voting-images/result`.
    - `k8-redis-deployment.yaml` : Déploie 1 réplique du service Redis avec l'image `redis:alpine`.
    - `k8-db-deployment.yaml` : Déploie 1 réplique du service PostgreSQL avec l'image `postgres:15-alpine`.
    - `k8-worker-deployment.yaml` : Déploie 1 réplique du service worker avec l'image `europe-west9-docker.pkg.dev/vote-app/voting-images/worker`.
  - **Services :**
    - `k8-vote-service.yaml` : Expose le service de vote sur le port 5000 en tant que LoadBalancer.
    - `k8-result-service.yaml` : Expose le service de résultats sur le port 4000 en tant que LoadBalancer.
    - `k8-redis-service.yaml` : Expose le service Redis sur le port 6379.
    - `k8-db-service.yaml` : Expose le service PostgreSQL sur le port 5432.
  - **Job :**
    - `k8-seed-job.yaml` : Exécute un job ponctuel pour générer des données de vote avec l'image `europe-west9-docker.pkg.dev/vote-app/voting-images/seed`.

- **Dossier `k8-ansible` :**
  - Déploiement utilisant Ansible pour configurer et gérer la réplication de la base de données PostgreSQL.
  - **Différences spécifiques :**
    - **EndpointSlices :**
      - `k8-db-endpointslice-replica.yaml` : Déclare un EndpointSlice pour la réplication de la base de données PostgreSQL.
      - `k8-db-endpointslice.yaml` : Déclare un EndpointSlice pour la base de données PostgreSQL principale.
    - **Namespaces :**
      - `1k8-db-replica-namespace.yaml` : Crée un namespace `db-replica` pour les services de réplication de la base de données.
    - **Services spécifiques au namespace `db-replica` :**
      - `k8-db-service-replica.yaml` : Expose le service PostgreSQL répliqué sur le port 5432 dans le namespace `db-replica`.
      - `k8-result-service.yaml` : Expose le service de résultats dans le namespace `db-replica`.

### Ansible

- **Fonctionnalités réalisées :**
  - Installation et configuration de PostgreSQL sur des VM GCP.
  - Mise en place de la réplication PostgreSQL entre instances primaires et secondaires.
  - Sauvegarde automatique des bases de données.

#### Inventaires

- **`inventories/postgresql_installation.yaml` :**
  - Décrit les hôtes et leurs attributs pour l'installation de PostgreSQL. Contient les informations de connexion SSH, les paramètres spécifiques à PostgreSQL et les paramètres de configuration de la mémoire.

- **`inventories/postgresql_replication.yml` :**
  - Décrit les hôtes et leurs attributs pour la configuration de la réplication PostgreSQL. Définit les informations pour les instances primaires et standby, y compris les détails de connexion et les paramètres de réplication.

#### Playbooks

- **`setup_postgres.yml` :**
  - Installe et configure PostgreSQL sur toutes les machines spécifiées dans l'inventaire en utilisant le rôle `postgresql_installation`.

- **`setup_postgres_with_replicas.yml` :**
  - Installe PostgreSQL sur toutes les machines spécifiées.
  - Configure la réplication PostgreSQL pour les instances primaires et standby en utilisant les rôles `postgresql_installation` et `postgresql_replication`.

#### Rôles

- **Rôle `postgresql_installation` :**
  - **Handlers :**
    - `handlers/main.yml` : Contient les tâches pour redémarrer le service PostgreSQL après les modifications de configuration.
  - **Tasks :**
    - `tasks/main.yml` : Installe les paquets PostgreSQL nécessaires, démarre le service PostgreSQL, crée la base de données et l'utilisateur, configure `pg_hba.conf` pour les connexions, et ajuste les paramètres de configuration pour optimiser les performances.

- **Rôle `postgresql_replication` :**
  - **Handlers :**
    - `handlers/main.yml` : Contient les tâches pour redémarrer le service PostgreSQL après les modifications de configuration.
  - **Tasks :**
    - `tasks/main.yml` : Configure un utilisateur de réplication sur les nœuds primaires et standby, modifie `pg_hba.conf` pour permettre la connexion de l'utilisateur de réplication, configure les paramètres PostgreSQL nécessaires pour la réplication, et initialise la réplication avec `pg_basebackup`.
  - **Templates :**
    - `templates/pgpass.j2` : Utilisé pour créer le fichier `.pgpass` nécessaire pour l'authentification PostgreSQL lors de la réplication.

#### Sauvegarde

- **Playbook `backup/backup-db.yaml` :**
  - Crée un dump de la base de données PostgreSQL sur la machine distante.
  - Récupère le fichier de dump sur la machine locale pour une sauvegarde sécurisée.
  - Supprime le fichier de dump de la machine distante après récupération.

## Démarrage

### Docker Compose
![image](img/DockerCompose.drawio.svg)

1. **Construire et exécuter les services avec docker-compose :**

    ```bash
    docker compose build --no-cache
    docker compose up
    ```

2. **Vérifier les services :**

    - **Vote :** [http://localhost](http://localhost)
    - **Result :** [http://localhost:4000](http://localhost:4000)

3. **Arrêter les services :**

    ```bash
    docker compose down
    ```

### Kubernetes
![image](img/kubernetes.drawio.svg)

1. **Configurer le projet GCP et le cluster Kubernetes :**

    ```bash
    # Set GCP project
    gcloud config set project vote-app

    # Create container registry
    gcloud artifacts repositories create voting-images --repository-format=docker --location=europe-west9

    # Authenticate Docker to GCP registry
    gcloud auth configure-docker europe-west9-docker.pkg.dev

    # Create Kubernetes cluster
    gcloud container clusters create project --machine-type e2-small --num-nodes 3 --zone europe-west9-a
    ```

2. **Construire et pousser les images Docker :**

    ```bash
    docker compose build --no-cache
    docker compose push
    ```

3. **Déployer les manifests Kubernetes :**

    ```bash
    kubectl apply -f classic-k8/
    kubectl apply -f ansible-k8/
    ```
    Ansible - switcher entre namespace default / db-replica :

     ```bash
    kubectl config set-context --current --namespace=db-replica
    kubectl config set-context --current --namespace=default
    ```

4. **Vérifier les déploiements et services :**

    ```bash
    kubectl get deployments
    kubectl get services
    kubectl get pods
    kubectl get jobs
    ```

### Ansible
![image](img/Ansible.drawio.svg)

1. **Ajouter des tags réseau aux VMs :**

    ```bash
    gcloud compute instances add-tags --zone "us-central1-c" "vm-ansible-replicas-primary" --project "vote-app" --tags=db-server
    gcloud compute instances add-tags --zone "us-central1-c" "vm-ansible-replicas-standby" --project "vote-app" --tags=db-server
    ```

2. **Exécuter les playbooks Ansible :**

    ```bash
    # Déployer PostgreSQL
    ansible-playbook -i deployments/ansible/inventories/gcp.yaml deployments/ansible/setup_postgres.yml

    # Sauvegarder la base de données
    ansible-playbook -i deployments/ansible/inventories/gcp.yaml deployments/ansible/backup/backup-db.yaml

    # Déployer la réplication PostgreSQL
    ansible-playbook -i deployments/ansible/inventories/postgresql_replication.yml deployments/ansible/setup_postgres_with_replicas.yml
    ```

3. **Connexion en SSH aux VMs :**

    ```bash
    # Standby
    gcloud compute ssh --zone "us-central1-c" "vm-ansible-replicas-standby" --project "vote-app"

    # Master
    gcloud compute ssh --zone "us-central1-c" "vm-ansible-replicas-primary" --project "vote-app"
    ```

4. **Vérification de la connexion PostgreSQL :**

    ```bash
    docker run postgres pg_isready --host=<IP_ADDRESS>
    ```
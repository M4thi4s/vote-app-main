#!/bin/sh

# Ce script génère 3000 votes (2000 pour l'option a, 1000 pour l'option b)
# Il utilise l'outil 'ab' (Apache Benchmark) pour envoyer les requêtes

# L'hôte cible
HOST="nginx"

sleep 15

# Ping l'hôte
ping -c 1 $HOST > /dev/null 2>&1

# Vérifier le statut du dernier ping
if [ $? -eq 0 ]; then
    echo "Docker-compose est en cours d'exécution"
    ab -n 1000 -c 50 -s 9999 -p posta -T "application/x-www-form-urlencoded" http://$HOST/
    ab -n 1000 -c 50 -s 9999 -p postb -T "application/x-www-form-urlencoded" http://$HOST/
    ab -n 1000 -c 50 -s 9999 -p posta -T "application/x-www-form-urlencoded" http://$HOST/
else
    echo "Kubernetes est en cours d'exécution"
    ab -n 1000 -c 50 -s 9999 -p posta -T "application/x-www-form-urlencoded" http://vote:5000/
    ab -n 1000 -c 50 -s 9999 -p postb -T "application/x-www-form-urlencoded" http://vote:5000/
    ab -n 1000 -c 50 -s 9999 -p posta -T "application/x-www-form-urlencoded" http://vote:5000/
fi

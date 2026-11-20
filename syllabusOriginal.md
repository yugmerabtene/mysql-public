
Ressources matérielles (lab isolé)

- Maximum 3 VMs, idéalement 2 VMs, pour préserver la machine hôte.
- Par VM : 1 vCPU, 1 Go RAM, 15 Go disque dur.
- Système : Ubuntu Server 24.04 LTS (ou 22.04 LTS en alternative).
- Réseau : VirtualBox Host-only vboxnet0, 192.168.56.0/24, DHCP désactivé, pas d'accès Internet pendant les labs.
- Hôte : 192.168.56.1.
- VM 1 (192.168.56.10) : nœud de gestion + nœud SQL.
- VM 2 (192.168.56.11) : deux nœuds de stockage (ndbmtd node-id 1 et 2).

Objectifs pédagogiques

    Comprendre l'architecture de MySQL Cluster
    Installer et configurer un cluster MySQL
    Gérer la réplication et la tolérance aux pannes
    Optimiser les performances et la scalabilité
    Superviser et maintenir un cluster MySQL en production
    Utiliser les architectures shared-disk et shared-nothing
    Mettre en place et configurer un proxy pour MySQL Cluster

Programme
Jour 1 – Introduction à MySQL Cluster

    Présentation de MySQL Cluster et de son architecture
    Les composants principaux : MySQL Server, NDB Cluster, management nodes
    Pourquoi MySQL Cluster est-il adapté aux applications critiques ?
    Études de cas et exemples d'utilisation
    Travaux pratiques : exploration des composants de MySQL Cluster à travers des exemples concrets et des études de cas

Installation de MySQL Cluster

    Pré-requis matériels et logiciels
    Installation des différents composants du cluster
    Configuration initiale et démarrage des services
    Comment vérifier l'intégrité de l'installation ?
    Travaux pratiques : mise en place d'un environnement de test, installation des composants et vérification du bon fonctionnement du cluster

Architecture de MySQL Cluster

    Le moteur de stockage NDB
    Différents types de nœuds
    Partitionnement et réplication
    Redondance et résilience

Jour 2 – Configuration et Administration de MySQL Cluster

    Configurer les nœuds de gestion, de stockage et SQL
    Paramètres de configuration essentiels
    Ajout et suppression de nœuds dans le cluster
    Comment surveiller l'état du cluster ?
    Travaux pratiques : configuration détaillée des nodes, gestion des ajouts et suppressions, et mise en place des outils de surveillance

Supervision et Maintenance

    Outils de supervision et d'alertes
    Tâches de maintenance courantes
    Sauvegarde et restauration de données
    Comment assurer une maintenance sans interruption de service ?
    Travaux pratiques : configuration des outils de supervision, planification des tâches de maintenance et mise en œuvre des stratégies de sauvegarde et de restauration

MySQL Cluster Manager

    Installer les agents et clients MySQL Cluster Manager
    Création de clusters
    Importer des configurations
    Maintenance et gestion de clusters
    Travaux pratiques : installation et configuration de MySQL Cluster Manager

Jour 3 – Optimisation des Performances et Scalabilité

    Paramètres de performance à optimiser
    Techniques de sharding et de partitionnement
    Comment diagnostiquer et résoudre les problèmes de performance ?
    Études de cas de performance
    Travaux pratiques : mise en œuvre de techniques d'optimisation et résolution de problèmes de performance sur un cluster MySQL

Gestion de la Réplication et de la Tolérance aux Pannes

    Concepts de réplication en MySQL Cluster
    Configurer la réplication entre clusters
    Gestion des pannes et des récupérations
    Mécanismes de failover et de failback
    Travaux pratiques : configuration de la réplication, simulation de pannes et mise en place de stratégies de récupération

Sécuriser MySQL Cluster

    Sécurité des connexions
    Sécurité des données
    Sécurité des nœuds serveurs
    Travaux pratiques : configuration de la sécurité d'un cluster MySQL


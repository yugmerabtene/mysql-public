MySQL InnoDB Cluster et MySQL InnoDB ReplicaSet sont deux solutions officielles de haute disponibilité (HA) et de réplication intégrées directement à l'écosystème MySQL. [1] (https://dev.mysql.com/blog-archive/introducing-mysql-innodb-replicaset/), [2] (https://mengojojo.wordpress.com/2020/03/02/mon-cluster-mysql-innodb/)
Le terme « InnoDB » fait référence au moteur de stockage par défaut de MySQL, et ces architectures permettent de synchroniser plusieurs serveurs MySQL ensemble pour éviter toute perte de données ou interruption de service en cas de panne. [1] (https://www.youtube.com/watch?v=wthZYEjnmVo&t=368), [2] (https://www.reddit.com/r/mysql/comments/11u2afd/replication/?tl=fr)

Les 3 briques de base communes

Ces deux architectures reposent sur l'assemblage de trois outils natifs de MySQL : [1] (https://dev.mysql.com/blog-archive/introducing-mysql-innodb-replicaset/), [2] (https://mengojojo.wordpress.com/2020/03/02/mon-cluster-mysql-innodb/)
• Les serveurs MySQL (moteur InnoDB). Ils hébergent les données et assurent leur réplication d'une machine à l'autre. [1] (https://www.stephane-robert.info/docs/services/bdd/relationnelles/mysql/replication/)
• MySQL Router. Un proxy léger qui se place entre votre application et les bases de données pour rediriger automatiquement le trafic vers le bon serveur (en lecture ou en écriture). [1] (https://dasini.net/blog/2017/03/13/tester-mysql-innodb-cluster/), [2] (https://www.advandata.org/fr/insights/mysql-high-availability-design/)
• MySQL Shell. Un outil en ligne de commande (via l'AdminAPI) qui permet de déployer, configurer et administrer l'ensemble de l'architecture en quelques commandes. [1] (https://dev.mysql.com/blog-archive/introducing-mysql-innodb-replicaset/), [2] (https://mengojojo.wordpress.com/2020/03/02/mon-cluster-mysql-innodb/)

La différence entre InnoDB Cluster et InnoDB ReplicaSet

Bien que le nom prête souvent à confusion, ils répondent à deux niveaux d'exigence différents :

Critère	InnoDB Cluster	InnoDB ReplicaSet
Technologie sous-jacente	Group Replication (réplication de groupe quasi-synchrone)	Réplication classique (asynchrone Source / Replica)
Basculement (Failover)	Automatique en quelques secondes en cas de panne d'un serveur	Manuel (nécessite une commande via MySQL Shell)
Nombre de nœuds	Minimum 3 serveurs recommandés (pour maintenir un quorum)	À partir de 2 serveurs (1 source + 1 ou plusieurs réplicas)
Usage principal	Applications critiques nécessitant une disponibilité continue (zéro interruption)	Montée en charge en lecture, sauvegardes ou reprise après sinistre simple

(Note : Il existe aussi les Read Replicas, des nœuds en lecture seule qu'il est possible d'ajouter en complément d'un InnoDB Cluster pour absorber un fort trafic de lecture sans alourdir le groupe principal.)
Pour en savoir plus sur leur mise en place, consultez la présentation de MySQL InnoDB Cluster, l'annonce officielle de MySQL InnoDB ReplicaSet, ou ce guide complet sur la réplication MySQL.
Souhaitez-vous que je vous aide à choisir entre ces deux architectures ? Si oui, précisez :
• Votre tolérance aux interruptions de service en cas de panne
• Le nombre de serveurs dont vous disposez

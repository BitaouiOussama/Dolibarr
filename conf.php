<?php
// Fichier de configuration Dolibarr

// URL racine de Dolibarr
$dolibarr_main_url_root = 'https://dolibarr-68ch.onrender.com';
$dolibarr_main_document_root = '/var/www/html/htdocs';

// Répertoire pour les documents et fichiers Dolibarr
$dolibarr_main_data_root = '/var/www/html/documents';

// Informations de connexion à la base de données
$dolibarr_main_db_host = 'dolibarr-dolibarr-1010.k.aivencloud.com';
$dolibarr_main_db_port = '17031';
$dolibarr_main_db_name = 'defaultdb';
$dolibarr_main_db_user = 'avnadmin';
$dolibarr_main_db_pass = getenv('DOLIBARR_DB_PASS');;
$dolibarr_main_db_type = 'mysqli';

// SSL pour la connexion à MySQL
$dolibarr_main_db_ssl = 1;
$dolibarr_main_db_ssl_ca = '/ca.pem';

// Méthode d'authentification par défaut
$dolibarr_main_authentication = 'dolibarr';

// Forcer l'installation automatique (évite le wizard)
$dolibarr_main_force_install = 1;

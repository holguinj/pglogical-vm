#!/bin/bash
set -euo pipefail

# database setup
sudo su postgres -c psql <<EOF
 CREATE USER replicator SUPERUSER LOGIN PASSWORD 'replicator';

 CREATE USER "spike-classifier" SUPERUSER LOGIN PASSWORD 'spike-classifier';
 CREATE DATABASE "spike-classifier" WITH OWNER="spike-classifier";
 \c spike-classifier
 GRANT ALL ON DATABASE "spike-classifier" to replicator;

 CREATE USER perbac LOGIN PASSWORD 'foobar';
 CREATE DATABASE perbac_test WITH OWNER=perbac;
 \c perbac_test
 CREATE EXTENSION IF NOT EXISTS citext;
 GRANT ALL ON DATABASE perbac_test to replicator;

 CREATE USER activity LOGIN PASSWORD 'activity';
 CREATE DATABASE activity WITH OWNER=activity;
 \c activity
 GRANT ALL ON DATABASE activity to replicator;

EOF

echo "host    replication               replicator             192.168.33.10/0 md5" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    spike-classifier          replicator             192.168.33.10/0 md5" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    perbac_test               replicator             192.168.33.10/0 md5" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    activity                  replicator             192.168.33.10/0 md5" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf

sudo service postgresql restart

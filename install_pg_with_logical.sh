#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Sorry mom
# sudo su -

# add the apt repo
echo "Adding the apt-get repo for postgresql"
sudo echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
    sudo apt-key add -
sudo apt-get update

# install postgres
echo "installing postgresql 9.4"
sudo apt-get install -y postgresql-9.4

# add the apt repo for pglogical
echo "adding the apt-get repo for pglogical"
sudo echo "deb [arch=amd64] http://packages.2ndquadrant.com/pglogical/apt/ trusty-2ndquadrant main" > /etc/apt/sources.list.d/2ndquadrant.list
wget --quiet -O - http://packages.2ndquadrant.com/pglogical/apt/AA7A6805.asc | sudo apt-key add -
sudo apt-get update

# install pglogical
echo "installing pglogical"
sudo apt-get install -y postgresql-9.4-pglogical postgresql-9.4-pglogical-output

echo "adding lines to postgresql.conf"
sudo echo "wal_level = 'logical'" >> /etc/postgresql/9.4/main/postgresql.conf
sudo echo "max_worker_processes = 10   # one per database needed on provider node" >> /etc/postgresql/9.4/main/postgresql.conf
sudo echo "max_replication_slots = 10  # one per node needed on provider node" >> /etc/postgresql/9.4/main/postgresql.conf
sudo echo "max_wal_senders = 10        # one per node needed on provider node" >> /etc/postgresql/9.4/main/postgresql.conf
sudo echo "listen_addresses = '*'" >> /etc/postgresql/9.4/main/postgresql.conf

echo "trusting the rep user"
echo "host    replication         rep                      0.0.0.0/0       trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    test_replication    rep                      0.0.0.0/0       trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf

echo "allowing password login for all users"
echo "host    all                  all                     0.0.0.0/0       md5" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf

echo "allowing replication by PE users"
echo "host    replication          pe-orchestrator         192.168.33.10/0 trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    replication          pe-puppetdb             192.168.33.10/0 trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    replication          pe-activity             192.168.33.10/0 trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    replication          pe-classifier           192.168.33.10/0 trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    replication          pe-rbac                 192.168.33.10/0 trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf

echo "allowing PE (console) users access to their own databases"
echo "host    pe-orchestrator      pe-orchestrator         192.168.33.10/0 trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    pe-puppetdb          pe-puppetdb             192.168.33.10/0 trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    pe-activity          pe-activity             192.168.33.10/0 trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    pe-classifier        pe-classifier           192.168.33.10/0 trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    pe-rbac              pe-rbac                 192.168.33.10/0 trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
sudo service postgresql restart

echo "setting up initial user/db"
sudo su postgres -c "psql -c 'CREATE USER vagrant;'"
sudo su postgres -c "psql -c 'CREATE DATABASE vagrant'"
sudo su postgres -c "psql -c 'GRANT ALL ON DATABASE vagrant TO vagrant'"

echo "adding pglogical to shared_preload_libraries"
sudo echo "shared_preload_libraries = 'pglogical'" >> /etc/postgresql/9.4/main/postgresql.conf
sudo service postgresql restart

echo "creating pglogical extension"
sudo su postgres -c "psql -c 'CREATE EXTENSION IF NOT EXISTS pglogical;'"

echo "creating the database and table"
sudo su postgres -c "psql -c 'CREATE DATABASE test_replication'"
sudo su postgres -c "psql -c 'GRANT ALL ON DATABASE test_replication TO vagrant'"
sudo su postgres -c "psql -c 'GRANT ALL ON DATABASE test_replication TO postgres'"
sudo su postgres -c "psql -c 'CREATE USER rep SUPERUSER REPLICATION LOGIN CONNECTION LIMIT 10'"
sudo su postgres -c "psql -c 'GRANT ALL ON DATABASE test_replication TO rep'"

sudo su postgres -c psql <<EOF
 \c test_replication;
 CREATE EXTENSION IF NOT EXISTS pglogical;
 CREATE EXTENSION IF NOT EXISTS pglogical_origin;
EOF

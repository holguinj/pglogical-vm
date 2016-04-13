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
echo "installing postgresql 9.5"
sudo apt-get install -y postgresql-9.5

# add the apt repo for pglogical
echo "adding the apt-get repo for pglogical"
sudo echo "deb [arch=amd64] http://packages.2ndquadrant.com/pglogical/apt/ trusty-2ndquadrant main" > /etc/apt/sources.list.d/2ndquadrant.list
wget --quiet -O - http://packages.2ndquadrant.com/pglogical/apt/AA7A6805.asc | sudo apt-key add -
sudo apt-get update

# install pglogical
echo "installing pglogical"
sudo apt-get install -y postgresql-9.5-pglogical postgresql-9.5-pglogical-output

echo "setting up initial user/db"
sudo su postgres -c "psql -c 'CREATE USER vagrant;'"
sudo su postgres -c "psql -c 'CREATE DATABASE vagrant'"
sudo su postgres -c "psql -c 'GRANT ALL ON DATABASE vagrant TO vagrant'"

echo "adding pglogical to shared_preload_libraries"
sudo echo "shared_preload_libraries = 'pglogical'" >> /etc/postgresql/9.5/main/postgresql.conf
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
 CREATE TABLE messages(
  ID INT PRIMARY KEY NOT NULL,
  MESSAGE TEXT NOT NULL
 );
EOF

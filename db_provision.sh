#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "beginning db-specific config:"

echo "creating messages table"
sudo su postgres -c psql <<EOF
 \c test_replication;
 CREATE TABLE messages(
  ID INT PRIMARY KEY NOT NULL,
  MESSAGE TEXT NOT NULL
 );
 INSERT INTO messages (id, message) VALUES(0, 'boo.');
 INSERT INTO messages (id, message) VALUES(1, 'hey there, friend');
EOF

echo "updating pg_hba.conf"
echo "host    replication          rep             192.168.33.10/0 trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    test_replication     rep             192.168.33.10/0 trust" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
echo "host    all                  all             0.0.0.0/0       md5"   | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf

echo "restarting postgres"
sudo service postgresql restart

# create provider node
echo "creating the provider node"
sudo su postgres -c psql <<EOF
 \c test_replication;
 SELECT pglogical.create_node(node_name := 'provider1', dsn := 'host=192.168.33.2 port=5432 dbname=test_replication');
EOF

# Add all tables in public schema to the default replication set.
echo "adding public tables to the default replication set"
sudo su postgres -c psql <<EOF
 \c test_replication;
 SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);
EOF

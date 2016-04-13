#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "beginning master-specific config:"

echo "adding lines to postgresql.conf"
sudo echo "wal_level = 'logical'" >> /etc/postgresql/9.5/main/postgresql.conf
sudo echo "max_worker_processes = 10   # one per database needed on provider node" >> /etc/postgresql/9.5/main/postgresql.conf
sudo echo "max_replication_slots = 10  # one per node needed on provider node" >> /etc/postgresql/9.5/main/postgresql.conf
sudo echo "max_wal_senders = 10        # one per node needed on provider node" >> /etc/postgresql/9.5/main/postgresql.conf
sudo echo "listen_addresses = '*'" >> /etc/postgresql/9.5/main/postgresql.conf

echo "updating pg_hba.conf"
sudo echo "host    replication          rep             192.168.33.10/32 trust" >> /etc/postgresql/9.5/main/pg_hba.conf
sudo echo "host    test_replication     rep             192.168.33.10/32 trust" >> /etc/postgresql/9.5/main/pg_hba.conf

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

exit

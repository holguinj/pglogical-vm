#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


echo "beginning replica-specific config:"
sudo echo "listen_addresses = '*'" >> /etc/postgresql/9.5/main/postgresql.conf

echo "updating pg_hba.conf"
sudo echo "host    replication          rep             192.168.33.10/32 trust" >> /etc/postgresql/9.5/main/pg_hba.conf
sudo echo "host    test_replication     rep             192.168.33.10/32 trust" >> /etc/postgresql/9.5/main/pg_hba.conf

sudo service postgresql restart

# create the subscriber node
echo "creating the subscriber node"
sudo su postgres -c psql <<EOF
 \c test_replication;
 SELECT pglogical.create_node(node_name := 'subscriber1', dsn := 'host=192.168.33.10 port=5432 dbname=test_replication user=rep');
EOF

sudo sh -c 'echo "192.168.33.2 master" >> /etc/hosts'

# http://2ndquadrant.com/en-us/resources/pglogical/pglogical-docs/

echo "subscribing"
sudo su postgres -c psql <<EOF
 \c test_replication;
 SELECT pglogical.create_subscription(
     subscription_name := 'subscription1',
     provider_dsn := 'host=master port=5432 dbname=test_replication user=rep'
 );
EOF


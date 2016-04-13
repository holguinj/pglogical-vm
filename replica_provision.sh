#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


echo "beginning replica-specific config:"

# create the subscriber node
echo "creating the subscriber node"
sudo su postgres -c psql <<EOF
 SELECT pglogical.create_node(node_name := 'subscriber1', dsn := 'host=192.168.33.10 port=5432 dbname=test_replication user=rep');
EOF

sudo sh -c 'echo "192.168.33.2 master" >> /etc/hosts'

# http://2ndquadrant.com/en-us/resources/pglogical/pglogical-docs/

echo "subscribing (broken right now)"
sudo su postgres -c psql <<EOF
 SELECT pglogical.create_subscription(
     subscription_name := 'subscription1',
     provider_dsn := 'host=master port=5432 dbname=test_replication user=rep'
 );
EOF


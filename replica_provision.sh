#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


echo "beginning replica-specific config:"

# create the subscriber node
echo "creating the subscriber node"
sudo su postgres -c psql <<EOF
 \c test_replication;
 SELECT pglogical.create_node(node_name := 'subscriber1', dsn := 'host=192.168.33.10 port=5432 dbname=test_replication user=rep');
EOF

# http://2ndquadrant.com/en-us/resources/pglogical/pglogical-docs/

echo "creating test_replication subscription"
sudo su postgres -c psql <<EOF
 \c test_replication
 SELECT pglogical.create_subscription(
     subscription_name := 'subscription1',
     provider_dsn := 'host=db port=5432 dbname=test_replication user=pe-classifier password=puppetlabs',
     synchronize_structure := TRUE
 );
EOF

echo "creating orchestrator subscription"
sudo su postgres -c psql <<EOF
 \c pe-orchestrator
 SELECT pglogical.create_node(node_name := 'orchestrator_subscriber',
                              dsn := 'host=192.168.33.10 port=5432 dbname=pe-orchestrator user=pe-orchestrator password=puppetlabs');
 SELECT pglogical.create_subscription(
     subscription_name := 'orchestrator_sub',
     provider_dsn := 'host=db port=5432 dbname=pe-orchestrator user=pe-orchestrator password=puppetlabs',
     synchronize_structure := TRUE
 );
EOF

echo "creating activity subscription"
sudo su postgres -c psql <<EOF
 \c pe-activity
 SELECT pglogical.create_node(node_name := 'activity_subscriber',
                              dsn := 'host=192.168.33.10 port=5432 dbname=pe-activity user=pe-activity password=puppetlabs');
 SELECT pglogical.create_subscription(
     subscription_name := 'activity_sub',
     provider_dsn := 'host=db port=5432 dbname=pe-activity user=pe-activity password=puppetlabs',
     synchronize_structure := TRUE
 );
EOF

echo "creating classifier subscription"
sudo su postgres -c psql <<EOF
 \c pe-classifier
 SELECT pglogical.create_node(node_name := 'classifier_subscriber',
                              dsn := 'host=192.168.33.10 port=5432 dbname=pe-classifier user=pe-classifier password=puppetlabs');
 SELECT pglogical.create_subscription(
     subscription_name := 'classifier_sub',
     provider_dsn := 'host=db port=5432 dbname=pe-classifier user=pe-classifier password=puppetlabs',
     synchronize_structure := TRUE
 );
EOF

echo "creating rbac subscription"
sudo su postgres -c psql <<EOF
 \c pe-rbac
 SELECT pglogical.create_node(node_name := 'rbac_subscriber',
                              dsn := 'host=192.168.33.10 port=5432 dbname=pe-rbac user=pe-rbac password=puppetlabs');
 SELECT pglogical.create_subscription(
     subscription_name := 'rbac_sub',
     provider_dsn := 'host=db port=5432 dbname=pe-rbac user=pe-rbac password=puppetlabs',
     synchronize_structure := TRUE
 );
EOF

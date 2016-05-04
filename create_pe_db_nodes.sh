#!/bin/bash
set -euo pipefail

echo "creating pglogical nodes for PE databases"
sudo su postgres -c psql <<EOF
  \c pe-orchestrator
  SELECT pglogical.create_node(node_name := 'orchestrator_provider',
                               dsn := 'host=192.168.33.2 port=5432 dbname=pe-orchestrator');
  SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);

  \c pe-puppetdb
  SELECT pglogical.create_node(node_name := 'puppetdb_provider',
                               dsn := 'host=192.168.33.2 port=5432 dbname=pe-puppetdb');
  SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);

  \c pe-activity
  SELECT pglogical.create_node(node_name := 'activity_provider',
                               dsn := 'host=192.168.33.2 port=5432 dbname=pe-activity');
  SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);

  \c pe-classifier
  SELECT pglogical.create_node(node_name := 'classifier_provider',
                               dsn := 'host=192.168.33.2 port=5432 dbname=pe-classifier');
  SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);

  \c pe-rbac
  SELECT pglogical.create_node(node_name := 'rbac_provider',
                               dsn := 'host=192.168.33.2 port=5432 dbname=pe-rbac');
  SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);
EOF

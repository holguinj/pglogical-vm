#!/bin/bash
set -euo pipefail

# database setup
sudo su postgres -c psql <<EOF
 \c spike-classifier
 CREATE ROLE "readonly-classifier" LOGIN PASSWORD 'readonly-classifier';
 ALTER DEFAULT PRIVILEGES FOR ROLE "readonly-classifier" IN SCHEMA public
   GRANT SELECT ON TABLES TO "readonly-classifier";

 CREATE EXTENSION pglogical_origin;
 CREATE EXTENSION pglogical;
 SELECT pglogical.create_node(node_name := 'spike_classifier_subscriber',
                              dsn := 'host=192.168.33.10 port=5432 dbname=spike-classifier user=replicator password=replicator');
 SELECT pglogical.create_subscription(
     subscription_name := 'spike_classifier_sub',
     provider_dsn := 'host=db port=5432 dbname=spike-classifier user=replicator password=replicator',
     synchronize_structure := TRUE
 );

 \c perbac_test
 CREATE EXTENSION pglogical_origin;
 CREATE EXTENSION pglogical;
 SELECT pglogical.create_node(node_name := 'spike_rbac_subscriber',
                              dsn := 'host=192.168.33.10 port=5432 dbname=perbac_test user=replicator password=replicator');
 SELECT pglogical.create_subscription(
     subscription_name := 'spike_rbac_sub',
     provider_dsn := 'host=db port=5432 dbname=perbac_test user=replicator password=replicator',
     synchronize_structure := TRUE
 );

 \c activity
 CREATE EXTENSION pglogical_origin;
 CREATE EXTENSION pglogical;
 SELECT pglogical.create_node(node_name := 'spike_activity_subscriber',
                              dsn := 'host=192.168.33.10 port=5432 dbname=activity user=replicator password=replicator');
 SELECT pglogical.create_subscription(
     subscription_name := 'spike_activity_sub',
     provider_dsn := 'host=db port=5432 dbname=activity user=replicator password=replicator',
     synchronize_structure := TRUE
 );

EOF

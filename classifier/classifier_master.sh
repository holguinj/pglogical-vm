#!/bin/bash
set -euo pipefail

# database setup
sudo su postgres -c psql <<EOF
 \c spike-classifier
 CREATE EXTENSION pglogical_origin;
 CREATE EXTENSION pglogical;
 SELECT pglogical.create_node(node_name := 'spike_classifier_provider',
                              dsn := 'host=192.168.33.2 port=5432 dbname=spike-classifier');
 -- ALTER TABLE schema_migrations ADD PRIMARY KEY (id);
 ALTER TABLE last_sync ADD PRIMARY KEY (time);
 SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public'], TRUE);

 \c perbac_test
 CREATE EXTENSION pglogical_origin;
 CREATE EXTENSION pglogical;
 SELECT pglogical.create_node(node_name := 'spike_rbac_provider',
                              dsn := 'host=192.168.33.2 port=5432 dbname=perbac_test');
 ALTER TABLE schema_migrations ADD PRIMARY KEY (id);
 SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public'], TRUE);

 \c activity
 CREATE EXTENSION pglogical_origin;
 CREATE EXTENSION pglogical;
 SELECT pglogical.create_node(node_name := 'spike_activity_provider',
                              dsn := 'host=192.168.33.2 port=5432 dbname=activity');
 ALTER TABLE schema_migrations ADD PRIMARY KEY (id);
 SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public'], TRUE);
EOF

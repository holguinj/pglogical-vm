#!/bin/bash
set -euo pipefail

echo "creating PE users/databases"
sudo su postgres -c psql <<EOF
  CREATE USER "pe-orchestrator" PASSWORD 'puppetlabs';
  CREATE DATABASE "pe-orchestrator" OWNER "pe-orchestrator" ENCODING 'utf8' LC_CTYPE 'en_US.utf8' LC_COLLATE 'en_US.utf8' template template0;
  \c pe-orchestrator
  CREATE EXTENSION IF NOT EXISTS pglogical;
  SELECT pglogical.create_node(node_name := 'orchestrator_provider', dsn := 'host=192.168.33.2 port=5432 dbname=pe-orchestrator');

  CREATE USER "pe-puppetdb" PASSWORD 'puppetlabs';
  CREATE DATABASE "pe-puppetdb" OWNER "pe-puppetdb" ENCODING 'utf8' LC_CTYPE 'en_US.utf8' LC_COLLATE 'en_US.utf8' template template0;
  \c pe-puppetdb
  CREATE EXTENSION IF NOT EXISTS pglogical;
  CREATE EXTENSION IF NOT EXISTS pg_trgm;
  CREATE EXTENSION IF NOT EXISTS pgcrypto;
  SELECT pglogical.create_node(node_name := 'puppetdb_provider', dsn := 'host=192.168.33.2 port=5432 dbname=pe-puppetdb');

  CREATE USER "pe-activity" PASSWORD 'puppetlabs';
  CREATE DATABASE "pe-activity" OWNER "pe-activity" ENCODING 'utf8' LC_CTYPE 'en_US.utf8' LC_COLLATE 'en_US.utf8' template template0;
  \c pe-activity
  CREATE EXTENSION IF NOT EXISTS pglogical;
  SELECT pglogical.create_node(node_name := 'activity_provider', dsn := 'host=192.168.33.2 port=5432 dbname=pe-activity');

  CREATE USER "pe-classifier" PASSWORD 'puppetlabs';
  CREATE DATABASE "pe-classifier" OWNER "pe-classifier" ENCODING 'utf8' LC_CTYPE 'en_US.utf8' LC_COLLATE 'en_US.utf8' template template0;
  \c pe-classifier
  CREATE EXTENSION IF NOT EXISTS pglogical;
  SELECT pglogical.create_node(node_name := 'classifier_provider', dsn := 'host=192.168.33.2 port=5432 dbname=pe-classifier');

  CREATE USER "pe-rbac" PASSWORD 'puppetlabs';
  CREATE DATABASE "pe-rbac" OWNER "pe-rbac" ENCODING 'utf8' LC_CTYPE 'en_US.utf8' LC_COLLATE 'en_US.utf8' template template0;
  \c pe-rbac
  CREATE EXTENSION IF NOT EXISTS pglogical;
  CREATE EXTENSION IF NOT EXISTS citext;
  SELECT pglogical.create_node(node_name := 'rbac_provider', dsn := 'host=192.168.33.2 port=5432 dbname=pe-rbac');
EOF


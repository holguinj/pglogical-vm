#!/bin/bash
set -euo pipefail

echo "creating PE users/databases"
sudo su postgres -c psql <<EOF
  CREATE ROLE "pe-orchestrator" WITH SUPERUSER LOGIN PASSWORD 'puppetlabs';
  CREATE DATABASE "pe-orchestrator" OWNER "pe-orchestrator" ENCODING 'utf8' LC_CTYPE 'en_US.utf8' LC_COLLATE 'en_US.utf8' template template0;
  \c pe-orchestrator
  CREATE EXTENSION IF NOT EXISTS pglogical;
  CREATE EXTENSION IF NOT EXISTS pglogical_origin;

  CREATE ROLE "pe-puppetdb" WITH SUPERUSER LOGIN PASSWORD 'puppetlabs';
  CREATE DATABASE "pe-puppetdb" OWNER "pe-puppetdb" ENCODING 'utf8' LC_CTYPE 'en_US.utf8' LC_COLLATE 'en_US.utf8' template template0;
  \c pe-puppetdb
  CREATE EXTENSION IF NOT EXISTS pg_trgm;
  CREATE EXTENSION IF NOT EXISTS pgcrypto;

  CREATE ROLE "pe-activity" WITH SUPERUSER LOGIN PASSWORD 'puppetlabs';
  CREATE DATABASE "pe-activity" OWNER "pe-activity" ENCODING 'utf8' LC_CTYPE 'en_US.utf8' LC_COLLATE 'en_US.utf8' template template0;
  \c pe-activity
  CREATE EXTENSION IF NOT EXISTS pglogical;
  CREATE EXTENSION IF NOT EXISTS pglogical_origin;

  CREATE ROLE "pe-classifier" WITH SUPERUSER LOGIN PASSWORD 'puppetlabs';
  CREATE DATABASE "pe-classifier" OWNER "pe-classifier" ENCODING 'utf8' LC_CTYPE 'en_US.utf8' LC_COLLATE 'en_US.utf8' template template0;
  \c pe-classifier
  CREATE EXTENSION IF NOT EXISTS pglogical;
  CREATE EXTENSION IF NOT EXISTS pglogical_origin;

  CREATE ROLE "pe-rbac" WITH SUPERUSER LOGIN PASSWORD 'puppetlabs';
  CREATE DATABASE "pe-rbac" OWNER "pe-rbac" ENCODING 'utf8' LC_CTYPE 'en_US.utf8' LC_COLLATE 'en_US.utf8' template template0;
  \c pe-rbac
  CREATE EXTENSION IF NOT EXISTS pglogical;
  CREATE EXTENSION IF NOT EXISTS pglogical_origin;
  CREATE EXTENSION IF NOT EXISTS citext;
EOF

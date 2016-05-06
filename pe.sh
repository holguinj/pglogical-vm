#!/bin/bash
set -euo pipefail

PE_VERSION="puppet-enterprise-2016.2.0-rc1-112-ga08a2ea-ubuntu-14.04-amd64"

echo "downloading PE"
wget --no-verbose http://enterprise.delivery.puppetlabs.net/2016.2/ci-ready/$PE_VERSION.tar

echo "expanding PE"
tar xf $PE_VERSION.tar

echo "running PE installer with answer file"
cd $PE_VERSION
sudo ./puppet-enterprise-installer -D -a /vagrant/answerfile-external-pg

echo "extra configuration for PE databases"
sudo apt-get install -y postgresql-client-common postgresql-client-9.3
PGPASSWORD=puppetlabs psql -h db -U pe-classifier <<EOF
 \c pe-orchestrator
 SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public'], TRUE);

 \c pe-activity
 ALTER TABLE schema_migrations ADD PRIMARY KEY (id);
 SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public'], TRUE);

 \c pe-classifier
 ALTER TABLE schema_migrations ADD PRIMARY KEY (id);
 ALTER TABLE last_sync ADD PRIMARY KEY (time);
 SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public'], TRUE);

 \c pe-rbac
 ALTER TABLE schema_migrations ADD PRIMARY KEY (id);
 SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public'], TRUE);

EOF

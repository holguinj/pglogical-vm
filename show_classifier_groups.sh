#!/bin/bash
set -euo pipefail

echo "SMOKE TEST:"

echo "selecting messages on the db node for reference:"
PGPASSWORD=puppetlabs psql -h db -U pe-classifier <<EOF
 \c test_replication
 SELECT * FROM messages;
EOF

echo "selecting messages on the replica node:"
sudo su postgres -c psql <<EOF
 \c test_replication
 SELECT * FROM messages;
EOF

echo "selecting classifier groups on the db node for reference:"
PGPASSWORD=puppetlabs psql -h db -U pe-classifier <<EOF
 \c pe-classifier;
 SELECT * FROM groups;
EOF

echo "selecting * from groups on the replica"
sudo su postgres -c psql <<EOF
 \c pe-classifier;
 SELECT * FROM groups;
EOF

echo "selecting rbac roles on the db node for reference:"
PGPASSWORD=puppetlabs psql -h db -U pe-rbac <<EOF
 \c pe-rbac;
 SELECT * FROM roles;
EOF

echo "selecting * from roles on the replica"
sudo su postgres -c psql <<EOF
 \c pe-rbac;
 SELECT * FROM roles;
EOF

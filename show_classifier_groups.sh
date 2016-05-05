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

echo "selecting * from groups. If this fails, replication isn't working."
sudo su postgres -c psql <<EOF
 \c pe-classifier;
 SELECT * FROM groups;
EOF

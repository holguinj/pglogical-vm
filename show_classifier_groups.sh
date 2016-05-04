#!/bin/bash
set -euo pipefail

echo "SMOKE TEST: selecting * from groups. If this fails, replication isn't working."
sudo su postgres -c psql <<EOF
 \c pe-classifier;
 SELECT * FROM groups;
EOF

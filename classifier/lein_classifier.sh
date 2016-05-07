#!/bin/bash
set -euo pipefail

# database setup
sudo su postgres -c psql <<EOF
 CREATE USER "spike-classifier" LOGIN PASSWORD 'spike-classifier';
 CREATE DATABASE "spike-classifier" WITH OWNER="spike-classifier";

 CREATE USER perbac LOGIN PASSWORD 'foobar';
 CREATE DATABASE perbac_test WITH OWNER=perbac;
 \c perbac_test
 CREATE EXTENSION IF NOT EXISTS citext;

 CREATE USER activity LOGIN PASSWORD 'activity';
 CREATE DATABASE activity WITH OWNER=activity;
EOF

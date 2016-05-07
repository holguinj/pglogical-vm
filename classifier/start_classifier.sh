#!/bin/bash
set -euo pipefail

cd /vagrant/classifier/classifier
lein run --config ../spike-conf.d &

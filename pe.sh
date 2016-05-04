#!/bin/bash
set -euo pipefail

PE_VERSION="puppet-enterprise-2016.2.0-rc1-92-gb20e673-ubuntu-14.04-amd64"

echo "downloading PE"
wget --no-verbose http://enterprise.delivery.puppetlabs.net/2016.2/ci-ready/$PE_VERSION.tar

echo "expanding PE"
tar xf $PE_VERSION.tar

echo "running PE installer with answer file"
cd $PE_VERSION
sudo ./puppet-enterprise-installer -D -a /vagrant/answerfile-external-pg

#!/bin/bash
set -euo pipefail

PE_SHA="gad695e2"
PE_VERSION="puppet-enterprise-2016.2.0-rc1-68-$PE_SHA-ubuntu-14.04-amd64"
echo "downloading PE"
wget --no-verbose http://enterprise.delivery.puppetlabs.net/2016.2/ci-ready/$PE_VERSION.tar

tar xf $PE_VERSION.tar
cd $PE_VERSION
echo "skipping actual install"
echo "take this opportunity to manually edit the installer to allow postgres 9.5"
# sudo ./puppet-enterprise-installer -D -a /vagrant/answerfile-external-pg

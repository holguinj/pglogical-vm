#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# install jdk8 ! insecure!
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y oracle-java8-installer oracle-java8-set-default

# install leiningen
wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
sudo chmod +x lein
sudo cp lein /usr/bin/lein

# let lein complete its installation
LEIN_ROOT=TRUE lein help

# install git
sudo apt-get install -y git

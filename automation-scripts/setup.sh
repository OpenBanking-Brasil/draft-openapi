#!/usr/bin/env bash


# Execute this script to setup your environment
# This file must be allowed to be an executable. If it is still not executable, run the following command: sudo chmod 777 setup.sh
# Usage: sudo ./setup.sh

# Also see recommended VSCode extensions for this project: YAML, OpenAPI(Swagger) Editor, VSCode Ruby, Edit csv, Spectral, GitHub Pull Requests and Issues.

echo "Iniciando operação"

# exit when any command fails
set -e

echo "apt update"
# Update your apt package list
apt-add-repository ppa:brightbox/ruby-ng
apt update

echo "Installing RUBY"
apt install curl gnupg2 
curl -sSL https://rvm.io/mpapis.asc | sudo gpg2 --import - 
curl -sSL https://rvm.io/pkuczynski.asc | sudo gpg2 --import - 
curl -sSL https://get.rvm.io | sudo bash -s stable 
source /etc/profile.d/rvm.sh 
rvm requirements 

rvm install 2.6
rvm use 2.6 --default 

wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64

chmod a+x /usr/local/bin/yq

apt install jq -y

echo "Installing NODE"
apt install nodejs
npm install -g @apidevtools/swagger-cli

echo "Installing python"
# Install pip
apt install python3-pip

# Install openapi-spec-validator
pip install openapi-spec-validator

echo "Installing GIT"
# Install git
apt install git -y


#!/usr/bin/env bash

apt-get update
apt-get install -y git curl nodejs screen ruby ruby-dev
echo 'gem: --no-document' >> /home/vagrant/.gemrc
gem install bundler
cd /vagrant && bundle install
echo "alias srv='cd /vagrant/ && rails s -b 0.0.0.0'" >> /home/vagrant/.bashrc
echo ".mode column" > /home/vagrant/.sqliterc
echo ".headers on" >> /home/vagrant/.sqliterc
sudo locale-gen UTF-8
git config --global color.ui true
git config --global core.autocrlf input
git config --global core.filemode false

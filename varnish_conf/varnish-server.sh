#!/bin/bash

sudo apt update && sudo apt -y full-upgrade
sudo apt install debian-archive-keyring curl gnupg apt-transport-https -y
curl -fsSL https://packagecloud.io/varnishcache/varnish70/gpgkey|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/varnish.gpg

. /etc/os-release
sudo tee /etc/apt/sources.list.d/varnishcache_varnish70.list > /dev/null <<-EOF
deb https://packagecloud.io/varnishcache/varnish70/$ID/ $VERSION_CODENAME main
deb-src https://packagecloud.io/varnishcache/varnish70/$ID/ $VERSION_CODENAME main
EOF

sudo apt update
sudo apt install varnish -y

cd /tmp
sudo cp varnish.service /etc/systemd/system/
sudo rm /etc/varnish/default.vcl
sudo cp default.vcl /etc/varnish/
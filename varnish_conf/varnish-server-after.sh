#!/bin/bash

sudo sed -i "s/99.99.99.99/$magento_private_ip/g" /etc/varnish/default.vcl
sudo systemctl daemon-reload
sudo systemctl stop varnish
sudo systemctl start varnish

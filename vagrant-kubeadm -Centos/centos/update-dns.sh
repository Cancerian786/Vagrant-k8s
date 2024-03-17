#!/bin/bash

sed -i -e 's/#DNS=/DNS=8.8.8.8/' /etc//resolv.conf
sed -i -e 's/#DNS=/DNS=192.168.0.1/' /etc//resolv.conf

# service systemd-resolved restart
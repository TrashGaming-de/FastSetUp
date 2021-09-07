#!/bin/bash

### upgrading packages

apt_upgrade()
{
  echo "upgrading packages"
  apt update
  apt upgrade -y
}

### Main script

echo "installing Nextcloud"
apt_upgrade

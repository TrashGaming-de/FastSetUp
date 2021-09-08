#!/bin/bash

### upgrading packages

apt_upgrade()
{
  echo "upgrading packages"
  apt update
  apt upgrade -y
}

### apache2 & PHP8

apache2_PHP8_installation()
{
  echo "installing packages"
  apt install ca-certificates apt-transport-https lsb-release gnupg curl nano unzip -y
  echo "adding package-source for PHP8"
  wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
  apt_upgrade
  echo "installing apache2 and PHP8"
  apt install apache2 -y
  apt install php8.0 php8.0-cli php8.0-common php8.0-curl php8.0-gd php8.0-intl php8.0-mbstring php8.0-mysql php8.0-opcache php8.0-readline php8.0-xml php8.0-xsl php8.0-zip php8.0-bz2 libapache2-mod-php8.0 -y
}

### installing MariaDB

MariaDB_installation()
{
  echo "installing MariaDB"
  apt install mariadb-server mariadb-client -y
  echo "enter root_password: "
  read root_password
  mysql -e "UPDATE mysql.user SET Password = PASSWORD('$root_password') WHERE User = 'root'"
  mysql -e "DROP USER IF EXISTS ''@'localhost'"
  mysql -e "DROP USER IF EXISTS ''@'$(hostname)'"
  mysql -e "DROP DATABASE IF EXISTS test"
  echo "creating secondary user for MariaDB"
  echo "enter username: "
  read user_name
  echo "enter userpassword: "
  read user_password
  mysql -e "CREATE USER '${user_name}'@'localhost' IDENTIFIED BY '${user_password}'"
  mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${user_name}'@'localhost' WITH GRANT OPTION"
}

###

phpMyAdmin_installation()
{
  echo "installing phpmyadmin"
  cd /usr/share
  wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O phpmyadmin.zip
  unzip phpmyadmin.zip
  rm phpmyadmin.zip
  mv phpMyAdmin-*-all-languages phpmyadmin
  chmod -R 0755 phpmyadmin
  echo "# phpMyAdmin Apache configuration

Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php
</Directory>

# Disallow web access to directories that don't need it
<Directory /usr/share/phpmyadmin/templates>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>" > /etc/apache2/conf-available/phpmyadmin.conf
  echo "activating phpmyadmin and reloading apache2 deamon"
  a2enconf phpmyadmin
  systemctl reload apache2
  mkdir /usr/share/phpmyadmin/tmp/
  chown -R www-data:www-data /usr/share/phpmyadmin/tmp/
}

### This is the main function

QSS()
{
  echo "Are you ready? [y/n]"
  read Ready
  if [ $Ready = "n" ]
  then
    exit 0
  elif [ $Ready = "y" ]
  then
    echo "We will now start the installation process..."
    apt_upgrade
    apache2_PHP8_installation
    MariaDB_installation
    phpMyAdmin_installation
    echo "Setup completed"
    exit 0
    esac
  else
    echo "Try again!"
    QSS
  fi
}

### Ask for Additions

Request_Additions()
{
  echo "Should any additional programms be installed [y/n]"
  read yn_additions
  if [ $yn_additions = "n" ]
  then
    exit 0
  elif [ $yn_additions = "y" ]
  then
    echo "Commencing installation. To see which programms are available look at: "
    echo https://github.com/TrashGaming-de/FastSetUp
    echo "So which additional program should be installed first?: "
    read addition
    echo "Searching for ${addition}"
    Which_Addition
    while [ $addition != "" ]
    do
      echo "Which program should be installed next? (leave empty to exit)"
      read addition
      if [ $addition != "" ]
      then
        echo "Searching for ${addition}"
        Which_Addition
      else
        echo "left empty beginning exit"
      fi
    done
  fi
}

### Check which Additional program should be installed

Which_Addition
{
  if [ $addition = "Nextcloud" ]
  then
    bash ./Additions/Add_Nextcloud.sh
  else
    echo "Unknown program, returning to the begin..."
    Request_Additions
  fi
}

### Main script starts here

cd
echo "TrashGamingDE - Quick-Server-Setup (QSS)v0.1"
echo "This script needs to be executed as root! (It is not yet configured to be executed otherwise.)"
echo "This setup-programm was created for one specific case! Please mind, that it might not install everything you need or even to much."
echo "Additionally: This script currently only works properly on Debian!"
echo "It is possible, that a configurable setup-process will be used in the future."
QSS
Request_Additions
exit 0

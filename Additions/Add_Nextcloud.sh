#!/bin/bash

### upgrading packages

apt_upgrade()
{
  echo "upgrading packages"
  apt update
  apt upgrade -y
}

### Main script

cd
echo "installing Nextcloud"
apt_upgrade
cd /var/www/html
wget https://download.nextcloud.com/server/releases/latest.tar.bz2
tar xfvj latest.tar.bz2
rm latest.tar.bz2
a2enmod rewrite
systemctl restart apache2
chown -R www-data:www-data /var/www/html/nextcloud/
echo "Als nächstes müssen Sie die für die Nextcloud benötigte Datenbank anlegen. Rufen Sie hierzu phpMyAdmin im Browser auf, indem Sie hinter der IP-Adresse oder Domain Ihres Servers \"/phpmyadmin\" anhängen und loggen Sie sich dort ein (wie in der Apache2-Anleitung beschrieben).
Klicken Sie oben auf den Reiter \"Benutzerkonten\" und anschließend auf \"Benutzerkonto hinzufügen\" [Enter]."
read
echo "Vergeben Sie nun einen Benutzernamen (z.B. \"nextcloud\") sowie ein Passwort für den Datenbank-Benutzer. [Enter]"
read
echo "Anschließend müssen Sie noch den Haken \"Erstelle eine Datenbank mit gleichem Namen und gewähre alle Rechte\" setzen, damit neben dem Datenbank-Benutzer auch die Datenbank selbst erstellt wird. Der Datenbankname ist dann der gleiche wie der Benutzername, den Sie angegeben haben.
Klicken Sie danach am Ende der Seite auf den Button \"OK\" (rechts). Somit haben Sie die Datenbank inklusive Datenbank-Benutzer angelegt. [Enter]"
read
echo "Rufen Sie als nächstes die Nextcloud im Browser auf. Die URL ist die IP-Adresse oder Domain Ihres Servers, gefolgt von \"/nextcloud\". Es erscheint die Einrichtungsseite.
Erstellen Sie nun ein Administrator-Konto für die Nextcloud, mit welchem Sie sich später einloggen können. Geben Sie dazu im Textfeld \"Benutzername\" Ihren gewünschten Benutzernamen und im Textfeld \"Passwort\" dementsprechend Ihr gewünschtes Passwort ein.
Anschließend müssen Sie den Datenbank-Benutzernamen (z.B. \"nextcloud\"), das Passwort für diesen Benutzer und den Datenbanknamen (der gleiche wie der Datenbank-Benutzername) der vorhin über phpMyAdmin erstellen Datenbank in die dafür vorgesehenen Textfelder eintragen.
Klicken Sie auf den Button \"Installation abschließen\", um die Installation fertigzustellen."
sed -i '/DocumentRoot/a<Directory /var/www/html>
    AllowOverride All
</Directory>' /etc/apache2/sites-available/000-default.conf
systemctl reload apache2
cd

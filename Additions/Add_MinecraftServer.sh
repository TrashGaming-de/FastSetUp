#!/bin/bash

### upgrading packages

apt_upgrade()
{
  echo "upgrading packages"
  apt update
  apt upgrade -y
}

### Download Minecraft

dwnld_minecraft()
{
  minecraft_ram = "4096"
  echo "Enter \"Spigot\" or \"Craftbukkit\":"
  read minecraft_edit
  echo "Enter Minecraft-Version:"
  read minecraft_version
  echo "Enter Minecraft-Server-RAM in Mb:"
  read minecraft_ram
  if [ ${minecraft_edit} = "Spigot" ]
  then
    wget https://download.getbukkit.org/spigot/spigot-${minecraft_version}.jar
    echo "screen -AmdS minecraft java -Xms${minecraft_ram}M -Xmx${minecraft_ram}M -jar /home/minecraft/spigot-${minecraft_version}.jar nogui" > start.sh
    echo "screen -r minecraft -X quit" > stop.sh
  elif [ ${minecraft_edit} = "Craftbukkit" ]
  then
    wget https://download.getbukkit.org/craftbukkit/craftbukkit-${minecraft_version}.jar
    echo "screen -AmdS minecraft java -Xms${minecraft_ram}M -Xmx${minecraft_ram}M -jar /home/minecraft/craftbukkit-${minecraft_version}.jar nogui" > start.sh
    echo "screen -r minecraft -X quit" > stop.sh
  else
    echo "Not readable Minecraft Edit"
    dwnld_minecraft
  fi
}

### Main script

cd
echo "installing Minecraft-Server"
apt_upgrade
echo "installing Java first"
apt install gnupg curl dirmngr nano unzip -y
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 73C3DB2A
echo "deb http://ppa.launchpad.net/linuxuprising/java/ubuntu focal main" | tee /etc/apt/sources.list.d/java.list
apt_upgrade
apt install oracle-java16-installer -y
echo "installing screen"
apt install screen -y
echo "setting up \"minecraft\" user"
adduser --disabled-login minecraft
su minecraft
cd
dwnld_minecraft
chmod +x start.sh stop.sh
echo "eula = true" > eula.txt
echo "starting minecraft"
su minecraft
./start.sh
script /dev/null
screen -r minecraft
echo "completed"
exit 0

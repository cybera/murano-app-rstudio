#!/bin/bash

# Enable updates, if available
if [[ -f /usr/local/bin/enableAutoUpdate ]]; then
  /usr/local/bin/enableAutoUpdate
fi

# Make a directory under /opt
mkdir /opt/rstudio

# Mount a volume, if one was specified
vol="/dev/$(lsblk -o name,type,mountpoint,label,uuid | grep -v root | grep -v ephem | grep -v SWAP | grep -v sda | grep -v vda | grep -v NAME| tail -1 | awk '{print $1}')"
if [[ "${vol}" != "/dev/" ]]; then
  fs=$(blkid -o value -s TYPE $vol)
  if [[ $fs != "ext4" ]]; then
    mkfs -t ext4 $vol
  fi

  mount $vol /opt/rstudio
  uuid=$(lsblk -o name,type,mountpoint,label,uuid | grep -v root | grep -v ephem | grep -v SWAP | grep -v sda | grep -v vda | grep -v NAME| tail -1 | awk '{print $4}')
  echo "UUID=${uuid} /opt/rstudio ext4 defaults 0 1 " | tee --append  /etc/fstab
fi

# Add a user
useradd -m rstudio -d /opt/rstudio
echo rstudio:%PASSWORD% | /usr/sbin/chpasswd
chown -R rstudio: /opt/rstudio

# Install and configure rstudio
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
echo "deb http://muug.ca/mirror/cran/bin/linux/ubuntu xenial/" > /etc/apt/sources.list.d/r.list
apt-get update
apt-get install -y r-base gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.0.153-amd64.deb
/usr/bin/gdebi -n rstudio-server-1.0.153-amd64.deb

echo "www-address=::" | tee -a /etc/rstudio/rserver.conf
echo "www-port=80" | tee -a /etc/rstudio/rserver.conf
service rstudio-server restart

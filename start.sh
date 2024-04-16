#!/usr/bin/env bash

IFS=': ' read -r -a bios <<< "$MOUNT_BIOS"
if [ ! -d "/mnt/bios" ]; then
    mkdir -p /mnt/bios
else
    findmnt -T /mnt/bios
    if [ $? -eq 0 ]; then
        echo "/mnt/bios is mounted, proceed to unmount..."
        umount -l /mnt/bios
    fi
fi
if [ ! -d "/mnt/cise" ]; then
    mkdir -p /mnt/cise
else
    findmnt -T /mnt/cise
    if [ $? -eq 0 ]; then
        echo "/mnt/cise is mounted, proceed to unmount..."
        umount -l /mnt/cise
    fi
fi
chmod 777 -R /mnt/bios
chmod 777 -R /mnt/cise
cd /etc
if [ -d "/etc/cifs-credentials" ]; then
    rm -rf cifs-credentials
fi
echo -e "username=${FACELESS_USR}\npassword=${FACELESS_PWD}" > cifs-credentials
#Retry a few times to mount
max_iteration=3
for i in $(seq 1 $max_iteration); do
    mount -t cifs -o user=${FACELESS_USR},password=${FACELESS_PWD},domain=amd,vers=3.0 ${PNG_DRIVE_PATH} /mnt/cise
    result=$?
    if [[ $result -eq 0 ]]
    then
      echo "Mount successful"
      break
    else
      echo "Mount unsuccessful"
      sleep 1
    fi
done
#If all trials not successful then exit
if [[ $result -ne 0 ]]
then
  exit 1
fi
mount -t cifs -o credentials=/etc/cifs-credentials ${BIOS_DRIVE_PATH} /mnt/bios
cd /var
if [ ! -d "/var/www/" ] 
then
   mkdir -p /var/www/
fi
chmod 777 -R /var/www/
if [ -d "/var/www/html" ]; 
then
    echo "folder exist, removing folder..."
    rm -rf /var/www/html
    ln -sf /mnt/cise/file_service/$SERVICE /var/www/html
else
    ln -sf /mnt/cise/file_service/$SERVICE /var/www/html
fi
for folder in "${bios[@]}"; do
   if [ -d "/var/www/html/dist/bios/$folder" ]
   then
        rm -rf /var/www/html/dist/bios/$folder*/
   fi
   mkdir -p /var/www/html/dist/bios/$folder
   mount -t cifs -o credentials=/etc/cifs-credentials ${BIOS_DRIVE_PATH}/$folder /var/www/html/dist/bios/$folder
done

service ssh start

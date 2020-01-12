#!/usr/bin/env bash

# file names & paths
tmp="$(pwd)" # destination folder to store the final iso file
hostname="coderdojo-clean"

# define spinner function for slow tasks
# courtesy of http://fitnr.com/showing-a-bash-spinner.html
spinner() {
  local pid=$1
  local delay=0.75
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# define download function
# courtesy of http://fitnr.com/showing-file-download-progress-using-wget.html
download() {
  local url=$1
  echo -n "    "
  wget --progress=dot $url 2>&1 | grep --line-buffered "%" |
    sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
  echo -ne "\b\b\b\b"
  echo " DONE"
}

# define function to check if program is installed
# courtesy of https://gist.github.com/JamieMason/4761049
function program_is_installed() {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0; }
  # return value
  echo $return_
}

# print a pretty header
echo
echo " +---------------------------------------------------+"
echo " |            UNATTENDED UBUNTU ISO MAKER            |"
echo " +---------------------------------------------------+"
echo

# ask if script runs without sudo or root priveleges
if [ $UID != 0 ]; then
  echo " you need sudo privileges to run this script, or run it as root"
  exit 1
fi

#get the latest versions of Ubuntu LTS

tmphtml=$tmp/tmphtml
rm $tmphtml >/dev/null 2>&1
wget -O $tmphtml 'http://releases.ubuntu.com/' >/dev/null 2>&1

bion=$(fgrep Bionic $tmphtml | head -1 | awk '{print $3}' | sed 's/href=\"//; s/\/\"//')
bion_vers=$(fgrep Bionic $tmphtml | head -1 | awk '{print $6}')

# ask whether to include vmware tools or not
download_file="ubuntu-$bion_vers-server-amd64.iso"
download_location="http://cdimage.ubuntu.com/releases/$bion/release/"
new_iso_name="ubuntu-unattended.iso"

if [ -f /etc/timezone ]; then
  timezone=$(cat /etc/timezone)
elif [ -h /etc/localtime ]; then
  timezone=$(readlink /etc/localtime | sed "s/\/usr\/share\/zoneinfo\///")
else
  checksum=$(md5sum /etc/localtime | cut -d' ' -f1)
  timezone=$(find /usr/share/zoneinfo/ -type f -exec md5sum {} \; | grep "^$checksum" | sed "s/.*\/usr\/share\/zoneinfo\///" | head -n 1)
fi

# ask the user questions about his/her preferences
username=coderdojo
pwhash='x'
[[ -f unattended-parameters.env ]] && source unattended-parameters.env # override params here

if [[ "${pwhash}" == "x" ]]; then
  echo "No default password set in 'unattended-parameters.env'. You may not be able to log in!"
fi

# download the ubuntu iso. If it already exists, do not delete in the end.
cd $tmp
if [[ ! -f $tmp/$download_file ]]; then
  echo -n " downloading $download_file: "
  download "$download_location$download_file"
fi
if [[ ! -f $tmp/$download_file ]]; then
  echo "Error: Failed to download ISO: $download_location$download_file"
  echo "This file may have moved or may no longer exist."
  echo
  echo "You can download it manually and move it to $tmp/$download_file"
  echo "Then run this script again."
  exit 1
fi

# download coderdojo seed file
seed_file="coderdojo.seed"
if [[ ! -f $tmp/$seed_file ]]; then
  echo -n " downloading $seed_file: "
  download "https://raw.githubusercontent.com/CoderDojoRotselaar/os-config/master/bootstrap/$seed_file"
fi

# create working folders
echo " remastering your iso file"
mkdir -p $tmp
mkdir -p $tmp/iso_org
mkdir -p $tmp/iso_new

# mount the image
if grep -qs $tmp/iso_org /proc/mounts; then
  echo " image is already mounted, continue"
else
  (mount -o loop $tmp/$download_file $tmp/iso_org >/dev/null 2>&1)
fi

# copy the iso contents to the working directory
(cp -rT $tmp/iso_org $tmp/iso_new >/dev/null 2>&1) &
spinner $!

# set the language for the installation menu
cd $tmp/iso_new
#doesn't work for 16.04
echo en >$tmp/iso_new/isolinux/lang

# copy the coderdojo seed file to the iso
cp -rT $tmp/$seed_file $tmp/iso_new/preseed/$seed_file

cat <<EOF >>$tmp/iso_new/preseed/$seed_file
${extra_preseed}
EOF
# include firstrun script
cat <<EOF >>$tmp/iso_new/preseed/$seed_file
# setup firstrun script
d-i preseed/late_command                                    string      \
  wget https://raw.githubusercontent.com/CoderDojoRotselaar/os-config/master/bootstrap/predeploy.sh -O /target/tmp/predeploy.sh; \
  chroot /target bash /tmp/predeploy.sh
EOF

# update the seed file to reflect the users' choices
# the normal separator for sed is /, but both the password and the timezone may contain it
# so instead, I am using @
sed -i "s@{{username}}@$username@g" $tmp/iso_new/preseed/$seed_file
sed -i "s@{{pwhash}}@$pwhash@g" $tmp/iso_new/preseed/$seed_file
sed -i "s@{{hostname}}@$hostname@g" $tmp/iso_new/preseed/$seed_file
sed -i "s@{{timezone}}@$timezone@g" $tmp/iso_new/preseed/$seed_file

# calculate checksum for seed file
seed_checksum=$(md5sum $tmp/iso_new/preseed/$seed_file)

# add the autoinstall option to the menu
sed -i "/label install/ilabel autoinstall\n\
  menu label ^Autoinstall CoderDojo\n\
  kernel /install/vmlinuz\n\
  append file=/cdrom/preseed/ubuntu-server.seed initrd=/install/initrd.gz auto=true priority=high preseed/file=/cdrom/preseed/coderdojo.seed preseed/file/checksum=$seed_checksum --" $tmp/iso_new/isolinux/txt.cfg

# add the autoinstall option to the menu for USB Boot
sed -i '/set timeout=5/amenuentry "Autoinstall Netson Ubuntu Server" {\n\	set gfxpayload=keep\n\	linux /install/vmlinuz append file=/cdrom/preseed/ubuntu-server.seed initrd=/install/initrd.gz auto=true priority=high preseed/file=/cdrom/preseed/coderdojo.seed quiet ---\n\	initrd	/install/initrd.gz\n\}' $tmp/iso_new/boot/grub/grub.cfg
sed -i -r 's/timeout=[0-9]+/timeout=1/g' $tmp/iso_new/boot/grub/grub.cfg

echo " creating the remastered iso"
cd $tmp/iso_new
(mkisofs -D -r -V "CODERDOJO_UBUNTU" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $tmp/$new_iso_name . >/dev/null 2>&1) &
spinner $!

# make iso bootable (for dd'ing to  USB stick)
isohybrid $tmp/$new_iso_name

# cleanup
umount $tmp/iso_org
rm -rf $tmp/iso_new
rm -rf $tmp/iso_org
rm -rf $tmphtml

# print info to user
echo " -----"
echo " finished remastering your ubuntu iso file"
echo " the new file is located at: $tmp/$new_iso_name"
echo " your username is: $username"
echo " your hostname is: $hostname"
echo " your timezone is: $timezone"
echo

# unset vars
unset username
unset hostname
unset timezone
unset pwhash
unset download_file
unset download_location
unset new_iso_name
unset tmp
unset seed_file
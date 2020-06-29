#!/bin/sh

### Checks if running as root
if [ $(id -u) -ne 0 ]; then
   echo "This script must be run as root"
   exit;
fi

### Takes a username
username=$1

### Update generic /boot/loader.conf settings
sysrc -f /boot/loader.conf loader_logo="beastie"
sysrc -f /boot/loader.conf autoboot_delay=2
sysrc -f /boot/loader.conf loader_delay=2

### Update generic /etc/rc.conf settings
sysrc clear_tmp_enable="YES"
sysrc syslogd_flags="-ss"
sysrc sendmail_enable="NONE"
sysrc local_unbound_enable="YES"
sysrc sshd_enable="YES"
sysrc moused_enable="YES"
sysrc ntpdate_enable="YES"
sysrc ntpd_enable="YES"
sysrc powerd_enable="YES"
sysrc dumpdev="NO"

### Disable beeps
sysrc allscreens_kbdflags="-b quiet.off"
kbdcontrol -b off

### Setup Wifi
echo "Enter Wireless SSID:"
read ssid
echo "Enter Wireless PSK:"
read psk
sysrc -f /boot/loader.conf if_rtwn_pci_load="YES"
echo 'legal.realtek.license_ack=1' >> /boot/loader.conf
sysrc wlans_rtwn0="wlan0"
sysrc ifconfig_wlan0="WPA SYNCDHCP"
touch /etc/wpa_supplicant.conf
cat > /etc/wpa_supplicant.conf <<EOL
network={
    ssid="${ssid}"
    psk="${psk}"
}
EOL

### Update FreeBSD
freebsd-update fetch install --not-running-from-cron
echo 'root: ${username}' >> /etc/aliases
newaliases
echo "@daily                                  root    freebsd-update cron" >> /etc/crontab

### Bootstrap pkg
sed -i '' "s/quarterly/latest/g" /etc/pkg/FreeBSD.conf
pkg update

### Install Intel graphics
pkg install -y graphics/drm-kmod
sysrc kld_list="/boot/modules/i915kms.ko"
pw group mod video -m $username

### Setup Linux Compatibility
kldload linux64
pkg install -y emulators/linux_base-c7
sysrc linux_enable="YES"
sysrc fdescfs_load="YES"
echo 'linprocfs   /compat/linux/proc  linprocfs       rw      0       0' >> /etc/fstab
echo 'linsysfs    /compat/linux/sys   linsysfs        rw      0       0' >> /etc/fstab
echo 'tmpfs    /compat/linux/dev/shm  tmpfs   rw,mode=1777    0       0' >> /etc/fstab
echo 'fdescfs /dev/fd  fdescfs  rw  0  0' >> /etc/fstab
mount -a

### Install Gnome
pkg install -y \
    deskutils/gnome-shell-extra-extensions \
    x11/gnome3 \
    x11-drivers/xf86-video-intel \
    x11/xorg-minimal \
    x11-fonts/powerline-fonts

echo 'kern.vty=vt' >> /boot/loader.conf
echo 'hw.psm.synaptics_support="1"' >> /boot/loader.conf
sysrc dbus_enable="YES"
sysrc hald_enable="YES"
sysrc gdm_enable="YES"
sysrc gnome_enable="YES"

### Setup Firewall
sysrc firewall_enable="YES"
sysrc firewall_type="workstation"
sysrc firewall_allowservices="any"
sysrc firewall_myservices="22/tcp 80/tcp"

### Setup sudo
pkg install -y security/sudo
echo '${username} ALL=(ALL) NOPASSWD: ALL' >> /usr/local/etc/sudoers

### Install additional shells
pkg install -y shells/bash shells/fish
chsh -s /usr/local/bin/fish $username

### Install software (pkg prime-origins)
pkg install -y \
    devel/autoconf \
    devel/automake \
    sysutils/automount \
    devel/bison \
    devel/geany \
    devel/geany-plugin-spellcheck \
    devel/geany-plugin-treebrowser \
    devel/geany-plugin-workbench \
    devel/geany-plugins \
    devel/geany-themes \
    devel/gettext-tools \
    devel/git \
    www/iridium \
    editors/libreoffice \
    devel/libtool \
    editors/vim \
    net-mgmt/wifimgr \
    sysutils/cdrtools
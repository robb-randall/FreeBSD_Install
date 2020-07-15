#!/bin/sh

### Checks if running as root
if [ $(id -u) -ne 0 ]; then
   echo "This script must be run as root"
   exit 1;
fi

### Takes a username
if [ "$#" -ne 1 ]; then
  echo "Usage ${0} <username>" >&2
  exit 1
fi
username=$1

### Boot settings
echo 'loader_logo="beastie"' >> /boot/loader.conf
echo 'loader_delay=2' >> /boot/loader.conf
echo 'autoboot_delay="0"' >> /boot/loader.conf
echo 'hw.usb.no_boot_wait="1"' >> /boot/loader.conf

echo 'kern.vty=vt' >> /boot/loader.conf

### Update generic /etc/rc.conf settings
sysrc clear_tmp_enable="YES"
sysrc sshd_enable="YES"
sysrc moused_enable="YES"
sysrc ntpd_enable="YES"
sysrc powerd_enable="YES"
sysrc dumpdev="NO"

### Disable beeps
echo 'kern.vt.enable_bell=0' >> /etc/sysctl.conf
sysrc allscreens_kbdflags="-b quiet.off"
kbdcontrol -b off

### Set chron email
echo "Enter email address for cron:"
read cron_email
sysrc -f cron_flags="-m ${cron_email}"

### Setup Wifi
echo "Enter Wireless SSID:"
read ssid
echo "Enter Wireless PSK:"
read psk
echo 'if_rtwn_pci_load="YES"' >> /boot/loader.conf
echo 'legal.realtek.license_ack=1' >> /boot/loader.conf
sysrc wlans_rtwn0="wlan0"
sysrc ifconfig_wlan0="WPA SYNCDHCP"
sysrc cloned_interfaces="lagg0"
sysrc ifconfig_lagg0="laggproto failover laggport alc0 laggport wlan0 DHCP"
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

### Install and configure graphics
pkg install -y graphics/drm-kmod
sysrc kld_list+="/boot/modules/i915kms.ko"
echo 'compat.linuxkpi.i915_disable_power_well="0"' >> /boot/loader.conf
pw group mod video -m $username

pkg install intel-backlight
echo 'acpi_video_load="YES"' >> /boot/loader.conf
cp /usr/local/share/examples/intel-backlight/acpi-video-intel-backlight.conf \
    /usr/local/etc/devd/

pw groupmod video -m $username

### Install iichid
pkg install -y sysutils/iichid
sysrc kld_list+="/boot/modules/iichid.ko"
cp /usr/local/share/X11/xorg.conf.d/40-libinput.conf \
    /usr/local/etc/X11/xorg.conf.d/

### Install CPU microcode patches
pkg install -y devcpu-data
echo 'cpu_microcode_load="YES"' >> /boot/loader.conf
echo 'cpu_microcode_name="/boot/firmware/intel-ucode.bin"' >> /boot/loader.conf

### Install webcam
echo 'cuse_load="YES"' >> /boot/loader.conf
sysrc webcamd_enable="YES"
pw groupmod webcamd -m $username

### Touchpad
echo 'hw.psm.synaptics_support="1"' >> /boot/loader.conf

### Printing
pkg install -y cups
sysrc cupsd_enable="YES"
service cupsd start

### Setup Linux Compatibility
sysrc linux_enable="YES"
sysrc fdescfs_load="YES"
kldload linux64
pkg install -y emulators/linux_base-c7
echo 'linprocfs   /compat/linux/proc  linprocfs       rw      0       0' >> /etc/fstab
echo 'linsysfs    /compat/linux/sys   linsysfs        rw      0       0' >> /etc/fstab
echo 'tmpfs    /compat/linux/dev/shm  tmpfs   rw,mode=1777    0       0' >> /etc/fstab
echo 'fdescfs /dev/fd  fdescfs  rw  0  0' >> /etc/fstab
mount -a

### Filesystem
pkg install -y \
    sysutils/automount \
    emulators/fuse \
    sysutils/fusefs-ntfs \
    sysutils/fusefs-ext2
sysrc -f /boot/loader.conf fuse_load="YES"

### Setup sudo
pkg install -y security/sudo
echo '${username} ALL=(ALL) NOPASSWD: ALL' >> /usr/local/etc/sudoers
pw groupmod wheel -m $username

### Install Gnome
pkg install -y \
    deskutils/gnome-shell-extra-extensions \
    x11/gnome3-lite \
    x11-drivers/xf86-video-intel \
    x11/xorg-minimal \
    x11-fonts/powerline-fonts

sysrc dbus_enable="YES"
sysrc gdm_enable="YES"
sysrc gnome_enable="YES"

### Setup Firewall IPFW
sysrc firewall_enable="YES"
sysrc firewall_type="workstation"
sysrc firewall_allowservices="any"
sysrc firewall_myservices="22/tcp 80/tcp"

### Setup Firewall PF
#echo "block in all" > /etc/pf.conf
#echo "set skip on lo0" >> /etc/pf.conf
#echo "pass out all keep state" >> /etc/pf.conf
#sysrc pf_enable="YES"
#service pf start

### Install software (pkg prime-origins)
pkg install -y \
    devel/autoconf \
    devel/automake \
    devel/bison \
    devel/git \
    www/iridium \
    editors/libreoffice \
    devel/libtool \
    editors/vim \
    net-mgmt/wifimgr \
    sysutils/cdrtools \
    sysutils/neofetch

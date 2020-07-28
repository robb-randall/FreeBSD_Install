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

### Backup configs
cp /boot/loader.conf /boot/loader.conf.original
cp /etc/pkg/FreeBSD.conf /etc/pkg/FreeBSD.conf.original
cp /etc/fstab /etc/fstab.original
cp /etc/rc.conf /etc/rc.conf.original
cp /etc/sysctl.conf /etc/sysctl.conf.original

### Boot settings
echo 'loader_logo="beastie"' >> /boot/loader.conf
echo 'loader_delay=2' >> /boot/loader.conf
echo 'autoboot_delay="0"' >> /boot/loader.conf
echo 'hw.usb.no_boot_wait="1"' >> /boot/loader.conf

echo 'kern.vty=vt' >> /boot/loader.conf
echo 'hw.vga.textmode=1' >> /boot/loader.conf
echo 'i915kms_load="YES"' >> /boot/loader.conf

### Tunables
echo 'kern.sched.preempt_thresh=224' >> /etc/sysctl.conf
echo 'kern.maxfiles=200000' >> /etc/sysctl.conf
echo 'vfs.usermount=1' >> /etc/sysctl.conf
echo 'kern.maxproc=100000' >> /boot/loader.conf
echo 'kern.ipc.shmseg=1024' >> /boot/loader.conf
echo 'kern.ipc.shmmni=1024' >> /boot/loader.conf

### Hardening settings
sysrc clear_tmp_enable="YES"
sysrc dumpdev="NO"

### Basic services
sysrc sshd_enable="YES"
sysrc ntpd_enable="YES"
sysrc powerd_enable="YES"
sysrc background_dhclient="YES"
sysrc dbus_enable="YES"
sysrc moused_enable="YES"

### Disable beeps
echo 'kern.vt.enable_bell=0' >> /etc/sysctl.conf
sysrc allscreens_kbdflags="-b quiet.off"
kbdcontrol -b off

### Setup Wireless interface
echo "Enter Wireless SSID:"
read ssid
echo "Enter Wireless PSK:"
read psk
echo 'if_rtwn_pci_load="YES"' >> /boot/loader.conf
echo 'legal.realtek.license_ack=1' >> /boot/loader.conf
sysrc wlans_rtwn0="wlan0"
sysrc ifconfig_wlan0="WPA up"
touch /etc/wpa_supplicant.conf
cat > /etc/wpa_supplicant.conf <<EOL
network={
    ssid="${ssid}"
    psk="${psk}"
}
EOL

### Setup Ethernet interface
sysrc ifconfig_alc0="ether 74:de:2b:6d:63:87 up"

### Setup Lagg interface
sysrc cloned_interfaces="lagg0"
ifconfig_alc0="ether 74:de:2b:6d:63:87"
sysrc ifconfig_lagg0="laggproto failover laggport alc0 laggport wlan0 DHCP up"

### Update FreeBSD
freebsd-update fetch install --not-running-from-cron

### Bootstrap pkg
sed -i '' "s/quarterly/latest/g" /etc/pkg/FreeBSD.conf
pkg update

### Setup Linux Compatibility
sysrc linux_enable="YES"
sysrc fdescfs_load="YES"
echo 'tmpfs_load="YES"' >> /boot/loader.conf
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
echo 'fuse_load="YES"' >> /boot/loader.conf

### Install and configure graphics
pkg install -y graphics/drm-kmod
sysrc kld_list="/boot/modules/i915kms.ko"
echo 'compat.linuxkpi.i915_disable_power_well="0"' >> /boot/loader.conf
pw group mod video -m $username

pkg install -y graphics/intel-backlight
echo 'acpi_video_load="YES"' >> /boot/loader.conf
cp /usr/local/share/examples/intel-backlight/acpi-video-intel-backlight.conf \
    /usr/local/etc/devd/

### Install iichid
pkg install -y sysutils/iichid
sysrc kld_list+="/boot/modules/iichid.ko"
cp /usr/local/share/X11/xorg.conf.d/40-libinput.conf \
    /usr/local/etc/X11/xorg.conf.d/

### Install CPU microcode patches
pkg install -y sysutils/devcpu-data
echo 'cpu_microcode_load="YES"' >> /boot/loader.conf
echo 'cpu_microcode_name="/boot/firmware/intel-ucode.bin"' >> /boot/loader.conf

### Install webcam
echo 'cuse_load="YES"' >> /boot/loader.conf
sysrc webcamd_enable="YES"
pw groupmod webcamd -m $username

### Touchpad
echo 'hw.psm.synaptics_support="1"' >> /boot/loader.conf

### Sound
echo 'snd_driver_load="YES"' >> /boot/loader.conf
echo 'hw.snd.default_auto=1' >> /etc/sysctl.conf

### Printing
pkg install -y print/cups
sysrc cupsd_enable="YES"
pw groupmod cups -m $username
service cupsd start

### Setup sudo
pkg install -y security/sudo
pw groupmod wheel -m $username

### Install Gnome
pkg install -y \
    deskutils/gnome-shell-extra-extensions \
    x11/gnome3 \
    x11-drivers/xf86-video-intel \
    x11/xorg-minimal \
    x11-fonts/powerline-fonts \
    x11/xterm

sysrc gdm_enable="YES"
sysrc gnome_enable="YES"

### Setup Firewall IPFW
sysrc firewall_enable="YES"
sysrc firewall_type="workstation"
sysrc firewall_allowservices="any"
sysrc firewall_myservices="22/tcp 80/tcp"

### Setup Firewall PF
#touch /etc/pf.conf
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

### Post install backup
cp /boot/loader.conf /boot/loader.conf.initial
cp /etc/pkg/FreeBSD.conf /etc/pkg/FreeBSD.conf.initial
cp /etc/fstab /etc/fstab.initial
cp /etc/rc.conf /etc/rc.conf.initial
cp /etc/sysctl.conf /etc/sysctl.conf.initial
cp /etc/wpa_supplicant.conf /etc/wpa_supplicant.conf.initial
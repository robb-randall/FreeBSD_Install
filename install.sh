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

kldload linux64

### /boot/loader.conf
cat >> /boot/loader.conf <<EOL
loader_logo="beastie"
loader_delay=2
autoboot_delay="0"
hw.usb.no_boot_wait="1"
kern.vty=vt
kern.maxproc=100000'
kern.ipc.shmseg=1024'
kern.ipc.shmmni=1024'
compat.linuxkpi.i915_disable_power_well="0"
fuse_load="YES"
hw.psm.synaptics_support="1"
cuse_load="YES"
cpu_microcode_load="YES"
cpu_microcode_name="/boot/firmware/intel-ucode.bin"
coretemp_load="YES"
acpi_video_load="YES"
snd_driver_load="YES"
if_rtwn_pci_load="YES"
legal.realtek.license_ack=1
tmpfs_load="YES"
EOL

### /etc/fstab
cat >> /etc/fstab <<EOL
linprocfs   /compat/linux/proc        linprocfs       rw      0       0
linsysfs    /compat/linux/sys         linsysfs        rw      0       0
tmpfs       /compat/linux/dev/shm     tmpfs   rw,mode=1777    0       0
fdescfs     /dev/fd                   fdescfs         rw      0       0
tmpfs       /tmp                      tmpfs   rw,mode=1777    0       0
EOL

### /etc/sysctl.conf
cat >> /etc/sysctl.conf <<EOL
kern.sched.preempt_thresh=224
kern.maxfiles=200000
vfs.usermount=1
kern.vt.enable_bell=0
hw.snd.default_auto=1
EOL

### /etc/rc.conf
cat >> /etc/rc.conf <<EOL
syslogd_flags="-ss"
sendmail_enable="NONE"
hostname="robb-pc"
zfs_enable="YES"
clear_tmp_enable="YES"
dumpdev="NO"
sshd_enable="YES"
ntpd_enable="YES"
powerd_enable="YES"
background_dhclient="YES"
dbus_enable="YES"
moused_enable="YES"
hald_enable="YES"
avahi_daemon_enable="YES"
avahi_dnsconfd_enable="YES"
allscreens_kbdflags="-b quiet.off"
wlans_rtwn0="wlan0"
ifconfig_wlan0="WPA up"
ifconfig_alc0="ether 74:de:2b:6d:63:87 up"
cloned_interfaces="lagg0"
ifconfig_lagg0="laggproto failover laggport alc0 laggport wlan0 DHCP up"
linux_enable="YES"
fdescfs_load="YES"
kld_list="
    /boot/modules/i915kms.ko
    /boot/modules/iichid.ko
" # kld_list
aesni_load="YES"
webcamd_enable="YES"
cupsd_enable="YES"
firewall_enable="YES"
firewall_type="workstation"
firewall_allowservices="any"
firewall_myservices="22/tcp 80/tcp"
microcode_update_enable="YES"
sddm_enable="YES"
EOL

### Setup Wireless interface
echo "Enter Wireless SSID (will echo):"
read ssid
echo "Enter Wireless PSK (will echo):"
read psk

cat > /etc/wpa_supplicant.conf <<EOL
network={
    ssid="${ssid}"
    psk="${psk}"
}
EOL

### Update FreeBSD
freebsd-update fetch install --not-running-from-cron

### Bootstrap pkg
sed -i '' "s/quarterly/latest/g" /etc/pkg/FreeBSD.conf
pkg update

pkg install -y                      \
    devel/autoconf                  \
    devel/automake                  \
    devel/bison                     \
    devel/git                       \
    devel/libtool                   \
    graphics/drm-kmod               \
    editors/libreoffice             \
    editors/vim                     \
    emulators/fuse                  \
    emulators/linux_base-c7         \
    graphics/intel-backlight        \
    irc/hexchat                     \
    print/cups                      \
    security/sudo                   \
    sysutils/automount              \
    sysutils/cdrtools               \
    sysutils/devcpu-data            \
    sysutils/fusefs-ext2            \
    sysutils/fusefs-ntfs            \
    sysutils/iichid                 \
    www/iridium                     \
    x11-drivers/xf86-video-intel    \
    x11/xorg                        \
    x11-fonts/powerline-fonts       \
    x11/kde5

cp /usr/local/share/X11/xorg.conf.d/40-libinput.conf \
    /usr/local/etc/X11/xorg.conf.d/

pw groupmod wheel -m $username
pw groupmod webcamd -m $username
pw groupmod video -m $username
pw groupmod cups -m $username

### Post install backup
cp /boot/loader.conf /boot/loader.conf.initial
cp /etc/pkg/FreeBSD.conf /etc/pkg/FreeBSD.conf.initial
cp /etc/fstab /etc/fstab.initial
cp /etc/rc.conf /etc/rc.conf.initial
cp /etc/sysctl.conf /etc/sysctl.conf.initial
cp /etc/wpa_supplicant.conf /etc/wpa_supplicant.conf.initial
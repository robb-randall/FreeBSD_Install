### Update FreeBSD
freebsd-update fetch install


### Update /etc/rc.conf
sysrc clear_tmp_enable="YES"
sysrc syslogd_flags="-ss"
sysrc sendmail_enable="NONE"
sysrc hostname="robb-laptop"
sysrc local_unbound_enable="YES"
sysrc sshd_enable="YES"
sysrc moused_enable="YES"
sysrc ntpdate_enable="YES"
sysrc ntpd_enable="YES"
sysrc powerd_enable="YES"
sysrc dumpdev="NO"

sysrc allscreens_kbdflags="-b quiet.off"

sysrc wlans_rtwn0="wlan0"
sysrc ifconfig_wlan0="WPA SYNCDHCP"

sysrc kld_list="/boot/modules/i915kms.ko"

sysrc firewall_enable="YES"
sysrc firewall_type="workstation"
sysrc firewall_allowservices="any"
sysrc firewall_myservices="22/tcp 80/tcp"

sysrc dbus_enable="YES"
sysrc hald_enable="YES"
sysrc gdm_enable="YES"
sysrc gnome_enable="YES"

sysrc linux_enable="YES"
kldload linux64


### Update /boot/loader.conf
echo 'kern.vty=vt' >> /boot/loader.conf

echo 'if_rtwn_pci_load="YES"' >> /boot/loader.conf
echo 'legal.realtek.license_ack=1' >> /boot/loader.conf

echo 'hw.psm.synaptics_support="1"' >> /boot/loader.conf


### Create /etc/wpa_supplicant.conf
touch /etc/wpa_supplicant.conf
cat > /etc/wpa_supplicant.conf <<EOL
network={
    ssid="R-Link"
    psk="TheRandall'sPassw0rd!0"
}
EOL


### Bootstrap pkg
sed -i '' "s/quarterly/latest/g" /etc/pkg/FreeBSD.conf
pkg update


### Install Packages (pkg prime-origins)
pkg install -y \
    devel/autoconf \
    devel/automake \
    sysutils/automount \
    shells/bash \
    devel/bison \
    sysutils/debootstrap \
    graphics/drm-kmod \
    devel/geany \
    devel/geany-plugin-spellcheck \
    devel/geany-plugin-treebrowser \
    devel/geany-plugin-workbench \
    devel/geany-plugins \
    devel/geany-themes \
    devel/gettext-tools \
    devel/git \
    deskutils/gnome-shell-extra-extensions \
    x11/gnome3 \
    www/iridium \
    editors/libreoffice \
    devel/libtool \
    emulators/linux_base-c7 \
    security/sudo \
    editors/vim \
    editors/vscode \
    net-mgmt/wifimgr \
    x11-drivers/xf86-video-intel \
    x11/xorg-minimal


### Update /etc/fstab
echo 'linprocfs   /compat/linux/proc  linprocfs       rw      0       0' >> /etc/fstab
echo 'linsysfs    /compat/linux/sys   linsysfs        rw      0       0' >> /etc/fstab
echo 'tmpfs    /compat/linux/dev/shm  tmpfs   rw,mode=1777    0       0' >> /etc/fstab
mount -a


# Update robb's user
pw group mod wheel -m robb
pw group mod video -m robb
pw group mod operator -m robb

chsh -s /usr/local/bin/bash robb
echo 'robb ALL=(ALL) NOPASSWD: ALL' >> /usr/local/etc/sudoers
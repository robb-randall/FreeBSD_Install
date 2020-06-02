### Update FreeBSD
freebsd-update fetch install

### Change pkg from Quarterly to Latest
sed -i '' "s/quarterly/latest/g" /etc/pkg/FreeBSD.conf

### Bootstrap pkg
pkg update

### Setup wifi (rtwn)
sysrc -f /boot/loader.conf if_rtwn_pci_load="YES"
echo 'legal.realtek.license_ack=1' >> /boot/loader.conf
sysrc wlans_rtwn0="wlan0"
sysrc ifconfig_wlan0="WPA SYNCDHCP"
touch /etc/wpa_supplicant.conf
cat > /etc/wpa_supplicant.conf <<EOL
network={
    ssid="R-Link"
    psk="TheRandall'sPassw0rd!0"
}
EOL

### Setup Intel Graphics
pkg install -y drm-kmod
sysrc kld_list="/boot/modules/i915kms.ko"

### Firewall (IPFW)
sysrc firewall_enable="YES"
sysrc firewall_type="workstation"
sysrc firewall_allowservices="any"
sysrc firewall_myservices="22 80"
service ipfw start

### Automount


### Install and configure Xorg, Slim, and i3
pkg install -y xorg
echo 'kern.vty=vt' >> /boot/loader.conf

### Install and configure i3
pkg install -y i3-gaps i3blocks i3lock i3status conky dmenu

### Install Software
pkg install -y chromium git  gnome-screenshot nitrogen vscode xterm
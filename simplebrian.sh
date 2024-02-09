#!/bin/bash

# [DISCLAIMER]
# This script was made by an idiot and may not work as intended, just because it worked for me, doesn't mean it will work for you.

# check if user is running in root/sudo, exits if they are because pkgbuild is stupid and won't run on root/sudo.
if [ "$EUID" = 0 ]
  then echo "Please do not run this script as sudo or in root."
  exit
fi

# confirmation script so user doesn't get shot in the foot by running the script too early.
cd
echo -e '\033[1mWelcome to the SimpleBrian installation script!\033[0m'
echo
echo -e '\033[1mBefore we run the script, it is important that you have recently used sudo, and run the script before the sudo timeout occurs (this is done if you want the script to run fully automated).\033[0m'
echo
read -p "With that said, are you ready to install everything? [Y/N] " -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
# let the games begin.

# add pacman progress bar to pacman, and color.
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
sudo sed -i '38iILoveCandy' /etc/pacman.conf

# update any outdated packages and installs a few make dependencies before officially beginning.
sudo pacman -Syu --needed --noconfirm git base-devel wget

# build and install an AUR helper.
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd

# download package list and use paru to install everything (using as pacman wrapper on top of AUR packages).
wget https://github.com/SimpleBrian/install-script/raw/main/packages.txt
paru -Syu --needed --sudoloop --noconfirm < packages.txt

# make terminal hella fancy (and configure colors). must fix vte config later.
git clone --recursive https://github.com/andresgongora/synth-shell.git
chmod +x synth-shell/setup.sh
cd synth-shell
echo iunyyyy | ./setup.sh
cd
sed -i 's/^background_user=.*/background_user="27"/' .config/synth-shell/synth-shell-prompt.config
sed -i 's/^background_host=.*/background_host="18"/' .config/synth-shell/synth-shell-prompt.config

# download and install WelcomeXP theme.
git clone https://github.com/mshernandez5/WelcomeXP.git
mkdir WelcomeXP/fonts
cd WelcomeXP/fonts
wget "https://github.com/SimpleBrian/install-script/raw/main/fonts/FRADMIT.TTF"
wget "https://github.com/SimpleBrian/install-script/raw/main/fonts/tahoma.ttf"
wget "https://github.com/SimpleBrian/install-script/raw/main/fonts/tahomabd.ttf"
cd
sudo cp -R WelcomeXP /usr/share/web-greeter/themes
sudo chmod -R 755 /usr/share/web-greeter/themes/WelcomeXP

# download and install the tela icon theme.
git clone https://github.com/vinceliuice/Tela-icon-theme.git
cd Tela-icon-theme
sudo ./install.sh
cd

# download and install the qogir theme.
git clone https://github.com/vinceliuice/Qogir-theme.git
cd Qogir-theme
sudo ./install.sh --tweaks round -c dark
cd

# download and install posy's cursor.
git clone https://github.com/simtrami/posy-improved-cursor-linux.git
cd posy-improved-cursor-linux
sudo cp -R Posy_Cursor /usr/share/icons
cd

# enables the lightdm service.
sudo systemctl enable lightdm

# enables the network manager.
sudo systemctl enable NetworkManager

# enables bluetooth.
sudo modprobe btusb
sudo systemctl enable bluetooth

# enable firewall.
sudo systemctl enable ufw

# enable printer.
sudo systemctl enable cups.service
sudo systemctl enable avahi-daemon.service
sudo sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns/' /etc/nsswitch.conf
sudo ufw allow 5353
sudo sed -i 's/^noipv4ll/#noipv4ll/' /etc/dhcpcd.conf

# point lightdm to use budgie desktop, web-greeter, and theme web-greeter with WelcomeXP.
sudo sed -i 's/^#greeter-session=.*/greeter-session=web-greeter/' /etc/lightdm/lightdm.conf
sudo sed -i 's/^#user-session=.*/user-session=budgie-desktop/' /etc/lightdm/lightdm.conf
sudo sed -i 's/^    theme:.*/    theme: WelcomeXP/' /etc/lightdm/web-greeter.yml

# run the discord patch command, then uninstall.
discord-canary-update-skip
paru -R --noconfirm discord-canary-update-skip-git

# delete git repos after everything has been installed.
sudo rm -r paru WelcomeXP Tela-icon-theme Qogir-theme posy-improved-cursor-linux synth-shell

# download appimage(s).
wget "https://github.com/ppy/osu/releases/latest/download/osu.AppImage"

# aggresively clean pacman and AUR caches, and uninstalls any unused dependencies.
paru -Scc --noconfirm
sudo pacman -Rsn --noconfirm $(pacman -Qdtq)

# create a 4GB swapfile and enable it.
sudo dd if=/dev/zero of=/swapfile bs=1M count=4k status=progress
sudo chmod 0600 /swapfile
sudo mkswap -U clear /swapfile
sudo swapon /swapfile
sudo su root -c "echo '/swapfile none swap defaults 0 0' >> /etc/fstab"
sudo su root -c "echo 'vm.swappiness = 1' > /etc/sysctl.d/99-swappiness.conf"

# create, sign, and enroll keys to enable secure boot (will be unable to enroll the keys if setup mode is disabled, but everything else works).
sudo sbctl create-keys
sudo sbctl sign -s /boot/vmlinuz-linux
sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
sudo sbctl sign -s /boot/EFI/systemd/systemd-bootx64.efi
sudo sbctl sign -s -o /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi
sudo sbctl enroll-keys -m

# arch btw.
echo
echo
neofetch
echo

# finish installation.
echo -e '\033[1m(Note: If any packages failed to install, install them later via terminal.)\033[0m'
echo
echo -e '\033[1mIf everything went well like god intended, enjoy using Arch BTW (reboot in 10s).\033[0m'
echo -e '\033[1mOn the off-chance that it actually fucked up, CTRL+C now.\033[0m'

# ten second delay before rebooting.
sleep 10
sudo shutdown -r now
fi

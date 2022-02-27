#!/bin/sh

source ./config.sh
source ./lib/partitioning.sh

# Update the system clock
timedatectl set-ntp true

partitioning

# Apply best DNS selection
echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > /etc/resolv.conf

reflector --save /etc/pacman.d/mirrorlist --country Brazil

# Install essential packages
pacstrap /mnt \
  base \
  linux \
  linux-firmware \
  vim

# fstab
genfstab -U /mnt >> /mnt/etc/fstab

cat <<EOF > /mnt/root/install.sh
#!/bin/sh
# Time Zone
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

# Localisation
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'KEYMAP=us' > /etc/vconsole.conf

# Network
echo $HOSTNAME > /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$HOSTNAME.localdomain $HOSTNAME" > /etc/hosts

# Root password
echo 'Set root password'
passwd

# Bootloader
pacman -S grub efibootmgr os-prober dosfstools mtools
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

# Network
pacman -S networkmanager
systemctl enable NetworkManager

EOF

chmod +x /mnt/root/install.sh

arch-chroot /mnt /root/install.sh

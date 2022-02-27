clean_the_device() {
  sfdisk --delete $DEVICE
}

create_partitions() {
  sfdisk --label gpt $DEVICE << EOF
,$EFI_SIZE,U
,$SWAP_SIZE,S
,,L
EOF
}

format_efi_partition() {
  mkfs.fat -F 32 $EFI_PARTITION
}

format_root_partition() {
  mkfs.ext4 -F $ROOT_PARTITION
}

format_swap_partition() {
  mkswap $SWAP_PARTITION
}

format_partitions() {
  format_efi_partition
  format_swap_partition
  format_root_partition
}

mount_root_partition() {
  mount $ROOT_PARTITION /mnt
}

mount_efi_partition() {
  mkdir -p /mnt/boot/efi
  mount $EFI_PARTITION /mnt/boot/efi
}

mount_partitions() {
  mount_efi_partition
  mount_root_partition
}

activate_swap() {
  swapon $SWAP_PARTITION
}

partitioning() {
  clean_the_device
  create_partitions
  format_partitions
  mount_partitions
  activate_swap
}

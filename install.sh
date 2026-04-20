#!/usr/bin/env bash

# Exit immediately if a command fails
set -e

# Safety check: Ensure /mnt is actually a mount point
if ! mountpoint -q /mnt; then
    echo "Error: /mnt is not mounted. Please mount your partitions first."
    exit 1
fi

echo "Updating to NixOS Unstable channel..."
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nix-channel --update

echo "Generating hardware configuration..."
sudo nixos-generate-config --root /mnt

echo "Copying system configuration..."
# Logic check: ensures your local configuration.nix actually exists
if [ -f "./configuration.nix" ]; then
    sudo cp ./configuration.nix /mnt/etc/nixos/configuration.nix
else
    echo "Error: configuration.nix not found in current directory."
    exit 1
fi

echo "Starting installation..."
sudo nixos-install --no-channel-copy

echo "--------------------------------------------------"
echo "Installation complete. You can now reboot."

#!/bin/bash
# fix-azure-update-manager.sh
# Ensures WALinuxAgent is installed and sudo works for Update Manager

set -e

echo "=== Checking WALinuxAgent ==="
if ! command -v waagent &>/dev/null; then
  echo "Installing WALinuxAgent..."
  sudo apt-get update -y
  sudo apt-get install walinuxagent -y
fi

echo "Enabling WALinuxAgent service..."
sudo systemctl enable walinuxagent || true
sudo systemctl start walinuxagent || true
systemctl status walinuxagent --no-pager || true
waagent --version || true

echo "=== Configuring sudoers for NOPASSWD ==="
SUDOERS_FILE="/etc/sudoers.d/azureuser"
if [ ! -f "$SUDOERS_FILE" ]; then
  echo "azureuser ALL=(ALL) NOPASSWD:ALL" | sudo tee $SUDOERS_FILE
  sudo chmod 440 $SUDOERS_FILE
fi

echo "Validating sudoers config..."
sudo visudo -c

echo "Testing sudo..."
if sudo -n true; then
  echo "NOPASSWD sudo works."
else
  echo "ERROR: sudo still requires a password!"
  exit 1
fi

echo "=== Done! Retry Azure Update Manager assessment. ==="

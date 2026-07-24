#!/bin/bash
# ==================================================
# UFW Firewall Configuration Script
# Task 2 — Basic Firewall Configuration with UFW
# ==================================================
# This script installs, enables, and configures UFW
# (Uncomplicated Firewall) with a defined rule set.
# Run with: sudo bash ufw_configuration.sh
# ==================================================

echo "[1/6] Installing UFW (if not already installed)..."
sudo apt update
sudo apt install ufw -y

echo "[2/6] Enabling UFW..."
sudo ufw enable

echo "[3/6] Allowing SSH (port 22)..."
sudo ufw allow ssh

echo "[4/6] Denying HTTP (port 80)..."
sudo ufw deny http

echo "[5/6] Allowing HTTPS (port 443) — custom rule 1..."
sudo ufw allow https

echo "[6/6] Denying traffic from a specific IP range — custom rule 2..."
sudo ufw deny from 192.168.50.0/24

echo ""
echo "==================================================="
echo "All rules applied. Current status:"
echo "==================================================="
sudo ufw status verbose

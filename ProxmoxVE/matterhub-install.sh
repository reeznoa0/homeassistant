#!/usr/bin/env bash

# Copyright (c) 2024 reeznoa0
# Author: reeznoa0
# License: MIT
# Source: https://github.com/t0bst4r/home-assistant-matter-hub

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y gpg
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get update
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Install MatterHub" 
mkdir -p /root/MatterHub
$STD npm install -g home-assistant-matter-hub
msg_ok "Installed MatterHub"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/matterhub.service
[Unit]
Description=matterhub
After=network-online.target

[Service]
Type=simple
ExecStart=matterhub -bridge -service
WorkingDirectory=/root/MatterHub
StandardOutput=inherit
StandardError=inherit
Restart=always
RestartSec=10s
TimeoutStopSec=30s

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now matterhub.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"

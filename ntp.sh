#!/bin/bash

# Exit on any error
set -e

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Update package list
log "Updating package list..."
apt-get update

# Install NTP
log "Installing NTP server..."
apt-get install -y ntp

# Backup original configuration
log "Backing up original NTP configuration..."
cp /etc/ntp.conf /etc/ntp.conf.backup

# Configure NTP servers
log "Configuring NTP servers..."
cat > /etc/ntp.conf << 'EOL'
# /etc/ntp.conf, configuration for ntpd; see ntp.conf(5) for help

# Drift file to remember clock rate adjustments
driftfile /var/lib/ntp/ntp.drift

# Leap seconds definition provided by tzdata
leapfile /usr/share/zoneinfo/leap-seconds.list

# Enable this if you want statistics to be logged.
#statsdir /var/log/ntpstats/

statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable

# Specify time servers to synchronize with
pool 0.ubuntu.pool.ntp.org iburst
pool 1.ubuntu.pool.ntp.org iburst
pool 2.ubuntu.pool.ntp.org iburst
pool 3.ubuntu.pool.ntp.org iburst

# By default, exchange time with everybody, but don't allow configuration.
restrict -4 default kod notrap nomodify nopeer noquery limited
restrict -6 default kod notrap nomodify nopeer noquery limited

# Local users may interrogate the ntp server more closely.
restrict 127.0.0.1
restrict ::1

# Allow NTP service through UFW firewall
EOL

# Configure UFW if it's installed
if command -v ufw >/dev/null 2>&1; then
    log "Configuring firewall rules..."
    ufw allow 123/udp
    ufw status
fi

# Restart NTP service
log "Restarting NTP service..."
systemctl restart ntp

# Enable NTP service on boot
log "Enabling NTP service on boot..."
systemctl enable ntp

# Wait for NTP to sync
log "Waiting for NTP synchronization..."
sleep 10

# Check NTP status
log "Checking NTP status..."
ntpq -p

# Verify NTP service is running
log "Verifying NTP service..."
if systemctl is-active --quiet ntp; then
    log "NTP server setup completed successfully!"
else
    log "ERROR: NTP service is not running!"
    exit 1
fi

# Display NTP synchronization status
log "Current NTP synchronization status:"
timedatectl status

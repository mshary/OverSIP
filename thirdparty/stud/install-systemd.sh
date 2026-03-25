#!/bin/bash
# stud systemd service installation script

set -e

# Configuration
SERVICE_NAME="stud"
SERVICE_FILE="stud.service"
INSTALL_DIR="/usr/local/lib/systemd/system"
CONFIG_DIR="/etc/stud"
CERT_FILE="${CONFIG_DIR}/stud.pem"
USER_NAME="stud"
GROUP_NAME="stud"

echo "Installing stud systemd service..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   exit 1
fi

# Create stud user and group if they don't exist
if ! id -u "$USER_NAME" >/dev/null 2>&1; then
    echo "Creating user: $USER_NAME"
    useradd --system --shell /bin/false --home /var/lib/stud --create-home "$USER_NAME"
fi

if ! getent group "$GROUP_NAME" >/dev/null 2>&1; then
    echo "Creating group: $GROUP_NAME"
    groupadd --system "$GROUP_NAME"
fi

# Create configuration directory
echo "Creating configuration directory: $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"
chmod 755 "$CONFIG_DIR"

# Create runtime directory
echo "Creating runtime directory: /var/run/stud"
mkdir -p /var/run/stud
chown "$USER_NAME:$GROUP_NAME" /var/run/stud
chmod 755 /var/run/stud

# Install systemd service file
echo "Installing systemd service file to: $INSTALL_DIR"
cp "$SERVICE_FILE" "$INSTALL_DIR/"
chmod 644 "$INSTALL_DIR/$SERVICE_FILE"

# Create log directory
echo "Creating log directory: /var/log/stud"
mkdir -p /var/log/stud
chown "$USER_NAME:$GROUP_NAME" /var/log/stud
chmod 755 /var/log/stud

# Check if certificate exists
if [[ ! -f "$CERT_FILE" ]]; then
    echo "WARNING: Certificate file not found at: $CERT_FILE"
    echo "Please create your certificate file and place it at: $CERT_FILE"
    echo "Example: openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes"
    echo "         cat key.pem cert.pem > $CERT_FILE"
    echo "         chmod 600 $CERT_FILE"
    echo "         chown $USER_NAME:$GROUP_NAME $CERT_FILE"
fi

# Reload systemd daemon
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Enable service
echo "Enabling stud service..."
systemctl enable "$SERVICE_NAME"

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "1. Create/modify your certificate file at: $CERT_FILE"
echo "2. Edit the service file if needed: $INSTALL_DIR/$SERVICE_FILE"
echo "3. Start the service: systemctl start stud"
echo "4. Check status: systemctl status stud"
echo "5. View logs: journalctl -u stud -f"
echo ""
echo "To customize the service (frontend/backend addresses, TLS version, etc.):"
echo "   systemctl edit stud"
echo "   # Add overrides in the [Service] section"
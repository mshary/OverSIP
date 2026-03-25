# stud systemd Service Setup

This directory contains systemd service files and installation scripts for running stud as a daemon.

## Files

- `stud.service` - systemd service unit file
- `install-systemd.sh` - automated installation script

## Quick Installation

```bash
# Run as root
sudo ./install-systemd.sh
```

This will:
- Create the `stud` user and group
- Install the systemd service file
- Set up necessary directories and permissions
- Enable the service

## Manual Installation

1. **Create stud user:**
   ```bash
   sudo useradd --system --shell /bin/false --home /var/lib/stud --create-home stud
   sudo groupadd --system stud
   ```

2. **Create directories:**
   ```bash
   sudo mkdir -p /etc/stud /var/run/stud /var/log/stud
   sudo chown stud:stud /var/run/stud /var/log/stud
   ```

3. **Install service file:**
   ```bash
   sudo cp stud.service /usr/local/lib/systemd/system/
   sudo chmod 644 /usr/local/lib/systemd/system/stud.service
   ```

4. **Create certificate:**
   ```bash
   # Generate self-signed certificate (replace with your real cert)
   sudo openssl req -x509 -newkey rsa:4096 -keyout /etc/stud/key.pem -out /etc/stud/cert.pem -days 365 -nodes -subj "/CN=localhost"
   sudo cat /etc/stud/key.pem /etc/stud/cert.pem > /etc/stud/stud.pem
   sudo chmod 600 /etc/stud/stud.pem
   sudo chown stud:stud /etc/stud/stud.pem
   ```

5. **Enable and start service:**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable stud
   sudo systemctl start stud
   ```

## Configuration

### Basic Configuration

Edit the service file or use `systemctl edit stud` to override settings:

```bash
# Change frontend port
sudo systemctl edit stud
# Add: [Service]
#      ExecStart=
#      ExecStart=/usr/local/bin/stud --frontend *,443 --backend 127.0.0.1,80 /etc/stud/stud.pem
```

### TLS Version Enforcement

To enforce minimum TLS versions, modify the ExecStart line:

```bash
# TLS 1.2 minimum
ExecStart=/usr/local/bin/stud --tls12 --frontend *,8443 --backend 127.0.0.1,80 /etc/stud/stud.pem

# TLS 1.3 minimum
ExecStart=/usr/local/bin/stud --tls13 --frontend *,8443 --backend 127.0.0.1,80 /etc/stud/stud.pem
```

### Multiple Workers

For high-traffic deployments:

```bash
ExecStart=/usr/local/bin/stud --tls12 --workers 4 --frontend *,8443 --backend 127.0.0.1,80 /etc/stud/stud.pem
```

## Management Commands

```bash
# Check status
sudo systemctl status stud

# View logs
sudo journalctl -u stud -f

# Restart service
sudo systemctl restart stud

# Stop service
sudo systemctl stop stud

# Disable service
sudo systemctl disable stud
```

## Security Features

The systemd service includes several security hardening features:

- **NoNewPrivileges**: Prevents privilege escalation
- **ProtectHome**: Restricts access to home directories
- **ProtectSystem**: Prevents modification of system files
- **PrivateTmp**: Uses private temporary directories
- **MemoryDenyWriteExecute**: Prevents code injection attacks
- **RestrictAddressFamilies**: Limits network access
- **Resource limits**: Sets appropriate file descriptor limits

## Troubleshooting

### Service fails to start
Check the logs:
```bash
sudo journalctl -u stud -n 50
```

Common issues:
- Missing certificate file
- Incorrect permissions
- Port already in use

### High CPU usage
- Check for connection storms
- Verify backend is responding
- Consider increasing worker count

### Connection refused
- Verify backend service is running
- Check firewall rules
- Confirm network configuration
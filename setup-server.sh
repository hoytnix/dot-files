#!/usr/bin/env sh
set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

# Detect custom SSH port automatically or prompt
SSH_PORT=$(ss -tulpn | grep sshd | awk '{print $5}' | awk -F':' '{print $NF}' | head -n1)
if [ -z "$SSH_PORT" ]; then
    SSH_PORT=22
fi

info "Detected active SSH port: ${SSH_PORT}"

# --- 1. UFW CONFIGURATION ---
info "Configuring UFW Firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ${SSH_PORT}/tcp comment 'SSH Port'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Enable UFW non-interactively
echo "y" | sudo ufw enable
success "UFW active on ports: ${SSH_PORT} (SSH), 80 (HTTP), 443 (HTTPS)"

# --- 2. FAIL2BAN CONFIGURATION ---
info "Configuring Fail2Ban Jails & Filters..."

# Create jail.local
cat << JAIL | sudo tee /etc/fail2ban/jail.local > /dev/null
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled  = true
port     = ${SSH_PORT}
logpath  = %(sshd_log)s
backend  = %(sshd_backend)s

[nginx-req-limit]
enabled  = true
filter   = nginx-req-limit
action   = ufw
logpath  = /var/log/nginx/error.log
findtime = 60
maxretry = 10
bantime  = 24h

[nginx-badbots]
enabled  = true
filter   = nginx-badbots
action   = ufw
logpath  = /var/log/nginx/access.log
findtime = 600
maxretry = 5
bantime  = 48h
JAIL

# Add Fail2Ban Filters for Nginx
cat << FILTER | sudo tee /etc/fail2ban/filter.d/nginx-req-limit.conf > /dev/null
[Definition]
failregex = ^\s*\[error\] \d+#\d+: \*\d+ limiting requests, excess: .* by zone ".*", client: <HOST>
ignoreregex =
FILTER

cat << FILTER | sudo tee /etc/fail2ban/filter.d/nginx-badbots.conf > /dev/null
[Definition]
failregex = ^<HOST> -.*"(GET|POST|HEAD) .*\.(php|asp|exe|pl|cgi|env).* HTTP/.*" (400|403|404)
ignoreregex =
FILTER

sudo systemctl enable --now fail2ban
sudo systemctl restart fail2ban
success "Fail2Ban configured for SSH (Port ${SSH_PORT}) and Nginx rate limits/bots"

# --- 3. NGINX VERBOSE LOGGING & RATE LIMITS ---
info "Configuring Nginx Global Verbose Logging & Rate Limits..."

if [ -f /etc/nginx/nginx.conf ]; then
    # Backup nginx.conf
    sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

    # Ensure rate limit zones exist in http block
    if ! grep -q "req_limit_per_ip" /etc/nginx/nginx.conf; then
        sudo sed -i '/http {/a \    limit_req_zone $binary_remote_addr zone=req_limit_per_ip:10m rate=10r/s;\n    limit_conn_zone $binary_remote_addr zone=conn_limit_per_ip:10m;' /etc/nginx/nginx.conf
    fi

    # Add verbose log format if not present
    if ! grep -q "verbose_detailed" /etc/nginx/nginx.conf; then
        sudo sed -i '/http {/a \    log_format verbose_detailed \x27$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" rt=$request_time uct="$upstream_connect_time" uht="$upstream_header_time" urt="$upstream_response_time"\x27;' /etc/nginx/nginx.conf
    fi

    sudo nginx -t && sudo systemctl reload nginx
    success "Nginx verbose security logging and rate limit zones initialized"
fi

success "Server Hardening Complete! UFW, Fail2Ban, and Nginx are fully configured."

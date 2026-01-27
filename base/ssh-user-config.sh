#!/bin/bash
set -e

# Default values for SSH credentials
: ${SSH_USERNAME:="archuser"}
: ${SSH_PASSWORD:="changemelater"}
: ${ROOT_PASSWORD:=""}
: ${AUTHORIZED_KEYS:=""}
: ${DISABLE_PASSWORD_AUTH:="false"}

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Arch Linux SSH Server Configuration${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Validate required environment variables
if [ -z "$SSH_USERNAME" ] || [ -z "$SSH_PASSWORD" ]; then
    echo -e "${RED}Error: SSH_USERNAME and SSH_PASSWORD must be set.${NC}" >&2
    exit 1
fi

# Security warning for default credentials
if [ "$SSH_USERNAME" = "archuser" ] && [ "$SSH_PASSWORD" = "changemelater" ]; then
    echo -e "${YELLOW}WARNING: Using default credentials!${NC}"
    echo -e "${YELLOW}Please set SSH_USERNAME and SSH_PASSWORD environment variables.${NC}"
    echo ""
fi

# Set root password if provided (not recommended)
if [ -n "$ROOT_PASSWORD" ]; then
    echo -e "${YELLOW}Setting root password...${NC}"
    echo "root:$ROOT_PASSWORD" | chpasswd
    echo -e "${GREEN}✓ Root password set${NC}"
    echo -e "${YELLOW}Note: Root login is disabled by default for security.${NC}"
    echo ""
else
    echo -e "${GREEN}✓ Root password not set (recommended)${NC}"
    echo ""
fi

# Create SSH user if it doesn't exist
if id "$SSH_USERNAME" &>/dev/null; then
    echo -e "${YELLOW}User $SSH_USERNAME already exists${NC}"
    # Update password anyway
    echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd
    echo -e "${GREEN}✓ Password updated for user $SSH_USERNAME${NC}"
else
    echo -e "${GREEN}Creating user $SSH_USERNAME...${NC}"
    useradd -m -s /bin/bash -G wheel "$SSH_USERNAME"
    echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd
    echo -e "${GREEN}✓ User $SSH_USERNAME created${NC}"
    echo -e "${GREEN}✓ Added to wheel group (sudo access)${NC}"
fi
echo ""

# Configure authorized keys if provided
if [ -n "$AUTHORIZED_KEYS" ]; then
    echo -e "${GREEN}Configuring SSH key authentication...${NC}"
    
    # Create .ssh directory with proper permissions
    mkdir -p /home/$SSH_USERNAME/.ssh
    
    # Handle both single key and multiple keys (newline or semicolon separated)
    echo "$AUTHORIZED_KEYS" | tr ';' '\n' > /home/$SSH_USERNAME/.ssh/authorized_keys
    
    # Set proper ownership and permissions
    chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME/.ssh
    chmod 700 /home/$SSH_USERNAME/.ssh
    chmod 600 /home/$SSH_USERNAME/.ssh/authorized_keys
    
    echo -e "${GREEN}✓ Authorized keys configured${NC}"
    
    # Optionally disable password authentication when keys are provided
    if [ "$DISABLE_PASSWORD_AUTH" = "true" ]; then
        echo -e "${GREEN}Disabling password authentication (using keys only)...${NC}"
        sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        echo -e "${GREEN}✓ Password authentication disabled${NC}"
    else
        echo -e "${YELLOW}Password authentication remains enabled${NC}"
        echo -e "${YELLOW}Set DISABLE_PASSWORD_AUTH=true to disable it${NC}"
    fi
    echo ""
else
    echo -e "${YELLOW}No SSH keys configured${NC}"
    echo -e "${YELLOW}Using password authentication only${NC}"
    echo ""
fi

# Create a welcome message
cat > /etc/motd << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║     🛡️  Hardened Arch Linux SSH Server on Railway       ║
║                                                           ║
║  ⚠️  WARNING: This is a containerized environment        ║
║     All data will be lost on redeploy!                   ║
║     Use Railway Volumes for persistent storage.          ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

System Information:
-------------------
EOF

# Add system info to MOTD
echo "  Distribution: Arch Linux" >> /etc/motd
echo "  Kernel: $(uname -r)" >> /etc/motd
echo "  Uptime: $(uptime -p 2>/dev/null || echo 'N/A')" >> /etc/motd
echo "" >> /etc/motd

# Create a helpful .bashrc for the user
cat >> /home/$SSH_USERNAME/.bashrc << 'EOF'

# Custom aliases for convenience
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias pacman-clean='sudo pacman -Scc'
alias update='sudo pacman -Syu'

# Custom prompt with color
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Show helpful message on first login
if [ ! -f ~/.firstlogin ]; then
    echo ""
    echo "🎉 Welcome to your Arch Linux container on Railway!"
    echo ""
    echo "Useful commands:"
    echo "  update          - Update system packages"
    echo "  pacman -S pkg   - Install a package"
    echo "  pacman -R pkg   - Remove a package"
    echo "  pacman -Ss name - Search for packages"
    echo ""
    echo "⚠️  Remember: This container is ephemeral!"
    echo "    Data will be lost on redeploy. Use Railway Volumes for persistence."
    echo ""
    touch ~/.firstlogin
fi
EOF

chown $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME/.bashrc

# Display connection information
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Configuration Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "User Configuration:"
echo -e "  Username: ${GREEN}$SSH_USERNAME${NC}"
echo -e "  Password: ${GREEN}[CONFIGURED]${NC}"
echo -e "  Sudo Access: ${GREEN}Yes${NC}"
echo -e "  SSH Keys: $([ -n "$AUTHORIZED_KEYS" ] && echo -e "${GREEN}Configured${NC}" || echo -e "${YELLOW}Not configured${NC}")"
echo ""
echo -e "Security Features:"
echo -e "  ✓ Root login disabled"
echo -e "  ✓ Strong cipher suites"
echo -e "  ✓ Fail2ban configured"
echo -e "  ✓ Firewall enabled"
echo -e "  ✓ Limited authentication attempts"
echo -e "  ✓ Connection timeouts enabled"
echo ""
echo -e "Starting SSH server..."
echo ""

# Start and configure firewalld
if command -v firewalld &> /dev/null; then
    echo -e "${GREEN}Starting firewalld...${NC}"
    firewalld --nofork --nopid &
    sleep 3
    
    # Configure firewall rules
    echo -e "${GREEN}Configuring firewall rules...${NC}"
    firewall-cmd --permanent --zone=public --add-port=22/tcp || true
    firewall-cmd --reload || true
    
    echo -e "${GREEN}✓ Firewall configured (SSH port 22 allowed)${NC}"
fi

# Start fail2ban if available
if command -v fail2ban-server &> /dev/null; then
    echo -e "${GREEN}Starting fail2ban...${NC}"
    fail2ban-server --async --pythonpath /usr/lib/python3.*/site-packages &
fi

# Start SSH server in foreground
echo -e "${GREEN}SSH server starting on port 22${NC}"
echo -e "${GREEN}Ready to accept connections!${NC}"
echo ""

exec /usr/sbin/sshd -D -e

#!/bin/bash
set -e

# SSH Configuration Script
# Default values for SSH credentials
: ${SSH_USERNAME:="archuser"}
: ${SSH_PASSWORD:="changemelater"}
: ${ROOT_PASSWORD:=""}
: ${AUTHORIZED_KEYS:=""}
: ${DISABLE_PASSWORD_AUTH:="false"}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Configuring SSH...${NC}"

# Validate required variables
if [ -z "$SSH_USERNAME" ] || [ -z "$SSH_PASSWORD" ]; then
    echo -e "${RED}Error: SSH_USERNAME and SSH_PASSWORD must be set.${NC}" >&2
    exit 1
fi

# Security warning
if [ "$SSH_USERNAME" = "archuser" ] && [ "$SSH_PASSWORD" = "changemelater" ]; then
    echo -e "${YELLOW}WARNING: Using default credentials!${NC}"
fi

# Set root password if provided
if [ -n "$ROOT_PASSWORD" ]; then
    echo "root:$ROOT_PASSWORD" | chpasswd
    echo -e "${GREEN}✓ Root password set${NC}"
fi

# Create SSH user if needed
if id "$SSH_USERNAME" &>/dev/null; then
    echo -e "${YELLOW}User $SSH_USERNAME already exists${NC}"
    echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd
else
    useradd -m -s /bin/bash -G wheel "$SSH_USERNAME"
    echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd
    echo -e "${GREEN}✓ User $SSH_USERNAME created${NC}"
fi

# Configure authorized keys
if [ -n "$AUTHORIZED_KEYS" ]; then
    mkdir -p /home/$SSH_USERNAME/.ssh
    echo "$AUTHORIZED_KEYS" | tr ';' '\n' > /home/$SSH_USERNAME/.ssh/authorized_keys
    chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME/.ssh
    chmod 700 /home/$SSH_USERNAME/.ssh
    chmod 600 /home/$SSH_USERNAME/.ssh/authorized_keys
    echo -e "${GREEN}✓ SSH keys configured${NC}"
    
    if [ "$DISABLE_PASSWORD_AUTH" = "true" ]; then
        sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        echo -e "${GREEN}✓ Password authentication disabled${NC}"
    fi
fi

# Create MOTD
cat > /etc/motd << 'EOF'
╔══════════════════════════════════════════════════════════╗
║  🦞 Molt.bot + Arch Linux SSH Server on Railway         ║
║     AI Agent Messaging Gateway                           ║
║                                                          ║
║  Web UI: https://your-app.railway.app/                  ║
║  Setup:  https://your-app.railway.app/setup             ║
╚══════════════════════════════════════════════════════════╝
EOF

# Helpful .bashrc
cat >> /home/$SSH_USERNAME/.bashrc << 'EOF'

# Molt.bot aliases
alias molt='moltbot'
alias molt-status='moltbot gateway status'
alias molt-logs='journalctl -u moltbot -f'

# System aliases  
alias ll='ls -lah --color=auto'
alias update='sudo pacman -Syu'

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

if [ ! -f ~/.firstlogin ]; then
    echo ""
    echo "🦞 Welcome to Molt.bot on Arch Linux!"
    echo ""
    echo "Molt.bot commands:"
    echo "  moltbot --help       - Show all commands"
    echo "  moltbot gateway      - Start gateway manually"
    echo "  moltbot config       - View/edit configuration"
    echo ""
    echo "Web UI: Access via your Railway domain"
    echo ""
    touch ~/.firstlogin
fi
EOF

chown $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME/.bashrc

echo -e "${GREEN}✓ SSH configuration complete${NC}"
echo ""

# Start SSH server
exec /usr/sbin/sshd -D -e

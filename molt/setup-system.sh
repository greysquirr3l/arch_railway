#!/bin/bash
set -e

echo "========================================="
echo " Molt.bot + SSH Server Setup"
echo "========================================="
echo ""

# Start and configure firewalld
if command -v firewalld &> /dev/null; then
    echo "Starting firewalld..."
    firewalld --nofork --nopid &
    sleep 3
    
    # Configure firewall rules
    echo "Configuring firewall rules..."
    firewall-cmd --permanent --zone=public --add-port=22/tcp || true
    firewall-cmd --permanent --zone=public --add-port=8080/tcp || true
    
    # If using remote gateway mode, also allow port 18789
    GATEWAY_BIND="${GATEWAY_BIND:-loopback}"
    if [ "$GATEWAY_BIND" != "loopback" ]; then
        echo "Remote gateway mode detected ($GATEWAY_BIND), allowing port 18789..."
        firewall-cmd --permanent --zone=public --add-port=18789/tcp || true
    fi
    
    firewall-cmd --reload || true
    echo "✓ Firewall configured (SSH: 22, HTTP: 8080$([ "$GATEWAY_BIND" != "loopback" ] && echo ", Gateway: 18789" || echo ""))"
fi

# Run SSH configuration first
if [ -f "/app/ssh-config.sh" ]; then
    echo "Configuring SSH server..."
    /app/ssh-config.sh &
    SSH_PID=$!
    echo "SSH server started (PID: $SSH_PID)"
else
    echo "Warning: ssh-config.sh not found"
fi

# Give SSH a moment to start
sleep 2

# Start the wrapper server (which manages the moltbot gateway)
echo ""
echo "Starting Molt.bot wrapper server..."
exec node /app/src/server.js

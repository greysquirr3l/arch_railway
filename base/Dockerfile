FROM archlinux:latest

# Set environment to non-interactive to avoid prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Update system and install essential packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    openssh \
    sudo \
    fail2ban \
    iproute2 \
    iputils \
    net-tools \
    bind-tools \
    curl \
    wget \
    vim \
    htop \
    tmux \
    git \
    base-devel && \
    pacman -Scc --noconfirm

# Create SSHD directory and set permissions
RUN mkdir -p /run/sshd && \
    chmod 755 /run/sshd

# Configure hardened SSH settings
RUN echo "# Hardened SSH Configuration for Railway" > /etc/ssh/sshd_config && \
    echo "Port 22" >> /etc/ssh/sshd_config && \
    echo "Protocol 2" >> /etc/ssh/sshd_config && \
    echo "HostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config && \
    echo "HostKey /etc/ssh/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config && \
    echo "HostKey /etc/ssh/ssh_host_ed25519_key" >> /etc/ssh/sshd_config && \
    echo "" >> /etc/ssh/sshd_config && \
    echo "# Logging" >> /etc/ssh/sshd_config && \
    echo "SyslogFacility AUTH" >> /etc/ssh/sshd_config && \
    echo "LogLevel INFO" >> /etc/ssh/sshd_config && \
    echo "" >> /etc/ssh/sshd_config && \
    echo "# Authentication" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "MaxAuthTries 3" >> /etc/ssh/sshd_config && \
    echo "MaxSessions 10" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config && \
    echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config && \
    echo "" >> /etc/ssh/sshd_config && \
    echo "# Disable forwarding by default" >> /etc/ssh/sshd_config && \
    echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config && \
    echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config && \
    echo "X11Forwarding no" >> /etc/ssh/sshd_config && \
    echo "PrintMotd no" >> /etc/ssh/sshd_config && \
    echo "" >> /etc/ssh/sshd_config && \
    echo "# Connection settings" >> /etc/ssh/sshd_config && \
    echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config && \
    echo "ClientAliveCountMax 2" >> /etc/ssh/sshd_config && \
    echo "TCPKeepAlive yes" >> /etc/ssh/sshd_config && \
    echo "UseDNS no" >> /etc/ssh/sshd_config && \
    echo "" >> /etc/ssh/sshd_config && \
    echo "# Security hardening" >> /etc/ssh/sshd_config && \
    echo "StrictModes yes" >> /etc/ssh/sshd_config && \
    echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config && \
    echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config && \
    echo "" >> /etc/ssh/sshd_config && \
    echo "# Use strong ciphers and algorithms" >> /etc/ssh/sshd_config && \
    echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config && \
    echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/sshd_config && \
    echo "KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256" >> /etc/ssh/sshd_config && \
    echo "" >> /etc/ssh/sshd_config && \
    echo "# Subsystems" >> /etc/ssh/sshd_config && \
    echo "Subsystem sftp /usr/lib/ssh/sftp-server" >> /etc/ssh/sshd_config

# Generate SSH host keys
RUN ssh-keygen -A

# Configure fail2ban for additional security
RUN mkdir -p /etc/fail2ban && \
    echo "[sshd]" > /etc/fail2ban/jail.local && \
    echo "enabled = true" >> /etc/fail2ban/jail.local && \
    echo "port = 22" >> /etc/fail2ban/jail.local && \
    echo "filter = sshd" >> /etc/fail2ban/jail.local && \
    echo "logpath = /var/log/auth.log" >> /etc/fail2ban/jail.local && \
    echo "maxretry = 3" >> /etc/fail2ban/jail.local && \
    echo "bantime = 3600" >> /etc/fail2ban/jail.local && \
    echo "findtime = 600" >> /etc/fail2ban/jail.local

# Configure sudoers for wheel group
RUN echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers && \
    echo "Defaults env_keep += \"SSH_AUTH_SOCK\"" >> /etc/sudoers

# Copy and configure the entrypoint script
COPY ssh-user-config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/ssh-user-config.sh

# Create a healthcheck script
RUN echo '#!/bin/bash' > /usr/local/bin/healthcheck.sh && \
    echo 'nc -z localhost 22' >> /usr/local/bin/healthcheck.sh && \
    chmod +x /usr/local/bin/healthcheck.sh

# Set up basic security limits
RUN echo "* soft nofile 65536" >> /etc/security/limits.conf && \
    echo "* hard nofile 65536" >> /etc/security/limits.conf && \
    echo "* soft nproc 32768" >> /etc/security/limits.conf && \
    echo "* hard nproc 32768" >> /etc/security/limits.conf

# Expose SSH port
EXPOSE 22

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Start SSH server
CMD ["/usr/local/bin/ssh-user-config.sh"]

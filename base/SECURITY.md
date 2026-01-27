# Security Policy

## 🔒 Security Features

This template implements multiple layers of security hardening to protect your Railway deployment.

### SSH Security Hardening

#### Protocol & Cryptography

- **SSH Protocol 2 Only**: Only the more secure SSH protocol version 2 is allowed
- **Strong Ciphers**:
  - `chacha20-poly1305@openssh.com` (fastest, modern AEAD cipher)
  - `aes256-gcm@openssh.com` (hardware-accelerated where available)
  - `aes128-gcm@openssh.com`
  - `aes256-ctr`, `aes192-ctr`, `aes128-ctr` (fallback ciphers)
  
- **Strong MACs (Message Authentication Codes)**:
  - `hmac-sha2-512-etm@openssh.com`
  - `hmac-sha2-256-etm@openssh.com`
  - `hmac-sha2-512`
  - `hmac-sha2-256`
  
- **Strong Key Exchange Algorithms**:
  - `curve25519-sha256` (recommended, modern elliptic curve)
  - `diffie-hellman-group16-sha512`
  - `diffie-hellman-group18-sha512`
  - `diffie-hellman-group14-sha256`

#### Authentication Security

- **Root Login Disabled**: The root account cannot be accessed via SSH
- **Maximum Auth Tries**: Limited to 3 attempts before disconnection
- **SSH Key Support**: Public key authentication available and recommended
- **Optional Password Disable**: Can disable password auth when using keys
- **No Empty Passwords**: Empty passwords are prohibited
- **Challenge-Response Disabled**: Prevents keyboard-interactive attacks

#### Connection Management

- **Client Alive Interval**: 300 seconds (5 minutes) - keeps connections alive
- **Client Alive Count Max**: 2 - disconnects after 2 missed keepalives
- **TCP Keep Alive**: Enabled to detect dead connections
- **DNS Lookups Disabled**: Faster connections, prevents DNS-based attacks
- **Strict Modes**: File permission checks for security-critical files
- **Max Sessions**: Limited to 10 concurrent sessions per connection

#### Access Control

- **Sudo Access via Wheel Group**: SSH user has controlled sudo access
- **Password Required for Sudo**: Must enter password for privilege escalation
- **SSH Agent Forwarding**: Enabled but controlled
- **TCP Forwarding**: Enabled but can be restricted
- **X11 Forwarding**: Disabled (not needed for server use)

### Fail2ban Protection

Automatic IP banning for brute-force protection:

- **Enabled for SSH**: Monitors SSH login attempts
- **Max Retries**: 3 failed attempts before ban
- **Ban Time**: 3600 seconds (1 hour)
- **Find Time**: 600 seconds (10 minute window)
- **Log Path**: Monitors `/var/log/auth.log`

### Railway Platform Security

Railway provides network-level security that complements the container hardening:

- **Network Isolation**: Services run in isolated containers
- **TCP Proxy**: Acts as a gateway/firewall for SSH access
- **Port Control**: Only explicitly exposed ports are accessible
- **DDoS Protection**: Railway handles network-level attacks
- **TLS Termination**: HTTPS handled by Railway platform

**Why no container firewall?**

Railway containers run without `CAP_NET_ADMIN` privileges (by design for security). This means traditional firewall tools (iptables, firewalld, ufw) cannot function. However, this is not a security concern because:

1. Railway controls network access at the platform level
2. Only ports you explicitly expose via TCP Proxy or HTTP are accessible
3. Container isolation prevents cross-service attacks
4. Our SSH hardening + fail2ban still protect against brute-force

### System Hardening

#### Resource Limits

- **File Descriptors**: 65536 soft/hard limit (prevents resource exhaustion)
- **Processes**: 32768 soft/hard limit per user
- **Core Dumps**: Managed through system limits

#### Minimal Attack Surface

- Only essential packages installed
- No unnecessary services running
- Regular package updates available (Arch Linux rolling release)
- SSH is the only exposed service

### Container Security

- **Non-root User**: SSH user runs with standard user privileges
- **Ephemeral Storage**: Data loss on redeploy encourages stateless design
- **Health Checks**: Automatic service monitoring
- **Restart Policy**: Automatic restart on failure (max 10 retries)

## 🛡️ Security Best Practices

### For Administrators

1. **Use SSH Keys**: Always prefer SSH key authentication over passwords

   ```bash
   # Generate a strong ED25519 key
   ssh-keygen -t ed25519 -a 100 -C "your_email@example.com"
   ```

2. **Disable Password Auth**: After setting up SSH keys, disable password authentication

   ```bash
   # Set this environment variable in Railway
   DISABLE_PASSWORD_AUTH=true
   ```

3. **Strong Passwords**: If using password auth, use strong, unique passwords
   - Minimum 16 characters
   - Mix of uppercase, lowercase, numbers, symbols
   - Use a password manager

4. **Regular Monitoring**: Check Railway logs regularly for suspicious activity

   ```bash
   # After SSH'ing in, check fail2ban status
   sudo fail2ban-client status sshd
   ```

5. **Update Regularly**: Keep the base image and packages updated

   ```bash
   # While connected via SSH
   sudo pacman -Syu
   ```

6. **Use Volumes for Sensitive Data**: Never store secrets in the container filesystem
   - Use Railway Volumes for persistent data
   - Use Railway environment variables for secrets

7. **Principle of Least Privilege**: Only grant necessary permissions
   - Don't enable root login
   - Use sudo only when required

### For Developers

1. **Never Commit Secrets**: Don't commit passwords, keys, or tokens to Git
   - Use `.env` files (which are gitignored)
   - Use Railway environment variables
   - Use `.env.example` for templates

2. **Audit Environment Variables**: Regularly review what's exposed

   ```bash
   # In Railway dashboard, check Variables tab
   ```

3. **Network Segmentation**: Use Railway's private networking when possible
   - Connect to databases via private networking
   - Only expose SSH via TCP proxy

4. **Monitoring & Alerting**: Set up monitoring for your service
   - Use Railway's built-in monitoring
   - Monitor SSH connection logs
   - Set up alerts for service downtime

5. **Backup Important Data**: Use Railway Volumes and external backups

   ```bash
   # Example: Backup to external storage
   rsync -avz /data/ user@backup-server:/backups/
   ```

## 🚨 Reporting Security Issues

If you discover a security vulnerability in this template:

1. **DO NOT** open a public issue
2. Email the maintainer directly (see README for contact)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

We will respond within 48 hours and work on a fix promptly.

## 🔄 Security Update Policy

### Template Updates

- Security patches will be released as soon as possible
- Check the repository regularly for updates
- Watch the repository for security announcements

### Arch Linux Updates

Since this is based on Arch Linux (rolling release):

- Base image gets regular updates
- Rebuild your container periodically to get latest packages
- Monitor Arch Linux security announcements: <https://security.archlinux.org/>

### Railway Platform Security

Railway handles:

- Platform-level security
- DDoS protection
- Network isolation
- Infrastructure security

Read more: <https://railway.com/legal/security>

## 📋 Security Checklist

Before deploying to production, ensure:

- [ ] Changed default SSH username and password
- [ ] Set strong, unique password (or disabled password auth)
- [ ] Configured SSH keys for authentication
- [ ] Set `DISABLE_PASSWORD_AUTH=true` if using keys only
- [ ] Reviewed and configured Railway environment variables
- [ ] Configured TCP Proxy in Railway settings
- [ ] Tested SSH connection from your machine
- [ ] Reviewed SSH configuration in Dockerfile
- [ ] Set up Railway Volumes for persistent data
- [ ] Documented access procedures for your team
- [ ] Set up monitoring and logging
- [ ] Tested fail2ban is working
- [ ] Reviewed Railway service logs
- [ ] Documented incident response procedures

## 🔗 Security Resources

### SSH Security

- [Mozilla SSH Security Guidelines](https://infosec.mozilla.org/guidelines/openssh)
- [OpenSSH Best Practices](https://www.ssh.com/academy/ssh/security)
- [Hardening SSH](https://www.sshaudit.com/hardening_guides.html)

### Arch Linux Security

- [Arch Security Wiki](https://wiki.archlinux.org/title/Security)
- [Arch Security Tracker](https://security.archlinux.org/)
- [Arch Linux Hardening](https://wiki.archlinux.org/title/Security#Hardening)

### Railway Security

- [Railway Security](https://railway.com/legal/security)
- [Railway Compliance](https://trust.railway.com/)
- [Railway Best Practices](https://docs.railway.com/overview/best-practices)

### General Security

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

## ⚖️ Compliance Considerations

If you need to comply with security standards:

### SOC 2 / ISO 27001

- Enable audit logging
- Implement access controls
- Document security procedures
- Regular security reviews
- Incident response plan

### PCI DSS

- Use SSH keys (multi-factor authentication)
- Regular security updates
- Access logging and monitoring
- Secure password storage
- Network segmentation

### HIPAA

- Encrypt data at rest (use encrypted volumes)
- Encrypt data in transit (SSH provides this)
- Access controls and audit logs
- Business associate agreements
- Incident response procedures

### GDPR

- Data minimization
- Access controls
- Audit logging
- Data protection impact assessment
- Privacy by design

**Note**: This template provides security features but is not pre-certified for any compliance framework. You are responsible for implementing additional controls as needed for your specific compliance requirements.

## 📝 Audit Log Examples

### Check Failed Login Attempts

```bash
# View auth logs
sudo journalctl -u sshd

# Check fail2ban status
sudo fail2ban-client status sshd

# View banned IPs
sudo fail2ban-client get sshd banip
```

### Monitor Active Connections

```bash
# Who is logged in
who

# Detailed connection info
w

# Last login history
last
```

### Review System Access

```bash
# Check sudo usage
sudo journalctl SYSLOG_IDENTIFIER=sudo

# View user login history
lastlog
```

---

**Last Updated**: January 2026  
**Template Version**: 1.0.0  
**Maintained By**: See README for contributors

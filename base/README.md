# 🛡️ Hardened Arch Linux SSH Server for Railway

A security-hardened Docker image based on Arch Linux, designed specifically for Railway deployment with SSH server access. This template provides a minimal, secure, and rolling-release Linux environment with modern security practices.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new)

## ✨ Features

### Core Features

- **Arch Linux Base**: Rolling-release distribution with cutting-edge packages
- **SSH Server (OpenSSH)**: Pre-configured for remote access
- **Security Hardened**: Multiple layers of security configurations
- **Railway Optimized**: Built specifically for Railway's platform
- **Flexible Authentication**: Supports both password and SSH key authentication

### Security Features

- 🔒 **Root login disabled** by default
- � **Firewalld protection** with strict port policies
- �🔐 **Strong cryptographic ciphers** (ChaCha20, AES-256-GCM)
- 🚫 **Fail2ban integration** for brute-force protection
- ⏱️ **Connection timeouts** and rate limiting
- 🔑 **SSH key authentication** support
- 📊 **Maximum 3 authentication attempts**
- 🛡️ **Minimal attack surface** with only essential packages

### Included Tools

- **System utilities**: sudo, vim, htop, tmux
- **Network tools**: iproute2, iputils, net-tools, bind-tools
- **Development tools**: git, base-devel, curl, wget
- **Security**: firewalld, fail2ban, openssh with hardened config

## ⚠️ Important Notice

**Railway runs Docker containers, not VPS!** Any data stored in the container will be **lost when redeploying**. This includes:

- Files created after deployment
- Installed packages (via pacman)
- Configuration changes
- User data

**For persistent storage**, use [Railway's Volume Mounts](https://docs.railway.com/reference/volumes).

## 🚀 Quick Start

### Option 1: Deploy from Template

1. Click the "Deploy on Railway" button above
2. Configure required environment variables:
   - `SSH_USERNAME` - Your desired SSH username
   - `SSH_PASSWORD` - Your desired password (use strong password!)
   - `AUTHORIZED_KEYS` - (Optional) SSH public keys for key-based auth
3. Wait for deployment to complete
4. Configure TCP Proxy (see below)
5. Connect via SSH

### Option 2: Deploy from Repository

1. Fork or clone this repository
2. Connect to Railway and create a new project
3. Link your GitHub repository
4. Configure environment variables
5. Deploy!

## 📋 Setup Instructions

### Step 1: Configure SSH Credentials

You can set credentials in two ways:

#### Option A: Railway Environment Variables (Recommended)

1. Go to your Railway project dashboard
2. Navigate to **Variables** tab
3. Add the following variables:
   - `SSH_USERNAME` - Your desired username
   - `SSH_PASSWORD` - Your desired password
   - `AUTHORIZED_KEYS` - (Optional) Your SSH public keys
   - `DISABLE_PASSWORD_AUTH` - (Optional) Set to `true` to disable password auth when using keys

4. Redeploy the service

#### Option B: Modify ssh-user-config.sh

1. Edit `ssh-user-config.sh` and change default values:

   ```bash
   : ${SSH_USERNAME:="archuser"}
   : ${SSH_PASSWORD:="changemelater"}
   ```

2. Commit and push changes
3. **⚠️ WARNING**: Do NOT commit real passwords to Git! Use environment variables instead.

### Step 2: Configure TCP Proxy

Railway requires TCP Proxy configuration for SSH access:

1. Go to your Railway project dashboard
2. Click on your service
3. Navigate to **Settings** → **Networking**
4. Under **Public Networking**, click **TCP Proxy**
5. Enter port `22` (SSH default port)
6. Click **Add Proxy**
7. Railway will provide you with:
   - A domain (e.g., `mainline.proxy.rlwy.net`)
   - A port number (e.g., `30899`)

**Need help with ports?** See [Port Reference Guide](../PORTS.md)

### Step 3: Connect via SSH

Use the domain and port provided by Railway:

```bash
ssh <username>@<domain> -p <port>
```

Example:

```bash
ssh archuser@mainline.proxy.rlwy.net -p 30899
```

#### Using SSH Keys

If you configured `AUTHORIZED_KEYS`:

```bash
ssh -i ~/.ssh/id_rsa archuser@mainline.proxy.rlwy.net -p 30899
```

## 🔧 Configuration

### Environment Variables

| Variable | Required | Default | Description |
| ---------- | ---------- | --------- | ------------- |
| `SSH_USERNAME` | Yes | `archuser` | SSH username for login |
| `SSH_PASSWORD` | Yes | `changemelater` | Password for the SSH user |
| `AUTHORIZED_KEYS` | No | - | SSH public keys (separate multiple keys with newlines or semicolons) |
| `DISABLE_PASSWORD_AUTH` | No | `false` | Set to `true` to disable password auth when using keys |
| `ROOT_PASSWORD` | No | - | Root password (not recommended, root login is disabled) |

### SSH Key Authentication

To use SSH keys instead of passwords:

1. Generate an SSH key pair (if you don't have one):

   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. Copy your public key:

   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

3. Add the public key to Railway environment variable `AUTHORIZED_KEYS`

4. (Optional) Set `DISABLE_PASSWORD_AUTH=true` for key-only authentication

5. Redeploy the service

### Example: Multiple SSH Keys

Separate multiple keys with newlines or semicolons in `AUTHORIZED_KEYS`:

```
ssh-ed25519 AAAAC3... user1@machine1;ssh-rsa AAAAB3... user2@machine2
```

## 🔒 Security Features Explained

### 1. SSH Hardening

- **Protocol 2 Only**: Uses only SSH protocol 2 (more secure)
- **Strong Ciphers**: ChaCha20-Poly1305, AES-256-GCM, AES-128-GCM
- **Strong MACs**: HMAC-SHA2-512, HMAC-SHA2-256
- **Strong Key Exchange**: Curve25519, DH-Group16/18-SHA512
- **Limited Auth Attempts**: Maximum 3 attempts before disconnection
- **Connection Timeouts**: Auto-disconnect idle connections (5 minutes)

### 2. Fail2ban Protection

Automatically bans IPs after failed login attempts:

- **Max Retries**: 3 failed attempts
- **Ban Time**: 1 hour
- **Find Time**: 10 minutes window

### 3. User Permissions

- Root login completely disabled
- SSH user has sudo access via `wheel` group
- Password required for sudo commands

### 4. System Hardening

- Minimal package installation
- Security limits configured
- No unnecessary services running

## 📦 Persistent Storage

Since Railway containers are ephemeral, use **Railway Volumes** for persistent data:

1. Go to your service settings
2. Navigate to **Volumes** tab
3. Click **New Volume**
4. Mount to a path like `/data` or `/home/archuser/persistent`
5. Store important data in mounted volumes

Example: Mounting a volume at `/data`

```bash
# After connecting via SSH
cd /data
# Your files here will persist across redeploys
```

## 🛠️ Common Tasks

### Update System Packages

```bash
sudo pacman -Syu
```

### Install New Packages

```bash
sudo pacman -S package-name
```

Example:

```bash
sudo pacman -S python nodejs docker
```

### Search for Packages

```bash
pacman -Ss search-term
```

### Remove Packages

```bash
sudo pacman -R package-name
```

### Clean Package Cache

```bash
sudo pacman -Scc
```

## 🐛 Troubleshooting

### Cannot Connect via SSH

1. **Check TCP Proxy Configuration**: Ensure port 22 is exposed in Railway settings
2. **Verify Credentials**: Double-check username and password in environment variables
3. **Check Service Status**: Ensure the container is running in Railway dashboard
4. **Firewall**: Verify your local firewall allows outbound SSH connections
5. **Correct Domain/Port**: Use the exact domain and port provided by Railway

### "Permission Denied" Error

1. Verify you're using the correct username
2. Check password is set correctly in environment variables
3. If using SSH keys, ensure `AUTHORIZED_KEYS` is configured properly
4. Try password authentication if keys aren't working

### Connection Timeout

1. Check Railway service is running
2. Verify TCP Proxy is configured correctly
3. Test from a different network (could be local firewall issue)

### "Too Many Authentication Failures"

This happens when SSH tries multiple keys before the right one:

```bash
ssh -o IdentitiesOnly=yes -i ~/.ssh/specific_key user@host -p port
```

### Data Loss After Redeploy

This is expected behavior! Use Railway Volumes for persistent storage.

## 📊 Monitoring & Logs

### View Live Logs

In Railway dashboard:

1. Click on your service
2. Go to **Deployments** tab
3. Click on the active deployment
4. View logs in real-time

### Check SSH Server Status

After connecting:

```bash
sudo systemctl status sshd
```

### View Failed Login Attempts

```bash
sudo fail2ban-client status sshd
```

## 🎯 Use Cases

- **Remote Development**: Full Arch Linux environment accessible from anywhere
- **System Administration**: Practice Arch Linux commands and administration
- **Build Environment**: Use rolling-release packages for development
- **Testing Ground**: Quickly spin up/destroy Arch environments
- **Learning Platform**: Learn Linux administration safely
- **Personal Server**: Run scripts, cron jobs, or small applications

## 🔄 Railway Metal Compatibility

This template is fully compatible with Railway Metal (Railway's next-generation infrastructure):

- ✅ Optimized for Railway Metal performance
- ✅ Health checks configured
- ✅ Proper signal handling for graceful shutdowns
- ✅ TCP proxy support
- ✅ Volume mount ready

Learn more about [Railway Metal](https://docs.railway.com/railway-metal).

## ⚡ Pro Tips

1. **Use SSH Keys**: Much more secure than passwords
2. **Enable Volumes**: Don't lose important data on redeploys
3. **Regular Updates**: Keep the container updated when ssh'd in (changes lost on redeploy)
4. **Strong Passwords**: If using password auth, use a strong, unique password
5. **Monitor Logs**: Check Railway logs for any security issues
6. **Fail2ban**: Check banned IPs periodically if you notice issues

## 📝 Example Session

```bash
# Connect to your container
ssh archuser@mainline.proxy.rlwy.net -p 30899

# Update system
sudo pacman -Syu

# Install development tools
sudo pacman -S python python-pip nodejs npm

# Create a project directory (use /data if you have a volume mounted)
mkdir ~/project
cd ~/project

# Do your work
git clone https://github.com/yourusername/yourproject.git
cd yourproject
python main.py
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Resources

- [Port Reference Guide](../PORTS.md) - Complete port configuration
- [Railway Documentation](https://docs.railway.com/)
- [Railway Metal](https://docs.railway.com/railway-metal)
- [Railway Volumes](https://docs.railway.com/reference/volumes)
- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [OpenSSH Documentation](https://www.openssh.com/manual.html)
- [Fail2ban Documentation](https://www.fail2ban.org/wiki/index.php/Main_Page)

## ⚠️ Security Disclaimer

While this image implements multiple security hardening measures, no system is 100% secure. Always:

- Use strong, unique passwords
- Prefer SSH key authentication over passwords
- Keep your system updated
- Monitor access logs regularly
- Use Railway's security features
- Never commit sensitive credentials to Git

## 💬 Support

For issues specific to this template:

- Open an issue on GitHub

For Railway platform issues:

- [Railway Station (Help Forum)](https://station.railway.com/)
- [Railway Discord](https://discord.gg/railway)
- [Railway Status](https://status.railway.com/)

---

*Remember: This is a containerized environment, not a VPS. Use Railway Volumes for persistent storage!*

# Quick Start Guide

Get your hardened Arch Linux SSH server running on Railway in 5 minutes!

## 🚀 Fast Track Deployment

### 1. Deploy to Railway (1 minute)

Click the deploy button or connect your forked repo:

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new)

### 2. Set Environment Variables (1 minute)

In Railway dashboard, go to **Variables** and add:

```
SSH_USERNAME=yourusername
SSH_PASSWORD=your-strong-password-here
```

**Optional but recommended:**

```
AUTHORIZED_KEYS=ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWm... your-email@example.com
DISABLE_PASSWORD_AUTH=true
```

### 3. Configure TCP Proxy (1 minute)

1. Go to project **Settings** → **Networking**
2. Click **TCP Proxy**
3. Enter port: `22`
4. Click **Add Proxy**
5. Note the domain and port (e.g., `mainline.proxy.rlwy.net:30899`)

📘 **Need help?** See [Port Reference Guide](../PORTS.md)

### 4. Wait for Deployment (1-2 minutes)

Watch the build logs in Railway dashboard. Wait for "Deployed" status.

### 5. Connect! (30 seconds)

```bash
ssh yourusername@mainline.proxy.rlwy.net -p 30899
```

Enter your password when prompted. Done! 🎉

## 📝 Quick Reference

### Common Commands

```bash
# Update system
sudo pacman -Syu

# Install package
sudo pacman -S package-name

# Search packages
pacman -Ss search-term

# Remove package
sudo pacman -R package-name
```

### Useful Aliases (Pre-configured)

```bash
ll        # Detailed list
la        # List all
update    # System update
```

## ⚡ Pro Tips

1. **Use SSH Keys**: Much more secure than passwords!

   ```bash
   ssh-keygen -t ed25519
   # Add public key to AUTHORIZED_KEYS in Railway
   ```

2. **Set up a Volume**: For persistent storage
   - Railway Dashboard → Volumes → New Volume
   - Mount at `/data` or `/home/yourusername/persistent`

3. **Bookmark Connection**: Save SSH config locally

   ```bash
   # Add to ~/.ssh/config
   Host railway-arch
       HostName mainline.proxy.rlwy.net
       Port 30899
       User yourusername
       IdentityFile ~/.ssh/id_ed25519
   
   # Then just run:
   ssh railway-arch
   ```

## 🔒 Security Checklist

- [ ] Changed default credentials
- [ ] Using strong password or SSH keys
- [ ] Confirmed TCP proxy is configured
- [ ] Tested SSH connection
- [ ] Reviewed security settings

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Connection refused | Check TCP Proxy is configured, service is running |
| Permission denied | Verify username/password in dashboard Variables |
| Connection timeout | Check firewall, try different network |
| Too many auth failures | Use `ssh -o IdentitiesOnly=yes -i ~/.ssh/key` |

## 📚 Next Steps

- Read the full [README.md](README.md) for detailed instructions
- Review [SECURITY.md](SECURITY.md) for security best practices  
- Set up Railway Volumes for persistent storage
- Configure monitoring and alerts

## 🔗 Helpful Links

- [Railway Docs](https://docs.railway.com/)
- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [SSH Key Guide](https://www.ssh.com/academy/ssh/keygen)

---

**Need help?** Check the full README or open an issue on GitHub!

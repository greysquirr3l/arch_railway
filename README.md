# Hardened Arch Linux Templates for Railway

Production-ready, security-hardened Arch Linux Docker templates optimized for Railway deployment. Choose the variant that fits your needs:

## 🎯 Templates

### [`base/`](base/) - SSH-Only Server

Minimal, hardened Arch Linux with SSH access only. Perfect for:

- Remote development environments
- System administration practice  
- Secure command-line workspaces
- Learning Linux administration

**Features:**

- Hardened OpenSSH with strong ciphers
- Firewalld protection with strict port policies
- Fail2ban brute-force protection
- Root login disabled
- Minimal attack surface
- Railway optimized

[📖 Base Template Documentation](base/README.md)

---

### [`molt/`](molt/) - AI Agent Gateway + SSH

Everything in `base/` PLUS [Molt.bot](https://docs.molt.bot/) AI agent messaging gateway. Perfect for:

- AI assistants via WhatsApp/Telegram/Discord
- Remote development + AI agent access
- Self-hosted AI messaging gateway
- Agent workflow development

**Features:**

- All security features from `base/`
- Molt.bot gateway (formerly clawdbot)
- WhatsApp, Telegram, Discord, iMessage support
- Web-based Control UI
- Setup wizard at `/setup`
- **Fixed gateway auth token issue**
- **Pinned to stable version (v2026.1.24)**
- **Optional remote gateway mode** (for multi-device setups)

[📖 Molt Template Documentation](molt/README.md)

## 🚀 Quick Start

### Deploy Base Template

```bash
cd base/
# Deploy to Railway, configure TCP proxy for port 22
```

### Deploy Molt Template

```bash
cd molt/
# Deploy to Railway
# Add Volume at /data
# Configure TCP proxy for port 22
# Access /setup wizard
```

## 📋 Common Setup

Both templates require:

1. **Railway Volume** mounted at `/data` (for persistent storage)
2. **TCP Proxy** configured for port 22 (for SSH access)
3. **Environment Variables**:
   - `SSH_USERNAME` - Your SSH username
   - `SSH_PASSWORD` - Your SSH password  
   - `AUTHORIZED_KEYS` - (Optional) SSH public keys

Additionally, `molt/` requires:

- `SETUP_PASSWORD` - Password for `/setup` wizard
- `MOLTBOT_STATE_DIR=/data/.moltbot`
- `MOLTBOT_WORKSPACE_DIR=/data/workspace`

📘 **Complete port configuration guide:** [PORTS.md](PORTS.md)

## 🔒 Security Features

Both templates include:

- ✅ Root login disabled
- ✅ Firewalld with dynamic port management
- ✅ Strong SSH ciphers (ChaCha20, AES-256-GCM)
- ✅ Fail2ban integration
- ✅ Connection timeouts
- ✅ Limited authentication attempts (max 3)
- ✅ SSH key authentication support
- ✅ Minimal package installation

## 🏗️ Repository Structure

```
arch_railway/
├── base/                      # SSH-only template
│   ├── Dockerfile
│   ├── ssh-user-config.sh
│   ├── railway.toml
│   ├── README.md
│   └── SECURITY.md
│
├── molt/                      # Molt.bot + SSH template
│   ├── Dockerfile
│   ├── setup-system.sh
│   ├── ssh-config.sh
│   ├── wrapper/               # Node.js wrapper server
│   │   ├── package.json
│   │   └── src/server.js
│   ├── railway.toml
│   └── README.md
│
├── LICENSE                    # MIT License (shared)
├── .gitignore                # Shared gitignore
├── PERSONAL.md               # Personal deployment notes (gitignored)
└── README.md                 # This file
```

## 🔄 Choosing Between Templates

| Need | Template |
| ------ | ---------- |
| Just SSH access | **base/** |
| SSH + AI agent gateway | **molt/** |
| Minimal resource usage | **base/** |
| WhatsApp/Telegram bot | **molt/** |
| Simple terminal server | **base/** |
| AI messaging workflows | **molt/** |
| Reproducible builds | Both (molt pinned to v2026.1.24) |

## 💾 Persistent Storage

**Important**: Railway containers are ephemeral!  

Both templates require a **Railway Volume** mounted at `/data`:

1. Railway Dashboard → Your Service → Volumes
2. New Volume → Mount path: `/data`
3. Deploy

**What persists:**

- `base/`: User files, installed packages (if stored in `/data`)
- `molt/`: Molt.bot config, sessions, workspace, chat history

## 🛡️ The Molt Gateway Token Fix

The `molt/` template includes a **critical fix** for the common error:

```
disconnected (1008): unauthorized: gateway token missing
(set gateway.remote.token to match gateway.auth.token)
```

**Solution**: The wrapper automatically configures both `gateway.auth.token` AND `gateway.remote.token` to match, allowing proper browser authentication.

Reference: [greysquirr3l/clawdbot-railway-template](https://github.com/greysquirr3l/clawdbot-railway-template)

## 📚 Documentation

- [Port Reference Guide](PORTS.md) - **Complete port configuration guide**
- [Base Template README](base/README.md) - SSH-only server guide
- [Base Security Policy](base/SECURITY.md) - Security features explained
- [Base Quick Start](base/QUICKSTART.md) - 5-minute setup
- [Molt Template README](molt/README.md) - AI gateway + SSH guide
- [Molt Remote Gateway Setup](molt/REMOTE_GATEWAY.md) - **Multi-device configuration**
- [Molt Gateway Token Fix](molt/GATEWAY_TOKEN_FIX.md) - Fixes auth error
- [Molt Version Strategy](molt/VERSION.md) - Version pinning details
- [Molt.bot Official Docs](https://docs.molt.bot/) - Molt.bot documentation
- [Railway Docs](https://docs.railway.com/) - Railway platform docs

## 🤝 Contributing

Contributions welcome! Please:

1. Fork this repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

## ⚠️ Security

- Never commit real SSH keys or passwords to Git
- Use `PERSONAL.md` for local deployment notes (gitignored)
- Set credentials via Railway environment variables only
- Use SSH keys instead of passwords when possible
- Enable `DISABLE_PASSWORD_AUTH=true` for key-only access

## 📄 License

MIT License - see [LICENSE](LICENSE) file

Both templates are free to use, modify, and distribute.

## 🙏 Credits

- **Base Template**: Original hardened Arch Linux SSH server
- **Molt Integration**: Based on [greysquirr3l/clawdbot-railway-template](https://github.com/greysquirr3l/clawdbot-railway-template)
- **Molt.bot**: [moltbot/moltbot](https://github.com/moltbot/moltbot) (formerly clawdbot)
- **Railway**: [Railway Platform](https://railway.com/)

## 🔗 Resources

- [Railway Templates](https://railway.com/templates)
- [Arch Linux Docker Hub](https://hub.docker.com/_/archlinux/)
- [Railway Metal Upgrade](https://docs.railway.com/reference/metal-upgrade)
- [Molt.bot Documentation](https://docs.molt.bot/)
- [OpenSSH Security](https://www.openssh.com/security.html)

---

**Built with ❤️ for the Railway community**

*Questions? Open an issue on GitHub!*

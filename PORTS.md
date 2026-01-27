# Port Reference Guide

Complete list of ports used by both templates and how to configure them in Railway.

## Base Template (SSH-Only)

### Required Ports

| Port | Protocol | Service | Railway Config | Exposed To |
| ------ | ---------- | --------- | ---------------- | ------------ |
| 22 | TCP | SSH Server | TCP Proxy | Internet (via Railway proxy) |

### Railway Configuration

1. **Settings** → **Networking** → **TCP Proxy**
2. Add port: `22`
3. Railway provides: `domain:port` (e.g., `mainline.proxy.rlwy.net:30899`)
4. Connect via: `ssh username@domain -p port`

### No Other Ports Needed

The base template is minimal - only SSH is exposed.

---

## Molt Template (AI Gateway + SSH)

### Required Ports

| Port | Protocol | Service | Railway Config | Exposed To |
| ------ | ---------- | --------- | ---------------- | ------------ |
| 22 | TCP | SSH Server | TCP Proxy | Internet (via Railway proxy) |
| 8080 | HTTP/WS | Web UI + Wrapper | Public Networking (HTTP) | Internet (Railway auto-assigns domain) |

### Internal Ports (Not Exposed by Default)

| Port | Protocol | Service | Binding | Notes |
| ------ | ---------- | --------- | --------- | ------- |
| 18789 | HTTP/WS | Molt.bot Gateway | Loopback (default) | Proxied through wrapper on port 8080. Can be exposed for remote gateway mode - see below |

#### Optional: Remote Gateway Mode

By default, the gateway binds to loopback only for security. However, you can enable direct access:

**Configuration:**

```bash
# In Railway environment variables
GATEWAY_BIND=loopback      # Default - web UI only
GATEWAY_BIND=tailnet       # Tailscale access (secure)
GATEWAY_BIND=0.0.0.0       # All interfaces (use with caution)
```

**To expose port 18789 for remote access:**

1. Set `GATEWAY_BIND=tailnet` or `GATEWAY_BIND=0.0.0.0`
2. **Settings** → **Networking** → **TCP Proxy**
3. Add port: `18789`
4. Railway provides: `gateway-domain:port`
5. Configure remote nodes to connect to this endpoint

**Security Warning:** Only enable remote gateway if you understand the security implications. See [REMOTE_GATEWAY.md](molt/REMOTE_GATEWAY.md) for detailed setup.

### Railway Configuration

#### 1. HTTP Service (Automatic)

Railway automatically exposes port 8080 via Public Networking:

- No manual configuration needed
- Railway assigns: `https://your-service-name.up.railway.app`
- Access web UI: `https://your-service-name.up.railway.app/`
- Access setup: `https://your-service-name.up.railway.app/setup`

#### 2. SSH Access (Manual)

1. **Settings** → **Networking** → **TCP Proxy**
2. Add port: `22`
3. Railway provides: `domain:port` (e.g., `conductor.proxy.rlwy.net:41234`)
4. Connect via: `ssh username@domain -p port`

### Port Flow Diagram

```
Internet
   │
   ├─ HTTPS (443) → Railway → :8080 (Wrapper)
   │                              │
   │                              └─ Proxy → :18789 (Gateway)
   │
   └─ SSH → Railway TCP Proxy → :22 (SSH Server)
```

---

## Environment Variable Ports

### Base Template

No port-related environment variables needed.

### Molt Template

| Variable | Default | Purpose | Change? |
| ---------- | --------- | --------- | --------- |
| `PORT` | `8080` | Wrapper HTTP port | ❌ No (Railway sets this) |
| `INTERNAL_GATEWAY_PORT` | `18789` | Gateway internal port | ⚠️ Only if needed |
| `INTERNAL_GATEWAY_HOST` | `127.0.0.1` | Gateway bind address | ⚠️ Only if needed |

**Note**: Do NOT change `PORT` - Railway automatically sets it to 8080 and routes traffic accordingly.

---

## Firewall Considerations

### Outbound Ports (Both Templates)

Your containers may need **outbound** access to:

| Service | Ports | Protocol | Purpose |
| --------- | ------- | ---------- | --------- |
| HTTPS | 443 | TCP | API calls, package downloads |
| HTTP | 80 | TCP | Package downloads, redirects |
| DNS | 53 | UDP/TCP | Domain resolution |
| NTP | 123 | UDP | Time synchronization (optional) |

Railway allows all outbound traffic by default.

### Inbound Ports Summary

**Base Template:**

- Only port 22 (SSH) via TCP Proxy

**Molt Template:**

- Port 8080 (HTTP/WebSocket) via Railway automatic routing
- Port 22 (SSH) via TCP Proxy

---

## Security Notes

### Base Template

1. ✅ SSH is the only exposed service
2. ✅ Hardened SSH configuration (strong ciphers)
3. ✅ Fail2ban protection
4. ✅ No web services exposed

### Molt Template

1. ✅ Gateway runs on loopback only (not directly exposed)
2. ✅ Wrapper handles all internet-facing connections
3. ✅ Token authentication required for gateway
4. ✅ SSH and web UI are separate services
5. ⚠️ `/setup` endpoint protected by `SETUP_PASSWORD`
6. ⚠️ Gateway requires `MOLTBOT_GATEWAY_TOKEN` for API access

---

## Service Health Checks

### Base Template

**Health Check Endpoint:** None (uses TCP port check on 22)

Railway verifies SSH is listening on port 22.

### Molt Template

**Health Check Endpoint:** `GET /healthz`

```bash
# Check service health
curl https://your-service.up.railway.app/healthz

# Response
{
  "ok": true,
  "configured": true
}
```

**Configured in:**

- [Dockerfile](molt/Dockerfile): `HEALTHCHECK` directive
- [railway.toml](molt/railway.toml): `healthcheckPath`

---

## Common Port Issues

### "Cannot connect via SSH"

**Symptoms:**

- Connection timeout
- Connection refused
- No route to host

**Solutions:**

1. ✅ Verify TCP Proxy is configured in Railway settings
2. ✅ Check correct domain and port from Railway dashboard
3. ✅ Ensure container is running (check Railway logs)
4. ✅ Test from different network (firewall issue?)
5. ✅ Verify SSH service started (check deployment logs)

### "Cannot access web UI" (Molt only)

**Symptoms:**

- 502 Bad Gateway
- Connection timeout
- Service unavailable

**Solutions:**

1. ✅ Verify service is deployed and running
2. ✅ Check Railway assigned a public domain
3. ✅ Wait for health check to pass (~30 seconds)
4. ✅ Check container logs for errors
5. ✅ Try accessing `/healthz` endpoint first

### "Gateway token error" (Molt only)

**Symptoms:**

- `disconnected (1008): unauthorized`
- WebSocket connection fails

**Solutions:**

1. ✅ This template fixes this automatically!
2. ✅ Verify `MOLTBOT_GATEWAY_TOKEN` is set
3. ✅ Check `/data/.moltbot/moltbot.json` has both tokens
4. ✅ See [GATEWAY_TOKEN_FIX.md](molt/GATEWAY_TOKEN_FIX.md)

---

## Testing Port Connectivity

### Test SSH Port (Both Templates)

```bash
# Test if port is open (from your machine)
nc -zv domain.proxy.rlwy.net PORT

# Expected output:
# Connection to domain.proxy.rlwy.net PORT succeeded!
```

### Test HTTP Port (Molt Only)

```bash
# Test health endpoint
curl -v https://your-service.up.railway.app/healthz

# Test WebSocket (requires token)
wscat -c wss://your-service.up.railway.app/__moltbot__/ws

# Check setup page (requires auth)
curl -u "admin:$SETUP_PASSWORD" https://your-service.up.railway.app/setup
```

---

## Port Customization (Advanced)

### Changing Internal Gateway Port (Molt)

If port 18789 conflicts with something else:

1. Set environment variable:

   ```
   INTERNAL_GATEWAY_PORT=18790
   ```

2. Update wrapper configuration (no code changes needed)

3. Redeploy

**Note**: The wrapper automatically uses this port for proxying.

### Custom SSH Port (Not Recommended)

Railway's TCP Proxy handles port mapping automatically. The container always listens on port 22 internally. Railway maps it to an external port like `30899`.

**Do not** change the internal SSH port from 22 unless you have a specific reason.

---

## Quick Reference

### Base Template

```bash
# SSH Connection
ssh username@domain.proxy.rlwy.net -p ASSIGNED_PORT

# Port to configure in Railway
TCP Proxy: 22
```

### Molt Template

```bash
# Web UI
https://your-service-name.up.railway.app/

# Setup Wizard  
https://your-service-name.up.railway.app/setup

# Health Check
https://your-service-name.up.railway.app/healthz

# SSH Connection
ssh username@domain.proxy.rlwy.net -p ASSIGNED_PORT

# Ports to configure in Railway
Public Networking: Automatic (HTTP)
TCP Proxy: 22
```

---

## Related Documentation

- [Base Template README](base/README.md)
- [Molt Template README](molt/README.md)
- [Remote Gateway Setup](molt/REMOTE_GATEWAY.md) - Direct gateway access configuration
- [Railway Networking Docs](https://docs.railway.com/guides/networking)
- [Railway TCP Proxy Docs](https://docs.railway.com/guides/networking#tcp-proxying)
- [Molt Gateway Token Fix](molt/GATEWAY_TOKEN_FIX.md)

---

**Last Updated:** January 27, 2026  
**Templates Version:** Base (latest) | Molt (v2026.1.24)

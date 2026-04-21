# n8n-mcp

This document covers the `n8n-mcp` service added to the platform.

## Purpose

`n8n-mcp` is a dedicated MCP server for AI-assisted n8n workflow building. In this platform it is hosted on the same VM and Docker network as `n8n`, and reaches n8n over the internal Docker hostname `http://n8n:5678`.

## Public endpoint

- Base domain: `https://n8n-mcp.samandrey.work`
- MCP endpoint for clients: `https://n8n-mcp.samandrey.work/mcp`
- Health endpoint: `https://n8n-mcp.samandrey.work/health`

Important: MCP clients must use the `/mcp` path, not just the domain root.

## Required environment variables

Add these values to `.env`:

```env
N8N_MCP_API_KEY=<n8n-api-key-from-settings-api>
N8N_MCP_AUTH_TOKEN=<generate-32-plus-char-random-token>
N8N_MCP_LOG_LEVEL=info
```

Notes:
- `N8N_MCP_API_KEY` is created in the n8n UI under `Settings -> API`
- `N8N_MCP_AUTH_TOKEN` is used as the bearer token for MCP clients
- the compose config maps the same token to both `MCP_AUTH_TOKEN` and `AUTH_TOKEN`

## Deployment

```bash
docker compose pull n8n-mcp
docker compose up -d n8n-mcp caddy
```

If the domain is newly introduced, also make sure DNS for `n8n-mcp.samandrey.work` points to the VM before expecting a valid public HTTPS route.

## Verification

### Docker network

```bash
docker exec lab-caddy wget -qO- http://n8n-mcp:3000/health
```

Expected result: health response from the container.

### Through Caddy on the server

```bash
curl -vk --resolve n8n-mcp.samandrey.work:443:127.0.0.1 https://n8n-mcp.samandrey.work/health
```

Expected result: HTTP 200.

### MCP endpoint smoke test

Replace `<TOKEN>` with the value from `N8N_MCP_AUTH_TOKEN`.

```bash
curl -X POST https://n8n-mcp.samandrey.work/mcp \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"id\":1}"
```

Expected result: JSON response with the tools list.

## Logs

```bash
docker logs --tail 50 lab-n8n-mcp
docker logs -f lab-n8n-mcp
```

## Image pin

The platform pins:

- `ghcr.io/czlonkowski/n8n-mcp:v2.47.13`

Update only by editing `docker-compose.yml` in a focused dependency-change commit.

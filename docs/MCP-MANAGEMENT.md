# MCP management layer

## Purpose

The platform exposes one or more MCP servers (currently just `n8n-mcp`).
Several agent clients consume them: Claude inside Cowork, Codex CLI, and
potentially more over time. The management layer answers three questions
in one place:

1. Which MCP servers does the platform expose?
2. Which clients are allowed to use each server?
3. How is each client supposed to be configured?

Without this layer, every client accumulates its own snippet and the
list drifts.

## Shape of the solution (phase 3a)

The approach here is a **client-side manifest + generator**:

- `mcp/servers.yaml` is the single source of truth.
- `scripts/render-mcp-configs.py` reads the manifest and writes one
  file per client into `mcp/rendered/`.
- Each rendered file uses `${ENV_VAR}` placeholders instead of real
  token values, which keeps the rendered outputs safe to commit and
  forces the operator to wire secrets through the platform `.env`
  or their user environment, not a checked-in file.
- Clients still have their own native config files (the Cowork UI,
  `~/.codex/config.toml`). The manifest does not replace them —
  it feeds them.

No gateway is running between clients and servers right now. Each
client talks directly to each server by URL.

## When to revisit

This shape is right while:

- the number of servers is small (1–3),
- the number of clients is small (≤3), and
- there is no pressing need for central audit, rate limits, or per-client
  token rotation.

If any of the following changes, it is worth looking at an **MCP gateway**
as a proper platform service (Docker Compose entry, Caddy route, digest
pin — same discipline as `n8n-mcp`):

- You add a third server and want clients to see one endpoint rather than three.
- You want per-client audit logs in one place.
- You want to rotate tokens server-side without touching every client.
- You want to throttle or sandbox specific tools before they reach n8n.

A research note on gateway options (`metamcp`, `mcp-proxy`, `mcpo`, etc.)
can be commissioned before making that call — but until we hit the
triggers above, the manifest-and-generator design stays.

## File layout

```
platform-repo/
├── mcp/
│   ├── README.md
│   ├── servers.yaml          ← edit this
│   └── rendered/             ← generated; committed with placeholders
│       ├── claude-cowork.md
│       └── codex.toml
└── scripts/
    └── render-mcp-configs.py
```

## Common tasks

### Add a new server

1. Add a block under `servers:` in `mcp/servers.yaml`.
2. Choose which clients should see it via `enabled_for`.
3. Run `python scripts/render-mcp-configs.py`.
4. Commit the manifest change and the refreshed `rendered/` files together.

If the new server is also a platform-hosted service, add the service to
`docker-compose.yml` and document it in `docs/` (as was done for `n8n-mcp`
in `docs/N8N-MCP.md`) in the same pull request, so the platform stays
reproducible from a clean clone.

### Add a new client

1. Add a block under `clients:` in `mcp/servers.yaml`. Pick a `kind`
   that the renderer knows how to handle (currently
   `cowork-custom-connector`, `codex-cli`).
2. If the client is of a new `kind`, teach the renderer about it:
   add a renderer function in `scripts/render-mcp-configs.py` and wire
   it into `RENDERERS`.
3. Run the generator and commit.

### Disable a server for one client temporarily

Remove the client from that server's `enabled_for` list. Regenerate.
The rendered config for that client will simply stop containing the
server, and the next time the operator applies the rendered output the
server will go away on that client side.

### Rotate a bearer token

Tokens are not stored here. Rotate the value in the platform `.env`
(for server side) and in the shell environment of each client machine
(for client side). The rendered files do not need to change unless the
env-variable name changes.

## Guarantees and non-guarantees

- Guaranteed: a clean clone of this repo plus
  `python scripts/render-mcp-configs.py` reproduces the intended client
  configuration layout.
- Guaranteed: no real secrets enter git via this layer.
- Not guaranteed: the renderer does not apply configs to clients for
  you. The operator still pastes `rendered/claude-cowork.md` into the
  Cowork UI and merges `rendered/codex.toml` into `~/.codex/config.toml`.
  This is intentional — fully automatic application would require
  writing into user-home files, which crosses a trust boundary the
  platform does not own.

# `mcp/` — MCP management layer

Single source of truth for how client agents (Claude in Cowork, Codex CLI,
future clients) connect to the MCP servers this platform hosts.

## Contents

- `servers.json` — manifest. **Edit this file, not the rendered outputs.**
- `rendered/` — per-client configs generated from the manifest.
  Checked into git on purpose, with placeholders in place of secrets.

## CI / pre-commit guard

To verify that `rendered/` is in sync with the manifest:

```bash
python3 scripts/render-mcp-configs.py --check
```

Exits non-zero if anything drifts. Run from the repo root.

## Design rationale

The shape here is a **client-side manifest + generator**:

- `servers.json` is the single source of truth.
- `scripts/render-mcp-configs.py` reads it and writes one file per client
  into `rendered/`. Rendered files use `${ENV_VAR}` placeholders for
  tokens, so they are safe to commit.
- Clients still keep their own native config files (the Cowork UI,
  `~/.codex/config.toml`). The manifest does not replace them — it feeds
  them. Final application is manual on purpose: writing into user-home
  files crosses a trust boundary the platform does not own.

Two deliberate constraints:

- **Stdlib only.** JSON over YAML/TOML, no `pip install`, no
  `requirements.txt`. A clean clone plus `python3` is enough to
  regenerate. This is what makes `--check` meaningful in CI.
- **No gateway.** Each client talks directly to each server by URL.
  Adding a gateway would mean another Compose service, another Caddy
  route, another digest pin — not worth it for 1 server / 2 clients.

### When to revisit (gateway triggers)

Move to a proper MCP gateway as a platform service when any of these
becomes true:

- A 3rd server appears and clients want one endpoint instead of N.
- Per-client audit logs need to live in one place.
- Tokens need to rotate server-side without touching every client.
- Specific tools need throttling or sandboxing before reaching n8n.

Until then, the manifest-and-generator design stays.

## Common tasks

### Add a new server

1. Add a block under `servers` in `servers.json`.
2. Set `enabled_for` to the clients that should see it.
3. `python3 scripts/render-mcp-configs.py`.
4. Commit the manifest change and the refreshed `rendered/` together.

If the new server is also a platform-hosted service, add it to
`docker-compose.yml` and document the operational bits in
`../docs/RUNBOOK.md` in the same PR.

### Add a new client

1. Add a block under `clients` in `servers.json`. Pick a `kind` the
   renderer already knows (`cowork-desktop-config`, `codex-cli`).
2. If the client is a new `kind`, teach the renderer: add a function in
   `scripts/render-mcp-configs.py` and wire it into `RENDERERS`.
3. Regenerate and commit.

### Disable a server for one client

Remove the client from that server's `enabled_for`. Regenerate. The
rendered config for that client stops containing the server; the next
time the operator applies the rendered output, the server goes away on
that client side.

### Rotate a bearer token

Tokens never live in this layer. Rotate the value in the platform `.env`
(server side) and in the shell environment of each client machine
(client side). Rendered files do not need to change unless the
env-variable name itself changes.

## Guarantees

- A clean clone plus `python3 scripts/render-mcp-configs.py` reproduces
  the intended client configuration layout.
- No real secrets enter git via this layer.
- The renderer does **not** apply configs to clients automatically —
  the operator pastes `rendered/claude-cowork.md` into the Cowork UI
  and merges `rendered/codex.toml` into `~/.codex/config.toml` by hand.

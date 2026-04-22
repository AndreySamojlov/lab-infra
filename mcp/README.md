# `mcp/` — MCP management layer

Single source of truth for how client agents (Claude in Cowork, Codex CLI,
future clients) connect to the MCP servers this platform hosts.

## Contents

- `servers.yaml` — manifest. **Edit this file, not the rendered outputs.**
- `rendered/` — per-client configs generated from the manifest.
  Checked into git on purpose, with placeholders in place of secrets.

## How to change the landscape

1. Edit `servers.yaml` (add or remove a server, change `enabled_for`, update URL).
2. Run the renderer:
   ```bash
   python scripts/render-mcp-configs.py
   ```
3. Commit `servers.yaml` and the updated `rendered/` together in one commit.

## CI / pre-commit guard

To verify that `rendered/` is in sync with the manifest:

```bash
python scripts/render-mcp-configs.py --check
```

Exits non-zero if anything drifts.

## Why this exists

See `../docs/MCP-MANAGEMENT.md` for the design rationale: when to keep
everything in the manifest, when a gateway starts to earn its keep,
and how the pieces relate to `docker-compose.yml`.

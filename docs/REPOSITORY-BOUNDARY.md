# Repository Boundary

`lab-infra/repo` is the platform repository for deployed shared runtime.

Keep here:

- `docker-compose.yml` for the platform stack
- Caddy, monitoring, backup, and MCP management files
- generic operational scripts and docs

Do not keep here:

- project-specific parsers, analytics services, or APIs
- workflow exports tied to one business domain
- datasets, notebooks, generated reports, or research packs
- ad hoc experiments that are not part of the shared platform

Decision rule:

- If removing the artifact would break every project using the lab, it
  probably belongs here.
- If it exists mainly for one product/domain/workflow, it belongs in a
  separate project repo.

Temporary exception:

- `services/` may be used as a local private overlay for experiments, but
  the canonical committed version must stay empty or generic.

# Mods For Days

NeoForge 1.21.1 modpack managed with [packwiz](https://packwiz.infra.link/).

## How to Add a Mod

**Web UI (recommended):** Browse to <https://mods.theduckylab.org>, log in, and use the interface to search and add mods. Changes are auto-committed back to this repo.

**GitHub web editor:** Open this repo in [github.dev](https://github.dev/Qwertik/ModsForDays) and add `.pw.toml` files to the `mods/` folder.

**CLI:** Clone this repo, then:
```bash
packwiz mr add <mod-slug>   # Modrinth
packwiz cf add <mod-slug>   # CurseForge (needs API key)
packwiz refresh
```
Commit and push — the server auto-restarts on every push to `main`.

## Client Setup

See [CLIENT_SETUP.md](../CLIENT_SETUP.md) in the stack repo, or ask the server admin for the Prism Launcher instructions.

# Zephyr's Wake

NeoForge 1.21.1 modpack managed with [packwiz](https://packwiz.infra.link/) and distributed via GitHub Releases (and optionally CurseForge).

## Distribution

Download the latest modpack from:
- **GitHub Releases**: <https://github.com/Qwertik/ZephyrsWake/releases>
- **CurseForge**: *(available once the project is created)*

Each release includes a **client pack** and a **server pack**.

## How to Add a Mod

**GitHub web editor:** Open this repo in [github.dev](https://github.dev/Qwertik/ZephyrsWake) and add `.pw.toml` files to the `mods/` folder.

**CLI:** Clone this repo, then:
```bash
packwiz curseforge add <mod-slug> -y
packwiz refresh
```
Commit and push to `main`.

## Releasing a New Version

1. Commit your changes to `main`
2. Tag the release: `git tag -a v0.2.0 -m "description of changes"`
3. Push the tag: `git push origin v0.2.0`
4. GitHub Actions builds and publishes client + server packs automatically

## Client Setup

See the [Client Setup Guide](https://github.com/Qwertik/ZephyrsWake/blob/main/CLIENT_SETUP.md) for CurseForge App and Prism Launcher instructions.

## Current Mods

| Mod | Side | Description |
|-----|------|-------------|
| Create | Both | Mechanical building and automation |
| Just Enough Items | Both | Recipe viewer and item lookup |
| Sodium | Client | Performance optimization |

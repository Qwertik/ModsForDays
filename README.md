# Zephyr's Wake

A NeoForge 1.21.1 modpack featuring Create, Ars Nouveau, MineColonies, Apotheosis, and 80+ mods on floating sky islands.

## Download

- **GitHub Releases**: <https://github.com/Qwertik/ZephyrsWake/releases>

Each release includes a **client pack** (import into CurseForge App or Prism Launcher) and a **server pack**.

## Installing

1. Download the latest `-client.zip` from [Releases](https://github.com/Qwertik/ZephyrsWake/releases)
2. Open **CurseForge App** or **Prism Launcher** → Import → select the zip
3. Launch and connect to the server

## Adding Mods

```bash
packwiz curseforge add <mod-slug> -y
packwiz refresh
git add -A && git commit -m "add <mod>" && git push
```

## Releasing

1. Commit changes to `main`
2. `git tag -a v0.6.0 -m "description"` → `git push origin v0.6.0`
3. GitHub Actions builds both zips and creates a release automatically

## Updating the Server

```bash
./scripts/update-server.sh v0.6.0
```

Downloads the server pack from GitHub Releases and restarts the container. The `itzg/minecraft-server` image (AUTO_CURSEFORGE mode) handles mod downloads from CurseForge automatically.

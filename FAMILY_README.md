# Mods For Days — How to Manage the Modpack

This guide is for anyone who wants to add, remove, or configure mods without touching the command line.

## Adding Mods (Web UI)

1. Go to <https://mods.theduckylab.org>
2. Log in (you'll be prompted by Authelia first)
3. Use the admin password the server admin gave you
4. Search for mods and click to add them
5. Changes are automatically saved and pushed to GitHub
6. The Minecraft server restarts automatically within ~2 minutes

## Adding Mods (GitHub Web Editor)

1. Go to <https://github.dev/Qwertik/ModsForDays>
2. Sign in to GitHub
3. Add or edit files in the `mods/` folder
4. Commit your changes to the `main` branch
5. The server picks up changes and restarts automatically

## Editing Configs

Config files live in the `config/` folder. You can edit them the same way — through the GitHub web editor or by cloning the repo locally.

## What Happens When You Push

1. GitHub Actions refreshes the mod index
2. A webhook notifies the server
3. The server broadcasts a 60-second warning in chat
4. A world backup is created
5. The server restarts with the updated mods

Players using Prism Launcher get the new mods next time they launch.

## Need Help?

Ask the server admin or open an issue at <https://github.com/Qwertik/ModsForDays/issues>.

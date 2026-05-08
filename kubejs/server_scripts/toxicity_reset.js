// Crude wave mechanics for Toxicity mod
// Resets the toxic fog cycle every 10 in-game days.
// On the server the cloud rises to Y=88 (mountain bases are safe)
// and starts from Y=-64 (bottom of resource spawning). The cycle
// takes ~8 days; the reset fires on Day 10 to give a buffer.

ServerEvents.tick(event => {
    if (event.server.tickCount % 20 === 0) {
        let overworld = event.server.getLevel('minecraft:overworld');

        if (overworld) {
            let totalTime = overworld.time;
            let currentDay = Math.floor(totalTime / 24000);

            // Trigger on Day 10
            if (currentDay >= 10) {
                // 1. Reset the Mod logic
                event.server.runCommandSilent('toxicity setday 0');

                // 2. Reset the actual Minecraft Clock to Day 0 (Stops the repeating)
                overworld.setTime(0);

                // 3. Notify players
                event.server.tell('The toxic fog has dissipated... for now.');
            }
        }
    }
});

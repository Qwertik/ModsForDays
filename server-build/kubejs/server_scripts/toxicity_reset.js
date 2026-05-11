// Rising Toxicity — toxic fog cycle reset every 10 in-game days.
// MC 1.21.1 / NeoForge / KubeJS 7.x.

const TICKS_PER_DAY  = 24000
const DAYS_PER_CYCLE = 10
const CHECK_INTERVAL = 100
const PDATA_KEY      = 'toxicity_last_reset_tick'

const ANNOUNCE = [
    Text.gray('['),
    Text.darkGreen('Toxicity'),
    Text.gray('] '),
    Text.green('The toxic fog has dissipated... for now.')
]

ServerEvents.tick(event => {
    const server = event.server
    if (server.tickCount % CHECK_INTERVAL !== 0) return

    const overworld = server.overworld()
    if (!overworld) return

    const now  = Number(overworld.time)    // gameTime; monotonic, persists across restarts
    let   last = Number(server.persistentData.getLong(PDATA_KEY))

    // First run on an existing world: anchor baseline so we don't fire instantly.
    if (last === 0 && now > 0) {
        server.persistentData.putLong(PDATA_KEY, now)
        last = now
    }

    if (now - last < DAYS_PER_CYCLE * TICKS_PER_DAY) return

    // Edge-triggered reset — bump baseline FIRST.
    server.persistentData.putLong(PDATA_KEY, now)
    server.runCommandSilent('toxicity reset')
    server.tell(ANNOUNCE)
})

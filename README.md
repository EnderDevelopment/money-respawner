# Roblox Money Respawner Script

Money Respawner is a Roblox money pickup spawner and admin money management script. It creates collectible cash pickups at configured spawn points, rewards players through server-side leaderstats, respawns pickups after a cooldown, and includes a secure admin command and menu for granting money.

## Install

1. In Roblox Studio, create a `Script` inside `ServerScriptService` and paste in `MoneySpawner.server.lua`.
2. Create a `Script` inside `ServerScriptService` and paste in `AdminMoneyCommand.server.lua`.
3. Open `AdminMoneyCommand.server.lua` and add the Roblox UserIds of trusted administrators to the `ADMIN_USER_IDS` table.
4. Create a `LocalScript` inside `StarterPlayer > StarterPlayerScripts` and paste in `AdminMoneyMenu.client.lua`.
5. In `Workspace`, create a folder named `MoneySpawnPoints`.
6. Add one or more anchored `Part` objects inside `Workspace.MoneySpawnPoints`. Each part defines where a money pickup appears.
7. Start a play test and verify that players receive a `Cash` value in their `leaderstats`.

If `MoneySpawnPoints` does not exist, `MoneySpawner.server.lua` creates it automatically. You can add spawn point parts after the server starts.

## Use

Players collect money by touching the glowing pickup above a configured spawn point. Each pickup awards the amount set by `MONEY_VALUE` and returns after the number of seconds set by `RESPAWN_SECONDS`.

To customize the pickup, edit the configuration values at the top of `MoneySpawner.server.lua`, including the reward amount, respawn time, size, color, collection sound, and particle effects.

Administrators can use the in-game menu by selecting the `$` button, entering a whole amount, optionally entering a player name, and selecting `Grant money`.

Administrators can also use the chat commands:

```text
/givemoney <amount>
/givemoney <amount> <player>
```

The server checks the administrator UserId, validates the amount, limits each grant to `MAX_GRANT`, and verifies the target player before changing their cash. The script stores cash in server-created `leaderstats` during the current server session and does not save balances between sessions.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/c8410743-ba8a-404a-af85-e9e4dbb1fa35?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=c8410743-ba8a-404a-af85-e9e4dbb1fa35

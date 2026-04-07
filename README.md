# Bounty Hunt Script

A comprehensive Roblox bounty hunting script with UI, automatic enemy tracking, and combat mechanics.

## Features

✅ **UI System**
- Bounty earned display with real-time updates
- Skip Player button for quick target switching
- Target status information
- Safe zone detection

✅ **Enemy Tracking**
- Automatic nearest player detection
- Character attachment and following
- Real-time distance monitoring
- Health tracking display

✅ **Combat System**
- Melee weapon attacks
- Fruit sword attacks
- Gun-based attacks
- Weapon switching
- Automatic target elimination

✅ **Safe Zone Protection**
- Safe zone detection
- Automatic server switching when in safe zone
- Safe zone position customization

✅ **Bounty System**
- Bounty rewards for kills
- Real-time bounty accumulation
- Kill notifications

## Installation

1. **Copy the script** to your Roblox game scripts folder or local project
2. **Create a LocalScript** in StarterPlayer > StarterPlayerScripts
3. **Copy the contents** of `BountyHuntScript.lua` into the LocalScript
4. **Customize** the `Config.lua` file to match your game settings

## Usage

1. **Join the game** - The script will automatically load when the player joins
2. **UI appears** - A bounty display frame will appear in the top-left corner
3. **Auto-hunting** - The script automatically finds and hunts the nearest player
4. **Skip target** - Click "Skip Player" to find a new target
5. **Safe zone** - If in a safe zone, clicking skip will teleport to another server
6. **Combat** - The character automatically attacks enemies with available weapons
7. **Bounty tracking** - Watch your bounty counter increase as you eliminate targets

## Configuration

Edit `Config.lua` to customize:

```lua
-- KillReward: Amount of bounty earned per kill
-- SearchRadius: How far to look for targets
-- Weapons: Names of weapons in your game
-- SafeZones: Locations where hunting is disabled
-- UI settings: Colors, sizes, and positions
```

## Script Files

- **BountyHuntScript.lua** - Main script with all functionality
- **Config.lua** - Configuration settings for customization
- **README.md** - This documentation file

## Weapon Setup

The script supports three weapon types:

1. **Melee** - Close-range physical attacks
2. **Sword/Fruit Sword** - Medium-range slashing weapon
3. **Gun** - Ranged weapon attacks

Make sure these weapons exist in your game and are in the player's backpack or character.

## Safe Zone Configuration

Add your game's safe zones in `Config.lua`:

```lua
SafeZones = {
    {Position = Vector3.new(x, y, z), Radius = 50},
    -- Add more as needed
}
```

## Troubleshooting

**Script not running?**
- Make sure it's placed in StarterPlayer > StarterPlayerScripts
- Check the Output console for errors
- Verify the game has the required services

**UI not showing?**
- Check PlayerGui permissions
- Verify the script can access the player

**Weapons not firing?**
- Update weapon names in Config.lua to match your game
- Check weapon RemoteEvents
- Ensure weapons are in player backpack

**Not finding targets?**
- Increase SearchRadius in Config.lua
- Check if other players are in the server
- Verify no firewall is blocking player detection

## Support

If you're having issues with the script, contact: **mr_alive.bg** on Discord

## Features Coming Soon

- Custom bounty rewards per player
- Bounty history/leaderboard
- Advanced combat AI
- Server performance monitoring
- Customizable UI themes
- Pvp mode toggle 

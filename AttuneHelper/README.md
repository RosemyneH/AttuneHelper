# AttuneHelper

> **ʕ •ᴥ•ʔ✿ Automatically Swaps Gear To Streamline Attunement ✿ ʕ •ᴥ•ʔ**

A powerful WoW addon designed to streamline the attunement process by automatically managing your gear swaps. Perfect for players who want to focus on gameplay rather than inventory management during attunement quests.

## ✨ Features

### 🎯 Core Functionality

- **Automatic Gear Swapping** - Seamlessly equips attunement gear when needed
- **Smart Inventory Management** - Optimized bag caching for better performance
- **Dual UI Modes** - Choose between compact mini-mode or full-featured interface
- **Combat-Aware** - Auto-equips attunable items after combat ends

### ⚔️ Weapon Control System

- **Granular Weapon Type Controls** - Fine-tune which weapon types can be equipped
- **MainHand & OffHand Management** - Separate controls for 1H/2H weapons, shields, and holdables
- **Flexible Slot Assignment** - Customize which items go where

### 🎨 Customization Options

- **Theme System** - Multiple visual themes to match your UI preferences
- **Slot Blacklisting** - Prevent specific slots from being auto-equipped
- **Item Ignore List** - Exclude specific items from automatic equipping
- **Performance Monitoring** - Built-in memory usage tracking and cleanup

### 🔧 Advanced Features

- **Vendor Integration** - Automatically sell attuned items when visiting vendors
- **Equipment Sets** - Create and manage custom equipment configurations
- **Performance Optimization** - Intelligent caching reduces memory usage
- **Debug Tools** - Comprehensive logging and troubleshooting options

## 🚀 Installation

1. **Download** the latest release from the repository
2. **Extract** the `AttuneHelper` folder to your `World of Warcraft/Interface/AddOns/` directory
3. **Restart** World of Warcraft or reload your UI (`/reload`)
4. **Configure** your preferences using `/ah help` to see available options

### 📋 Requirements

- **WoW Version:** 3.3.5a (WotLK)
- **Optional:** [SynastriaCoreLib](https://github.com/imevul/SynastriaCoreLib/releases) for enhanced functionality

## 📖 Usage Guide

### Getting Started

1. Type `/ah` to open the main interface
2. Use `/ah help` to see all available commands
3. Configure your weapon preferences with `/ah weapons`
4. Set up your equipment sets with `/ahset`

### Quick Commands

```bash
/ah show          # Show the main interface
/ah toggle        # Toggle auto-equip after combat
/ah weapons       # View weapon type settings
/ah memory        # Check performance stats
```

## 🎮 Slash Commands

### 🎯 Main Commands


| Command     | Description                           |
| ----------- | ------------------------------------- |
| `/ah`       | Main command with various subcommands |
| `/ah help`  | Show all available commands           |
| `/ah show`  | Show AttuneHelper frame               |
| `/ah hide`  | Hide AttuneHelper frame               |
| `/ah reset` | Reset frame positions to center       |


### ⚙️ Auto-Equip Controls


| Command            | Description                            |
| ------------------ | -------------------------------------- |
| `/ah toggle`       | Toggle auto-equip after combat         |
| `/ahtoggle`        | Alias for toggle auto-equip            |
| `/ah equip <slot>` | Manually equip items for specific slot |


### 🖥️ Display Mode


| Command          | Description                           |
| ---------------- | ------------------------------------- |
| `/ah togglemini` | Toggle between mini and full UI modes |


### ⚔️ Weapon Type Controls


| Command        | Description                       |
| -------------- | --------------------------------- |
| `/ah weapons`  | Show current weapon type settings |
| `/ah mh1h`     | Toggle MainHand 1H weapons        |
| `/ah mh2h`     | Toggle MainHand 2H weapons        |
| `/ah oh1h`     | Toggle OffHand 1H weapons         |
| `/ah oh2h`     | Toggle OffHand 2H weapons         |
| `/ah ohshield` | Toggle OffHand shields            |
| `/ah ohhold`   | Toggle OffHand holdables          |


### 📦 Item Management


| Command                    | Description                             |
| -------------------------- | --------------------------------------- |
| `/ahset <itemlink> [slot]` | Add item to equipment set               |
| `/ahset remove <itemlink>` | Remove item from equipment set          |
| `/ahsetlist`               | List all items in equipment set         |
| `/ahsetall`                | Add all currently equipped items to set |
| `/ahignore <itemlink>`     | Toggle item ignore status               |
| `/ahignorelist`            | List all ignored items                  |


### 🚫 Slot Blacklisting


| Command                | Description                     |
| ---------------------- | ------------------------------- |
| `/ah blacklist <slot>` | Toggle slot blacklist           |
| `/ahbl <slot>`         | Short version of slot blacklist |
| `/ahbll`               | List all blacklisted slots      |


### 🔍 Performance & Debug


| Command       | Description                  |
| ------------- | ---------------------------- |
| `/ah memory`  | Show memory usage statistics |
| `/ah cleanup` | Force memory cleanup         |


### 🎨 UI Controls


| Command      | Description                         |
| ------------ | ----------------------------------- |
| `/ah hidede` | Toggle disenchant button visibility |


### 🔄 Legacy Commands


| Command     | Description                         |
| ----------- | ----------------------------------- |
| `/ah2h`     | Toggle 2H weapon equipping (legacy) |
| `/AHIgnore` | Legacy ignore command               |
| `/AHSet`    | Legacy set command                  |


## 🎯 Slot Keywords

When using slot-specific commands, you can use these intuitive keywords:

### Weapon Slots

- `mh`, `mainhand` → **MainHandSlot**
- `oh`, `offhand` → **SecondaryHandSlot**
- `ranged` → **RangedSlot**

### Armor Slots

- `head` → **HeadSlot**
- `neck` → **NeckSlot**
- `shoulder` → **ShoulderSlot**
- `back` → **BackSlot**
- `chest` → **ChestSlot**
- `wrist` → **WristSlot**
- `hands` → **HandsSlot**
- `waist` → **WaistSlot**
- `legs`, `pants` → **LegsSlot**
- `feet` → **FeetSlot**

### Accessory Slots

- `finger1`, `ring1` → **Finger0Slot**
- `finger2`, `ring2` → **Finger1Slot**
- `trinket1` → **Trinket0Slot**
- `trinket2` → **Trinket1Slot**

## 💡 Tips & Tricks

### 🎯 Optimizing Performance

- Use `/ah memory` regularly to monitor memory usage
- Run `/ah cleanup` if you notice performance issues
- Consider using mini-mode for better performance

### ⚔️ Weapon Management

- Use `/ah weapons` to review your current settings
- Disable weapon types you don't want auto-equipped
- Combine with slot blacklisting for precise control

### 📦 Equipment Sets

- Use `/ahsetall` to quickly capture your current gear
- Review your sets with `/ahsetlist`
- Remove unwanted items with `/ahset remove`

### 🚫 Advanced Filtering

- Blacklist slots that should never be auto-equipped
- Use the ignore list for specific items
- Combine multiple filters for precise control

## 🔧 Configuration

### Interface Options

Access the addon's configuration through:

1. **Interface Options** → **AddOns** → **AttuneHelper**
2. **General Settings** - Core functionality options
3. **Weapon Controls** - Fine-tune weapon type preferences
4. **Theme Options** - Customize visual appearance

### Saved Variables

The addon automatically saves your preferences:

- **Global Settings** - Shared across all characters
- **Character Settings** - Specific to each character
- **Equipment Sets** - Custom gear configurations
- **Ignore Lists** - Items to exclude from auto-equipping

## 🐛 Troubleshooting

### Common Issues

- **Addon not appearing in Interface Options** → Reload UI with `/reload`
- **Commands not working** → Check if addon is enabled
- **Performance issues** → Use `/ah cleanup` and `/ah memory`
- **Weapons not equipping** → Check weapon type settings with `/ah weapons`

### Getting Help

1. Use `/ah help` for command reference
2. Check weapon settings with `/ah weapons`
3. Monitor performance with `/ah memory`
4. Review your configuration in Interface Options

## 📝 Changelog

### Version 1.4.0-Dev

- ✨ Added comprehensive weapon type controls
- 🎨 Enhanced theme customization options
- 🔧 Improved performance with optimized caching
- 📚 Updated documentation and command reference
- 🐛 Fixed various UI and functionality issues

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests to help improve AttuneHelper.

## 📄 License

This project is open source and available under the appropriate license terms.

---

**ʕ •ᴥ•ʔ✿ Happy Attuning! ✿ ʕ •ᴥ•ʔ**
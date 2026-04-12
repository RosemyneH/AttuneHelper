![ah-banner](https://github.com/user-attachments/assets/d9f61f77-13b2-488b-b4f6-a243ae400666)
Automaticly handles new attunes and your gear sets for quick and seamless gaming!

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

### 🔧 Advanced Features
- **Vendor Integration** - Automatically sell attuned items when visiting vendors
- **Equipment Sets** - Create and manage custom equipment configurations

## 🚀 Installation
1. **Download** the latest release from the repository
2. **Extract** the `AttuneHelper` folder to your `Synastria/Interface/AddOns/` directory
3. **Restart** World of Warcraft
4. **Customize** to your heart contents
<img width="660" height="302" alt="image" src="https://github.com/user-attachments/assets/b84507b4-44b3-4bf6-ab07-e7c2a7c5d87f" />

### 📋 Requirements
- **WoW Version:** 3.3.5a (WotLK)
- Synastria.org

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
```

## 🎮 Slash Commands
### 🎯 Main Commands
| Command | Description |
|---------|-------------|
| `/AHIgnore itemLink` | Causes AttuneHelper to not sell the arg1 item |
| `/AHSet` | Sets ur current AHSet Preset to be replaced for x slot |
| `/ah` | Main command with various subcommands |
| `/ah help` | Show all available commands |
| `/ah show` | Show AttuneHelper frame |
| `/ah hide` | Hide AttuneHelper frame |
| `/ah reset` | Reset frame positions to center |

### ⚙️ Auto-Equip Controls
| Command | Description |
|---------|-------------|
| `/ah toggle` | Toggle auto-equip after combat |
| `/ahtoggle` | Alias for toggle auto-equip |

### 🖥️ Display Mode
| Command | Description |
|---------|-------------|
| `/ah togglemini` | Toggle between mini and full UI modes |

### ⚔️ Weapon Type Controls
| Command | Description |
|---------|-------------|
| `/ah weapons` | Show current weapon type settings |
| `/ah mh1h` | Toggle MainHand 1H weapons |
| `/ah mh2h` | Toggle MainHand 2H weapons |
| `/ah oh1h` | Toggle OffHand 1H weapons |
| `/ah oh2h` | Toggle OffHand 2H weapons |
| `/ah ohshield` | Toggle OffHand shields |
| `/ah ohhold` | Toggle OffHand holdables |

### 📦 Item Management
| Command | Description |
|---------|-------------|
| `/ahset <itemlink> [slot]` | Add item to equipment set |
| `/ahset remove <itemlink>` | Remove item from equipment set |
| `/ahsetlist` | List all items in equipment set |
| `/ahsetall` | Add all currently equipped items to set |
| `/ahignore <itemlink>` | Toggle item ignore status |
| `/ahignorelist` | List all ignored items |

### 🚫 Slot Blacklisting
| Command | Description |
|---------|-------------|
| `/ah blacklist <slot>` | Toggle slot blacklist |
| `/ahbl <slot>` | Short version of slot blacklist |
| `/ahbll` | List all blacklisted slots |

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


## 🐛 Troubleshooting

### Common Issues
- **Addon not appearing in Interface Options** → Reload UI with `/reload`
- **Commands not working** → Check if addon is enabled
- **Weapons not equipping** → Check weapon type settings with `/ah weapons`

### Getting Help
1. Use `/ah help` for command reference
2. Check weapon settings with `/ah weapons`
3. Monitor performance with `/ah memory`
4. Review your configuration in Interface Options


## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests to help improve AttuneHelper.

## 📄 License

This project is open source and available under the appropriate license terms.

-- ʕ •ᴥ•ʔ✿ Core constants ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

-- Mythic item id threshold (same value used in original file)
AH.MYTHIC_MIN_ITEMID = 52203

-- System throttle
AH.CHAT_MSG_SYSTEM_THROTTLE = 0.2

-- Forge map mirrors server-side Enum
AH.FORGE_LEVEL_MAP = {
    BASE         = 0,
    TITANFORGED  = 1,
    WARFORGED    = 2,
    LIGHTFORGED  = 3,
}

-- Default allowed forge types saved in DB
AH.defaultForgeKeysAndValues = {
    BASE        = true,
    TITANFORGED = true,
    WARFORGED   = true,
    LIGHTFORGED = true,
}

-- UI chooses from this list when building checkboxes
AH.forgeTypeOptionsList = {
    { label = "Base Items",   dbKey = "BASE"        },
    { label = "Titanforged",   dbKey = "TITANFORGED"  },
    { label = "Warforged",     dbKey = "WARFORGED"    },
    { label = "Lightforged",   dbKey = "LIGHTFORGED"  },
}

-- Slot number mapping for equipment functions
AH.slotNumberMapping = {
    Finger0Slot=11, Finger1Slot=12, Trinket0Slot=13, Trinket1Slot=14, 
    MainHandSlot=16, SecondaryHandSlot=17
}

-- All inventory slots list
AH.allInventorySlots = {
    "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot",
    "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
    "Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot"
}

-- Slot aliases for slash commands
AH.slotAliases = {
    oh="SecondaryHandSlot", offhand="SecondaryHandSlot", head="HeadSlot", neck="NeckSlot", 
    shoulder="ShoulderSlot", back="BackSlot", chest="ChestSlot", wrist="WristSlot", 
    hands="HandsSlot", waist="WaistSlot", legs="LegsSlot", pants="LegsSlot", feet="FeetSlot", 
    finger1="Finger0Slot", finger2="Finger1Slot", ring1="Finger0Slot", ring2="Finger1Slot", 
    trinket1="Trinket0Slot", trinket2="Trinket1Slot", mh="MainHandSlot", mainhand="MainHandSlot", 
    ranged="RangedSlot"
}

-- ʕ •ᴥ•ʔ✿ Slot name to slot mapping for /ah blacklist command ✿ ʕ •ᴥ•ʔ
AH.slotNameToSlot = {
    head="HeadSlot", neck="NeckSlot", shoulder="ShoulderSlot", back="BackSlot", 
    chest="ChestSlot", wrist="WristSlot", hands="HandsSlot", waist="WaistSlot", 
    legs="LegsSlot", feet="FeetSlot", finger1="Finger0Slot", finger2="Finger1Slot", 
    ring1="Finger0Slot", ring2="Finger1Slot", trinket1="Trinket0Slot", trinket2="Trinket1Slot", 
    mh="MainHandSlot", mainhand="MainHandSlot", oh="SecondaryHandSlot", offhand="SecondaryHandSlot", 
    ranged="RangedSlot"
}

-- Unified slot mapping from INVTYPE_* to UI slot name(s)
AH.itemTypeToUnifiedSlot = {
  INVTYPE_HEAD="HeadSlot",INVTYPE_NECK="NeckSlot",INVTYPE_SHOULDER="ShoulderSlot",INVTYPE_CLOAK="BackSlot",
  INVTYPE_CHEST="ChestSlot",INVTYPE_ROBE="ChestSlot",INVTYPE_WAIST="WaistSlot",INVTYPE_LEGS="LegsSlot",
  INVTYPE_FEET="FeetSlot",INVTYPE_WRIST="WristSlot",INVTYPE_HAND="HandsSlot",
  INVTYPE_FINGER= {"Finger0Slot", "Finger1Slot"},
  INVTYPE_TRINKET= {"Trinket0Slot", "Trinket1Slot"},
  INVTYPE_WEAPON= {"MainHandSlot", "SecondaryHandSlot"},
  INVTYPE_2HWEAPON="MainHandSlot",
  INVTYPE_WEAPONMAINHAND="MainHandSlot",
  INVTYPE_WEAPONOFFHAND="SecondaryHandSlot",
  INVTYPE_HOLDABLE="SecondaryHandSlot",
  INVTYPE_RANGED="RangedSlot",INVTYPE_THROWN="RangedSlot",
  INVTYPE_RANGEDRIGHT="RangedSlot",INVTYPE_RELIC="RangedSlot",
  INVTYPE_WAND="RangedSlot",
  INVTYPE_SHIELD="SecondaryHandSlot"
}


--Popups
function AH.LoadPopUps()
	StaticPopupDialogs["ATTUNEHELPER_CONFIRM_UPDATE_AHSET"] = {
		text = AH.t("Are you sure you want to update AHSet to match your currently equipped items?"),
		button1 = AH.t("Yes"),
		button2 = AH.t("Cancel"),
		OnAccept = function()
			AH.SetAHSetToEquipped()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3
	}
end
AH.LoadPopUps()

-- Export as globals for backward compatibility while we refactor
_G.MYTHIC_MIN_ITEMID       = AH.MYTHIC_MIN_ITEMID
_G.FORGE_LEVEL_MAP         = AH.FORGE_LEVEL_MAP
_G.defaultForgeKeysAndValues = AH.defaultForgeKeysAndValues
_G.forgeTypeOptionsList    = AH.forgeTypeOptionsList
_G.itemTypeToUnifiedSlot    = AH.itemTypeToUnifiedSlot
_G.slotNumberMapping       = AH.slotNumberMapping
_G.allInventorySlots       = AH.allInventorySlots
_G.slotAliases             = AH.slotAliases
_G.slotNameToSlot          = AH.slotNameToSlot 
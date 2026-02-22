-- ʕ •ᴥ•ʔ✿ AttuneHelper Global Initialization ✿ ʕ •ᴥ•ʔ

-- Create the main addon table
AttuneHelper = {}
local AH = AttuneHelper

-- Create alias for easier access
_G.AH = AH

-- Initialize core structures
AH.flags = {
    GENERAL_DEBUG_MODE = false,
    AHSET_DEBUG_MODE = false,
    VENDOR_PREVIEW_DEBUG_MODE = false
}

-- Initialize UI structure
AH.UI = {
    mainFrame = nil,
    miniFrame = nil,
    buttons = {},
    miniButtons = {},
    itemCountText = nil
}

-- Initialize cache tables
AH.bagSlotCache = {}
AH.equipSlotCache = {}

-- Initialize option UI caches
AH.blacklist_checkboxes = {}
AH.general_option_checkboxes = {}
AH.theme_option_controls = {}
AH.forge_type_checkboxes = {}

-- Initialize session state
AH.isSCKLoaded = false
AH.lastAttemptedSlotForEquip = nil
AH.lastAttemptedItemTypeForEquip = nil
AH.currentAttunableItemCount = 0

-- Store in-case other modules need
AH._addonName = addonName
AH._addonTable = addonTable

-- Flags sub-table (guaranteed to exist before debug.lua runs) so users can type AH.flags.X = true in chat
AH.flags = AH.flags or {}
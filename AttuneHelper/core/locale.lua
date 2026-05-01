-- ʕ •ᴥ•ʔ✿ Localization module ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper or {}
_G.AttuneHelper = AH

-- Ensure saved variable table exists
AttuneHelperDB = AttuneHelperDB or {}

------------------------------------------------------------------------
-- Determine active locale
------------------------------------------------------------------------
local savedLocale = AttuneHelperDB["Language"] -- "default" | nil | texture code
local systemLocale = GetLocale()
local activeLocale = (savedLocale and savedLocale ~= "default") and savedLocale or systemLocale

-- Normalise variants that share same translation table
if activeLocale == "enGB" then activeLocale = "enUS" end -- fall back to US English

------------------------------------------------------------------------
-- English base strings (always loaded). Other locales: Locales/*.lua.
------------------------------------------------------------------------
local enUS = {
    ["Equip Attunables"]                                                              = "Equip Attunables",
    ["Prepare Disenchant"]                                                            = "Prepare Disenchant",
    ["Vendor Attuned"]                                                                = "Vendor Attuned",
    ["Vendor Attuned Items"]                                                          = "Vendor Attuned Items",
    ["Add To Vendor"]                                                                 = "Add To Vendor",
    ["System Default"]                                                                = "System Default",
    ["English (US)"]                                                                  = "English (US)",
    ["Español"]                                                                       = "Español",
    ["Deutsch"]                                                                       = "Deutsch",
    ["Select Language:"]                                                              = "Select Language:",
    ["Moves fully attuned mythic items to bag %d."]                                   = "Moves fully attuned mythic items to bag %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]              =
    "Clears target bag first, then fills with disenchant-ready items.",
    ["Attunable Items: %d"]                                                           = "Attunable Items: %d",
    ["Qualifying Attunables (%d):"]                                                   = "Qualifying Attunables (%d):",
    ["No qualifying attunables in bags."]                                             = "No qualifying attunables in bags.",
    ["Items to be sold (%d):"]                                                        = "Items to be sold (%d):",
    ["Always-vendor entries: %d"]                                                     = "Always-vendor entries: %d",
    ["No items will be sold based on current settings."]                              = "No items will be sold based on current settings.",
    ["Open merchant window to sell these items."]                                     = "Open merchant window to sell these items.",
    ["Drag an item here or pick it up and click to toggle always-vendor."]            = "Drag an item here or pick it up and click to toggle always-vendor.",
    ["Items added here are always included in AH vendor previews and selling."]        = "Items added here are always included in AH vendor previews and selling.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."]     =
    "Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists.",
    ["Update AHSet"]                                                                  = "Update AHSet",
    ["Sets AHSet to be equal to your currently equiped items."]                       =
    "Sets AHSet to be equal to your currently equiped items.",
    ["This will delete your current AHSet."]                                          = "This will delete your current AHSet.",
    ["Are you sure you want to update AHSet to match your currently equipped items?"] =
    "Are you sure you want to update AHSet to match your currently equipped items?",
    ["AHSet 1H pre-swap for off-hand attune"] =
    "AHSet: 1H pre-swap for off-hand attune (warrior multiclass)",
    ["AHSet 1h2h swap"] = "Warrior multiclass · 1H / 2H swap",
    ["AHSet 1h2h swap tip line 1"] =
    "For Chromie-style multiclass, your UI class is often not Warrior even when you play like one. With this option on and the per-preset swap flag set, Equip All may replace a 2H main hand with your AHSet one-hander so an off-hand attunable can equip.",
    ["AHSet 1h2h swap tip line 2"] = "You need a 2H equipped in main hand that is not actively attuning, an off-hand attunable in bags, and a 1H in bags mapped to Main Hand or to the 1H Weapon Swaps row in List Management.",
    ["AHSet 1h2h swap tip line 3"] = "Titan's Grip is played with a two-hander in main hand and either another TG two-hander or a one-hand axe in off-hand (for example a flurry-style build)—that is your real weapon pair, not the 1H Weapon Swaps / prep rows. Equip All normally skips this 2H→one-hander main swap while TG is detected so bag work can use your off-hand. Exception: main-hand-only one-handers cannot equip off-hand, so that swap may still run. The swap flag turns on when main hand maps to a two-hander and you map a one-hander to Main Hand or the 1H Weapon Swaps row; /ahset 1hspecial2h can still force it on before those exist.",
    ["AHSet 1h2h swap tip line 4"] = "Off-hand detection is strict when this preset maps anything to Off Hand or the prep off-hand square (ambiguous one-handers need /ahset … oh). Otherwise it is loose.",
    ["AHSet 1h2h swap tip line 5"] = "/ahset 1hspecial2h remove clears the optional force flag; Set AHSet wipes the whole preset.",
    ["Off-hand swap trigger"] = "Off-hand swap trigger",
    ["AHSet OH trigger strict"] = "AHSet / native off-hand only (strict)",
    ["AHSet OH trigger loose"] = "Any off-hand-capable 1H (loose)",
    ["AHSet OH trigger strict tip"] =
    "Strict: shields, holdables, and off-hand weapons always count. Ambiguous one-handers count only if you mapped them with /ahset <link> oh (AHSet off-hand).",
    ["AHSet OH trigger loose tip"] =
    "Loose: any attunable one-hander in bags counts as a reason to swap, even without an AHSet off-hand mapping (may swap more often).",
    ["AHSet 1h2h preset button title"] = "Warrior multiclass 1H/2H swap (preset)",
    ["AHSet 1h2h preset tip line 1"] =
    "Toggles the per-preset swap flag (same as /ahset 1hspecial2h). This is not a generic sentinel: it exists because multiclass warriors often run a 2H main profile while off-hand items still need attuning.",
    ["AHSet 1h2h preset tip line 2"] = "Equip All only performs the swap when this flag is On, the checkbox above is enabled, and the other conditions in that tooltip are met.",
    ["AHSet 1h2h preset tip line 3"] = "Click again to turn Off and remove the flag from this preset only.",
    ["MC 1h2h: On"] = "MC 1h2h: On",
    ["MC 1h2h: Off"] = "MC 1h2h: Off",
    ["AHSet 1h2h list title"] = "Warrior MC · 1H/2H (this preset)",
    ["AHSet prep paper strip label"] = "1H Weapon Swaps",
    ["AHSet prep paper strip drag hint"] = "Prep Weapons",
    ["AHSet prep MH slot label"] = "1H · main-hand row",
    ["AHSet prep OH slot label"] = "Off-hand row",
    ["AHSet prep slot empty slash hint"] = "Set AHSet, /ahset prepmh, or /ahset prepoh also works.",
    ["AHSet 2h swap strip explanation"] =
    "Nothing here is a separate toggle: Equip All uses your weapon mappings on this preset. Map a one-hander to Main Hand or the squares below when the preset main hand is a two-hander.",
    ["AHSet auto status swap on"] = "1H prep swap path: active for this preset.",
    ["AHSet auto status swap off"] = "1H prep swap path: inactive (map a one-hander to Main Hand or the squares below, or /ahset 1hspecial2h to force).",
    ["AHSet auto status oh fmt"] = "Off-hand attunable detection: %s.",
    ["AHSet OH trigger strict short"] = "strict",
    ["AHSet OH trigger loose short"] = "loose",
    ["Weapon panel multiclass header"] = "Warrior multiclass · AHSet swap",
    ["Weapon panel TG detection note"] = "Titan's Grip is detected from your talents (including Chromie-style multiclass talent tabs). Dual 2H in bags/equip logic applies only to two-handed axes, maces, and swords—not staves or polearms.",
    ["AHSet 2h swap section title"] = "1H Weapon Swaps",
    ["AHSet 1h2h preset row label"] = "1H/2H swap on this preset",
    ["AHSet swap flag on"] = "On",
    ["AHSet swap flag off"] = "Off",
    ["Yes"]                                                                           = "Yes",
    ["No"]                                                                            = "No",
    ["Cancel"]                                                                        = "Cancel",
    ["Toggle Auto-Equip"]                                                             = "Toggle Auto-Equip",
    ["Disable Auto-Equip"]                                                            = "Disable Auto-Equip",
    ["Enable Auto-Equip"]                                                             = "Enable Auto-Equip",
    ["Currently enabled."]                                                            = "Currently enabled.",
    ["Currently disabled."]                                                           = "Currently disabled.",
    ["Open Settings"]                                                                 = "Open Settings",
    ["Opens the General Logic Options settings page."]                                = "Opens the General Logic Options settings page.",
    ["Hold Shift for additional options"]                                             = "Hold Shift for additional options",
    ["Background Color"]                                                              = "Background Color",
    ["Equip Attunable Affixes up to:"]                                                = "Equip Attunable Affixes up to:",
    ["Affix-Only Minimum Forge"]                                                      = "Affix-Only Minimum Forge",
    ["Works only when 'Equip New Affixes Only' is enabled."]                         =
    "Works only when 'Equip New Affixes Only' is enabled.",
    ["'All Items' disables the forge threshold behavior."]                            =
    "'All Items' disables the forge threshold behavior.",
    ["When enabled, this setting favors affixes you have not attuned yet."]          =
    "When enabled, this setting favors affixes you have not attuned yet.",
    ["Use the dropdown to choose where lenient behavior ends."]                       =
    "Use the dropdown to choose where lenient behavior ends.",
    ["Items below the selected forge tier can equip even if already seen."]           =
    "Items below the selected forge tier can equip even if already seen.",
    ["At the selected tier and above, the addon prefers truly new affixes."]         =
    "At the selected tier and above, the addon prefers truly new affixes.",
    ["If a variant is already attuned, only higher forge tiers can still auto-equip."] =
    "If a variant is already attuned, only higher forge tiers can still auto-equip.",
    ["Example: with 'Warforged', duplicate Warforged is blocked, but Lightforged can still equip."] =
    "Example: with 'Warforged', duplicate Warforged is blocked, but Lightforged can still equip.",
    ["Below this tier: lenient equip behavior."]                                      = "Below this tier: lenient equip behavior.",
    ["At this tier and above: strict new-affix behavior."]                            = "At this tier and above: strict new-affix behavior.",
    ["When a variant already exists, only higher forge tiers can override."]          =
    "When a variant already exists, only higher forge tiers can override.",
    ["'All Items' applies strict behavior to every forge tier."]                      =
    "'All Items' applies strict behavior to every forge tier.",
    ["Use the dropdown to set the highest forge tier that ignores attunement history (inclusive)."] =
    "Use the dropdown to set the highest forge tier that ignores attunement history (inclusive).",
    ["Example: 'Warforged' allows Base/Titanforged/Warforged to equip even if already seen; Lightforged still requires a new affix or no prior variant."] =
    "Example: 'Warforged' allows Base/Titanforged/Warforged to equip even if already seen; Lightforged still requires a new affix or no prior variant.",
    ["'All Items' removes this forge-tier limit while keeping the strict new-affix preference."] =
    "'All Items' removes this forge-tier limit while keeping the strict new-affix preference.",
    ["Select the highest forge tier that can equip regardless of prior attunement history."] =
    "Select the highest forge tier that can equip regardless of prior attunement history.",
    ["This applies only while the checkbox is enabled."]                              =
    "This applies only while the checkbox is enabled.",
    ["Tiers above your selected value still require a truly new affix (or no variant attuned yet)."] =
    "Tiers above your selected value still require a truly new affix (or no variant attuned yet).",
    ["'All Items' removes the forge-tier cap."]                                       = "'All Items' removes the forge-tier cap.",
    ["- Selected tier and up: unattuned variant only."]                               = "- Selected tier and up: unattuned variant only.",
    ["- Does not check extra affix unlocks."]                                         = "- Does not check extra affix unlocks.",
    ["- Base and TF - Equips all if Affix is attunable."]                             = "- Base and TF - Equips all if Affix is attunable.",
    ["Hide Center Button in Normal Mode"]                                             = "Hide Center Button in Normal Mode",
    ["Hides the center action button in normal view."]                                = "Hides the center action button in normal view.",
    ["Hold Ctrl to show Open Settings and Update AHSet."]                             =
    "Hold Ctrl to show Open Settings and Update AHSet."
}


------------------------------------------------------------------------
-- Non-English locales: loaded on demand via loadfile (see Locales/*.lua)
------------------------------------------------------------------------
AH._localeOverlaysByFile = AH._localeOverlaysByFile or {}

local function resolveLocaleFileCode(localeCode)
    if localeCode == "ptPT" then return "ptBR" end
    if localeCode == "esMX" then return "esES" end
    if localeCode == "enGB" or localeCode == "enUS" then return nil end
    return localeCode
end

local function loadLocaleOverlayForCode(localeCode)
    local fileCode = resolveLocaleFileCode(localeCode)
    if not fileCode then return nil end
    local cached = AH._localeOverlaysByFile[fileCode]
    if cached == false then return nil end
    if type(cached) == "table" then return cached end
    local paths = {
        "Interface\\AddOns\\AttuneHelper\\Locales\\" .. fileCode .. ".lua",
        "Interface/AddOns/AttuneHelper/Locales/" .. fileCode .. ".lua",
    }
    local chunk
    for _, p in ipairs(paths) do
        chunk = loadfile(p)
        if chunk then break end
    end
    if not chunk then
        AH._localeOverlaysByFile[fileCode] = false
        return nil
    end
    local ok, tbl = pcall(chunk)
    if not ok or type(tbl) ~= "table" then
        AH._localeOverlaysByFile[fileCode] = false
        return nil
    end
    AH._localeOverlaysByFile[fileCode] = tbl
    return tbl
end

------------------------------------------------------------------------
-- Core helper functions
------------------------------------------------------------------------
local function normalizeLocaleCode(localeCode)
    if not localeCode then return "enUS" end
    if localeCode == "default" then localeCode = GetLocale() end
    if localeCode == "enGB" then localeCode = "enUS" end
    return localeCode
end

local function activateLocale(localeCode)
    localeCode = normalizeLocaleCode(localeCode)
    local overlay = loadLocaleOverlayForCode(localeCode)
    if overlay then
        AH.L = setmetatable({}, {
            __index = function(_, k)
                local v = overlay[k]
                if v ~= nil then return v end
                v = enUS[k]
                if v ~= nil then return v end
                return k
            end,
        })
    else
        AH.L = setmetatable({}, {
            __index = function(_, k)
                local v = enUS[k]
                if v ~= nil then return v end
                return k
            end,
        })
    end
end

function AH.SetLocale(localeCode)
    if not localeCode then return end
    if localeCode == "default" then localeCode = GetLocale() end
    if localeCode == "enGB" then localeCode = "enUS" end
    AttuneHelperDB["Language"] = localeCode
    activateLocale(localeCode)
end

function AH.t(key, ...)
    local str = (AH.L and AH.L[key]) or key
    if select("#", ...) > 0 then return string.format(str, ...) end
    return str
end

activateLocale(activeLocale)

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, addonName)
    if addonName == "AttuneHelper" then
        AH.SetLocale(AttuneHelperDB and AttuneHelperDB["Language"] or "default")
        f:UnregisterEvent("ADDON_LOADED")
    end
end)

-- ʕ •ᴥ•ʔ✿ Core utility helpers ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper
local flags = AH.flags or {}

function AH.CreateItemIdentifier(itemLink, itemName)
    if not itemLink then return itemName end
    
    local itemId = AH.GetItemIDFromLink(itemLink)
    if not itemId then return itemName end -- Fallback to name if no ID
    
    -- Create unique identifier: "ItemName|ItemID"
    return itemName .. "|" .. tostring(itemId)
end

function AH.GetItemNameFromIdentifier(identifier)
    if not identifier then return nil end
    
    -- Extract name from "ItemName|ItemID" format
    local name = string.match(identifier, "^(.-)|")
    return name or identifier -- Return original if no separator found
end

function AH.GetItemIDFromIdentifier(identifier)
    if not identifier then return nil end
    
    -- Extract ID from "ItemName|ItemID" format
    local id = string.match(identifier, "|(%d+)$")
    return id and tonumber(id) or nil
end

-- Enhanced item comparison for duplicate detection
function AH.AreItemsSameType(itemLink1, itemLink2)
    if not itemLink1 or not itemLink2 then return false end
    
    local name1, _, _, _, _, _, _, _, equipLoc1 = GetItemInfo(itemLink1)
    local name2, _, _, _, _, _, _, _, equipLoc2 = GetItemInfo(itemLink2)
    
    -- Same name and equip location = same type
    return name1 == name2 and equipLoc1 == equipLoc2
end

-- Priority comparison for items of the same type
function AH.CompareItemPriority(itemLink1, itemLink2)
    if not itemLink1 or not itemLink2 then return false end
    
    -- First priority: Attunable > Set items
    local isAttunable1 = AH.IsItemAttunable(itemLink1)
    local isAttunable2 = AH.IsItemAttunable(itemLink2)
    
    if isAttunable1 ~= isAttunable2 then
        return isAttunable1 -- Attunable items have priority
    end
    
    -- Second priority: Higher forge level
    local forge1 = AH.GetForgeLevelFromLink(itemLink1)
    local forge2 = AH.GetForgeLevelFromLink(itemLink2)
    
    if forge1 ~= forge2 then
        return forge1 > forge2 -- Higher forge level wins
    end
    
    -- Third priority: Lower attunement progress (more room to grow)
    local progress1 = _G.GetItemLinkAttuneProgress and GetItemLinkAttuneProgress(itemLink1) or 0
    local progress2 = _G.GetItemLinkAttuneProgress and GetItemLinkAttuneProgress(itemLink2) or 0
    
    if progress1 ~= progress2 then
        return progress1 < progress2 -- Lower progress wins
    end
    
    -- Fourth priority: Lower item level (if enabled)
    if AttuneHelperDB["Prioritize Low iLvl for Auto-Equip"] == 1 then
        local _, _, _, ilvl1 = GetItemInfo(itemLink1)
        local _, _, _, ilvl2 = GetItemInfo(itemLink2)
        if ilvl1 and ilvl2 and ilvl1 ~= ilvl2 then
            return ilvl1 < ilvl2 -- Lower item level wins
        end
    end
    
    -- If all else is equal, prefer the first item
    return true
end

-- Helper function to check if item is attunable
function AH.IsItemAttunable(itemLink)
    if not itemLink then return false end
    
    local itemId = AH.GetItemIDFromLink(itemLink)
    if not itemId then return false end
    
    return _G.CanAttuneItemHelper and CanAttuneItemHelper(itemId) == 1
end

------------------------------------------------------------------------
-- Session state helpers
------------------------------------------------------------------------
function AH.SetMerchantWindowOpen(isOpen)
    AH.merchantWindowOpen = isOpen == true
end
_G.SetMerchantWindowOpen = AH.SetMerchantWindowOpen

function AH.IsVendorWindowOpen()
    if AH.merchantWindowOpen then
        return true
    end

    local merchantFrame = _G.MerchantFrame
    if merchantFrame and merchantFrame:IsShown() then
        return true
    end

    local scootsVendorMaster = _G["ScootsVendor-Master"]
    if scootsVendorMaster and scootsVendorMaster.IsShown and scootsVendorMaster:IsShown() then
        return true
    end

    return false
end
_G.IsVendorWindowOpen = AH.IsVendorWindowOpen

function AH.IsWeaponTypeForOffHandCheck(equipLoc)
    return equipLoc == "INVTYPE_WEAPON" or equipLoc == "INVTYPE_WEAPONMAINHAND" or equipLoc == "INVTYPE_WEAPONOFFHAND"
end
_G.IsWeaponTypeForOffHandCheck = AH.IsWeaponTypeForOffHandCheck

AH.UPDATE_MASK = AH.UPDATE_MASK or {
    FULL_LIST = 1,
    OBTAINED = 2,
    ATTUNED_PERCENT = 4
}

local _timeSinceLastUpdate = 0
local _needUpdate = 0
local _pendingBagUpdates = {}
local UPDATE_BATCH_INTERVAL = 0.5
local _updateFrameActive = false
local updateFrame

local function _flushPendingBagUpdates()
    local bags = {}
    for bagID in pairs(_pendingBagUpdates) do
        if type(bagID) == "number" and bagID >= 0 and bagID <= 4 then
            table.insert(bags, bagID)
        end
        _pendingBagUpdates[bagID] = nil
    end
    table.sort(bags)
    return bags
end

local function _actualUpdateFunc(mask, pendingBagIDs)
    if mask == 0 then
        return
    end

    local fullList = bit.band(mask, AH.UPDATE_MASK.FULL_LIST) ~= 0
    local obtained = bit.band(mask, AH.UPDATE_MASK.OBTAINED) ~= 0
    local attunedPercent = bit.band(mask, AH.UPDATE_MASK.ATTUNED_PERCENT) ~= 0
    local shouldRefreshText = (AH.IsDisplayVisible and AH.IsDisplayVisible()) or (AttuneHelperDB and AttuneHelperDB["Auto Equip Attunable After Combat"] == 1)

    if fullList then
        if AH.RefreshAllBagCaches then
            AH.RefreshAllBagCaches()
        end
    elseif obtained then
        local updatedAnyBag = false
        if AH.UpdateBagCache and pendingBagIDs and #pendingBagIDs > 0 then
            for _, bagID in ipairs(pendingBagIDs) do
                AH.UpdateBagCache(bagID)
                updatedAnyBag = true
            end
            if updatedAnyBag and AH.equipSlotCacheDirty and AH.RebuildEquipSlotCache then
                AH.RebuildEquipSlotCache()
            end
            if shouldRefreshText and AH.UpdateItemCountText then
                AH.UpdateItemCountText()
            end
        elseif AH.RefreshAllBagCaches then
            AH.RefreshAllBagCaches()
            updatedAnyBag = true
        end

        if not updatedAnyBag and shouldRefreshText and AH.UpdateItemCountText then
            AH.UpdateItemCountText()
        end
    elseif attunedPercent and shouldRefreshText and AH.UpdateItemCountText then
        AH.UpdateItemCountText()
    end

    if (fullList or obtained or attunedPercent) and AH.TriggerThrottledAutoEquip then
        AH.TriggerThrottledAutoEquip(0.02)
    end
end

local function _frameUpdate(_, elapsed)
    _timeSinceLastUpdate = _timeSinceLastUpdate + elapsed

    if _needUpdate ~= 0 and _timeSinceLastUpdate > UPDATE_BATCH_INTERVAL then
        local mask = _needUpdate
        _needUpdate = 0
        _timeSinceLastUpdate = 0
        _actualUpdateFunc(mask, _flushPendingBagUpdates())
    end

    if _needUpdate == 0 and _updateFrameActive then
        _updateFrameActive = false
        updateFrame:SetScript("OnUpdate", nil)
    end
end

updateFrame = CreateFrame("Frame")
local function _activateUpdateFrame()
    if not _updateFrameActive then
        _updateFrameActive = true
        _timeSinceLastUpdate = 0
        updateFrame:SetScript("OnUpdate", _frameUpdate)
    end
end

function AH.RequestUpdateList(mask, bagID)
    if type(mask) ~= "number" then
        return
    end

    if type(bagID) == "number" and bagID >= 0 and bagID <= 4 then
        _pendingBagUpdates[bagID] = true
    end

    _needUpdate = bit.bor(_needUpdate, mask)
    _activateUpdateFrame()

    if bit.band(mask, AH.UPDATE_MASK.FULL_LIST) ~= 0 then
        local pendingMask = _needUpdate
        _needUpdate = 0
        _timeSinceLastUpdate = 0
        _actualUpdateFunc(pendingMask, _flushPendingBagUpdates())
        if _updateFrameActive then
            _updateFrameActive = false
            updateFrame:SetScript("OnUpdate", nil)
        end
    end
end
_G.RequestUpdateList = AH.RequestUpdateList

local ServerBagMap = {
    [0] = 0xFF,
    [1] = 0x13,
    [2] = 0x14,
    [3] = 0x15,
    [4] = 0x16
}

function AH.NativeToServerBagSlot(nativeBag, nativeSlot)
    if not nativeBag or not nativeSlot then return nil, nil end

    if nativeBag == 0 then
        return 0xFF, 22 + nativeSlot
    end

    local serverBag = ServerBagMap[nativeBag]
    if serverBag then
        return serverBag, nativeSlot - 1
    end

    return nil, nil
end
_G.NativeToServerBagSlot = AH.NativeToServerBagSlot

function AH.IsSoulboundFromNativeBagSlot(nativeBag, nativeSlot)
    if not _G.Custom_IsItemSoulbound then return false end

    local serverBag, serverSlot = AH.NativeToServerBagSlot(nativeBag, nativeSlot)
    if not serverBag then return false end

    local ok, result = pcall(_G.Custom_IsItemSoulbound, serverBag, serverSlot)
    if not ok then return false end
    return result == true or result == 1
end
_G.IsSoulboundFromNativeBagSlot = AH.IsSoulboundFromNativeBagSlot

function AH.IsItemInEquipMgrFromNativeBagSlot(nativeBag, nativeSlot)
    if not _G.Custom_IsItemEquipMgr then return false end

    local serverBag, serverSlot = AH.NativeToServerBagSlot(nativeBag, nativeSlot)
    if not serverBag then return false end

    local ok, result = pcall(_G.Custom_IsItemEquipMgr, serverBag, serverSlot)
    if not ok then return false end
    return result == 1
end
_G.IsItemInEquipMgrFromNativeBagSlot = AH.IsItemInEquipMgrFromNativeBagSlot

------------------------------------------------------------------------
-- Table helpers
------------------------------------------------------------------------
function AH.tContains(tbl, val)
    if type(tbl) ~= "table" then return false end
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end
_G.tContains = AH.tContains -- legacy

------------------------------------------------------------------------
-- Item helpers
------------------------------------------------------------------------
function AH.GetItemIDFromLink(itemLink)
    if not itemLink then return nil end
    if not ItemLocIsLoaded() or not CustomExtractItemId then 
        local itemIdStr = string.match(itemLink, "item:(%d+)")
        return itemIdStr and tonumber(itemIdStr) or nil
    end
    return CustomExtractItemId(itemLink)
end
_G.GetItemIDFromLink = AH.GetItemIDFromLink

function AH.GetItemIconForId(itemId)
    if not itemId then
        return nil
    end
    local _, _, _, _, _, _, _, _, _, tex = GetItemInfo(itemId)
    if tex and tex ~= "" then
        return tex
    end
    if type(GetItemInfoCustom) == "function" then
        _, _, _, _, _, _, _, _, _, tex = GetItemInfoCustom(itemId)
        if tex and tex ~= "" then
            return tex
        end
    end
    if GetItemIcon then
        tex = GetItemIcon(itemId)
        if tex and tex ~= "" then
            return tex
        end
    end
    return nil
end

function AH.GetItemDisplayName(itemId, itemLink)
    if itemLink then
        local n = select(1, GetItemInfo(itemLink))
        if n then
            return n
        end
    end
    if itemId then
        local n = select(1, GetItemInfo(itemId))
        if n then
            return n
        end
        if type(GetItemInfoCustom) == "function" then
            n = select(1, GetItemInfoCustom(itemId))
            if n then
                return n
            end
        end
    end
    return nil
end

-- Convert FORGE_LEVEL_MAP value to 3-param API format (0–3)
function AH.ConvertForgeMapToApiParam(forgeLevelMapValue)
    local map = AH.FORGE_LEVEL_MAP
    if forgeLevelMapValue == map.TITANFORGED then return 1
    elseif forgeLevelMapValue == map.WARFORGED then return 2
    elseif forgeLevelMapValue == map.LIGHTFORGED then return 3
    end
    return 0
end
_G.ConvertForgeMapToApiParam = AH.ConvertForgeMapToApiParam

function AH.GetForgeLevelFromLink(itemLink)
    if not itemLink then return AH.FORGE_LEVEL_MAP.BASE end
    if _G.GetItemLinkTitanforge then
        local forgeValue = GetItemLinkTitanforge(itemLink)
        -- Validate against known values
        for _, v in pairs(AH.FORGE_LEVEL_MAP) do
            if forgeValue == v then return forgeValue end
        end
        --AH.print_debug_general("GetForgeLevelFromLink: unexpected value "..tostring(forgeValue))
    else
        --AH.print_debug_general("GetForgeLevelFromLink: API not available/disabled")
    end
    return AH.FORGE_LEVEL_MAP.BASE
end
_G.GetForgeLevelFromLink = AH.GetForgeLevelFromLink

-- Determine if an item is Mythic by any means available
function AH.IsMythic(itemID)
    if not itemID then return false end
    -- Primary: bitmask via GetItemTagsCustom
    if GetItemTagsCustom then
        local tags = GetItemTagsCustom(itemID)
        if tags then return bit.band(tags, 0x80) ~= 0 end
    end
    -- Fallback: numeric threshold
    if itemID >= AH.MYTHIC_MIN_ITEMID then return true end
    return false
end
_G.IsMythic = AH.IsMythic

------------------------------------------------------------------------
-- ʕ •ᴥ•ʔ✿ Optimized Wait helper with memory management ✿ ʕ •ᴥ•ʔ
------------------------------------------------------------------------
local waitTable = {}
local waitFrame = nil
local lastWaitCleanup = 0
local WAIT_CLEANUP_INTERVAL = 60  -- Clean every 60 seconds

local function WaitFrameOnUpdate(_, elapsed)
    if #waitTable == 0 then
        waitFrame:SetScript("OnUpdate", nil)
        return
    end

    local currentTime = GetTime()

    if currentTime - lastWaitCleanup > WAIT_CLEANUP_INTERVAL then
        local oldCount = #waitTable
        for i = #waitTable, 1, -1 do
            local rec = waitTable[i]
            if not rec or not rec[2] then
                table.remove(waitTable, i)
            end
        end
        local newCount = #waitTable
        if oldCount ~= newCount then
            --AH.print_debug_general(string.format("Wait table cleaned: %d -> %d entries", oldCount, newCount))
        end
        lastWaitCleanup = currentTime
    end

    local i = 1
    while i <= #waitTable do
        local rec = waitTable[i]
        if rec then
            local d, f, params = rec[1], rec[2], rec[3]
            if d > elapsed then
                rec[1] = d - elapsed
                i = i + 1
            else
                table.remove(waitTable, i)
                local success, err = pcall(f, unpack(params or {}))
                if not success then
                    --AH.print_debug_general("Wait function error: " .. tostring(err))
                end
            end
        else
            table.remove(waitTable, i)
        end
    end

    if #waitTable == 0 then
        waitFrame:SetScript("OnUpdate", nil)
    end
end

function AH.Wait(delay, func, ...)
    if type(delay) ~= "number" or type(func) ~= "function" then return false end
    
    if not waitFrame then
        waitFrame = CreateFrame("Frame", nil, UIParent)
    end
    
    table.insert(waitTable, { delay, func, { ... } })
    if not waitFrame:GetScript("OnUpdate") then
        waitFrame:SetScript("OnUpdate", WaitFrameOnUpdate)
    end
    return true
end
_G.AH_wait = AH.Wait -- maintain original global name

------------------------------------------------------------------------
-- Settings initialization
------------------------------------------------------------------------
function AH.InitializeDefaultSettings()
    AHCharSettings = AHCharSettings or {}
    AHVendorList = AHVendorList or {}
    if AttuneHelperDB["Background Style"] == nil then AttuneHelperDB["Background Style"] = "Tooltip" end
    if type(AttuneHelperDB["Background Color"]) ~= "table" or #AttuneHelperDB["Background Color"] < 4 then 
        AttuneHelperDB["Background Color"] = {0, 0, 0, 0.8} 
    end
    if AttuneHelperDB["Button Color"] == nil then AttuneHelperDB["Button Color"] = {1, 1, 1, 1} end
    if AttuneHelperDB["Button Theme"] == nil then AttuneHelperDB["Button Theme"] = "Normal" end
    if AttuneHelperDB["Button Layout Preset"] == nil then AttuneHelperDB["Button Layout Preset"] = "Standard" end
    if AttuneHelperDB["Button Layout Preset"] == "Compact" then AttuneHelperDB["Button Layout Preset"] = "Standard" end
    if AttuneHelperDB["Layout Normal Top"] == nil then AttuneHelperDB["Layout Normal Top"] = "equipAll" end
    if AttuneHelperDB["Layout Normal Center"] == nil then AttuneHelperDB["Layout Normal Center"] = "openSettings" end
    if AttuneHelperDB["Layout Normal Bottom"] == nil then AttuneHelperDB["Layout Normal Bottom"] = "vendor" end
    if AttuneHelperDB["Layout Shift Top"] == nil then AttuneHelperDB["Layout Shift Top"] = "toggleAutoEquip" end
    if AttuneHelperDB["Layout Shift Center"] == nil then AttuneHelperDB["Layout Shift Center"] = "AHSetUpdate" end
    if AttuneHelperDB["Layout Shift Bottom"] == nil then AttuneHelperDB["Layout Shift Bottom"] = "sort" end
    if AttuneHelperDB["Layout Ctrl Top"] == nil then AttuneHelperDB["Layout Ctrl Top"] = "AHSetUpdate" end
    if AttuneHelperDB["Layout Ctrl Center"] == nil then AttuneHelperDB["Layout Ctrl Center"] = "openSettings" end
    if AttuneHelperDB["Layout Ctrl Bottom"] == nil then AttuneHelperDB["Layout Ctrl Bottom"] = "openSettings" end
    if AttuneHelperDB["Disable Auto-Equip Mythic BoE"] == nil then AttuneHelperDB["Disable Auto-Equip Mythic BoE"] = 1 end
    if AttuneHelperDB["Auto Equip Attunable After Combat"] == nil then AttuneHelperDB["Auto Equip Attunable After Combat"] = 0 end
    if AttuneHelperDB["Equip BoE Bountied Items"] == nil then AttuneHelperDB["Equip BoE Bountied Items"] = 0 end
    if AttuneHelperDB["Disable Auto Equip 284 BoE Forges if Base Attuned"] == nil then AttuneHelperDB["Disable Auto Equip 284 BoE Forges if Base Attuned"] = 1 end
    if AttuneHelperDB["Mini Mode"] == nil then AttuneHelperDB["Mini Mode"] = 0 end
    if AttuneHelperDB["FramePosition"] == nil then AttuneHelperDB["FramePosition"] = { "CENTER", UIParent, "CENTER", 0, 0 } end
    if AttuneHelperDB["MiniFramePosition"] == nil then AttuneHelperDB["MiniFramePosition"] = { "CENTER", UIParent, "CENTER", 0, 0 } end
    if AttuneHelperDB["Disable Two-Handers"] == nil then AttuneHelperDB["Disable Two-Handers"] = 0 end
    if AttuneHelperDB["Language"] == nil then AttuneHelperDB["Language"] = "default" end

    -- Handle legacy setting migration
    if AttuneHelperDB["EquipUntouchedVariants"] ~= nil and AttuneHelperDB["EquipNewAffixesOnly"] == nil then
        AttuneHelperDB["EquipNewAffixesOnly"] = AttuneHelperDB["EquipUntouchedVariants"]
        --AH.print_debug_general("AttuneHelper: Migrated old setting 'EquipUntouchedVariants' to 'EquipNewAffixesOnly'.")
    end
    AttuneHelperDB["EquipUntouchedVariants"] = nil

    if AttuneHelperDB["EquipNewAffixesOnly"] == nil then AttuneHelperDB["EquipNewAffixesOnly"] = 0 end

    -- Migrate old boolean toggle to threshold dropdown model
    if AttuneHelperDB["AffixOnlyWarforgedAndAbove"] ~= nil and AttuneHelperDB["AffixOnlyMinForgeLevel"] == nil then
        if AttuneHelperDB["AffixOnlyWarforgedAndAbove"] == 1 then
            AttuneHelperDB["AffixOnlyMinForgeLevel"] = AH.FORGE_LEVEL_MAP.WARFORGED
        else
            AttuneHelperDB["AffixOnlyMinForgeLevel"] = -1
        end
    end
    AttuneHelperDB["AffixOnlyWarforgedAndAbove"] = nil
    if AttuneHelperDB["AffixOnlyMinForgeLevel"] == nil then
        AttuneHelperDB["AffixOnlyMinForgeLevel"] = AH.FORGE_LEVEL_MAP.WARFORGED
    end

    -- Handle renaming of EnableVendorPreview to EnableVendorSellConfirmationDialog
    if AttuneHelperDB["EnableVendorPreview"] ~= nil and AttuneHelperDB["EnableVendorSellConfirmationDialog"] == nil then
        AttuneHelperDB["EnableVendorSellConfirmationDialog"] = AttuneHelperDB["EnableVendorPreview"]
        --AH.print_debug_general("AttuneHelper: Migrated old setting 'EnableVendorPreview' to 'EnableVendorSellConfirmationDialog'.")
    end
    AttuneHelperDB["EnableVendorPreview"] = nil -- Remove old key

    -- Initialize forge types
    if type(AttuneHelperDB.AllowedForgeTypes) ~= "table" then
        AttuneHelperDB.AllowedForgeTypes = {}
        local defaultForgeKeysAndValues = AH.defaultForgeKeysAndValues or { BASE = true, TITANFORGED = true, WARFORGED = true, LIGHTFORGED = true }
        for keyName, defaultValue in pairs(defaultForgeKeysAndValues) do 
            AttuneHelperDB.AllowedForgeTypes[keyName] = defaultValue 
        end
    end
    
    -- Initialize general options
    local generalOptionDefaults = {
        ["Sell Attuned Mythic Gear?"] = 0, 
        ["Auto Equip Attunable After Combat"] = 0, 
        ["Do Not Sell BoE Items"] = 1,
        ["Do Not Sell Grey And White Items"] = 0,
        ["Limit Selling to 12 Items?"] = 0, 
        ["Disable Auto-Equip Mythic BoE"] = 1, 
        ["Equip BoE Bountied Items"] = 0,
        ["Disable Auto Equip 284 BoE Forges if Base Attuned"] = 1,
        ["Mini Mode"] = 0, 
        ["EquipNewAffixesOnly"] = 1, 
        ["AffixOnlyMinForgeLevel"] = AH.FORGE_LEVEL_MAP.WARFORGED,
        ["Prioritize Low iLvl for Auto-Equip"] = 1,
        ["EnableVendorSellConfirmationDialog"] = 1,
        ["Vendor preview on Right (Default On)"] = 1,
        ["Draggable by Right Click"] = 1,
        ["Lock AH in Place (Buttons Only Mouse)"] = 0,
        ["Hide Center Button in Normal Mode"] = 0,
        ["Hide Disenchant Button"] = 0,  -- ʕ •ᴥ•ʔ✿ Show disenchant button by default ✿ ʕ •ᴥ•ʔ
        ["Use Bag 1 for Disenchant"] = 0  -- ʕ •ᴥ•ʔ✿ Use bag 0 by default ✿ ʕ •ᴥ•ʔ
    }
    for optName, defValue in pairs(generalOptionDefaults) do
        if AttuneHelperDB[optName] == nil then 
            AttuneHelperDB[optName] = defValue 
        end
    end
    
    -- ʕ •ᴥ•ʔ✿ Initialize blacklist defaults (all slots enabled by default) ✿ ʕ •ᴥ•ʔ
    local blacklistDefaults = {
        ["HeadSlot"] = 0, ["NeckSlot"] = 0, ["ShoulderSlot"] = 0, ["BackSlot"] = 0,
        ["ChestSlot"] = 0, ["WristSlot"] = 0, ["HandsSlot"] = 0, ["WaistSlot"] = 0,
        ["LegsSlot"] = 0, ["FeetSlot"] = 0, ["Finger0Slot"] = 0, ["Finger1Slot"] = 0,
        ["Trinket0Slot"] = 0, ["Trinket1Slot"] = 0, ["MainHandSlot"] = 0, 
        ["SecondaryHandSlot"] = 0, ["RangedSlot"] = 0
    }
    for slotName, defValue in pairs(blacklistDefaults) do
        if AttuneHelperDB[slotName] == nil then 
            AttuneHelperDB[slotName] = defValue 
        end
    end

    
	-- ʕ •ᴥ•ʔ✿ Default ignored items (only seeded once, never overwritten) ✿ ʕ •ᴥ•ʔ
    -- AHIgnoreList is keyed by item name (string). A nil value means
    -- the user explicitly removed it; only seed if the key is absent.
    local defaultIgnoreItemIDs = {
        -- Ring of the Kirin Tor
        44935, 45690, 48956,
        -- Band of the Kirin Tor
        40586, 45688, 48954,
        -- Loop of the Kirin Tor
        44934, 45689, 48955,
        -- Signet of the Kirin Tor
        40585, 45691, 48957,
        -- Miscellaneous
        18608, 17074, 49496, 49302, 49888,
        -- Questing
        2944, 32649,
        -- Ashen Verdict
        50375, 50388, 50403, 50377, 50384, 50397, 50376, 50387, 50401, 52569, 52570, 52571, 50378, 50386, 50399,
        -- Brood of Nozdormu
        21196, 21197, 21198, 21199, 21201, 21202, 21203, 21204, 21206, 21207, 21208, 21209,
        -- Crafting
        28428, 28429, 28431, 28432, 28437, 28438, 28425, 28426, 28434, 28435, 28440, 28441,
        23563, 23564, 28483, 28484, 41245, 41355, 5966,
        -- Engineering
        32473, 32480, 32472, 32476, 32461, 32495, 32475, 32478, 32474, 32479, 10502, 10543,
        4368, 32494, 4385, 10500, 13503, 9149,
        -- Leatherworking / Tailoring
        4243, 4246, 14044, 41520, 10026, 4255, 7387,
        -- T10 Hunter
        50114, 51154, 50115, 51153, 50116, 51152, 50117, 51151, 50118, 51150,
        -- T10 Warrior DPS
        50078, 51214, 50079, 51213, 50080, 51212, 50081, 51211, 50082, 51210,
        -- T10 Warrior Tank
        50846, 51215, 50847, 51216, 50848, 51218, 50849, 51217, 50850, 51219,
        -- T10 Paladin Holy
        50865, 51166, 50866, 51168, 50867, 51167, 50868, 51169, 50869, 51165,
        -- T10 Paladin Protection
        50860, 51170, 50861, 51171, 50862, 51173, 50863, 51172, 50864, 51174,
        -- T10 Paladin Retribution
        50324, 51160, 50325, 51161, 50326, 51162, 50327, 51163, 50328, 51164,
        -- T10 Death Knight Blood
        50853, 51130, 50854, 51131, 50855, 51133, 50856, 51132, 50857, 51134,
        -- T10 Death Knight Frost/Unholy
        50094, 51129, 50095, 51128, 50096, 51127, 50097, 51126, 50098, 51125,
        -- T10 Rogue
        50105, 51185, 50089, 51187, 50090, 51186, 50087, 51189, 50088, 51188,
        -- T10 Priest Holy/Disc
        50769, 51177, 50768, 51176, 50767, 51175, 50766, 51179, 50765, 51178,
        -- T10 Priest Shadow
        50393, 51181, 50394, 51180, 50396, 51182, 50391, 51183, 50392, 51184,
        -- T10 Shaman Elemental
        50841, 51200, 50842, 51201, 50843, 51202, 50844, 51203, 50845, 51204,
        -- T10 Shaman Enhancement
        50830, 51195, 50831, 51196, 50832, 51197, 50833, 51198, 50834, 51199,
        -- T10 Shaman Restoration
        50835, 51190, 50836, 51191, 50837, 51192, 50838, 51193, 50839, 51194,
        -- T10 Mage
        50275, 51159, 50276, 51158, 50277, 51157, 50278, 51156, 50279, 51155,
        -- T10 Warlock
        50240, 51209, 50241, 51208, 50242, 51207, 50243, 51206, 50244, 51205,
        -- T10 Druid Balance
        50819, 51147, 50820, 51146, 50821, 51149, 50822, 51148, 50823, 51145,
        -- T10 Druid Feral
        50824, 51140, 50825, 51142, 50826, 51143, 50827, 51144, 50828, 51141,
        -- T10 Druid Restoration
        50106, 51139, 50107, 51138, 50108, 51137, 50109, 51136, 50113, 51135,
        -- T0.5 Hunter
        16680, 16676, 16681, 16675, 16678, 16679, 16677, 16674,
        -- T0.5 Druid
        16717, 16716, 16715, 16719, 16718, 16714, 16720, 16706,
        -- T0.5 Mage
        16685, 16684, 16683, 16682, 16687, 16689, 16686, 16688,
        -- T0.5 Paladin
        16723, 16724, 16725, 16728, 16729, 16722, 16726, 16727,
        -- T0.5 Priest
        16692, 16696, 16697, 16690, 16693, 16695, 16694, 16691,
        -- T0.5 Rogue
        16712, 16713, 16708, 16711, 16709, 16710, 16721, 16707,
        -- T0.5 Shaman
        16671, 16669, 16670, 16668, 16666, 16667, 16672, 16673,
        -- T0.5 Warlock
        16705, 16702, 16703, 16701, 16699, 16704, 16700, 16698,
        -- T0.5 Warrior
        16737, 16736, 16734, 16732, 16733, 16735, 16730, 16731,
        -- Sunmote Gear (Cloth)
        34342, 34339, 34233, 34202, 34170,
        -- Sunmote Gear (Leather)
        34234, 34244, 34245, 34212, 34211, 34195, 34209, 34188, 34169, 34351,
        -- Sunmote Gear (Mail)
        34229, 34350, 34332, 34208, 34186,
        -- Sunmote Gear (Plate)
        34167, 34243, 34345, 34180, 34216, 34215, 34193, 34192,
        -- Tools
        39505, 23821, 40772, 40768, 21133, 22649, 6256, 19440, 21215, 20805, 21386, 21131, 20513, 20515, 20802, 20800, 20801, 
    }
    for _, itemID in ipairs(defaultIgnoreItemIDs) do
        local key = "id:" .. itemID
        if AHIgnoreList[key] == nil then
            AHIgnoreList[key] = true
        end
    end

    local defaultAlwaysVendorItemIDs = {
    }
    if AttuneHelperDB["AlwaysVendorDefaultsApplied"] ~= 1 then
        for _, itemID in ipairs(defaultAlwaysVendorItemIDs) do
            AHVendorList["id:" .. itemID] = true
        end
        AttuneHelperDB["AlwaysVendorDefaultsApplied"] = 1
    end

    if AH.InitCharProfileAfterLoad then
        AH.InitCharProfileAfterLoad()
    end
end
_G.InitializeDefaultSettings = AH.InitializeDefaultSettings

function AH.GetWeaponControlSetting(settingName)
    if not settingName then
        return 0
    end

    if AH.GetCharProfile then
        local p = AH.GetCharProfile()
        if p.weapon[settingName] ~= nil then
            return p.weapon[settingName]
        end
    end

    AHCharSettings = AHCharSettings or {}
    if AHCharSettings[settingName] ~= nil then
        return AHCharSettings[settingName]
    end
    if AttuneHelperDB and AttuneHelperDB[settingName] ~= nil then
        return AttuneHelperDB[settingName]
    end

    local weaponControlDefaults = {
        ["Allow MainHand 1H Weapons"] = 1,
        ["Allow MainHand 2H Weapons"] = 1,
        ["Allow OffHand 1H Weapons"] = 1,
        ["Allow OffHand 2H Weapons"] = 0,
        ["Allow OffHand Shields"] = 1,
        ["Allow OffHand Holdables"] = 1
    }

    return weaponControlDefaults[settingName] or 0
end
_G.GetWeaponControlSetting = AH.GetWeaponControlSetting

function AH.SetWeaponControlSetting(settingName, value)
    if not settingName then
        return
    end
    if AH.GetCharProfile then
        local p = AH.GetCharProfile()
        p.weapon[settingName] = value
    end
    AHCharSettings = AHCharSettings or {}
    AHCharSettings[settingName] = value
end
_G.SetWeaponControlSetting = AH.SetWeaponControlSetting

------------------------------------------------------------------------
-- ʕ •ᴥ•ʔ✿ Blacklist management ✿ ʕ •ᴥ•ʔ
------------------------------------------------------------------------
function AH.ToggleSlotBlacklist(slotName)
    if not slotName then return end
    
    -- Toggle the blacklist status
    AttuneHelperDB[slotName] = 1 - (AttuneHelperDB[slotName] or 0)
    
    local status = (AttuneHelperDB[slotName] == 1) and "blacklisted" or "unblacklisted"
    print(string.format("|cffffd200[AH]|r %s %s.", slotName, status))
    
    -- Force save the setting
    AH.ForceSaveSettings()
end
_G.ToggleSlotBlacklist = AH.ToggleSlotBlacklist

------------------------------------------------------------------------
-- ʕ •ᴥ•ʔ✿ Disenchant button visibility control ✿ ʕ •ᴥ•ʔ
------------------------------------------------------------------------
function AH.UpdateDisenchantButtonVisibility()
    local shouldHide = AttuneHelperDB["Hide Disenchant Button"] == 1
    
    -- Hide/show main frame disenchant button
    if _G.AttuneHelperSortInventoryButton then
        if shouldHide then
            _G.AttuneHelperSortInventoryButton:Hide()
        else
            _G.AttuneHelperSortInventoryButton:Show()
        end
    end
    
    -- Hide/show mini frame disenchant button
    if _G.AttuneHelperMiniSortButton then
        if shouldHide then
            _G.AttuneHelperMiniSortButton:Hide()
        else
            _G.AttuneHelperMiniSortButton:Show()
        end
    end
    
    --AH.print_debug_general(string.format("Disenchant buttons %s", shouldHide and "hidden" or "shown"))
end
_G.UpdateDisenchantButtonVisibility = AH.UpdateDisenchantButtonVisibility

-- ʕ •ᴥ•ʔ✿ Gameplay · Equip logic & policies ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper
local flags = AH.flags or {}

-- ʕ •ᴥ•ʔ✿ Create reusable tooltip for performance ✿ ʕ •ᴥ•ʔ
local willBindScannerTooltip = nil

-- ʕ •ᴥ•ʔ✿ Recently equipped items tracking to prevent immediate re-equipping ✿ ʕ •ᴥ•ʔ
local recentlyEquippedItems = {}
local RECENTLY_EQUIPPED_TIMEOUT = 5.0 -- seconds

-- ʕ •ᴥ•ʔ✿ GetItemInfo cache to prevent repeated expensive API calls ✿ ʕ •ᴥ•ʔ
local itemInfoEquipCache = setmetatable({}, { __mode = "v" })
local lastEquipCacheCleanup = 0
local EQUIP_CACHE_CLEANUP_INTERVAL = 45

local function GetCachedItemInfoForEquip(itemLink)
    if not itemLink then return nil end

    local currentTime = GetTime()
    if currentTime - lastEquipCacheCleanup > EQUIP_CACHE_CLEANUP_INTERVAL then
        itemInfoEquipCache = setmetatable({}, { __mode = "v" })
        lastEquipCacheCleanup = currentTime
    end

    if not itemInfoEquipCache[itemLink] then
        local name, _, _, _, _, _, _, _, equipLoc = GetItemInfo(itemLink)
        if name then
            itemInfoEquipCache[itemLink] = { name, equipLoc }
        end
    end

    local cached = itemInfoEquipCache[itemLink]
    return cached and cached[1], cached and cached[2]
end

------------------------------------------------------------------------
-- ʕ •ᴥ•ʔ✿ Weapon type checking functions ✿ ʕ •ᴥ•ʔ
------------------------------------------------------------------------
function AH.IsWeaponTypeAllowed(equipSlot, targetSlot)
    if not equipSlot or not targetSlot then return true end

    if targetSlot == "MainHandSlot" then
        -- Check 1H weapons
        if equipSlot == "INVTYPE_WEAPON" or equipSlot == "INVTYPE_WEAPONMAINHAND" then
            return AttuneHelperDB["Allow MainHand 1H Weapons"] == 1
        end
        -- Check 2H weapons
        if equipSlot == "INVTYPE_2HWEAPON" then
            return AttuneHelperDB["Allow MainHand 2H Weapons"] == 1
        end
    elseif targetSlot == "SecondaryHandSlot" then
        -- Check 1H weapons
        if equipSlot == "INVTYPE_WEAPON" or equipSlot == "INVTYPE_WEAPONOFFHAND" then
            return AttuneHelperDB["Allow OffHand 1H Weapons"] == 1
        end
        -- Check 2H weapons (unusual but possible in some custom servers)
        if equipSlot == "INVTYPE_2HWEAPON" then
            return AttuneHelperDB["Allow OffHand 2H Weapons"] == 1
        end
        -- Check shields
        if equipSlot == "INVTYPE_SHIELD" then
            return AttuneHelperDB["Allow OffHand Shields"] == 1
        end
        -- Check holdables
        if equipSlot == "INVTYPE_HOLDABLE" then
            return AttuneHelperDB["Allow OffHand Holdables"] == 1
        end
    end

    -- Default: allow non-weapon items
    return true
end

_G.IsWeaponTypeAllowed = AH.IsWeaponTypeAllowed

function AH.GetWeaponTypeDisplayName(equipSlot)
    local typeNames = {
        ["INVTYPE_WEAPON"] = "1H Weapon",
        ["INVTYPE_2HWEAPON"] = "2H Weapon",
        ["INVTYPE_WEAPONMAINHAND"] = "1H Main Hand",
        ["INVTYPE_WEAPONOFFHAND"] = "1H Off Hand",
        ["INVTYPE_SHIELD"] = "Shield",
        ["INVTYPE_HOLDABLE"] = "Holdable"
    }
    return typeNames[equipSlot] or "Unknown"
end

_G.GetWeaponTypeDisplayName = AH.GetWeaponTypeDisplayName

------------------------------------------------------------------------
-- Policy check for whether an item should be auto-equipped
------------------------------------------------------------------------
local ServerBagMap = {
    [0] = 0xFF,
    [1] = 0x13,
    [2] = 0x14,
    [3] = 0x15,
    [4] = 0x16
}
local function NativeToServerBagSlot(nativeBag, nativeSlot)
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

local function IsSoulboundFromNativeBagSlot(nativeBag, nativeSlot)
    local serverBag, serverSlot = NativeToServerBagSlot(nativeBag, nativeSlot)
    if not serverBag then return false end

    local result = Custom_IsItemSoulbound(serverBag, serverSlot)
    return result == true or result == 1
end

function AH.CanEquipItemPolicyCheck(candidateRec)
    if not candidateRec or not candidateRec.link then
        AH.print_debug_general("CanEquipItemPolicyCheck: Invalid candidateRec")
        return false
    end

    local itemLink = candidateRec.link
    local itemBag = candidateRec.bag
    local itemSlotInBag = candidateRec.slot
    local itemId = AH.GetItemIDFromLink(itemLink)

    local function IsBoEAndNotBound(itemLink, itemBag, itemSlotInBag)
        local isSoulbound = IsSoulboundFromNativeBagSlot(itemBag, itemSlotInBag)
        --print("IsBoEAndNotBound", itemLink, itemBag, itemSlotInBag, isSoulbound)
        return not isSoulbound
    end

    local itemIsBoENotBound = IsBoEAndNotBound(itemLink, itemBag, itemSlotInBag)
    if itemId then
        -- ʕ •ᴥ•ʔ✿ Check bounty status first for all items ✿ ʕ •ᴥ•ʔ
        local isBountied = (_G.GetCustomGameData and (_G.GetCustomGameData(31, itemId) or 0) > 0) or false
        if isBountied and itemIsBoENotBound then
            if AttuneHelperDB["Equip BoE Bountied Items"] ~= 1 then
                return false
            end
        end

        -- ʕ •ᴥ•ʔ✿ Check mythic BoE restrictions ✿ ʕ •ᴥ•ʔ
        local isMythic = AH.IsMythic(itemId)
        if AttuneHelperDB["Disable Auto-Equip Mythic BoE"] == 1 and isMythic and itemIsBoENotBound then
            return false
        end
    --elseif itemIsBoENotBound then
        -- No ItemID for BoE checks on " .. itemLink .. ", proceeding with forge check.
    end

    local determinedForgeLevel = AH.GetForgeLevelFromLink(itemLink)

    local allowedTypes = AttuneHelperDB.AllowedForgeTypes or {}
    if determinedForgeLevel == AH.FORGE_LEVEL_MAP.BASE and allowedTypes.BASE then
        return true
    end
    if determinedForgeLevel == AH.FORGE_LEVEL_MAP.TITANFORGED and allowedTypes.TITANFORGED then
        return true
    end
    if determinedForgeLevel == AH.FORGE_LEVEL_MAP.WARFORGED and allowedTypes.WARFORGED then
        return true
    end
    if determinedForgeLevel == AH.FORGE_LEVEL_MAP.LIGHTFORGED and allowedTypes.LIGHTFORGED then
        return true
    end

    return false
end

_G.CanEquipItemPolicyCheck = AH.CanEquipItemPolicyCheck

------------------------------------------------------------------------
-- Core equip action
------------------------------------------------------------------------
function AH.performEquipAction(itemRecord, targetSlotID, currentSlotNameForAction)
    if not itemRecord or not itemRecord.link then
        return false
    end

    if not itemRecord.bag or not itemRecord.slot then
        return false
    end

    local inCombat = InCombatLockdown()

    local itemLinkToEquip = itemRecord.link
    local itemEquipLocToEquip = itemRecord.equipSlot
    local sckEventsTemporarilyUnregistered = false

    if AH.isSCKLoaded and _G["SCK"] and _G["SCK"].frame then
        if _G["SCK"].confirmActive then _G["SCK"].confirmActive = false end
        _G["SCK"].frame:UnregisterEvent('EQUIP_BIND_CONFIRM')
        _G["SCK"].frame:UnregisterEvent('AUTOEQUIP_BIND_CONFIRM')
        sckEventsTemporarilyUnregistered = true
    end

    -- ʕ●ᴥ●ʔ✿ Session protection - prevent re-equipping same item ✿ ʕ●ᴥ●ʔ
    if AH.sessionEquippedItems and AH.sessionEquippedItems[itemRecord.link] then
        return false
    end

    local success, err = pcall(function()
        AH.lastAttemptedSlotForEquip = currentSlotNameForAction
        AH.lastAttemptedItemTypeForEquip = itemEquipLocToEquip

        -- Clear cursor first to ensure clean state
        if CursorHasItem() then
            ClearCursor()
        end

        -- ʕ •ᴥ•ʔ✿ Combat-aware equip method with enhanced error handling ✿ ʕ •ᴥ•ʔ
        local function attemptEquip()
            PickupContainerItem(itemRecord.bag, itemRecord.slot)
            if CursorHasItem() then

                -- First attempt to equip
                EquipCursorItem(targetSlotID)

                -- If item is still on cursor, it might be a BoE requiring confirmation
                if CursorHasItem() then
                    -- Handle BoE confirmation for WotLK
                    EquipPendingItem(0)

                    -- If still on cursor, try manual StaticPopup confirmation
                    if CursorHasItem() then
                        StaticPopup_Show("EQUIP_BIND")
                        -- Combat-aware delay handling
                        local confirmDelay = inCombat and 0.05 or 0.1
                        AH.Wait(confirmDelay, function()
                            -- Find and click "Yes" button on any BoE popup
                            for i = 1, STATICPOPUP_NUMDIALOGS do
                                local popup = _G["StaticPopup" .. i]
                                if popup and popup:IsVisible() and (popup.which == "EQUIP_BIND" or popup.which == "AUTOEQUIP_BIND") then
                                    if popup.button1 and popup.button1:IsEnabled() then
                                        popup.button1:Click()
                                        break
                                    end
                                end
                            end
                            -- Try equipping again after confirmation
                            if CursorHasItem() then
                                EquipCursorItem(targetSlotID)
                            end
                        end)
                    end
                end
                return not CursorHasItem() -- Success if cursor is clear
            else
                -- Fallback to original method
                UseContainerItem(itemRecord.bag, itemRecord.slot)
                -- Handle BoE for fallback method too
                EquipPendingItem(0)
                AH.HideEquipPopups()
                return true -- Assume success for fallback method
            end
        end

        -- ʕ •ᴥ•ʔ✿ Combat-specific retry logic ✿ ʕ •ᴥ•ʔ
        local equipSuccess = attemptEquip()

        if inCombat and not equipSuccess and CursorHasItem() then
            -- During combat, try one more time with a slight delay
            AH.Wait(0.1, function()
                if CursorHasItem() then
                    EquipCursorItem(targetSlotID)
                    if CursorHasItem() then
                        ClearCursor()
                    end
                end
            end)
        end

        -- Clean up any remaining cursor items
        if CursorHasItem() then
            ClearCursor()
        end
    end)

    if sckEventsTemporarilyUnregistered and _G["SCK"] and _G["SCK"].frame then
        _G["SCK"].frame:RegisterEvent('EQUIP_BIND_CONFIRM')
        _G["SCK"].frame:RegisterEvent('AUTOEQUIP_BIND_CONFIRM')
    end

    if not success then

        -- ʕ •ᴥ•ʔ✿ During combat, schedule a retry after a short delay ✿ ʕ •ᴥ•ʔ
        if inCombat and AttuneHelperDB["Auto Equip Attunable After Combat"] == 1 then
            AH.Wait(0.5, function()
                -- Don't retry if we've left combat or if item was already equipped
                if not InCombatLockdown() or (AH.sessionEquippedItems and AH.sessionEquippedItems[itemRecord.link]) then
                    return
                end
                AH.performEquipAction(itemRecord, targetSlotID, currentSlotNameForAction)
            end)
        end
    else
        -- ʕ●ᴥ●ʔ✿ Mark item as equipped this session ✿ ʕ●ᴥ●ʔ
        if AH.sessionEquippedItems then
            AH.sessionEquippedItems[itemRecord.link] = true
        end
        -- ʕ●ᴥ●ʔ✿ Refresh bag cache after successful equipment, with combat-aware delay ✿ ʕ●ᴥ●ʔ
        if inCombat then
            AH.Wait(0.1, function()
                AH.RefreshAllBagCaches()
            end)
        else
            AH.RefreshAllBagCaches()
        end
    end
    return success
end

_G.performEquipAction = AH.performEquipAction

------------------------------------------------------------------------
-- Helper: Hide equip popups
------------------------------------------------------------------------
function AH.HideEquipPopups()
    StaticPopup_Hide("EQUIP_BIND")
    StaticPopup_Hide("AUTOEQUIP_BIND")
    for i = 1, STATICPOPUP_NUMDIALOGS do
        local f = _G["StaticPopup" .. i]
        if f and f:IsVisible() then
            local w = f.which
            if w == "EQUIP_BIND" or w == "AUTOEQUIP_BIND" then
                f:Hide()
            end
        end
    end
end

_G.HideEquipPopups = AH.HideEquipPopups

------------------------------------------------------------------------
-- Get list of qualifying items for tooltips/UI
------------------------------------------------------------------------
function AH.GetAttunableItemNamesList()
    local itemData = {}
    if ItemLocIsLoaded() then
        local isStrictEquip = (AttuneHelperDB["EquipNewAffixesOnly"] == 1)
        for _, bagTbl in pairs(AH.bagSlotCache) do
            if bagTbl then
                for _, rec in pairs(bagTbl) do
                    if rec and rec.isAttunable then
                        local itemId = AH.GetItemIDFromLink(rec.link)
                        if itemId then
                            if AH.ItemQualifiesForBagEquip(itemId, rec.link, isStrictEquip) then
                                local tempRec = {
                                    link = rec.link,
                                    bag = rec.bag,
                                    slot = rec.slot
                                }
                                if AH.CanEquipItemPolicyCheck(tempRec) then
                                    table.insert(itemData, {
                                        name = rec.name or "Unknown Item",
                                        link = rec.link,
                                        id = itemId
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return itemData
end

_G.GetAttunableItemNamesList = AH.GetAttunableItemNamesList

------------------------------------------------------------------------
-- Main equip all logic - comprehensive equipment function
------------------------------------------------------------------------
function AH.EquipAllAttunables()
    if MerchantFrame and MerchantFrame:IsShown() then
        return
    end

    -- ʕ●ᴥ●ʔ✿ Combat lockdown handling - force bag cache refresh ✿ ʕ●ᴥ●ʔ
    local inCombat = InCombatLockdown()
    if inCombat then
        if AH.RefreshAllBagCaches then
            AH.RefreshAllBagCaches()
        end
        -- Small delay to ensure cache is current during combat
        AH.Wait(0.1, function()
        end)
    end

    -- ʕ●ᴥ●ʔ✿ Session protection - prevent re-equipping same item multiple times ✿ ʕ●ᴥ●ʔ
    local sessionEquippedItems = {}

    -- ʕ •ᴥ•ʔ✿ Only refresh if cache is stale (performance optimization) ✿ ʕ •ᴥ•ʔ
    if not AH.lastBagCacheRefresh or (GetTime() - AH.lastBagCacheRefresh) > 1.0 then
        AH.RefreshAllBagCaches()
        AH.lastBagCacheRefresh = GetTime()
    end

    -- ʕ●ᴥ●ʔ✿ Smart slot targeting - only check slots with items that actually qualify ✿ ʕ●ᴥ●ʔ
    local allSlotsList = { "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "WristSlot", "HandsSlot",
        "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "MainHandSlot",
        "SecondaryHandSlot", "RangedSlot" }

    local targetedSlots = {}
    local isEquipNewAffixesOnlyEnabled = (AttuneHelperDB["EquipNewAffixesOnly"] == 1)

    -- ʕ •ᴥ•ʔ✿ Check P2 (attunable) candidates that actually qualify ✿ ʕ •ᴥ•ʔ
    for _, bagTbl in pairs(AH.bagSlotCache) do
        if bagTbl then
            for _, rec in pairs(bagTbl) do
                if rec and rec.isAttunable then
                    local recItemId = AH.GetItemIDFromLink(rec.link)
                    if recItemId and AH.ItemQualifiesForBagEquip(recItemId, rec.link, isEquipNewAffixesOnlyEnabled) and AH.CanEquipItemPolicyCheck(rec) then
                        local candidateEquipLoc = rec.equipSlot
                        local unifiedSlots = AH.itemTypeToUnifiedSlot[candidateEquipLoc]
                        if unifiedSlots then
                            if type(unifiedSlots) == "string" then
                                targetedSlots[unifiedSlots] = true
                            elseif type(unifiedSlots) == "table" then
                                for _, slotName in ipairs(unifiedSlots) do
                                    targetedSlots[slotName] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- ʕ •ᴥ•ʔ✿ Check P3 (AHSet) candidates that exist and qualify ✿ ʕ •ᴥ•ʔ
    for itemName, targetSlot in pairs(AHSetList) do
        if targetSlot then
            -- Check if AHSet item exists in bags
            for _, bagTbl in pairs(AH.bagSlotCache) do
                if bagTbl then
                    for _, rec in pairs(bagTbl) do
                        if rec and rec.name == itemName and rec.inSet and AH.CanEquipItemPolicyCheck(rec) then
                            targetedSlots[targetSlot] = true
                            break
                        end
                    end
                end
            end
        end
    end

    -- Convert to sorted list for consistent processing order
    local slotsList = {}
    for _, slotName in ipairs(allSlotsList) do
        if targetedSlots[slotName] then
            table.insert(slotsList, slotName)
        end
    end

    if #slotsList == 0 then
        return
    end

    local twoHanderEquippedInMainHandThisEquipCycle = false

    -- ʕ •ᴥ•ʔ✿ Use optimized combat detection and throttling ✿ ʕ •ᴥ•ʔ
    local inCombat = AH.IsInCombatOptimized()
    local equipThrottle = AH.GetEquipThrottle()

    local function CanEquip2HInMainHandWithoutInterruptingOHAttunement()
        local ohLink = GetInventoryItemLink("player", GetInventorySlotInfo("SecondaryHandSlot"))
        if ohLink then
            local ohItemId = AH.GetItemIDFromLink(ohLink)
            if ohItemId then
                if AH.ItemIsActivelyLeveling(ohItemId, ohLink) then
                    return false
                end
            end
        end
        return true
    end

    -- ʕ •ᴥ•ʔ✿ Pass session protection to equipment functions ✿ ʕ •ᴥ•ʔ
    AH.sessionEquippedItems = sessionEquippedItems

    local function checkAndEquip(slotName)
        if AttuneHelperDB[slotName] == 1 then
            return
        end

        -- ʕ •ᴥ•ʔ✿ Check if we recently equipped something for this slot ✿ ʕ •ᴥ•ʔ
        local currentTime = GetTime()
        if recentlyEquippedItems[slotName] then
            local timeSinceEquip = currentTime - recentlyEquippedItems[slotName].time
            if timeSinceEquip < RECENTLY_EQUIPPED_TIMEOUT then
                return
            else
                -- Clean up old entry
                recentlyEquippedItems[slotName] = nil
            end
        end

        local currentMHLink_OverallCheck = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))
        local currentMHIs2H = false
        if currentMHLink_OverallCheck then
            -- ʕ •ᴥ•ʔ✿ Use cached GetItemInfo ✿ ʕ •ᴥ•ʔ
            local _, currentMHEquipLoc = GetCachedItemInfoForEquip(currentMHLink_OverallCheck)
            if currentMHEquipLoc == "INVTYPE_2HWEAPON" then
                currentMHIs2H = true
            end
        end

        if slotName == "SecondaryHandSlot" then
            if currentMHIs2H then
                return
            end
            if twoHanderEquippedInMainHandThisEquipCycle then
                return
            end
        end

        local invSlotID = GetInventorySlotInfo(slotName)
        local eqID = AH.slotNumberMapping[slotName] or invSlotID
        local equippedItemLink = GetInventoryItemLink("player", invSlotID)
        local isEquippedItemActivelyLevelingFlag = false
        local equippedItemName, equippedItemEquipLoc

        if equippedItemLink then
            local equippedItemId = AH.GetItemIDFromLink(equippedItemLink)
            -- ʕ •ᴥ•ʔ✿ Use cached GetItemInfo ✿ ʕ •ᴥ•ʔ
            equippedItemName, equippedItemEquipLoc = GetCachedItemInfoForEquip(equippedItemLink)
            if equippedItemId then

                -- ʕ •ᴥ•ʔ✿ Enhanced debugging for actively leveling check ✿ ʕ •ᴥ•ʔ
                if _G.CanAttuneItemHelper then
                    local canAttune = CanAttuneItemHelper(equippedItemId)
                end

                if _G.GetItemLinkAttuneProgress then
                    local progress = GetItemLinkAttuneProgress(equippedItemLink)
                end

                isEquippedItemActivelyLevelingFlag = AH.ItemIsActivelyLeveling(equippedItemId, equippedItemLink)
            end
        else
        end

        if isEquippedItemActivelyLevelingFlag then
            return
        end

        local candidates = AH.equipSlotCache[slotName] or {}
        local isEquipNewAffixesOnlyEnabled = (AttuneHelperDB["EquipNewAffixesOnly"] == 1)

        -- P2: Look for attunable items from bags, prioritized by forge level and progress
        local attunableCandidates = {}
        for _, rec in ipairs(candidates) do
            if rec.isAttunable then
                local recItemId = AH.GetItemIDFromLink(rec.link)
                if recItemId then
                    if AH.ItemQualifiesForBagEquip(recItemId, rec.link, isEquipNewAffixesOnlyEnabled) then
                        if AH.CanEquipItemPolicyCheck(rec) then
                            table.insert(attunableCandidates, rec)
                        else
                        end
                    end
                end
            end
        end

        -- Sort candidates by priority (higher forge level and lower progress first)
        table.sort(attunableCandidates, function(a, b)
            return AH.ShouldPrioritizeItem(a.link, b.link)
        end)

        -- Try to equip the best candidate
        for _, rec in ipairs(attunableCandidates) do
            local proceed = true

            -- ʕ •ᴥ•ʔ✿ Check weapon type restrictions ✿ ʕ •ᴥ•ʔ
            if not AH.IsWeaponTypeAllowed(rec.equipSlot, slotName) then
                proceed = false
                local weaponTypeName = AH.GetWeaponTypeDisplayName(rec.equipSlot)
            end

            if slotName == "MainHandSlot" and rec.equipSlot == "INVTYPE_2HWEAPON" then
                if not CanEquip2HInMainHandWithoutInterruptingOHAttunement() then
                    proceed = false
                end
            end
            if slotName == "SecondaryHandSlot" and AH.cannotEquipOffHandWeaponThisSession and AH.IsWeaponTypeForOffHandCheck(rec.equipSlot) then
                proceed = false
            end
            if proceed then
                local equipSuccess = AH.performEquipAction(rec, eqID, slotName)
                if equipSuccess then
                    -- ʕ •ᴥ•ʔ✿ Track this item as recently equipped ✿ ʕ •ᴥ•ʔ
                    recentlyEquippedItems[slotName] = {
                        time = GetTime(),
                        itemLink = rec.link,
                        type = "P2_Attunable"
                    }
                    -- ʕ •ᴥ•ʔ✿ Track combat equip for performance monitoring ✿ ʕ •ᴥ•ʔ
                    AH.TrackCombatEquip()
                    if rec.equipSlot == "INVTYPE_2HWEAPON" and (slotName == "MainHandSlot" or slotName == "RangedSlot") then
                        twoHanderEquippedInMainHandThisEquipCycle = true
                    end
                    -- ʕ●ᴥ●ʔ✿ Combat cooldown after successful equip ✿ ʕ●ᴥ●ʔ
                    if inCombat then
                        AH.Wait(equipThrottle, function() end)
                    end
                    return -- Only equip one item per slot per cycle
                elseif inCombat then
                    -- ʕ●ᴥ●ʔ✿ Combat equip failed - note for potential retry ✿ ʕ●ᴥ●ʔ
                    -- Small delay before trying next item in combat
                    AH.Wait(equipThrottle, function() end)
                end
            else
            end
        end

        -- P3: AHSet logic (main gear - only equip if no attunable items needed progress)

        -- ʕ●ᴥ●ʔ✿ Don't displace actively attuning items ✿ ʕ●ᴥ●ʔ
        if equippedItemID and AH.ItemIsActivelyLeveling(equippedItemID, equippedItemLink) then
            return
        end
        for _, rec_set in ipairs(candidates) do
            -- ʕ •ᴥ•ʔ✿ Use enhanced identifier for AHSet lookup ✿ ʕ •ᴥ•ʔ
            local identifier = AH.CreateItemIdentifier(rec_set.link, rec_set.name)
            local designatedSlotForCandidate = AHSetList[identifier] or AHSetList[rec_set.name] -- Fallback to name for compatibility
            if designatedSlotForCandidate == slotName then
                local candidateEquipLoc = rec_set.equipSlot
                local equipThisSetItem = false

                if slotName == "MainHandSlot" then
                    if candidateEquipLoc == "INVTYPE_WEAPON" or candidateEquipLoc == "INVTYPE_2HWEAPON" or candidateEquipLoc == "INVTYPE_WEAPONMAINHAND" then
                        equipThisSetItem = true
                    end
                elseif slotName == "SecondaryHandSlot" then
                    if not currentMHIs2H then
                        if candidateEquipLoc == "INVTYPE_WEAPON" or candidateEquipLoc == "INVTYPE_WEAPONOFFHAND" or candidateEquipLoc == "INVTYPE_SHIELD" or candidateEquipLoc == "INVTYPE_HOLDABLE" then
                            equipThisSetItem = true
                        end
                    end
                elseif slotName == "RangedSlot" then
                    if AH.tContains({ "INVTYPE_RANGED", "INVTYPE_THROWN", "INVTYPE_RELIC", "INVTYPE_WAND", "INVTYPE_RANGEDRIGHT" }, candidateEquipLoc) then
                        equipThisSetItem = true
                    end
                else
                    local unifiedCandidateSlot = AH.itemTypeToUnifiedSlot[candidateEquipLoc]
                    if (type(unifiedCandidateSlot) == "string" and unifiedCandidateSlot == slotName) or (type(unifiedCandidateSlot) == "table" and AH.tContains(unifiedCandidateSlot, slotName)) then
                        equipThisSetItem = true
                    end
                end

                if equipThisSetItem and AH.CanEquipItemPolicyCheck(rec_set) then
                    local proceed = true

                    -- ʕ●ᴥ●ʔ✿ Don't displace recently equipped attunable items ✿ ʕ●ᴥ●ʔ
                    if recentlyEquippedItems[slotName] and recentlyEquippedItems[slotName].type == "P2_Attunable" then
                        local timeSinceEquip = GetTime() - recentlyEquippedItems[slotName].time
                        if timeSinceEquip < 5.0 then
                            proceed = false
                        end
                    end

                    -- ʕ •ᴥ•ʔ✿ Check weapon type restrictions for AHSet items ✿ ʕ •ᴥ•ʔ
                    if not AH.IsWeaponTypeAllowed(rec_set.equipSlot, slotName) then
                        proceed = false
                        local weaponTypeName = AH.GetWeaponTypeDisplayName(rec_set.equipSlot)
                    end

                    if (slotName == "MainHandSlot" or slotName == "RangedSlot") and rec_set.equipSlot == "INVTYPE_2HWEAPON" then
                        if not CanEquip2HInMainHandWithoutInterruptingOHAttunement() then
                            proceed = false
                        end
                    end

                    if slotName == "SecondaryHandSlot" and AH.cannotEquipOffHandWeaponThisSession and AH.IsWeaponTypeForOffHandCheck(rec_set.equipSlot) then
                        proceed = false
                    end

                    if proceed then
                        local equipSuccess = AH.performEquipAction(rec_set, eqID, slotName)
                        if equipSuccess then
                            -- ʕ •ᴥ•ʔ✿ Track this item as recently equipped ✿ ʕ •ᴥ•ʔ
                            recentlyEquippedItems[slotName] = {
                                time = GetTime(),
                                itemLink = rec_set.link,
                                type = "P3_AHSet"
                            }
                            -- ʕ •ᴥ•ʔ✿ Track combat equip for performance monitoring ✿ ʕ •ᴥ•ʔ
                            AH.TrackCombatEquip()
                            if rec_set.equipSlot == "INVTYPE_2HWEAPON" and (slotName == "MainHandSlot" or slotName == "RangedSlot") then
                                twoHanderEquippedInMainHandThisEquipCycle = true
                            end
                            -- ʕ●ᴥ●ʔ✿ Combat cooldown after successful AHSet equip ✿ ʕ●ᴥ●ʔ
                            if inCombat then
                                AH.Wait(equipThrottle, function() end)
                            end
                            return -- Exit after successful equip
                        elseif inCombat then
                            -- ʕ●ᴥ●ʔ✿ Combat AHSet equip failed - note for potential retry ✿ ʕ●ᴥ●ʔ
                            -- Small delay before trying next AHSet item in combat
                            AH.Wait(equipThrottle, function() end)
                        end
                    end
                end
            end
        end
    end

    -- Use the appropriate throttle based on combat status
    for i, slotName_iter in ipairs(slotsList) do
        AH.Wait(equipThrottle * i, checkAndEquip, slotName_iter)
    end

    -- ʕ●ᴥ●ʔ✿ Post-equip combat handling ✿ ʕ●ᴥ●ʔ
    if inCombat then
        local finalDelay = equipThrottle * (#slotsList + 2)

        AH.Wait(finalDelay, function()
            -- Force a final bag cache refresh in combat to ensure consistency
            if AH.RefreshAllBagCaches then
                AH.RefreshAllBagCaches()
            end

            -- If still in combat and auto-equip is enabled, schedule a gentle retry
            if InCombatLockdown() and AttuneHelperDB["Auto Equip Attunable After Combat"] == 1 then
                AH.Wait(3.0, function()
                    if InCombatLockdown() then
                        AH.TriggerThrottledAutoEquip(0.5)
                    end
                end)
            end
        end)
    else
        -- ʕ●ᴥ●ʔ✿ Non-combat final cache refresh ✿ ʕ●ᴥ●ʔ
        local finalDelay = equipThrottle * (#slotsList + 1)
        AH.Wait(finalDelay, function()
            if AH.RefreshAllBagCaches then
                AH.RefreshAllBagCaches()
            end
        end)
    end
end

_G.EquipAllAttunables = AH.EquipAllAttunables

------------------------------------------------------------------------
-- Sort inventory functionality
------------------------------------------------------------------------
function AH.SortInventoryItems()

    -- ʕ •ᴥ•ʔ✿ Determine target bag based on user preference ✿ ʕ •ᴥ•ʔ
    local targetBag = (AttuneHelperDB["Use Bag 1 for Disenchant"] == 1) and 1 or 0
    local targetBagName = "bag " .. targetBag

    local readyForDisenchant, emptySlots, ignoredList = {}, {}, {}

    -- Build ignored list (case-insensitive)
    if AHIgnoreList then
        for name in pairs(AHIgnoreList) do
            ignoredList[string.lower(name)] = true
        end
    end

    -- Determine which bags to scan
    local bagsToScan = { 0, 1, 2, 3, 4 }
    local includeBankBags = false

    -- Check if bank is open (bank bags are 5-11 in WotLK)
    if BankFrame and BankFrame:IsShown() then
        for bankBag = 5, 11 do
            table.insert(bagsToScan, bankBag)
        end
        includeBankBags = true
        print("|cffffd200[Attune Helper]|r Bank is open - including bank bags in sort.")
    end

    -- Gather all items from equipment sets
    local setItems = {}
    local numSets = GetNumEquipmentSets()
    for i = 1, numSets do
        local name, icon, setID = GetEquipmentSetInfo(i)
        if setID then
            local itemIDs = GetEquipmentSetItemIDs(name)
            for slot, itemID in pairs(itemIDs) do
                if itemID and itemID > 0 then
                    setItems[itemID] = name
                end
            end
        end
    end

    -- Enhanced function to check if item is ready for disenchanting
    local function IsReadyForDisenchant(itemId, itemLink, itemName, bag, slot)
        if not itemId or not itemLink or not itemName then
            return false, "Missing item data"
        end

        -- Check 1: Must be Mythic
        if not AH.IsMythic(itemId) then
            return false, "Not mythic"
        end

        -- Check 2: Must not be part of an equipment set
        if setItems[itemId] then
            return false, "Part of equipment set: " .. setItems[itemId]
        end

        -- Check 3: Must not be in ignore list
        if ignoredList[string.lower(itemName)] then
            return false, "In AHIgnore list"
        end

        -- Check 4: Must not be in AHSet list
        if AHSetList and AHSetList[itemName] then
            return false, "In AHSet list"
        end

        -- Check 5: Must be soulbound
        local isSoulbound = false
        local tooltip = CreateFrame("GameTooltip", "AttuneHelperDisenchantBoundScan", UIParent, "GameTooltipTemplate")
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")

        if bag and slot then
            tooltip:SetBagItem(bag, slot)
        else
            tooltip:SetHyperlink(itemLink)
        end

        for i = 1, tooltip:NumLines() do
            local line = _G["AttuneHelperDisenchantBoundScanTextLeft" .. i]
            if line then
                local text = line:GetText()
                if text and string.find(text, ITEM_SOULBOUND, 1, true) then
                    isSoulbound = true
                    break
                end
            end
        end
        tooltip:Hide()

        if not isSoulbound then
            return false, "Not soulbound"
        end

        -- Check 6: Must be 100% attuned
        local progress = 0
        if _G.GetItemLinkAttuneProgress then
            local progressResult = GetItemLinkAttuneProgress(itemLink)
            if type(progressResult) == "number" then
                progress = progressResult
            else
                AH.print_debug_general("IsReadyForDisenchant: GetItemLinkAttuneProgress returned non-number for " ..
                    itemLink .. ": " .. tostring(progressResult))
                return false, "Cannot determine attunement progress"
            end
        else
            AH.print_debug_general("IsReadyForDisenchant: GetItemLinkAttuneProgress API not available for " .. itemLink)
            return false, "Attunement API not available"
        end

        if progress < 100 then
            return false, "Not fully attuned (" .. progress .. "%)"
        end

        return true, "Ready for disenchant"
    end

    -- Check for enough empty slots
    local emptyCount = 0
    for _, b in ipairs(bagsToScan) do
        for s = 1, GetContainerNumSlots(b) do
            if not GetContainerItemID(b, s) then
                emptyCount = emptyCount + 1
                table.insert(emptySlots, { b = b, s = s })
            end
        end
    end

    local requiredEmptySlots = includeBankBags and 16 or 8
    if emptyCount < requiredEmptySlots then
        print("|cffff0000[Attune Helper]|r Need at least " ..
            requiredEmptySlots .. " empty slots for sorting" .. (includeBankBags and " (including bank)" or "") .. ".")
        return
    end

    -- Track which slots in target bag will become available
    local availableTargetSlots = {}

    -- Scan all bags and categorize items
    for _, b in ipairs(bagsToScan) do
        for s = 1, GetContainerNumSlots(b) do
            local id = GetContainerItemID(b, s)
            if id then
                local link = GetContainerItemLink(b, s)
                local name = GetItemInfo(id)

                if link and name then
                    local isReady, reason = IsReadyForDisenchant(id, link, name, b, s)

                    if b == targetBag then
                        -- Items currently in target bag
                        if not isReady then
                            -- Non-disenchant-ready items in target bag (need to move out)
                            table.insert(availableTargetSlots, s)
                            AH.print_debug_general("Target " ..
                                targetBagName .. " item '" .. name .. "' will be moved out: " .. reason)
                        else
                            -- Disenchant-ready items already in target bag (leave them)
                            table.insert(readyForDisenchant,
                                { b = b, s = s, id = id, name = name, link = link, alreadyInTarget = true })
                            AH.print_debug_general("Target " ..
                                targetBagName .. " item '" .. name .. "' is ready for disenchant and staying in place")
                        end
                    else
                        -- Items in other bags
                        if isReady then
                            -- Items ready for disenchanting (need to move to target bag)
                            table.insert(readyForDisenchant,
                                { b = b, s = s, id = id, name = name, link = link, fromBank = (b >= 5) })
                            AH.print_debug_general("Found disenchant-ready item in bag " .. b .. ": " .. name)
                        else
                            AH.print_debug_general("Item '" .. name .. "' not ready for disenchant: " .. reason)
                        end
                    end
                end
            else
                -- Empty slots
                if b == targetBag then
                    table.insert(availableTargetSlots, s)
                end
            end
        end
    end

    -- Sort available target bag slots in ascending order
    table.sort(availableTargetSlots)

    local itemsFromBank = 0
    local itemsFromRegularBags = 0
    for _, item in ipairs(readyForDisenchant) do
        if not item.alreadyInTarget then
            if item.fromBank then
                itemsFromBank = itemsFromBank + 1
            else
                itemsFromRegularBags = itemsFromRegularBags + 1
            end
        end
    end

    print("|cffffd200[Attune Helper]|r Found " .. #readyForDisenchant .. " items ready for disenchanting" ..
        (itemsFromBank > 0 and " (" .. itemsFromBank .. " from bank, " .. itemsFromRegularBags .. " from regular bags)" or
            itemsFromRegularBags > 0 and " (" .. itemsFromRegularBags .. " from regular bags)" or "") .. ".")

    if #availableTargetSlots > 0 then
        print("|cffffd200[Attune Helper]|r Available " ..
            targetBagName .. " slots: " .. table.concat(availableTargetSlots, ", "))
    end

    -- Function to safely move items
    local function MoveItem(fromBag, fromSlot, toBag, toSlot)
        if GetContainerItemID(fromBag, fromSlot) then
            PickupContainerItem(fromBag, fromSlot)
            if GetContainerItemID(toBag, toSlot) then
                -- Target slot has item, need to swap
                PickupContainerItem(toBag, toSlot)
                PickupContainerItem(fromBag, fromSlot)
            else
                -- Target slot is empty
                PickupContainerItem(toBag, toSlot)
            end
        end
    end

    -- Step 1: Move non-disenchant-ready items out of target bag to make room
    local nonReadyMoved = 0
    for s = 1, GetContainerNumSlots(targetBag) do
        local id = GetContainerItemID(targetBag, s)
        if id then
            local link = GetContainerItemLink(targetBag, s)
            local name = GetItemInfo(id)

            if link and name then
                local isReady, reason = IsReadyForDisenchant(id, link, name, targetBag, s)
                if not isReady and #emptySlots > 0 then
                    local target = table.remove(emptySlots)
                    if target then
                        MoveItem(targetBag, s, target.b, target.s)
                        nonReadyMoved = nonReadyMoved + 1
                        print("|cffffd200[Attune Helper]|r Moved non-disenchant item from " ..
                            targetBagName .. ": " .. name .. " (" .. reason .. ")")
                    end
                end
            end
        end
    end

    -- Step 2: Move disenchant-ready items to target bag
    local disenchantItemsMoved = 0
    local slotIndex = 1

    for _, item in ipairs(readyForDisenchant) do
        if not item.alreadyInTarget and slotIndex <= #availableTargetSlots then
            local targetSlot = availableTargetSlots[slotIndex]
            MoveItem(item.b, item.s, targetBag, targetSlot)
            disenchantItemsMoved = disenchantItemsMoved + 1
            print("|cffffd200[Attune Helper]|r Moved disenchant-ready item to " ..
                targetBagName .. " slot " .. targetSlot .. ": " ..
                item.name .. (item.fromBank and " (from bank)" or ""))
            slotIndex = slotIndex + 1
        elseif not item.alreadyInTarget then
            print("|cffff0000[Attune Helper]|r No more available slots in " .. targetBagName .. " for: " .. item.name)
        end
    end

    print("|cffffd200[Attune Helper]|r Prepare Disenchant complete. Moved " .. disenchantItemsMoved ..
        " disenchant-ready items to " ..
        targetBagName ..
        (nonReadyMoved > 0 and ", moved " .. nonReadyMoved .. " other items out of " .. targetBagName or "") .. ".")

    if disenchantItemsMoved == 0 and #readyForDisenchant == 0 then
        print(
            "|cffffd200[Attune Helper]|r No items found that are 100% attuned, soulbound, mythic, and not in ignore/set lists.")
    end
end

------------------------------------------------------------------------
-- Update AHSet to current equiped items functionality
------------------------------------------------------------------------
function AH.SetAHSetToEquipped()
    AHSetList = {}
    print("|cffffd200[AttuneHelper]|r Deleted previous AHSetList Items.")

    local slotsList = { "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "WristSlot",
        "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "MainHandSlot",
        "SecondaryHandSlot", "RangedSlot" }
    local slotNumberMapping = { Finger0Slot = 11, Finger1Slot = 12, Trinket0Slot = 13, Trinket1Slot = 14, MainHandSlot = 16, SecondaryHandSlot = 17 }

    for i, slotName in ipairs(slotsList) do
        local eqID = GetInventoryItemID("player", i)
        if eqID then
            local equippedItemLink = GetInventoryItemLink("player", i)
            local equippedItemName = GetItemInfo(equippedItemLink)
            if equippedItemName then
                -- ʕ •ᴥ•ʔ✿ Use enhanced identifier for duplicate name handling ✿ ʕ •ᴥ•ʔ
                local identifier = AH.CreateItemIdentifier(equippedItemLink, equippedItemName)
                AHSetList[identifier] = slotName
                print("|cffffd200[AH]|r '" .. equippedItemName .. "' (ID: " .. (AH.GetItemIDFromLink(equippedItemLink) or "unknown") .. 
                    ") added to AHSet, designated for slot " .. slotName .. ".")
            end
        end
    end
end

------------------------------------------------------------------------
-- Toggle Auto-Equip functionality
------------------------------------------------------------------------
function AH.ToggleAutoEquip()
    AttuneHelperDB["Auto Equip Attunable After Combat"] = 1 - (AttuneHelperDB["Auto Equip Attunable After Combat"] or 0)
    print("|cffffd200[AH]|r Auto-Equip After Combat: " ..
        (AttuneHelperDB["Auto Equip Attunable After Combat"] == 1 and "|cff00ff00Enabled|r." or "|cffff0000Disabled|r."))
end

-- ʕ •ᴥ•ʔ✿ Enhanced combat performance optimizations ✿ ʕ •ᴥ•ʔ
AH.combatPerformance = AH.combatPerformance or {
    lastCombatCheck = 0,
    combatThrottle = 0.5,  -- Reduced from 1.0s to 0.5s
    nonCombatThrottle = 0.1, -- Reduced from 0.2s to 0.1s
    maxCombatEquips = 3,    -- Maximum equips per combat cycle
    combatEquipCount = 0,
    lastCombatEquipTime = 0
}

-- Enhanced combat detection with caching
function AH.IsInCombatOptimized()
    local currentTime = GetTime()
    if currentTime - AH.combatPerformance.lastCombatCheck > 0.1 then
        AH.combatPerformance.lastCombatCheck = currentTime
        AH.combatPerformance.inCombat = UnitAffectingCombat("player")
    end
    return AH.combatPerformance.inCombat
end

-- Enhanced equip throttling for combat
function AH.GetEquipThrottle()
    if AH.IsInCombatOptimized() then
        return AH.combatPerformance.combatThrottle
    else
        return AH.combatPerformance.nonCombatThrottle
    end
end

-- Combat-aware equip tracking
function AH.TrackCombatEquip()
    local currentTime = GetTime()
    AH.combatPerformance.combatEquipCount = AH.combatPerformance.combatEquipCount + 1
    AH.combatPerformance.lastCombatEquipTime = currentTime
    
    -- Reset counter if not in combat
    if not AH.IsInCombatOptimized() then
        AH.combatPerformance.combatEquipCount = 0
    end
end

-- Check if we should skip equip due to combat limits
function AH.ShouldSkipCombatEquip()
    if not AH.IsInCombatOptimized() then return false end
    
    local currentTime = GetTime()
    local timeSinceLastEquip = currentTime - AH.combatPerformance.lastCombatEquipTime
    
    -- Skip if we've hit the combat equip limit
    if AH.combatPerformance.combatEquipCount >= AH.combatPerformance.maxCombatEquips then
        return true
    end
    
    -- Skip if we're still in the throttle period
    if timeSinceLastEquip < AH.combatPerformance.combatThrottle then
        return true
    end
    
    return false
end

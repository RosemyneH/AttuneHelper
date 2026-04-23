-- ʕ •ᴥ•ʔ✿ Gameplay · Equip logic & policies ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper
local flags = AH.flags or {}

AH.synastriaDataReady = (GetCustomGameData(41, 0) ~= 0)

-- ʕ •ᴥ•ʔ✿ Recently equipped items tracking to prevent immediate re-equipping ✿ ʕ •ᴥ•ʔ
local recentlyEquippedItems = {}
local RECENTLY_EQUIPPED_TIMEOUT = 5.0 -- seconds
local attunableListCache = {
    generation = -1,
    strict = nil,
    timestamp = 0,
    data = {}
}
local ATTUNABLE_LIST_CACHE_TTL = 0.5

-- ʕ •ᴥ•ʔ✿ Cursor safety tooltip for disenchant preparation ✿ ʕ •ᴥ•ʔ
local AHDisenchantSafetyTooltip =
    CreateFrame("GameTooltip", "AHDisenchantSafetyTooltip", UIParent, "GameTooltipTemplate")
AHDisenchantSafetyTooltip:SetFrameStrata("TOOLTIP")
AHDisenchantSafetyTooltip:SetClampedToScreen(true)

local disenchantSafetyTooltipHideToken = 0

local function HideDisenchantSafetyTooltip()
    if AHDisenchantSafetyTooltip then
        AHDisenchantSafetyTooltip:Hide()
        AHDisenchantSafetyTooltip:ClearLines()
    end
end

local function ShowDisenchantSafetyTooltip(itemList, headerText, subtitleText)
    if not itemList or #itemList == 0 then
        return
    end

    disenchantSafetyTooltipHideToken = (disenchantSafetyTooltipHideToken or 0) + 1
    local token = disenchantSafetyTooltipHideToken

    HideDisenchantSafetyTooltip()
    AHDisenchantSafetyTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")

    local title = headerText or AH.t("Disenchant Bag Safety")
    AHDisenchantSafetyTooltip:SetText("|cffff4040" .. tostring(title) .. "|r")
    if subtitleText and subtitleText ~= "" then
        AHDisenchantSafetyTooltip:AddLine(tostring(subtitleText), 0.95, 0.95, 0.95, true)
    end
    AHDisenchantSafetyTooltip:AddLine(" ", 0.6, 0.6, 0.6, true)

    for _, item in ipairs(itemList) do
        if item and item.link and item.name then
            -- Safety tooltip: only show items that are actually unsafe/offending.
            if item.isUnsafe == true then
                local iconTex = item.texture

                if not iconTex then
                    local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(item.link)
                    if itemTexture then
                        iconTex = itemTexture
                    end
                end

                if not iconTex and item.b and item.s then
                    local _, _, _, _, _, _, _, _, _, containerTexture = GetContainerItemInfo(item.b, item.s)
                    if containerTexture then
                        iconTex = containerTexture
                    end
                end

                local iconText = iconTex and string.format("|T%s:14:14:0:0:64:64:4:60:4:60|t ", iconTex) or ""
                local displayName = iconText .. item.name

                if item.isAttunable then
                    displayName = displayName .. " |cffff0000ATTUNABLE|r"
                end

                local r, g, b = 1, 0.12, 0.12
                AHDisenchantSafetyTooltip:AddLine(displayName, r, g, b, true)
            end
        end
    end

    AHDisenchantSafetyTooltip:Show()

    if AH.Wait then
        AH.Wait(5, function()
            if token ~= disenchantSafetyTooltipHideToken then
                return
            end
            HideDisenchantSafetyTooltip()
        end)
    end
end

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

function AH.ClearRecentlyEquippedSlots()
    wipe(recentlyEquippedItems)
end

local function IsBaseVariantAttuned(itemId)
    if not itemId then
        return false
    end

    local hasBaseVariantFn = _G.HasAttunedVariantOfItem
    if type(hasBaseVariantFn) == "function" then
        local ok, result = pcall(hasBaseVariantFn, itemId, 0)
        if ok then
            return result == true or result == 1
        end
    end

    local hasAnyVariantFn = _G.HasAttunedAnyVariantOfItem
    if type(hasAnyVariantFn) == "function" then
        local ok, result = pcall(hasAnyVariantFn, itemId)
        if ok then
            return result == true or result == 1
        end
    end

    return false
end

------------------------------------------------------------------------
-- ʕ •ᴥ•ʔ✿ Weapon type checking functions ✿ ʕ •ᴥ•ʔ
------------------------------------------------------------------------
function AH.IsWeaponTypeAllowed(equipSlot, targetSlot)
    if not equipSlot or not targetSlot then return true end

    if targetSlot == "MainHandSlot" then
        -- ʕ •ᴥ•ʔ✿ Titan's Grip allows 2H in OH; it never blocks a 1H in MH.
        -- Gate by the user setting for both TG and non-TG warriors. ✿ ʕ •ᴥ•ʔ
        if equipSlot == "INVTYPE_WEAPON" or equipSlot == "INVTYPE_WEAPONMAINHAND" then
            return AH.GetWeaponControlSetting("Allow MainHand 1H Weapons") == 1
        end
        if equipSlot == "INVTYPE_2HWEAPON" then
            return AH.GetWeaponControlSetting("Allow MainHand 2H Weapons") == 1
        end
    elseif targetSlot == "SecondaryHandSlot" then
        -- Check 1H weapons
        if equipSlot == "INVTYPE_WEAPON" or equipSlot == "INVTYPE_WEAPONOFFHAND" then
            return AH.GetWeaponControlSetting("Allow OffHand 1H Weapons") == 1
        end
        -- Check 2H weapons (unusual but possible in some custom servers)
        if equipSlot == "INVTYPE_2HWEAPON" then
            return AH.GetWeaponControlSetting("Allow OffHand 2H Weapons") == 1
        end
        -- Check shields
        if equipSlot == "INVTYPE_SHIELD" then
            return AH.GetWeaponControlSetting("Allow OffHand Shields") == 1
        end
        -- Check holdables
        if equipSlot == "INVTYPE_HOLDABLE" then
            return AH.GetWeaponControlSetting("Allow OffHand Holdables") == 1
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
-- ʕ •ᴥ•ʔ✿ Build a policy-cache token that captures every input that can flip
-- the answer (bag generation, toggles, forge allowlist, synastria readiness).
-- When the token matches a rec's stored token we can skip the whole check. ✿ ʕ •ᴥ•ʔ
local function BuildPolicyToken()
    local allowed = AttuneHelperDB.AllowedForgeTypes or {}
    local mask = 0
    if allowed.BASE then mask = mask + 1 end
    if allowed.TITANFORGED then mask = mask + 2 end
    if allowed.WARFORGED then mask = mask + 4 end
    if allowed.LIGHTFORGED then mask = mask + 8 end
    return ((AH.bagCacheGeneration or 0))
        .. ":" .. tostring(AttuneHelperDB["Equip BoE Bountied Items"] or 0)
        .. ":" .. tostring(AttuneHelperDB["Disable Auto Equip 284 BoE Forges if Base Attuned"] or 0)
        .. ":" .. tostring(AttuneHelperDB["Disable Auto-Equip Mythic BoE"] or 0)
        .. ":" .. tostring(AH.synastriaDataReady and 1 or 0)
        .. ":" .. tostring(mask)
end

function AH.CanEquipItemPolicyCheck(candidateRec)
    if not candidateRec or not candidateRec.link then
        return false
    end

    if not AH.synastriaDataReady and GetCustomGameData(41, 0) ~= 0 then
        AH.synastriaDataReady = true
    end

    -- ʕ •ᴥ•ʔ✿ Skip all the work on repeat calls for the same rec within one
    -- equip cycle / settings snapshot. ✿ ʕ •ᴥ•ʔ
    local token = BuildPolicyToken()
    if candidateRec.policyToken == token then
        return candidateRec.policyResult
    end

    local itemLink = candidateRec.link
    local itemBag = candidateRec.bag
    local itemSlotInBag = candidateRec.slot
    local itemId = candidateRec.itemID or AH.GetItemIDFromLink(itemLink)

    local isSoulbound = candidateRec.isSoulbound
    if isSoulbound == nil then
        isSoulbound = AH.IsSoulboundFromNativeBagSlot(itemBag, itemSlotInBag) == true
    end
    local itemIsBoENotBound = not isSoulbound

    local result
    repeat
        if itemId then
            if itemIsBoENotBound then
                if not AH.synastriaDataReady and AttuneHelperDB["Equip BoE Bountied Items"] ~= 1 then
                    result = false
                    break
                end

                local bounty = candidateRec.bountyValue
                if bounty == nil and AH.synastriaDataReady then
                    local ok, v = pcall(GetCustomGameData, 31, itemId)
                    bounty = (ok and type(v) == "number") and v or 0
                end
                if AH.synastriaDataReady and (bounty or 0) > 0 and AttuneHelperDB["Equip BoE Bountied Items"] ~= 1 then
                    result = false
                    break
                end
            end

            local shouldBlockBoe284Forged = (AttuneHelperDB["Disable Auto Equip 284 BoE Forges if Base Attuned"] == 1)
            if shouldBlockBoe284Forged and itemIsBoENotBound then
                local currentForgeLevel = candidateRec.forgeLevel
                if currentForgeLevel == nil then
                    currentForgeLevel = AH.GetForgeLevelFromLink(itemLink)
                end
                if currentForgeLevel > AH.FORGE_LEVEL_MAP.BASE then
                    local _, _, _, iLvL = GetItemInfo(itemLink)
                    if iLvL == 284 and IsBaseVariantAttuned(itemId) then
                        result = false
                        break
                    end
                end
            end

            local isMythic = candidateRec.isMythic
            if isMythic == nil then
                isMythic = AH.IsMythic(itemId)
            end
            if AttuneHelperDB["Disable Auto-Equip Mythic BoE"] == 1 and isMythic and itemIsBoENotBound then
                result = false
                break
            end
        end

        local determinedForgeLevel = candidateRec.forgeLevel
        if determinedForgeLevel == nil then
            determinedForgeLevel = AH.GetForgeLevelFromLink(itemLink)
        end

        local allowedTypes = AttuneHelperDB.AllowedForgeTypes or {}
        if determinedForgeLevel == AH.FORGE_LEVEL_MAP.BASE and allowedTypes.BASE then
            result = true
            break
        end
        if determinedForgeLevel == AH.FORGE_LEVEL_MAP.TITANFORGED and allowedTypes.TITANFORGED then
            result = true
            break
        end
        if determinedForgeLevel == AH.FORGE_LEVEL_MAP.WARFORGED and allowedTypes.WARFORGED then
            result = true
            break
        end
        if determinedForgeLevel == AH.FORGE_LEVEL_MAP.LIGHTFORGED and allowedTypes.LIGHTFORGED then
            result = true
            break
        end
        result = false
    until true

    candidateRec.policyToken = token
    candidateRec.policyResult = result
    return result
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

    local didEquip = false
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
                        AH.Wait(0.05, function()
                            -- Find and click "Yes" button on any BoE popup
                            local popupClicked = false
                            for i = 1, STATICPOPUP_NUMDIALOGS do
                                if not popupClicked then
                                    local popup = _G["StaticPopup" .. i]
                                    if popup and popup:IsVisible() and (popup.which == "EQUIP_BIND" or popup.which == "AUTOEQUIP_BIND") then
                                        if popup.button1 and popup.button1:IsEnabled() then
                                            popup.button1:Click()
                                            popupClicked = true
                                        end
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

        didEquip = attemptEquip()

        -- Clean up any remaining cursor items
        if CursorHasItem() then
            ClearCursor()
        end
    end)

    if sckEventsTemporarilyUnregistered and _G["SCK"] and _G["SCK"].frame then
        _G["SCK"].frame:RegisterEvent('EQUIP_BIND_CONFIRM')
        _G["SCK"].frame:RegisterEvent('AUTOEQUIP_BIND_CONFIRM')
    end

    if didEquip then
        -- ʕ●ᴥ●ʔ✿ Mark item as equipped this session ✿ ʕ●ᴥ●ʔ
        if AH.sessionEquippedItems then
            AH.sessionEquippedItems[itemRecord.link] = true
        end
        -- ʕ •ᴥ•ʔ✿ Only refresh the bag we actually mutated; avoid a 5-bag rescan
        -- every slot.  BAG_UPDATE will follow up with the authoritative refresh. ✿ ʕ •ᴥ•ʔ
        if AH.UpdateBagCache and type(itemRecord.bag) == "number" then
            AH.UpdateBagCache(itemRecord.bag)
            if AH.RebuildEquipSlotCache and AH.equipSlotCacheDirty then
                AH.RebuildEquipSlotCache()
            end
        end
    end

    if not success then
        return false
    end

    return didEquip == true
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
    local currentGeneration = AH.bagCacheGeneration or 0
    local isStrictEquip = (AttuneHelperDB["EquipNewAffixesOnly"] == 1)
    local now = GetTime()

    if attunableListCache.generation == currentGeneration and
       attunableListCache.strict == isStrictEquip and
       (now - (attunableListCache.timestamp or 0)) < ATTUNABLE_LIST_CACHE_TTL then
        return attunableListCache.data
    end

    local itemData = {}
    if ItemLocIsLoaded() then
        for _, bagTbl in pairs(AH.bagSlotCache) do
            if bagTbl then
                for _, rec in pairs(bagTbl) do
                    if rec and rec.isAttunable then
                        local itemId = rec.itemID
                        if itemId then
                            if AH.ItemQualifiesForBagEquipRec(rec, isStrictEquip) then
                                if AH.CanEquipItemPolicyCheck(rec) then
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

    attunableListCache.generation = currentGeneration
    attunableListCache.strict = isStrictEquip
    attunableListCache.timestamp = now
    attunableListCache.data = itemData

    return itemData
end

_G.GetAttunableItemNamesList = AH.GetAttunableItemNamesList

-- ʕ •ᴥ•ʔ✿ AHSet 1H swap: warrior MC etc. — AH.AHSet1h2hMulticlassSwapPresetFlagActive in util (preset map inference) ✿ ʕ •ᴥ•ʔ
AH.AHSet1hSpecial2hSentinelActive = AH.AHSet1h2hMulticlassSwapPresetFlagActive

local function recDesignatedForSecondaryHand(rec)
    if not rec or not AHSetList then
        return false
    end
    local identifier = rec.identifier or AH.CreateItemIdentifier(rec.link, rec.name)
    local d = AHSetList[identifier] or AHSetList[rec.name]
    local prepOH = AH.AHSET_PREP_OFFHAND_SLOT or "PrepOffHandSlot"
    return d == "SecondaryHandSlot" or d == prepOH
end

local function recDesignatedForSecondaryHandExact(rec)
    if not rec or not AHSetList then
        return false
    end
    local identifier = rec.identifier or AH.CreateItemIdentifier(rec.link, rec.name)
    local d = AHSetList[identifier] or AHSetList[rec.name]
    return d == "SecondaryHandSlot"
end

local function recIsExplicitOffhandSetTarget(rec)
    if not rec or not rec.equipSlot then
        return false
    end

    local el = rec.equipSlot
    if el == "INVTYPE_WEAPONOFFHAND" or el == "INVTYPE_SHIELD" or el == "INVTYPE_HOLDABLE" then
        return true
    end

    if el == "INVTYPE_WEAPON" or el == "INVTYPE_WEAPONMAINHAND" or el == "INVTYPE_2HWEAPON" then
        -- Prep-swap should only consider real off-hand targets.
        -- If the item is mapped to PrepOffHandSlot, we prep-swap MH but do not equip OH.
        return recDesignatedForSecondaryHandExact(rec)
    end

    return false
end

local function bagTargetsOffHandOnly(rec)
    if not rec or not rec.equipSlot then
        return false
    end
    local el = rec.equipSlot
    if el == "INVTYPE_WEAPONOFFHAND" or el == "INVTYPE_SHIELD" or el == "INVTYPE_HOLDABLE" then
        return true
    end
    if el == "INVTYPE_WEAPON" or el == "INVTYPE_WEAPONMAINHAND" then
        if recDesignatedForSecondaryHand(rec) then
            return true
        end
        local mode = AH.AHSetInferredOhAttuneTriggerMode and AH.AHSetInferredOhAttuneTriggerMode() or (AH.AHSET_OH_TRIGGER_STRICT or 1)
        if mode >= (AH.AHSET_OH_TRIGGER_LOOSE or 2) then
            return true
        end
        return false
    end
    return false
end

local function findQualifyingOffhandBagRec(isEquipNewAffixesOnlyEnabled)
    for _, bagTbl in pairs(AH.bagSlotCache or {}) do
        if bagTbl then
            for _, rec in pairs(bagTbl) do
                if rec and bagTargetsOffHandOnly(rec) then
                    local rid = rec.itemID
                    if rec.isAttunable and rid and AH.ItemQualifiesForBagEquipRec(rec, isEquipNewAffixesOnlyEnabled) and AH.CanEquipItemPolicyCheck(rec) then
                        return rec
                    end
                    if rec.inSet and recIsExplicitOffhandSetTarget(rec) and AH.CanEquipItemPolicyCheck(rec) then
                        return rec
                    end
                end
            end
        end
    end
    return nil
end

-- Prep-swap gate for AHSet 2H -> 1H path.
-- IMPORTANT: this should only trigger if we have an explicit off-hand target to follow up with.
-- Otherwise we can end up equipping PrepMainHandSlot and never equipping OH.
local function findQualifyingOffhandBagRecForPrepSwap(isEquipNewAffixesOnlyEnabled)
    for _, bagTbl in pairs(AH.bagSlotCache or {}) do
        if bagTbl then
            for _, rec in pairs(bagTbl) do
                if rec and recIsExplicitOffhandSetTarget(rec) then
                    -- Mirror main equip restrictions so we don't prep-swap when OH can't be equipped.
                    if not AH.IsWeaponTypeAllowed(rec.equipSlot, "SecondaryHandSlot") then
                        -- Off-hand type not allowed by settings.
                    elseif AH.cannotEquipOffHandWeaponThisSession
                        and AH.IsWeaponTypeForOffHandCheck
                        and AH.IsWeaponTypeForOffHandCheck(rec.equipSlot)
                    then
                        -- Session restriction blocks off-hand weapon equips.
                    else
                    local rid = rec.itemID
                    if rec.isAttunable
                        and rid
                        and AH.ItemQualifiesForBagEquipRec(rec, isEquipNewAffixesOnlyEnabled)
                        and AH.CanEquipItemPolicyCheck(rec)
                        and (rec.equipSlot ~= "INVTYPE_2HWEAPON" or rec.isTGCompat2H)
                    then
                        return rec
                    end
                    end
                end
            end
        end
    end
    return nil
end

-- ʕ •ᴥ•ʔ✿ Find an AHSet item explicitly mapped to the PrepOffHandSlot paperdoll slot
-- that can be placed into SecondaryHandSlot. Used when a 2H -> 1H MH swap leaves the
-- off-hand empty and we want to auto-equip the prep off-hand follow-up. ✿ ʕ •ᴥ•ʔ
local function findAhsetPrepOffhandBagRec(isEquipNewAffixesOnlyEnabled)
    if type(AHSetList) ~= "table" then
        return nil
    end
    local prepOH = AH.AHSET_PREP_OFFHAND_SLOT or "PrepOffHandSlot"

    for _, bagTbl in pairs(AH.bagSlotCache or {}) do
        if bagTbl then
            for _, rec in pairs(bagTbl) do
                if rec and rec.inSet and rec.equipSlot then
                    local identifier = rec.identifier
                    local designated = AHSetList[identifier] or AHSetList[rec.name]
                    if designated == prepOH then
                        local el = rec.equipSlot
                        local fitsOH = (el == "INVTYPE_WEAPONOFFHAND"
                            or el == "INVTYPE_SHIELD"
                            or el == "INVTYPE_HOLDABLE"
                            or el == "INVTYPE_WEAPON")
                        if fitsOH and AH.IsWeaponTypeAllowed(el, "SecondaryHandSlot") then
                            local blockedBySession = AH.cannotEquipOffHandWeaponThisSession
                                and AH.IsWeaponTypeForOffHandCheck
                                and AH.IsWeaponTypeForOffHandCheck(el)
                            if not blockedBySession and AH.CanEquipItemPolicyCheck(rec) then
                                return rec
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function isOffHandSlotEmpty()
    local ohInvSlot = GetInventorySlotInfo("SecondaryHandSlot")
    if not ohInvSlot then
        return false
    end
    return GetInventoryItemLink("player", ohInvSlot) == nil
end

local function collectAhsetOneHandMainHandCandidates()
    local mainHandCandidates = {}
    local prepMainHandCandidates = {}
    if not AHSetList then
        return {}
    end
    for _, bagTbl in pairs(AH.bagSlotCache or {}) do
        if bagTbl then
            for _, rec in pairs(bagTbl) do
                if rec and rec.inSet then
                    local identifier = rec.identifier
                    local designated = AHSetList[identifier] or AHSetList[rec.name]
                    local prepMH = AH.AHSET_PREP_MAINHAND_SLOT or "PrepMainHandSlot"
                    if designated == "MainHandSlot" or designated == prepMH then
                        local el = rec.equipSlot
                        if el == "INVTYPE_WEAPON" or el == "INVTYPE_WEAPONMAINHAND" then
                            if AH.CanEquipItemPolicyCheck(rec) and AH.IsWeaponTypeAllowed(el, "MainHandSlot") then
                                if designated == "MainHandSlot" then
                                    table.insert(mainHandCandidates, rec)
                                else
                                    table.insert(prepMainHandCandidates, rec)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if #mainHandCandidates > 0 then
        return mainHandCandidates
    end
    return prepMainHandCandidates
end

function AH.TryPrepAhsetOneHandMainHandFromTwoHander()
    if not AH.AHSet1h2hMulticlassSwapPresetFlagActive() then
        return false
    end
    if InCombatLockdown() then
        return false
    end
    if AttuneHelperDB["MainHandSlot"] == 1 then
        return false
    end

    local mhLink = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))
    if not mhLink then
        return false
    end
    local _, mhEquip = GetCachedItemInfoForEquip(mhLink)
    if mhEquip ~= "INVTYPE_2HWEAPON" then
        return false
    end

    local mhId = AH.GetItemIDFromLink(mhLink)
    if mhId and AH.ItemIsActivelyLeveling(mhId, mhLink) then
        return false
    end

    local cands = collectAhsetOneHandMainHandCandidates()
    if #cands == 0 then
        return false
    end

    -- ʕ •ᴥ•ʔ✿ TG play is 2H MH + TG 2H or 1H axe OH; keep that unless MH-only 1H (cannot use OH). ✿ ʕ •ᴥ•ʔ
    local tgMhOnlyPrepSwap = false
    if AH.PlayerHasTitansGrip and AH.PlayerHasTitansGrip() then
        local mhOnly = {}
        for _, rec in ipairs(cands) do
            if rec.equipSlot == "INVTYPE_WEAPONMAINHAND" then
                table.insert(mhOnly, rec)
            end
        end
        if #mhOnly == 0 then
            return false
        end
        cands = mhOnly
        tgMhOnlyPrepSwap = true
    end

    local isStrict = (AttuneHelperDB["EquipNewAffixesOnly"] == 1)
    local prepOhCandidate = nil
    if not tgMhOnlyPrepSwap then
        if not findQualifyingOffhandBagRecForPrepSwap(isStrict) then
            -- ʕ •ᴥ•ʔ✿ Allow the 2H -> 1H MH swap when the off-hand is empty and we have a
            -- PrepOffHandSlot AHSet item queued up, so the user can transition into their
            -- 1H + prep OH setup in one click. Require that prep piece actually needs attune
            -- from bags — otherwise we yo-yo 2H <-> prep when prep is idle or already done. ✿ ʕ •ᴥ•ʔ
            if isOffHandSlotEmpty() and AttuneHelperDB["SecondaryHandSlot"] ~= 1 then
                prepOhCandidate = findAhsetPrepOffhandBagRec(isStrict)
                if prepOhCandidate then
                    local prid = prepOhCandidate.itemID
                    if not (prid and prepOhCandidate.isAttunable and AH.ItemQualifiesForBagEquipRec(prepOhCandidate, isStrict)) then
                        prepOhCandidate = nil
                    end
                end
            end
            if not prepOhCandidate then
                return false
            end
        end
    end

    table.sort(cands, function(a, b)
        return AH.ShouldPrioritizeItem(a.link, b.link)
    end)

    local invSlotID = GetInventorySlotInfo("MainHandSlot")
    local eqID = AH.slotNumberMapping["MainHandSlot"] or invSlotID
    for _, rec in ipairs(cands) do
        if AH.performEquipAction(rec, eqID, "MainHandSlot") then
            if AH.TryEquipAhsetPrepOffHandIfEmpty then
                AH.TryEquipAhsetPrepOffHandIfEmpty()
            end
            return true
        end
    end
    return false
end

local function GetAttuneProgressForLink(itemLink)
    if not itemLink or not _G.GetItemLinkAttuneProgress then
        return nil
    end
    local p = GetItemLinkAttuneProgress(itemLink)
    if type(p) ~= "number" then
        return nil
    end
    return p
end

local function IsAttunableFullyAttuned(itemLink)
    if not itemLink then
        return false
    end
    local itemId = AH.GetItemIDFromLink(itemLink)
    if not itemId then
        return false
    end
    if not _G.CanAttuneItemHelper or CanAttuneItemHelper(itemId) ~= 1 then
        return false
    end
    local progress = GetAttuneProgressForLink(itemLink)
    return progress ~= nil and progress >= 100
end

-- ʕ •ᴥ•ʔ✿ When the off-hand slot is empty, equip the AHSet PrepOffHandSlot item.
-- Called after a 2H -> 1H MH swap so the prep off-hand follows the main-hand change. ✿ ʕ •ᴥ•ʔ
function AH.TryEquipAhsetPrepOffHandIfEmpty()
    if InCombatLockdown() then
        return false
    end
    if AttuneHelperDB["SecondaryHandSlot"] == 1 then
        return false
    end
    if not isOffHandSlotEmpty() then
        return false
    end

    -- ʕ •ᴥ•ʔ✿ Don't try to place an OH while a 2H is still in main hand without TG. ✿ ʕ •ᴥ•ʔ
    local mhSlotId = GetInventorySlotInfo("MainHandSlot")
    local mhLink = mhSlotId and GetInventoryItemLink("player", mhSlotId) or nil
    if mhLink then
        local _, mhEquip = GetCachedItemInfoForEquip(mhLink)
        if mhEquip == "INVTYPE_2HWEAPON"
            and not (AH.MhLinkAllowsTitansGripStyleOffhandPairing and AH.MhLinkAllowsTitansGripStyleOffhandPairing(mhLink))
        then
            return false
        end
    end

    local isStrict = (AttuneHelperDB["EquipNewAffixesOnly"] == 1)
    local rec = findAhsetPrepOffhandBagRec(isStrict)
    if not rec then
        return false
    end

    local invSlotID = GetInventorySlotInfo("SecondaryHandSlot")
    local eqID = AH.slotNumberMapping["SecondaryHandSlot"] or invSlotID
    if not eqID then
        return false
    end

    return AH.performEquipAction(rec, eqID, "SecondaryHandSlot") == true
end

-- ʕ •ᴥ•ʔ✿ If the equipped OH just finished attuning (100%) while the MH is still
-- actively leveling, swap the OH back to the AHSet PrepOffHandSlot item so the
-- done OH goes to the bag and the user's default OH returns while MH keeps leveling. ✿ ʕ •ᴥ•ʔ
function AH.TrySwapFinishedOffHandToPrepOH()
    if InCombatLockdown() then
        return false
    end
    if AttuneHelperDB["SecondaryHandSlot"] == 1 then
        return false
    end

    local ohSlotId = GetInventorySlotInfo("SecondaryHandSlot")
    if not ohSlotId then
        return false
    end
    local ohLink = GetInventoryItemLink("player", ohSlotId)
    if not ohLink then
        return false
    end

    if not IsAttunableFullyAttuned(ohLink) then
        return false
    end

    local mhSlotId = GetInventorySlotInfo("MainHandSlot")
    local mhLink = mhSlotId and GetInventoryItemLink("player", mhSlotId) or nil
    if not mhLink then
        return false
    end
    local mhId = AH.GetItemIDFromLink(mhLink)
    if not mhId or not AH.ItemIsActivelyLeveling(mhId, mhLink) then
        return false
    end

    local _, mhEquip = GetCachedItemInfoForEquip(mhLink)
    if mhEquip == "INVTYPE_2HWEAPON"
        and not (AH.MhLinkAllowsTitansGripStyleOffhandPairing and AH.MhLinkAllowsTitansGripStyleOffhandPairing(mhLink))
    then
        return false
    end

    local isStrict = (AttuneHelperDB["EquipNewAffixesOnly"] == 1)
    local rec = findAhsetPrepOffhandBagRec(isStrict)
    if not rec then
        return false
    end
    if rec.link == ohLink then
        return false
    end

    local eqID = AH.slotNumberMapping["SecondaryHandSlot"] or ohSlotId
    return AH.performEquipAction(rec, eqID, "SecondaryHandSlot") == true
end

------------------------------------------------------------------------
-- Main equip all logic - comprehensive equipment function
------------------------------------------------------------------------
-- ʕ •ᴥ•ʔ✿ Coalesce spam clicks: only let one equip cycle run at a time.
-- Subsequent clicks while a cycle is pending are no-ops so we don't re-scan
-- every bag and re-queue 17 slot checks per click. ✿ ʕ •ᴥ•ʔ
AH.equipCycleInFlight = false
AH.lastEquipCycleStart = 0
local EQUIP_CYCLE_MIN_SPACING = 0.25

function AH.EquipAllAttunables()
    if AH.IsVendorWindowOpen and AH.IsVendorWindowOpen() then
        return
    end

    local now = GetTime()
    if AH.equipCycleInFlight then
        return
    end
    if (now - (AH.lastEquipCycleStart or 0)) < EQUIP_CYCLE_MIN_SPACING then
        return
    end
    AH.equipCycleInFlight = true
    AH.lastEquipCycleStart = now

    -- ʕ●ᴥ●ʔ✿ Session protection - prevent re-equipping same item multiple times ✿ ʕ●ᴥ●ʔ
    local sessionEquippedItems = {}

    -- ʕ •ᴥ•ʔ✿ If TryPrep just pulled AHSet 2H down to 1H, block re-equipping any 2H to MH
    -- for the rest of this same EquipAllAttunables cycle (avoids 2H→prep→2H ping-pong). ✿ ʕ •ᴥ•ʔ
    local blockTwoHandMainHandAfterPrepDownswapThisCycle = false

    -- ʕ •ᴥ•ʔ✿ Clear the session-wide OH weapon block when the reason is gone
    -- (MH is no longer a non-TG 2H), so new equip attempts get a fresh chance. ✿ ʕ •ᴥ•ʔ
    if AH.cannotEquipOffHandWeaponThisSession then
        local mhSlotIdForReset = GetInventorySlotInfo("MainHandSlot")
        local mhLinkForReset = mhSlotIdForReset and GetInventoryItemLink("player", mhSlotIdForReset) or nil
        local mhIs2HForReset = false
        if mhLinkForReset then
            local _, _, _, _, _, _, _, _, mhElForReset = GetItemInfo(mhLinkForReset)
            if mhElForReset == "INVTYPE_2HWEAPON" then
                mhIs2HForReset = true
            end
        end
        local hasTgForReset = AH.PlayerHasTitansGrip and AH.PlayerHasTitansGrip()
        if hasTgForReset or not mhIs2HForReset then
            AH.cannotEquipOffHandWeaponThisSession = false
        end
    end

    -- ʕ •ᴥ•ʔ✿ Only rescan all 5 bags if the cache is actually stale. BAG_UPDATE
    -- already refreshes it whenever inventory changes, so repeat clicks within
    -- a second can skip this entirely. ✿ ʕ •ᴥ•ʔ
    if AH.RefreshAllBagCachesIfStale then
        AH.RefreshAllBagCachesIfStale(1.0)
    elseif AH.RefreshAllBagCaches then
        AH.RefreshAllBagCaches()
    end

    if AH.TryPrepAhsetOneHandMainHandFromTwoHander then
        local didPrepMainHandSwap = AH.TryPrepAhsetOneHandMainHandFromTwoHander()
        if didPrepMainHandSwap then
            blockTwoHandMainHandAfterPrepDownswapThisCycle = true
            if AH.RefreshAllBagCaches then
                AH.RefreshAllBagCaches()
            end
        end
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
                    local recItemId = rec.itemID
                    if recItemId and AH.ItemQualifiesForBagEquipRec(rec, isEquipNewAffixesOnlyEnabled) and AH.CanEquipItemPolicyCheck(rec) then
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
    local prepOHSlotKey = AH.AHSET_PREP_OFFHAND_SLOT or "PrepOffHandSlot"
    for setKey, targetSlot in pairs(AHSetList) do
        local resolvedTarget = targetSlot
        if resolvedTarget == prepOHSlotKey then
            resolvedTarget = "SecondaryHandSlot"
        end
        if resolvedTarget and AH.tContains(AH.allInventorySlots, resolvedTarget) then
            local p3Matched = false
            for _, bagTbl in pairs(AH.bagSlotCache) do
                if bagTbl and not p3Matched then
                    for _, rec in pairs(bagTbl) do
                        if not p3Matched and rec and rec.inSet then
                            local recIdentifier = rec.identifier
                            if (setKey == recIdentifier or setKey == rec.name) and AH.CanEquipItemPolicyCheck(rec) then
                                targetedSlots[resolvedTarget] = true
                                p3Matched = true
                            end
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
        AH.equipCycleInFlight = false
        return
    end

    -- ʕ •ᴥ•ʔ✿ When OH is empty but MH holds a 1H, equip OH before MH so a generic
    -- INVTYPE_WEAPON attunable fills the empty OH instead of displacing the current MH. ✿ ʕ •ᴥ•ʔ
    if targetedSlots["MainHandSlot"] and targetedSlots["SecondaryHandSlot"] then
        local mhInvSlot = GetInventorySlotInfo("MainHandSlot")
        local ohInvSlot = GetInventorySlotInfo("SecondaryHandSlot")
        local mhLinkForOrder = mhInvSlot and GetInventoryItemLink("player", mhInvSlot) or nil
        local ohLinkForOrder = ohInvSlot and GetInventoryItemLink("player", ohInvSlot) or nil
        local mhIs2HForOrder = false
        if mhLinkForOrder then
            local _, mhEquipLocForOrder = GetCachedItemInfoForEquip(mhLinkForOrder)
            if mhEquipLocForOrder == "INVTYPE_2HWEAPON" then
                mhIs2HForOrder = true
            end
        end

        if mhLinkForOrder and not ohLinkForOrder and not mhIs2HForOrder
            and AttuneHelperDB["SecondaryHandSlot"] ~= 1
        then
            local mhIndex, ohIndex
            for i, name in ipairs(slotsList) do
                if name == "MainHandSlot" then mhIndex = i end
                if name == "SecondaryHandSlot" then ohIndex = i end
            end
            if mhIndex and ohIndex and ohIndex > mhIndex then
                table.remove(slotsList, ohIndex)
                table.insert(slotsList, mhIndex, "SecondaryHandSlot")
            end
        end
    end

    local twoHanderEquippedInMainHandThisEquipCycle = false

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

        if blockTwoHandMainHandAfterPrepDownswapThisCycle then
            return false
        end

        -- ʕ •ᴥ•ʔ✿ Multiclass: defer 2H MH while an OH is equipped and still needs attune,
        -- if bags still imply an OH attune pipeline. Empty OH: never defer here (bag-only
        -- queue was incorrectly blocking polearm / other 2H MH swaps). ✿ ʕ •ᴥ•ʔ
        if AttuneHelperDB and AttuneHelperDB["SecondaryHandSlot"] ~= 1
            and AH.AHSet1h2hMulticlassSwapPresetFlagActive
            and AH.AHSet1h2hMulticlassSwapPresetFlagActive()
            and not (AH.PlayerHasTitansGrip and AH.PlayerHasTitansGrip())
        then
            local strict = (AttuneHelperDB["EquipNewAffixesOnly"] == 1)
            if ohLink and findQualifyingOffhandBagRec(strict) then
                if not IsAttunableFullyAttuned(ohLink) then
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
            local _, currentMHEquipLoc = GetCachedItemInfoForEquip(currentMHLink_OverallCheck)
            if currentMHEquipLoc == "INVTYPE_2HWEAPON" then
                currentMHIs2H = true
            end
        end
        local mhAllowsTgStyleOhPairing = AH.MhLinkAllowsTitansGripStyleOffhandPairing
            and AH.MhLinkAllowsTitansGripStyleOffhandPairing(currentMHLink_OverallCheck)

        if slotName == "SecondaryHandSlot" then
            if currentMHIs2H and not mhAllowsTgStyleOhPairing then
                return
            end
            if twoHanderEquippedInMainHandThisEquipCycle and not AH.PlayerHasTitansGrip() then
                return
            end
        end

        local invSlotID = GetInventorySlotInfo(slotName)
        local eqID = AH.slotNumberMapping[slotName] or invSlotID
        local equippedItemLink = GetInventoryItemLink("player", invSlotID)
        local isEquippedItemActivelyLevelingFlag = false
        local equippedItemName, equippedItemEquipLoc
        local equippedItemId = nil

        if equippedItemLink then
            equippedItemId = AH.GetItemIDFromLink(equippedItemLink)
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
                local recItemId = rec.itemID
                if recItemId then
                    if AH.ItemQualifiesForBagEquipRec(rec, isEquipNewAffixesOnlyEnabled) then
                        if AH.CanEquipItemPolicyCheck(rec) then
                            table.insert(attunableCandidates, rec)
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
            if proceed and slotName == "SecondaryHandSlot" and rec.equipSlot == "INVTYPE_2HWEAPON" then
                if not rec.isTGCompat2H then
                    proceed = false
                end
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
                    AH.TrackCombatEquip()
                    if rec.equipSlot == "INVTYPE_2HWEAPON" and (slotName == "MainHandSlot" or slotName == "RangedSlot") then
                        twoHanderEquippedInMainHandThisEquipCycle = true
                    end
                    return -- Only equip one item per slot per cycle
                end
            else
            end
        end

        -- P3: AHSet logic (main gear - only equip if no attunable items needed progress)

        -- ʕ●ᴥ●ʔ✿ Don't displace actively attuning items ✿ ʕ●ᴥ●ʔ
        if equippedItemId and AH.ItemIsActivelyLeveling(equippedItemId, equippedItemLink) then
            return
        end
        for _, rec_set in ipairs(candidates) do
            -- ʕ •ᴥ•ʔ✿ Use pre-cached rec identifier for AHSet lookup ✿ ʕ •ᴥ•ʔ
            local identifier = rec_set.identifier
            local designatedSlotForCandidate = AHSetList[identifier] or AHSetList[rec_set.name]
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
                        elseif candidateEquipLoc == "INVTYPE_2HWEAPON" and AH.GetWeaponControlSetting("Allow OffHand 2H Weapons") == 1 and AH.PlayerHasTitansGrip() and rec_set.isTGCompat2H then
                            equipThisSetItem = true
                        end
                    elseif currentMHIs2H and candidateEquipLoc == "INVTYPE_2HWEAPON" and AH.GetWeaponControlSetting("Allow OffHand 2H Weapons") == 1 and AH.PlayerHasTitansGrip() and rec_set.isTGCompat2H then
                        equipThisSetItem = true
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
                            AH.TrackCombatEquip()
                            if rec_set.equipSlot == "INVTYPE_2HWEAPON" and (slotName == "MainHandSlot" or slotName == "RangedSlot") then
                                twoHanderEquippedInMainHandThisEquipCycle = true
                            end
                            return -- Exit after successful equip
                        end
                    end
                end
            end
        end

        -- ʕ •ᴥ•ʔ✿ Off-hand fallback. Covers two cases:
        --  1. OH slot is empty → equip the AHSet PrepOffHandSlot item (covers 2H->1H
        --     MH swaps that happen outside TryPrepAhsetOneHandMainHandFromTwoHander).
        --  2. OH is a fully-attuned (100%) attunable and the MH is still actively
        --     leveling → swap the OH back to the prep OH so the done item returns to
        --     bags while the MH keeps attuning. ✿ ʕ •ᴥ•ʔ
        if slotName == "SecondaryHandSlot"
            and AttuneHelperDB["SecondaryHandSlot"] ~= 1
            and not currentMHIs2H
            and not (twoHanderEquippedInMainHandThisEquipCycle and not AH.PlayerHasTitansGrip())
        then
            local prepOhHandled = false
            if AH.TryEquipAhsetPrepOffHandIfEmpty and AH.TryEquipAhsetPrepOffHandIfEmpty() then
                prepOhHandled = true
            elseif AH.TrySwapFinishedOffHandToPrepOH and AH.TrySwapFinishedOffHandToPrepOH() then
                prepOhHandled = true
            end
            if prepOhHandled then
                recentlyEquippedItems[slotName] = {
                    time = GetTime(),
                    itemLink = nil,
                    type = "P3_AHSet_PrepOH"
                }
                AH.TrackCombatEquip()
            end
        end
    end

    -- Use the appropriate throttle based on combat status
    for i, slotName_iter in ipairs(slotsList) do
        AH.Wait(equipThrottle * i, checkAndEquip, slotName_iter)
    end

    local finalDelay = equipThrottle * (#slotsList + 1)
    AH.Wait(finalDelay, function()
        -- ʕ •ᴥ•ʔ✿ performEquipAction already refreshes each bag it touches and
        -- BAG_UPDATE fires from the game for the equip swap itself, so a full
        -- rescan here is redundant unless nothing has refreshed in a while. ✿ ʕ •ᴥ•ʔ
        if AH.RefreshAllBagCachesIfStale then
            AH.RefreshAllBagCachesIfStale(1.0)
        elseif AH.RefreshAllBagCaches then
            AH.RefreshAllBagCaches()
        end
        AH.equipCycleInFlight = false
    end)
end

_G.EquipAllAttunables = AH.EquipAllAttunables

function AH.EquipAHSetOnly()
    if AH.IsVendorWindowOpen and AH.IsVendorWindowOpen() then
        return
    end
    if type(AHSetList) ~= "table" then
        return
    end

    if AH.RefreshAllBagCachesIfStale then
        AH.RefreshAllBagCachesIfStale(1.0)
    elseif AH.RefreshAllBagCaches then
        AH.RefreshAllBagCaches()
    end

    if AH.TryPrepAhsetOneHandMainHandFromTwoHander then
        local didPrepMainHandSwap = AH.TryPrepAhsetOneHandMainHandFromTwoHander()
        if didPrepMainHandSwap and AH.RefreshAllBagCaches then
            AH.RefreshAllBagCaches()
        end
    end

    local slotsList = {
        "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "WristSlot", "HandsSlot",
        "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot",
        "MainHandSlot", "SecondaryHandSlot", "RangedSlot"
    }

    local function canCandidateEquipSlot(slotName, equipLoc, currentMHLink, candidateLink)
        if slotName == "MainHandSlot" then
            if equipLoc ~= "INVTYPE_WEAPON" and equipLoc ~= "INVTYPE_2HWEAPON" and equipLoc ~= "INVTYPE_WEAPONMAINHAND" then
                return false
            end
            return AH.IsWeaponTypeAllowed(equipLoc, slotName)
        end
        if slotName == "SecondaryHandSlot" then
            if not (AH.MhLinkAllowsTitansGripStyleOffhandPairing and AH.MhLinkAllowsTitansGripStyleOffhandPairing(currentMHLink)) then
                return false
            end
            local mhEl = currentMHLink and select(9, GetItemInfo(currentMHLink)) or nil
            local mhIs2h = mhEl == "INVTYPE_2HWEAPON"
            if mhIs2h then
                if AH.PlayerHasTitansGrip() and equipLoc == "INVTYPE_2HWEAPON" and AH.GetWeaponControlSetting("Allow OffHand 2H Weapons") == 1 and candidateLink and AH.IsTitansGripCompatibleTwoHandWeaponByLink(candidateLink) then
                    return true
                end
                return false
            end
            if equipLoc == "INVTYPE_2HWEAPON" then
                return AH.GetWeaponControlSetting("Allow OffHand 2H Weapons") == 1
                    and AH.PlayerHasTitansGrip()
                    and candidateLink
                    and AH.IsTitansGripCompatibleTwoHandWeaponByLink(candidateLink)
            end
            if equipLoc == "INVTYPE_WEAPON" or equipLoc == "INVTYPE_WEAPONOFFHAND" or equipLoc == "INVTYPE_SHIELD" or equipLoc == "INVTYPE_HOLDABLE" then
                return AH.IsWeaponTypeAllowed(equipLoc, slotName)
            end
            return false
        end
        if slotName == "RangedSlot" then
            return AH.tContains({ "INVTYPE_RANGED", "INVTYPE_THROWN", "INVTYPE_RELIC", "INVTYPE_WAND", "INVTYPE_RANGEDRIGHT" }, equipLoc)
        end
        local unifiedCandidateSlot = AH.itemTypeToUnifiedSlot[equipLoc]
        if type(unifiedCandidateSlot) == "string" then
            return unifiedCandidateSlot == slotName
        end
        if type(unifiedCandidateSlot) == "table" then
            return AH.tContains(unifiedCandidateSlot, slotName)
        end
        return false
    end

    local equipThrottle = AH.GetEquipThrottle and AH.GetEquipThrottle() or 0.1
    local equipCount = 0
    local foundAnyAHSetCandidate = false

    for i, slotName in ipairs(slotsList) do
        AH.Wait(equipThrottle * i, function(targetSlot)
            local invSlotID = GetInventorySlotInfo(targetSlot)
            if not invSlotID then
                return
            end
            local eqID = AH.slotNumberMapping[targetSlot] or invSlotID

            local currentMHLink = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))

            local chosenCandidate = nil
            for _, bagTbl in pairs(AH.bagSlotCache or {}) do
                if bagTbl and not chosenCandidate then
                    for _, rec in pairs(bagTbl) do
                        if not chosenCandidate and rec then
                            local identifier = rec.identifier
                            local designatedSlot = AHSetList[identifier] or AHSetList[rec.name]
                            if designatedSlot == targetSlot and canCandidateEquipSlot(targetSlot, rec.equipSlot, currentMHLink, rec.link) then
                                chosenCandidate = rec
                                foundAnyAHSetCandidate = true
                            end
                        end
                    end
                end
            end

            if chosenCandidate and AH.performEquipAction(chosenCandidate, eqID, targetSlot) then
                equipCount = equipCount + 1
            end
        end, slotName)
    end

    AH.Wait(equipThrottle * (#slotsList + 1), function()
        if not foundAnyAHSetCandidate then
            print("|cffffd200[AttuneHelper]|r No AHSet items found in your bags.")
            return
        end
        if equipCount == 0 then
            print("|cffffd200[AttuneHelper]|r AHSet equip attempted, but no items were equipped.")
        else
            print("|cffffd200[AttuneHelper]|r Equipped " .. tostring(equipCount) .. " AHSet item(s).")
        end
    end)
end

------------------------------------------------------------------------
-- Sort inventory functionality
------------------------------------------------------------------------
function AH.SortInventoryItems()
    -- ʕ •ᴥ•ʔ✿ Clear previous sort warning tooltip before starting a new pass. ✿ ʕ •ᴥ•ʔ
    disenchantSafetyTooltipHideToken = (disenchantSafetyTooltipHideToken or 0) + 1
    HideDisenchantSafetyTooltip()

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
        local setIdentifier = AH.CreateItemIdentifier(itemLink, itemName)
        if AHSetList and (AHSetList[setIdentifier] or AHSetList[itemName]) then
            return false, "In AHSet list"
        end

        -- Check 5: Must be soulbound
        local isSoulbound = AH.IsSoulboundFromNativeBagSlot(bag, slot)
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

                return false, "Cannot determine attunement progress"
            end
        else
            --AH.print_debug_general("IsReadyForDisenchant: GetItemLinkAttuneProgress API not available for " .. itemLink)
            return false, "Attunement API not available"
        end

        if progress < 100 then
            return false, "Not fully attuned (" .. progress .. "%)"
        end

        return true, "Ready for disenchant"
    end

    local function IsAttunableButNotReady(itemId, itemLink, itemName, bag, slot)
        if not itemId or not itemLink or not itemName then
            return false
        end

        if not AH.IsItemAttunable(itemLink) then
            return false
        end

        local isReady = IsReadyForDisenchant(itemId, itemLink, itemName, bag, slot)
        return not isReady
    end

    -- Track free slots outside the target bag only. Empty slots inside the target bag
    -- do not help us evacuate blocked items out of that bag.
    local emptyCount = 0
    for _, b in ipairs(bagsToScan) do
        for s = 1, GetContainerNumSlots(b) do
            if b ~= targetBag and not GetContainerItemID(b, s) then
                emptyCount = emptyCount + 1
                table.insert(emptySlots, { b = b, s = s })
            end
        end
    end

    -- Track which slots in target bag will become available
    local availableTargetSlots = {}
    local nonReadyInTargetCount = 0
    local targetBagItemsAtScan = {}

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
                        local isAttunable = AH.IsItemAttunable and AH.IsItemAttunable(link) or false
                        if not isReady then
                            -- Non-disenchant-ready items in target bag (need to move out)
                            nonReadyInTargetCount = nonReadyInTargetCount + 1
                            table.insert(availableTargetSlots, s)
                            table.insert(targetBagItemsAtScan, {
                                b = b,
                                s = s,
                                id = id,
                                name = name,
                                link = link,
                                isUnsafe = true,
                                isAttunable = isAttunable,
                                reason = reason
                            })
                        else
                            -- Disenchant-ready items already in target bag (leave them)
                            table.insert(readyForDisenchant,
                                { b = b, s = s, id = id, name = name, link = link, alreadyInTarget = true })

                        end
                    else
                        -- Items in other bags
                        if isReady then
                            -- Items ready for disenchanting (need to move to target bag)
                            table.insert(readyForDisenchant,
                                { b = b, s = s, id = id, name = name, link = link, fromBank = (b >= 5) })
                            --AH.print_debug_general("Found disenchant-ready item in bag " .. b .. ": " .. name)
                        else
                            --AH.print_debug_general("Item '" .. name .. "' not ready for disenchant: " .. reason)
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

    if emptyCount < nonReadyInTargetCount then
        print("|cffff0000[Attune Helper]|r Need " .. nonReadyInTargetCount ..
            " empty slot(s) outside " .. targetBagName .. " but only found " .. emptyCount .. ".")
        print("|cffff0000[Attune Helper]|r ATTUNABLE ITEMS IN DISENCHANT BAG WARNING")
        print("|cffff0000[Attune Helper]|r Some items may remain in " .. targetBagName ..
            " because there is not enough space to move blockers out first.")
        ShowDisenchantSafetyTooltip(
            targetBagItemsAtScan,
            AH.t("Disenchant Bag Safety"),
            "Some items may remain in the target bag because there is not enough space to move blockers out first."
        )
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

    local attunableWarnings = {}
    local tooltipItems = {}
    for s = 1, GetContainerNumSlots(targetBag) do
        local id = GetContainerItemID(targetBag, s)
        if id then
            local link = GetContainerItemLink(targetBag, s)
            local name = GetItemInfo(id)
            if link and name then
                local isReady, reason = IsReadyForDisenchant(id, link, name, targetBag, s)
                local isAttunable = AH.IsItemAttunable and AH.IsItemAttunable(link) or false

                if not isReady and isAttunable then
                    table.insert(tooltipItems, {
                        b = targetBag,
                        s = s,
                        id = id,
                        name = name,
                        link = link,
                        isUnsafe = true,
                        isAttunable = true,
                        reason = reason
                    })
                    table.insert(attunableWarnings, targetBagName .. " slot " .. s .. ": " .. name)
                end
            end
        end
    end

    if #attunableWarnings > 0 then
        print("|cffff0000[Attune Helper]|r ATTUNABLE ITEMS IN DISENCHANT BAG WARNING")
        for _, warningLine in ipairs(attunableWarnings) do
            print("|cffff0000[Attune Helper]|r " .. warningLine)
        end
        ShowDisenchantSafetyTooltip(
            tooltipItems,
            AH.t("Disenchant Bag Safety"),
            "Unsafe disenchant items detected in the target bag."
        )
    end
end

------------------------------------------------------------------------
-- Update AHSet to current equiped items functionality
------------------------------------------------------------------------
function AH.AssignItemToAHSetSlot(identifier, itemName, targetSlotName)
    if not identifier or not itemName or not targetSlotName then
        return false
    end
    if AH.EnsureAHSetListTable then
        AH.EnsureAHSetListTable()
    elseif type(AHSetList) ~= "table" then
        AHSetList = {}
    end

    -- Remove old mapping for this item.
    AHSetList[identifier] = nil
    AHSetList[itemName] = nil

    -- Keep only one AHSet item per slot by removing previous occupant(s).
    for setKey, assignedSlot in pairs(AHSetList) do
        if assignedSlot == targetSlotName then
            AHSetList[setKey] = nil
        end
    end

    AHSetList[identifier] = targetSlotName
    print("|cffffd200[AttuneHelper]|r '" .. itemName .. "' added to AHSet, designated for slot " .. targetSlotName .. ".")

    for i = 0, 4 do
        AH.UpdateBagCache(i)
    end
    if AH.RebuildEquipSlotCache then
        AH.RebuildEquipSlotCache()
    end
    AH.UpdateItemCountText()
    if AH.RefreshListManagementPanel then
        AH.RefreshListManagementPanel()
    end
    if AH.ForceSaveSettings then
        AH.ForceSaveSettings()
    end
    return true
end

local function GetAHSetSlotChoiceLabels(itemEquipLoc, slot1, slot2)
    if itemEquipLoc == "INVTYPE_FINGER" then
        return "Ring 1", "Ring 2"
    end
    if itemEquipLoc == "INVTYPE_TRINKET" then
        return "Trinket 1", "Trinket 2"
    end
    if itemEquipLoc == "INVTYPE_WEAPON" then
        return "Main Hand", "Off Hand"
    end

    local fallbackLabels = {
        MainHandSlot = "Main Hand",
        SecondaryHandSlot = "Off Hand",
        Finger0Slot = "Ring 1",
        Finger1Slot = "Ring 2",
        Trinket0Slot = "Trinket 1",
        Trinket1Slot = "Trinket 2"
    }
    return fallbackLabels[slot1] or slot1, fallbackLabels[slot2] or slot2
end

local function EnsureAHSetSlotChoicePopup()
    if StaticPopupDialogs["ATTUNEHELPER_AHSET_SLOT_CHOICE"] then
        return
    end

    StaticPopupDialogs["ATTUNEHELPER_AHSET_SLOT_CHOICE"] = {
        text = "%s",
        button1 = "Option 1",
        button2 = "Option 2",
        OnShow = function(self, data)
            if data and self.button1 and self.button2 then
                self.button1:SetText(data.slotLabel1 or "Option 1")
                self.button2:SetText(data.slotLabel2 or "Option 2")
            end
        end,
        OnAccept = function(_, data)
            if data and data.identifier and data.itemName and data.slot1 then
                AH.AssignItemToAHSetSlot(data.identifier, data.itemName, data.slot1)
            end
        end,
        OnCancel = function(_, data, reason)
            if reason == "clicked" and data and data.identifier and data.itemName and data.slot2 then
                AH.AssignItemToAHSetSlot(data.identifier, data.itemName, data.slot2)
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
end

function AH.AddCursorItemToAHSet()
    if not CursorHasItem() then
        return false
    end
    if AH.EnsureAHSetListTable then
        AH.EnsureAHSetListTable()
    elseif type(AHSetList) ~= "table" then
        AHSetList = {}
    end

    local cursorType, cursorID, cursorLink = GetCursorInfo()
    if cursorType ~= "item" then
        return false
    end

    local itemLink = cursorLink or (cursorID and ("item:" .. tostring(cursorID))) or nil
    local itemName, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink or cursorID)
    if not itemName then
        print("|cffff0000[AttuneHelper]|r Could not read dragged item.")
        return false
    end

    local identifier = AH.CreateItemIdentifier(itemLink, itemName)
    local unifiedSlot = AH.itemTypeToUnifiedSlot and AH.itemTypeToUnifiedSlot[itemEquipLoc] or nil

    if type(unifiedSlot) == "table" then
        local slot1 = unifiedSlot[1]
        local slot2 = unifiedSlot[2]
        if not slot1 or not slot2 then
            print("|cffff0000[AttuneHelper]|r Could not determine a unique slot for '" .. itemName .. "'. Use /ahset with a slot.")
            return false
        end

        local slotLabel1, slotLabel2 = GetAHSetSlotChoiceLabels(itemEquipLoc, slot1, slot2)
        EnsureAHSetSlotChoicePopup()
        ClearCursor()
        StaticPopup_Show(
            "ATTUNEHELPER_AHSET_SLOT_CHOICE",
            string.format("Choose AHSet slot for '%s':", itemName),
            nil,
            {
                identifier = identifier,
                itemName = itemName,
                slot1 = slot1,
                slot2 = slot2,
                slotLabel1 = slotLabel1,
                slotLabel2 = slotLabel2
            }
        )
        return true
    end

    if type(unifiedSlot) ~= "string" then
        print("|cffff0000[AttuneHelper]|r Could not determine a unique slot for '" .. itemName .. "'. Use /ahset with a slot.")
        return false
    end

    AH.AssignItemToAHSetSlot(identifier, itemName, unifiedSlot)
    ClearCursor()
    return true
end

function AH.AssignItemToAHSetPaperdollSlot(targetSlotName, itemLink)
    if not targetSlotName or not itemLink then
        return false
    end
    if AH.EnsureAHSetListTable then
        AH.EnsureAHSetListTable()
    elseif type(AHSetList) ~= "table" then
        AHSetList = {}
    end

    local itemName, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
    if not itemName or not itemEquipLoc or itemEquipLoc == "" then
        print("|cffff0000[AttuneHelper]|r Could not read item for AHSet slot.")
        return false
    end

    local identifier = AH.CreateItemIdentifier(itemLink, itemName)
    local unifiedSlot = AH.itemTypeToUnifiedSlot and AH.itemTypeToUnifiedSlot[itemEquipLoc] or nil
    local prepMH = AH.AHSET_PREP_MAINHAND_SLOT or "PrepMainHandSlot"
    local prepOH = AH.AHSET_PREP_OFFHAND_SLOT or "PrepOffHandSlot"

    local function slotAllowed()
        if targetSlotName == prepMH then
            if itemEquipLoc == "INVTYPE_WEAPON" or itemEquipLoc == "INVTYPE_WEAPONMAINHAND" then
                return AH.IsWeaponTypeAllowed(itemEquipLoc, "MainHandSlot")
            end
            return false
        end
        if targetSlotName == prepOH then
            if itemEquipLoc == "INVTYPE_WEAPON" or itemEquipLoc == "INVTYPE_WEAPONOFFHAND" or itemEquipLoc == "INVTYPE_SHIELD" or itemEquipLoc == "INVTYPE_HOLDABLE" then
                return AH.IsWeaponTypeAllowed(itemEquipLoc, "SecondaryHandSlot")
            end
            if itemEquipLoc == "INVTYPE_2HWEAPON" and AH.PlayerHasTitansGrip and AH.PlayerHasTitansGrip() and AH.GetWeaponControlSetting("Allow OffHand 2H Weapons") == 1 and AH.IsTitansGripCompatibleTwoHandWeaponByLink(itemLink) then
                return true
            end
            return false
        end
        if type(unifiedSlot) == "table" then
            if targetSlotName == prepOH and AH.tContains(unifiedSlot, "SecondaryHandSlot") then
                return AH.IsWeaponTypeAllowed(itemEquipLoc, "SecondaryHandSlot")
            end
            if targetSlotName == prepMH and AH.tContains(unifiedSlot, "MainHandSlot") then
                return AH.IsWeaponTypeAllowed(itemEquipLoc, "MainHandSlot")
            end
            return AH.tContains(unifiedSlot, targetSlotName)
        end
        if type(unifiedSlot) == "string" then
            if unifiedSlot == targetSlotName then
                return true
            end
            if targetSlotName == "SecondaryHandSlot"
                and itemEquipLoc == "INVTYPE_2HWEAPON"
                and AH.PlayerHasTitansGrip
                and AH.PlayerHasTitansGrip()
                and AH.GetWeaponControlSetting("Allow OffHand 2H Weapons") == 1
                and AH.IsTitansGripCompatibleTwoHandWeaponByLink(itemLink)
            then
                return true
            end
        end
        return false
    end

    if not slotAllowed() then
        print("|cffff0000[AttuneHelper]|r That item does not go in the " .. tostring(targetSlotName) .. " AHSet slot.")
        return false
    end

    AH.AssignItemToAHSetSlot(identifier, itemName, targetSlotName)
    ClearCursor()
    return true
end

function AH.SetAHSetToEquipped()
    if AH.EnsureAHSetListTable then
        AH.EnsureAHSetListTable()
    end
    wipe(AHSetList)
    print("|cffffd200[AttuneHelper]|r Deleted previous AHSetList Items.")

    local slotsList = { "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "WristSlot",
        "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "MainHandSlot",
        "SecondaryHandSlot", "RangedSlot" }

    for _, slotName in ipairs(slotsList) do
        local invSlotID = GetInventorySlotInfo(slotName)
        local eqID = invSlotID and GetInventoryItemID("player", invSlotID) or nil
        if eqID then
            local equippedItemLink = GetInventoryItemLink("player", invSlotID)
            local linkForId = equippedItemLink or ("item:" .. eqID)
            local equippedItemName = AH.GetItemDisplayName and AH.GetItemDisplayName(eqID, equippedItemLink) or GetItemInfo(equippedItemLink)
            if equippedItemName then
                local identifier = AH.CreateItemIdentifier(linkForId, equippedItemName)
                AHSetList[identifier] = slotName
                if not AHSetList[equippedItemName] then
                    AHSetList[equippedItemName] = slotName
                end
                print("|cffffd200[AH]|r '" .. equippedItemName .. "' (ID: " .. tostring(eqID) ..
                    ") added to AHSet, designated for slot " .. slotName .. ".")
            end
        end
    end

    if AH.ForceSaveSettings then
        AH.ForceSaveSettings()
    end
    if AH.RefreshListManagementPanel then
        AH.RefreshListManagementPanel()
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
    throttle = 0.1
}

function AH.IsInCombatOptimized()
    return InCombatLockdown()
end

function AH.GetEquipThrottle()
    return AH.combatPerformance.throttle or 0.1
end

function AH.TrackCombatEquip()
    return
end

function AH.ShouldSkipCombatEquip()
    return false
end

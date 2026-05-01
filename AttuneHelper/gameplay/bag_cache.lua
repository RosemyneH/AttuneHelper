-- ʕ •ᴥ•ʔ✿ Gameplay · Bag cache & item counts ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

AH.bagSlotCache   = AH.bagSlotCache   or {}
AH.equipSlotCache = AH.equipSlotCache or {}
AH.bagCacheGeneration = AH.bagCacheGeneration or 0
-- ʕ •ᴥ•ʔ✿ Track when each bag was last rebuilt so callers can skip redundant
-- full refreshes when the cache is already hot. ✿ ʕ •ᴥ•ʔ
AH.lastBagRefreshTime = AH.lastBagRefreshTime or {}
AH.lastFullBagRefreshTime = AH.lastFullBagRefreshTime or 0

-- ʕ •ᴥ•ʔ✿ GetItemInfo cache: weak keys so rows drop when item links are released ✿ ʕ •ᴥ•ʔ
AH.itemInfoCache = AH.itemInfoCache or setmetatable({}, { __mode = "k" })
AH.lastItemInfoCleanup = AH.lastItemInfoCleanup or 0
AH.ITEMINFO_CACHE_CLEANUP_INTERVAL = 30 -- Full wipe interval (bounds stale keys after churn)

-- ʕ •ᴥ•ʔ✿ Performance tracking ✿ ʕ •ᴥ•ʔ
AH.cacheStats = AH.cacheStats or {
    hits = 0,
    misses = 0,
    updates = 0
}

local bagSlotCache   = AH.bagSlotCache
local equipSlotCache = AH.equipSlotCache

AH.bagRecArena = AH.bagRecArena or {}

local function createMemoryArena()
	return {
		rows = {},
		used = 0,
	}
end

local function resetMemoryArena(arena)
	if not arena then
		return
	end
	for i = 1, arena.used do
		local row = arena.rows[i]
		if row then
			wipe(row)
		end
	end
	arena.used = 0
end

local function allocArenaRow(arena)
	arena.used = arena.used + 1
	local row = arena.rows[arena.used]
	if not row then
		row = {}
		arena.rows[arena.used] = row
	end
	return row
end

local function getBagRecArena(bagID)
	local a = AH.bagRecArena[bagID]
	if not a then
		a = createMemoryArena()
		AH.bagRecArena[bagID] = a
	end
	return a
end

local function InsertRecordIntoEquipCache(rec)
    if not rec or not rec.equipSlot then
        return
    end
    local unified = AH.itemTypeToUnifiedSlot[rec.equipSlot]
    if not unified then
        return
    end
    local function insertRec(key)
        equipSlotCache[key] = equipSlotCache[key] or {}
        table.insert(equipSlotCache[key], rec)
    end
    if type(unified) == "string" then
        insertRec(unified)
    elseif type(unified) == "table" then
        for _, k in ipairs(unified) do
            insertRec(k)
        end
    end
    if rec.equipSlot == "INVTYPE_2HWEAPON"
        and rec.isTGCompat2H
        and AH.PlayerHasTitansGrip
        and AH.PlayerHasTitansGrip()
        and AH.GetWeaponControlSetting
        and AH.GetWeaponControlSetting("Allow OffHand 2H Weapons") == 1
    then
        insertRec("SecondaryHandSlot")
    end
end

-- Enhanced cached GetItemInfo with better performance
local function GetCachedItemInfo(link)
    if not link then return nil end

    local currentTime = GetTime()
    if currentTime - AH.lastItemInfoCleanup > AH.ITEMINFO_CACHE_CLEANUP_INTERVAL then
        AH.itemInfoCache = setmetatable({}, { __mode = "k" })
        AH.lastItemInfoCleanup = currentTime
    end

    if AH.itemInfoCache[link] then
        AH.cacheStats.hits = AH.cacheStats.hits + 1
        local cached = AH.itemInfoCache[link]
        return cached[1], cached[2]
    else
        AH.cacheStats.misses = AH.cacheStats.misses + 1
        local name, _, _, _, _, _, _, _, equipLoc = GetItemInfo(link)
        if name then
            AH.itemInfoCache[link] = { name, equipLoc }
        else
            local id = CustomExtractItemId(link)
            name, _, _, _, _, _, _, _, equipLoc = GetItemInfoCustom(id)
            AH.itemInfoCache[link] = { name, equipLoc }
        end
        
        local cached = AH.itemInfoCache[link]
        return cached and cached[1], cached and cached[2]
    end
end

------------------------------------------------------------------------
-- UpdateBagCache(bagID)
-- stores the results in AH.bagSlotCache / AH.equipSlotCache.
------------------------------------------------------------------------
function AH.UpdateBagCache(bagID)
    -- Skip bank bags (5-11 on WotLK)
    if bagID >= 5 then
        --AH.print_debug_general("UpdateBagCache: Skipping bank bag " .. bagID)
        return
    end

    local bagTbl = bagSlotCache[bagID]
    if not bagTbl then
        bagTbl = {}
        bagSlotCache[bagID] = bagTbl
    end
    local arena = getBagRecArena(bagID)
    resetMemoryArena(arena)
    wipe(bagTbl)

    -- Iterate slots in this bag
    for slotID = 1, GetContainerNumSlots(bagID) do
        local link = GetContainerItemLink(bagID, slotID)
        if link then
            -- ʕ •ᴥ•ʔ✿ Use cached GetItemInfo to save memory and CPU ✿ ʕ •ᴥ•ʔ
            local name, equipLoc = GetCachedItemInfo(link)
            if name and equipLoc and equipLoc ~= "" then
                local unified = AH.itemTypeToUnifiedSlot[equipLoc]
                if unified then
                    local itemID = AH.GetItemIDFromLink(link)
                    local canPlayerAttune = false
                    if itemID and _G.CanAttuneItemHelper then
                        canPlayerAttune = (CanAttuneItemHelper(itemID) == 1)
                    end

                    local idKey = itemID and (name .. "|" .. tostring(itemID)) or name
                    local inSet = (AHSetList and (AHSetList[idKey] ~= nil or AHSetList[name] ~= nil))

                    if canPlayerAttune or inSet then
                        -- ʕ •ᴥ•ʔ✿ Cache stable per-rec fields so hot loops don't
                        -- re-resolve them thousands of times per spam click. ✿ ʕ •ᴥ•ʔ
                        local forgeLevel = AH.GetForgeLevelFromLink and AH.GetForgeLevelFromLink(link) or 0
                        local isTGCompat2H = false
                        if equipLoc == "INVTYPE_2HWEAPON" and AH.IsTitansGripCompatibleTwoHandWeaponByLink then
                            isTGCompat2H = AH.IsTitansGripCompatibleTwoHandWeaponByLink(link) == true
                        end
                        local isSoulbound = false
                        if AH.IsSoulboundFromNativeBagSlot then
                            isSoulbound = AH.IsSoulboundFromNativeBagSlot(bagID, slotID) == true
                        end
                        local isMythic = false
                        if itemID and AH.IsMythic then
                            isMythic = AH.IsMythic(itemID) == true
                        end
                        local bountyValue = 0
                        if itemID and _G.GetCustomGameData and AH.synastriaDataReady then
                            local ok, v = pcall(GetCustomGameData, 31, itemID)
                            if ok and type(v) == "number" then
                                bountyValue = v
                            end
                        end
                        local rec = allocArenaRow(arena)
                        rec.bag = bagID
                        rec.slot = slotID
                        rec.equipSlot = equipLoc
                        rec.isAttunable = canPlayerAttune
                        rec.inSet = inSet
                        rec.itemID = itemID
                        rec.forgeLevel = forgeLevel
                        rec.isTGCompat2H = isTGCompat2H
                        rec.isSoulbound = isSoulbound
                        rec.isMythic = isMythic
                        rec.bountyValue = bountyValue
                        bagTbl[slotID] = rec
                    end
                end
            end
        end
    end

    AH.equipSlotCacheDirty = true
    AH.bagCacheGeneration = (AH.bagCacheGeneration or 0) + 1
    AH.lastBagRefreshTime[bagID] = GetTime()
end
_G.UpdateBagCache = AH.UpdateBagCache

function AH.RebuildEquipSlotCache()
    wipe(equipSlotCache)
    for _, bagTbl in pairs(bagSlotCache) do
        if bagTbl then
            for _, rec in pairs(bagTbl) do
                InsertRecordIntoEquipCache(rec)
            end
        end
    end
    AH.equipSlotCacheDirty = false
end
_G.RebuildEquipSlotCache = AH.RebuildEquipSlotCache

------------------------------------------------------------------------
-- Combat-aware bag cache refresh utility
------------------------------------------------------------------------
function AH.RefreshBagCacheForCombat()
    if not ItemLocIsLoaded() then
        return false
    end

    --AH.print_debug_general("RefreshBagCacheForCombat: refreshing regular bags")
    for bagId = 0, 4 do
        AH.UpdateBagCache(bagId)
    end
    if AH.RebuildEquipSlotCache then
        AH.RebuildEquipSlotCache()
    end

    if AH.UpdateItemCountText then
        AH.UpdateItemCountText()
    end

    return true
end

_G.RefreshBagCacheForCombat = AH.RefreshBagCacheForCombat

------------------------------------------------------------------------
function AH.RefreshAllBagCaches()
    if not ItemLocIsLoaded() then return end
    for b = 0, 4 do AH.UpdateBagCache(b) end
    if AH.RebuildEquipSlotCache then
        AH.RebuildEquipSlotCache()
    end
    if AH.UpdateItemCountText then AH.UpdateItemCountText() end
    AH.lastFullBagRefreshTime = GetTime()
end
_G.RefreshAllBagCaches = AH.RefreshAllBagCaches

-- ʕ •ᴥ•ʔ✿ Refresh all bags only if the cache is older than `maxAgeSeconds`.
-- This is what callers on the equip hot path should use so they don't rescan
-- 80+ bag slots immediately after BAG_UPDATE already did. ✿ ʕ •ᴥ•ʔ
function AH.RefreshAllBagCachesIfStale(maxAgeSeconds)
    if not ItemLocIsLoaded() then return end
    local age = GetTime() - (AH.lastFullBagRefreshTime or 0)
    if age < (maxAgeSeconds or 1.0) and next(bagSlotCache) ~= nil then
        return false
    end
    AH.RefreshAllBagCaches()
    return true
end
_G.RefreshAllBagCachesIfStale = AH.RefreshAllBagCachesIfStale

------------------------------------------------------------------------
-- ʕ •ᴥ•ʔ✿ Optimized item count calculation with caching ✿ ʕ •ᴥ•ʔ
------------------------------------------------------------------------
AH.cachedItemCount = 0
AH.cachedAccountAttunableCount = 0
AH.lastItemCountUpdate = 0
AH.ITEM_COUNT_CACHE_DURATION = 1.0  -- Cache for 1 second

local ACCOUNT_ATTUNE_COUNT_COLOR = "|cff3399ff"

local function BuildInventoryCountText(mainCount, accountCount, isPrestiged)
    local text = "Attunables in Inventory: " .. (mainCount or 0)
    if isPrestiged and (accountCount or 0) > 0 then
        text = text .. ACCOUNT_ATTUNE_COUNT_COLOR .. " (" .. (accountCount or 0) .. ")|r"
    end
    return text
end

local function GetAccountOnlyAttunableCount()
    if not ItemLocIsLoaded() or not _G.CanAttuneItemHelper then
        return 0
    end

    local count = 0
    for bagId = 0, 4 do
        local slots = GetContainerNumSlots(bagId)
        for slotId = 1, slots do
            local itemId = GetContainerItemID(bagId, slotId)
            local link = GetContainerItemLink(bagId, slotId)
            if itemId and link then
                local isAccountOnlyAttunable = CanAttuneItemHelper(itemId) == -2 and IsAttunableBySomeone(itemId)
                if isAccountOnlyAttunable then
                    local progress = _G.GetItemLinkAttuneProgress and GetItemLinkAttuneProgress(link) or 100
                    if progress < 100 then
                        local isSoulbound = AH.IsSoulboundFromNativeBagSlot and AH.IsSoulboundFromNativeBagSlot(bagId, slotId)
                        if not isSoulbound then
                            count = count + 1
                        end
                    end
                end
            end
        end
    end
    return count
end

function AH.UpdateItemCountText()
    local currentTime = GetTime()
    --local prestiged = true
    local prestiged = (CMCGetMultiClassEnabled() or 1) >= 2

    -- Use cached value if recent
    if currentTime - AH.lastItemCountUpdate < AH.ITEM_COUNT_CACHE_DURATION then
        if AttuneHelperItemCountText then
            AttuneHelperItemCountText:SetText(BuildInventoryCountText(AH.cachedItemCount, AH.cachedAccountAttunableCount, prestiged))
        end
        return
    end

    local count = 0
    if ItemLocIsLoaded() then
        local strict = (AttuneHelperDB["EquipNewAffixesOnly"] == 1)
        for _, bagTbl in pairs(bagSlotCache) do
            if bagTbl then
                for _, rec in pairs(bagTbl) do
                    if rec and rec.isAttunable then
                        if rec.itemID and AH.ItemQualifiesForBagEquipRec(rec, strict) then
                            count = count + 1
                        end
                    end
                end
            end
        end
    end

    local accountCount = 0
    if prestiged then
        accountCount = GetAccountOnlyAttunableCount()
    end

    AH.cachedItemCount = count
    AH.cachedAccountAttunableCount = accountCount
    AH.lastItemCountUpdate = currentTime
    currentAttunableItemCount = count -- keep legacy global up to date

    if AttuneHelperItemCountText then
        AttuneHelperItemCountText:SetText(BuildInventoryCountText(count, accountCount, prestiged))
    end
end
_G.UpdateItemCountText = AH.UpdateItemCountText

function AH.GetBagAttunableTooltipCounts()
    local prestiged = (CMCGetMultiClassEnabled() or 1) >= 2
    local currentTime = GetTime()

    if currentTime - AH.lastItemCountUpdate >= AH.ITEM_COUNT_CACHE_DURATION then
        AH.UpdateItemCountText()
    end

    return {
        prestiged = prestiged,
        attunableInBag = AH.cachedItemCount or 0,
        accountAttunableInBag = prestiged and (AH.cachedAccountAttunableCount or 0) or 0
    }
end

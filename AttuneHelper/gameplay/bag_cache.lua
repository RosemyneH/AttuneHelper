-- ʕ •ᴥ•ʔ✿ Gameplay · Bag cache & item counts ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

AH.bagSlotCache   = AH.bagSlotCache   or {}
AH.equipSlotCache = AH.equipSlotCache or {}
AH.bagCacheGeneration = AH.bagCacheGeneration or 0

-- ʕ •ᴥ•ʔ✿ Enhanced GetItemInfo cache with TTL and size limits ✿ ʕ •ᴥ•ʔ
AH.itemInfoCache = AH.itemInfoCache or setmetatable({}, {__mode = "v"})
AH.itemInfoCacheSize = AH.itemInfoCacheSize or 0
AH.lastItemInfoCleanup = AH.lastItemInfoCleanup or 0
AH.ITEMINFO_CACHE_CLEANUP_INTERVAL = 30 -- Clean every 30 seconds
AH.MAX_ITEMINFO_CACHE_SIZE = 500 -- Maximum cache entries

-- ʕ •ᴥ•ʔ✿ Performance tracking ✿ ʕ •ᴥ•ʔ
AH.cacheStats = AH.cacheStats or {
    hits = 0,
    misses = 0,
    updates = 0
}

local bagSlotCache   = AH.bagSlotCache
local equipSlotCache = AH.equipSlotCache

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
end

-- Enhanced cached GetItemInfo with better performance
local function GetCachedItemInfo(link)
    if not link then return nil end

    -- Clean cache periodically or when too large
    local currentTime = GetTime()
    if currentTime - AH.lastItemInfoCleanup > AH.ITEMINFO_CACHE_CLEANUP_INTERVAL or AH.itemInfoCacheSize > AH.MAX_ITEMINFO_CACHE_SIZE then
        AH.itemInfoCache = setmetatable({}, {__mode = "v"})
        AH.itemInfoCacheSize = 0
        AH.lastItemInfoCleanup = currentTime
        --AH.print_debug_general("ItemInfo cache cleaned")
    end

    if AH.itemInfoCache[link] then
        AH.cacheStats.hits = AH.cacheStats.hits + 1
        local cached = AH.itemInfoCache[link]
        return cached[1], cached[2]
    else
        AH.cacheStats.misses = AH.cacheStats.misses + 1
        local name, _, _, _, _, _, _, _, equipLoc = GetItemInfo(link)
        if name then
            AH.itemInfoCache[link] = {name, equipLoc}
            AH.itemInfoCacheSize = AH.itemInfoCacheSize + 1
        elseif not name then
            local id = CustomExtractItemId(link)
            local name, _, _, _, _, _, _, _, equipLoc = GetItemInfoCustom(id)
            AH.itemInfoCache[link] = {name, equipLoc}
            AH.itemInfoCacheSize = AH.itemInfoCacheSize + 1
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

    bagSlotCache[bagID] = {}

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

                    local identifier = AH.CreateItemIdentifier(link, name)
                    local inSet = (AHSetList and (AHSetList[identifier] ~= nil or AHSetList[name] ~= nil))

                    if canPlayerAttune or inSet then
                        -- ʕ •ᴥ•ʔ✿ Minimal record structure to save memory ✿ ʕ •ᴥ•ʔ
                        local rec = {
                            bag       = bagID,
                            slot      = slotID,
                            link      = link,
                            name      = name,
                            equipSlot = equipLoc,
                            isAttunable = canPlayerAttune,
                            inSet       = inSet,
                        }
                        bagSlotCache[bagID][slotID] = rec
                    end
                end
            end
        end
    end

    AH.equipSlotCacheDirty = true
    AH.bagCacheGeneration = (AH.bagCacheGeneration or 0) + 1
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
    --AH.print_debug_general("RefreshAllBagCaches: refreshing all (bags 0-4)")
    for b = 0, 4 do AH.UpdateBagCache(b) end
    if AH.RebuildEquipSlotCache then
        AH.RebuildEquipSlotCache()
    end
    if AH.UpdateItemCountText then AH.UpdateItemCountText() end
end
_G.RefreshAllBagCaches = AH.RefreshAllBagCaches

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
                        local itemId = AH.GetItemIDFromLink(rec.link)
                        if itemId and AH.ItemQualifiesForBagEquip(itemId, rec.link, strict) then
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

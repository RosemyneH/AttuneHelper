-- ʕ •ᴥ•ʔ✿ Gameplay · Item checks  ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

------------------------------------------------------------------------
-- Actively leveling?
------------------------------------------------------------------------
function AH.ItemIsActivelyLeveling(itemId, itemLink)
    if not itemLink then
        --AH.print_debug_general("ItemIsActivelyLeveling: itemLink required. ItemId="..tostring(itemId))
        return false
    end
    if not itemId then itemId = AH.GetItemIDFromLink(itemLink) end
    if not itemId then return false end

    -- Can this item even be attuned?
    if _G.CanAttuneItemHelper and CanAttuneItemHelper(itemId) ~= 1 then
        return false
    end

    if not _G.GetItemLinkAttuneProgress then
        --AH.print_debug_general("ItemIsActivelyLeveling: GetItemLinkAttuneProgress missing for "..itemLink)
        return false
    end

    local progress = GetItemLinkAttuneProgress(itemLink)
    if type(progress) ~= "number" then
        --AH.print_debug_general("ItemIsActivelyLeveling: progress not number for "..itemLink.." -> "..tostring(progress))
        return false
    end

    return progress < 100
end
_G.ItemIsActivelyLeveling = AH.ItemIsActivelyLeveling

------------------------------------------------------------------------
-- Should we equip a bag item?
------------------------------------------------------------------------
-- ʕ •ᴥ•ʔ✿ Per-generation memoization so spam clicks don't re-run API calls
-- across the same bag cache contents. ✿ ʕ •ᴥ•ʔ
local qualifyCache = {}
local qualifyCacheGeneration = -1
local qualifyCacheStamp = 0
local QUALIFY_CACHE_TTL = 0.5

function AH.InvalidateItemQualifiesCache()
    qualifyCache = {}
    qualifyCacheGeneration = -1
    qualifyCacheStamp = 0
end

function AH.ItemQualifiesForBagEquip(itemId, itemLink, isEquipNewAffixesOnlyEnabled)
    if not itemLink then return false end
    if not itemId then itemId = AH.GetItemIDFromLink(itemLink) end
    if not itemId then return false end

    local generation = AH.bagCacheGeneration or 0
    local now = GetTime()
    if generation ~= qualifyCacheGeneration or (now - qualifyCacheStamp) > QUALIFY_CACHE_TTL then
        qualifyCache = {}
        qualifyCacheGeneration = generation
        qualifyCacheStamp = now
    end
    local cacheKey = itemLink .. (isEquipNewAffixesOnlyEnabled and "|1" or "|0")
    local cached = qualifyCache[cacheKey]
    if cached ~= nil then
        return cached
    end

    if not _G.CanAttuneItemHelper or CanAttuneItemHelper(itemId) ~= 1 then
        qualifyCache[cacheKey] = false
        return false
    end

    local progress = 100
    if _G.GetItemLinkAttuneProgress then
        local p = GetItemLinkAttuneProgress(itemLink)
        if type(p) == "number" then progress = p end
    end
    if progress >= 100 then
        qualifyCache[cacheKey] = false
        return false
    end

    local currentForgeLevel = AH.GetForgeLevelFromLink(itemLink)

    local result
    if isEquipNewAffixesOnlyEnabled then
        local minForge = AttuneHelperDB["AffixOnlyMinForgeLevel"] or AH.FORGE_LEVEL_MAP.WARFORGED

        if minForge >= 0 and currentForgeLevel < minForge then
            result = true
        else
            local hasAttunedThresholdVariant = false
            local hasAttunedAnyVariantEx = _G.HasAttunedAnyVariantEx
            if hasAttunedAnyVariantEx then
                local r = hasAttunedAnyVariantEx(itemId, minForge)
                hasAttunedThresholdVariant = (r == true or r == 1)
            elseif _G.HasAttunedAnyVariantOfItem then
                hasAttunedThresholdVariant = HasAttunedAnyVariantOfItem(itemId) and true or false
            end
            if not hasAttunedThresholdVariant then
                result = true
            else
                local strictBoundary = (minForge >= 0) and minForge or AH.FORGE_LEVEL_MAP.BASE
                result = (currentForgeLevel > strictBoundary)
            end
        end
    else
        result = true
    end

    qualifyCache[cacheKey] = result
    return result
end
_G.ItemQualifiesForBagEquip = AH.ItemQualifiesForBagEquip

-- ʕ •ᴥ•ʔ✿ Rec-scoped wrapper: memoizes the answer on the rec itself so hot
-- loops stop making calls once a rec has been evaluated this cycle. ✿ ʕ •ᴥ•ʔ
function AH.ItemQualifiesForBagEquipRec(rec, isEquipNewAffixesOnlyEnabled)
    if not rec then return false end
    local link = AH.GetBagRecLink(rec)
    if not link then return false end
    local gen = AH.bagCacheGeneration or 0
    local now = GetTime()
    if rec.qualifyGen == gen
        and rec.qualifyStrict == isEquipNewAffixesOnlyEnabled
        and (now - (rec.qualifyStamp or 0)) < QUALIFY_CACHE_TTL
    then
        return rec.qualifyResult
    end
    local result = AH.ItemQualifiesForBagEquip(rec.itemID, link, isEquipNewAffixesOnlyEnabled)
    rec.qualifyGen = gen
    rec.qualifyStrict = isEquipNewAffixesOnlyEnabled
    rec.qualifyStamp = now
    rec.qualifyResult = result
    return result
end
_G.ItemQualifiesForBagEquipRec = AH.ItemQualifiesForBagEquipRec

------------------------------------------------------------------------
-- Which item to prioritise?
------------------------------------------------------------------------
function AH.ShouldPrioritizeItem(item1Link, item2Link)
    if not item1Link or not item2Link then return false end

    local prioritizeLowIlvl = (AttuneHelperDB["Prioritize Low iLvl for Auto-Equip"] == 1)
    if prioritizeLowIlvl then
        local _,_,_,ilvl1 = GetItemInfo(item1Link)
        local _,_,_,ilvl2 = GetItemInfo(item2Link)
        if ilvl1 and ilvl2 and ilvl1 ~= ilvl2 then
            return ilvl1 < ilvl2
        end
    end

    local forge1 = AH.GetForgeLevelFromLink(item1Link)
    local forge2 = AH.GetForgeLevelFromLink(item2Link)
    if forge1 ~= forge2 then return forge1 > forge2 end

    local p1,p2=0,0
    if _G.GetItemLinkAttuneProgress then
        p1 = GetItemLinkAttuneProgress(item1Link) or 0
        p2 = GetItemLinkAttuneProgress(item2Link) or 0
    end
    return p1 < p2
end
_G.ShouldPrioritizeItem = AH.ShouldPrioritizeItem 
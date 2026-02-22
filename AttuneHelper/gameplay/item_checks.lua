-- ʕ •ᴥ•ʔ✿ Gameplay · Item checks  ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

------------------------------------------------------------------------
-- Actively leveling?
------------------------------------------------------------------------
function AH.ItemIsActivelyLeveling(itemId, itemLink)
    if not itemLink then
        AH.print_debug_general("ItemIsActivelyLeveling: itemLink required. ItemId="..tostring(itemId))
        return false
    end
    if not itemId then itemId = AH.GetItemIDFromLink(itemLink) end
    if not itemId then return false end

    -- Can this item even be attuned?
    if _G.CanAttuneItemHelper and CanAttuneItemHelper(itemId) ~= 1 then
        return false
    end

    if not _G.GetItemLinkAttuneProgress then
        AH.print_debug_general("ItemIsActivelyLeveling: GetItemLinkAttuneProgress missing for "..itemLink)
        return false
    end

    local progress = GetItemLinkAttuneProgress(itemLink)
    if type(progress) ~= "number" then
        AH.print_debug_general("ItemIsActivelyLeveling: progress not number for "..itemLink.." -> "..tostring(progress))
        return false
    end

    return progress < 100
end
_G.ItemIsActivelyLeveling = AH.ItemIsActivelyLeveling

------------------------------------------------------------------------
-- Should we equip a bag item?
------------------------------------------------------------------------
function AH.ItemQualifiesForBagEquip(itemId, itemLink, isEquipNewAffixesOnlyEnabled)
    if not itemLink then return false end
    if not itemId then itemId = AH.GetItemIDFromLink(itemLink) end
    if not itemId then return false end

    if not _G.CanAttuneItemHelper or CanAttuneItemHelper(itemId) ~= 1 then return false end

    local progress = 100
    if _G.GetItemLinkAttuneProgress then
        local p = GetItemLinkAttuneProgress(itemLink)
        if type(p) == "number" then progress = p end
    end
    if progress >= 100 then return false end -- already done

    local currentForgeLevel = AH.GetForgeLevelFromLink(itemLink)

    if isEquipNewAffixesOnlyEnabled then
        local hasAnyVariant = true
        if _G.HasAttunedAnyVariantOfItem then
            hasAnyVariant = HasAttunedAnyVariantOfItem(itemId)
        end
        if not hasAnyVariant then return true end -- no variant attuned yet
        return currentForgeLevel > AH.FORGE_LEVEL_MAP.BASE -- higher forge override
    end

    return true -- lenient mode
end
_G.ItemQualifiesForBagEquip = AH.ItemQualifiesForBagEquip

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
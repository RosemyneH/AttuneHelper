-- ʕ •ᴥ•ʔ✿ Gameplay · Vendor logic & selling ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper
local CustomAPI = AH.CustomAPI or {}
local AHVendorOverflowTooltip = CreateFrame("GameTooltip", "AHVendorOverflowTooltip", UIParent, "GameTooltipTemplate")
AHVendorOverflowTooltip:SetFrameStrata("TOOLTIP")
AHVendorOverflowTooltip:SetClampedToScreen(true)
local AHVendorOverflowTooltipB = CreateFrame("GameTooltip", "AHVendorOverflowTooltipB", UIParent, "GameTooltipTemplate")
AHVendorOverflowTooltipB:SetFrameStrata("TOOLTIP")
AHVendorOverflowTooltipB:SetClampedToScreen(true)
local FORGE_BADGE_COLORS = {
    TF = "|cff8080FF",
    WF = "|cffFFA680",
    LF = "|cffFFFFA6"
}
local vendorListCache = {
    generation = -1,
    timestamp = 0,
    key = "",
    data = {}
}
local VENDOR_LIST_CACHE_TTL = 0.5
local VENDOR_SELL_BATCH_SIZE = 4
local VENDOR_SELL_BATCH_DELAY = 0.08
AH.vendorSellInProgress = AH.vendorSellInProgress or false
_G.AttuneHelperAddVendorToggle = false

AH.IGNORE_ALWAYS_VENDOR_WF_LF_DBKEY = "Ignore Always-Vendor for Warforged and Lightforged"

local function IsWarforgedOrLightforgedLink(link)
    local map = AH.FORGE_LEVEL_MAP
    if not link or not map then
        return false
    end
    local fl = AH.GetForgeLevelFromLink and AH.GetForgeLevelFromLink(link) or 0
    return fl == map.WARFORGED or fl == map.LIGHTFORGED
end

local function ShouldIgnoreAlwaysVendorForLink(link)
    return (AttuneHelperDB[AH.IGNORE_ALWAYS_VENDOR_WF_LF_DBKEY] == 1) and IsWarforgedOrLightforgedLink(link)
end

local addVendorCursorFrame = CreateFrame("Frame", "AttuneHelperAddVendorCursorFrame", UIParent)
local addVendorCursorLastSig = ""
local addVendorCursorPollAccum = 0
local ADD_VENDOR_CURSOR_POLL = 0.05

local function AddVendorCursorWatcherOnUpdate(_, elapsed)
    addVendorCursorPollAccum = addVendorCursorPollAccum + (elapsed or 0)
    if addVendorCursorPollAccum < ADD_VENDOR_CURSOR_POLL then
        return
    end
    addVendorCursorPollAccum = 0
    if not (_G.AttuneHelperAddVendorToggle and AH.IsVendorWindowOpen and AH.IsVendorWindowOpen()) then
        addVendorCursorFrame:SetScript("OnUpdate", nil)
        return
    end
    local sig = ""
    if CursorHasItem() then
        local t, id, link = GetCursorInfo()
        if t == "item" and id then
            sig = tostring(id) .. "\0" .. tostring(link or "")
        end
    end
    if sig ~= "" and sig ~= addVendorCursorLastSig then
        addVendorCursorLastSig = sig
        if AH.AddCursorItemToAlwaysVendorAddOnly then
            AH.AddCursorItemToAlwaysVendorAddOnly()
        end
    elseif sig == "" then
        addVendorCursorLastSig = ""
    end
end

function AH.SetAddVendorToggleMode(on)
    _G.AttuneHelperAddVendorToggle = on and true or false
    if _G.AttuneHelperAddVendorToggle then
        addVendorCursorLastSig = ""
        addVendorCursorPollAccum = 0
        addVendorCursorFrame:SetScript("OnUpdate", AddVendorCursorWatcherOnUpdate)
    else
        addVendorCursorFrame:SetScript("OnUpdate", nil)
        addVendorCursorLastSig = ""
    end
    if AH.RefreshAddVendorToggleOutline then
        AH.RefreshAddVendorToggleOutline()
    end
end

function AH.InvalidateVendorListCache()
    vendorListCache.generation = -1
    vendorListCache.timestamp = 0
    vendorListCache.key = ""
    vendorListCache.data = {}
end
_G.InvalidateVendorListCache = AH.InvalidateVendorListCache

local function GetAHSetVendorSignature()
    if AH.EnsureAHSetListTable then
        AH.EnsureAHSetListTable()
    end
    if type(AHSetList) ~= "table" then
        return "empty"
    end

    local keyCount = 0
    local keyLenSum = 0
    for k in pairs(AHSetList) do
        keyCount = keyCount + 1
        if type(k) == "string" then
            keyLenSum = keyLenSum + string.len(k)
        end
    end

    local guid = (AH.GetActivePlayerGUID and AH.GetActivePlayerGUID()) or "unknown"
    local preset = (AH.GetActiveAHPresetName and AH.GetActiveAHPresetName()) or "Default"
    return table.concat({ tostring(guid), tostring(preset), tostring(keyCount), tostring(keyLenSum) }, ":")
end

local function GetForgeBadgeText(itemLink)
    local forgeLevel = AH.GetForgeLevelFromLink and AH.GetForgeLevelFromLink(itemLink) or 0
    if forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.WARFORGED or 2) then
        return FORGE_BADGE_COLORS.WF .. "[WF]|r"
    elseif forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.LIGHTFORGED or 3) then
        return FORGE_BADGE_COLORS.LF .. "[LF]|r"
    elseif forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.TITANFORGED or 1) then
        return FORGE_BADGE_COLORS.TF .. "[TF]|r"
    end
    return ""
end

local function BuildVendorDisplayName(itemData)
    if not itemData then
        return "Unknown Item"
    end

    local badgeText = GetForgeBadgeText(itemData.link)
    local baseName = itemData.link or itemData.name or "Unknown Item"
    if itemData.alwaysVendored then
        baseName = baseName .. " |cff80ff80[Always]|r"
    end
    if itemData.deleteInstead then
        baseName = baseName .. " |cffff6060[Delete]|r"
    end
    if badgeText ~= "" then
        return badgeText .. " " .. baseName
    end
    return baseName
end

local function AddOverflowItemLinesToTooltip(tooltip, itemList)
    for _, itemData in ipairs(itemList) do
        local _, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemData.link)
        if (not itemTexture) and itemData.bag and itemData.slot then
            local _, _, _, _, _, _, _, _, _, containerTexture = GetContainerItemInfo(itemData.bag, itemData.slot)
            itemTexture = containerTexture
        end

        local iconText = itemTexture and string.format("|T%s:14:14:0:0:64:64:4:60:4:60|t ", itemTexture) or ""
        local displayName = BuildVendorDisplayName(itemData)
        local _, r, g, b = GetItemQualityColor(itemQuality or 1)
        r, g, b = r or 1, g or 1, b or 1
        tooltip:AddLine(iconText .. displayName, r, g, b, true)
    end
end

local function GetAlwaysVendorKey(itemID)
    if not itemID then
        return nil
    end
    return "id:" .. tostring(itemID)
end

function AH.IsItemAlwaysVendored(itemID)
    local key = GetAlwaysVendorKey(itemID)
    return key and AHVendorList and AHVendorList[key] == true or false
end
_G.IsItemAlwaysVendored = AH.IsItemAlwaysVendored

------------------------------------------------------------------------
-- Get items that qualify for vendoring based on settings
------------------------------------------------------------------------
function AH.GetQualifyingVendorItems()
    if AH.EnsureAHSetListTable then
        AH.EnsureAHSetListTable()
    end
    local activeAHSet = (type(AHSetList) == "table") and AHSetList or {}

    local generation = AH.bagCacheGeneration or 0
    local useGreyWhiteVendorRules = (AttuneHelperDB["Do Not Sell Grey And White Items"] ~= 1)
    local includeBank = (BankFrame and BankFrame:IsShown()) and 1 or 0
    local ahsetSig = GetAHSetVendorSignature()
    local alwaysVendorCount = 0
    if type(AHVendorList) == "table" then
        for key, enabled in pairs(AHVendorList) do
            if enabled == true and type(key) == "string" and string.find(key, "^id:", 1, false) then
                alwaysVendorCount = alwaysVendorCount + 1
            end
        end
    end
    local cacheKey = table.concat({
        tostring(useGreyWhiteVendorRules and 1 or 0),
        tostring(includeBank),
        tostring(AttuneHelperDB["Do Not Sell BoE Items"] or 0),
        tostring(AttuneHelperDB["Sell Attuned Mythic Gear?"] or 0),
        tostring(alwaysVendorCount),
        tostring(AttuneHelperDB[AH.IGNORE_ALWAYS_VENDOR_WF_LF_DBKEY] or 0),
        tostring(ahsetSig)
    }, ":")
    local now = GetTime()

    if vendorListCache.generation == generation and
       vendorListCache.key == cacheKey and
       (now - (vendorListCache.timestamp or 0)) < VENDOR_LIST_CACHE_TTL then
        return vendorListCache.data
    end

    local itemsToVendor = {}


    local function IsPotentialBoEUnboundForVendorCheck(itemID, bag, slot_idx)
        if not itemID or not bag or not slot_idx then
            return false
        end
        return not AH.IsSoulboundFromNativeBagSlot(bag, slot_idx)
    end

    -- Determine which bags to scan (include bank if open)
    local bagsToScan = {0, 1, 2, 3, 4}
    if BankFrame and BankFrame:IsShown() then
        for bankBag = 5, 11 do
            table.insert(bagsToScan, bankBag)
        end
    end


    local totalItemsProcessed = 0
    local itemsSkippedCount = 0

    for bagIndex, b in ipairs(bagsToScan) do
        
        local bagSlots = GetContainerNumSlots(b)
        
        for s = 1, bagSlots do
            totalItemsProcessed = totalItemsProcessed + 1
            
            local link = GetContainerItemLink(b, s)
            local id = GetContainerItemID(b, s)
            
            if link and id then
                local n, itemLinkFull, q, _, _, _, _, _, _, itemTexture, sellP = GetItemInfo(link)

                if n then
                    
                    local skip = false
                    local skipReason = ""
                    local isAlwaysVendored = AH.IsItemAlwaysVendored and AH.IsItemAlwaysVendored(id)
                    local effectiveAlwaysVendored = isAlwaysVendored and (not ShouldIgnoreAlwaysVendorForLink(link))
                    local deleteInstead = false

                    -- Sell price check
                    if not sellP or sellP == 0 then
                        if effectiveAlwaysVendored then
                            deleteInstead = true
                        else
                            skip = true
                            skipReason = "No/Zero sell price (" .. tostring(sellP) .. ")"
                        end
                    end

                    -- Double-check with container item info
                    if not skip and not deleteInstead then
                        local _, itemCount, _, _, _, _, cLink = GetContainerItemInfo(b, s)
                        if cLink then
                            local _, _, _, _, _, _, _, _, _, _, cSellPrice = GetItemInfo(cLink)
                            if not cSellPrice or cSellPrice == 0 then
                                if effectiveAlwaysVendored then
                                    deleteInstead = true
                                else
                                    skip = true
                                    skipReason = "Container check - No/Zero sell price"
                                end
                            end
                        end
                    end

                    if not skip and (not effectiveAlwaysVendored) and (AHIgnoreList[n] or AHIgnoreList["id:" .. tostring(id)]) then
                        skip = true
                        skipReason = "In AHIgnore list"
                    end

                    local setIdentifier = AH.CreateItemIdentifier(link, n, b, s)
                    local setLegacy = AH.GetLegacyItemIdentifier(link, n)
                    if not skip and (not effectiveAlwaysVendored) and (activeAHSet[setIdentifier] or (setLegacy and activeAHSet[setLegacy]) or activeAHSet[n]) then
                        skip = true
                        skipReason = "In AHSet list"
                    end

                    if not skip and (not effectiveAlwaysVendored) and AH.IsItemInEquipMgrFromNativeBagSlot and AH.IsItemInEquipMgrFromNativeBagSlot(b, s) then
                        skip = true
                        skipReason = "In Equipment Set"
                    end

                    -- Check attunement progress unless grey/white special rules are enabled
                    if not skip and (not effectiveAlwaysVendored) and ((q and q > 1) or (not useGreyWhiteVendorRules)) then
                        local thisVariantProgress = 0
                        local progress = CustomAPI.GetItemLinkAttuneProgress(link)
                        if type(progress) == "number" then
                            thisVariantProgress = progress
                        end

                        local isThisVariantFullyAttuned = (thisVariantProgress >= 100)

                        if not isThisVariantFullyAttuned then
                            skip = true
                            skipReason = "This variant only " .. thisVariantProgress .. "% attuned"
                        end
                    end

                    -- Final qualification checks
                    if not skip then
                        local isSoulbound = AH.IsSoulboundFromNativeBagSlot(b, s)
                        local isAttunableBySomeone = IsAttunableBySomeone(id)

                        if (not effectiveAlwaysVendored) and (not isSoulbound) and isAttunableBySomeone then
                            skip = true
                            skipReason = "Not soulbound and attunable by someone"
                        end

                        local shouldSellByQuality = false
                        local qualityReason = ""
                        if not skip then
                            if q == 0 then
                                shouldSellByQuality = true
                                qualityReason = "Grey quality"
                            elseif q == 1 then
                                shouldSellByQuality = isSoulbound or (not isAttunableBySomeone)
                                qualityReason = shouldSellByQuality and
                                    "White quality (soulbound or not attunable by someone)" or
                                    "White quality not soulbound and attunable by someone"
                            end
                        end

                        if effectiveAlwaysVendored then
                            table.insert(itemsToVendor, {
                                name = n,
                                link = link,
                                id = id,
                                quality = q,
                                bag = b,
                                slot = s,
                                alwaysVendored = true,
                                deleteInstead = deleteInstead
                            })
                        elseif useGreyWhiteVendorRules and (q == 0 or q == 1) then
                            if shouldSellByQuality then
                                table.insert(itemsToVendor, {
                                    name = n,
                                    link = link,
                                    id = id,
                                    quality = q,
                                    bag = b,
                                    slot = s,
                                    alwaysVendored = false
                                })
                            else
                                skip = true
                                skipReason = qualityReason
                            end
                        else
                            local isBoEU = IsPotentialBoEUnboundForVendorCheck(id, b, s)
                            local isM = AH.IsMythic(id) == true

                            local noSellBoE = (AttuneHelperDB["Do Not Sell BoE Items"] == 1 and isBoEU)
                            local sellM = (AttuneHelperDB["Sell Attuned Mythic Gear?"] == 1)
                            local doSell = (isM and sellM) or not isM

                            if doSell and not noSellBoE then
                                table.insert(itemsToVendor, {
                                    name = n,
                                    link = link,
                                    id = id,
                                    quality = q,
                                    bag = b,
                                    slot = s,
                                    alwaysVendored = false
                                })
                            else
                                skip = true
                                skipReason = "BoE/Mythic rules (doSell=" .. tostring(doSell) .. ", noSellBoE=" .. tostring(noSellBoE) .. ")"
                            end
                        end
                    end

                    if skip then
                        itemsSkippedCount = itemsSkippedCount + 1
                    end
                end
            end
        end
    end
    

    vendorListCache.generation = generation
    vendorListCache.key = cacheKey
    vendorListCache.timestamp = now
    vendorListCache.data = itemsToVendor

    return itemsToVendor
end
_G.GetQualifyingVendorItems = AH.GetQualifyingVendorItems

function AH.AddCursorItemToAlwaysVendor()
    if not CursorHasItem() then
        return false
    end

    local cursorType, cursorID, cursorLink = GetCursorInfo()
    if cursorType ~= "item" then
        return false
    end

    local itemName = GetItemInfo(cursorLink or cursorID)
    if not itemName or not cursorID then
        return false
    end

    AHVendorList = AHVendorList or {}
    local itemKey = GetAlwaysVendorKey(cursorID)
    local isAlreadyAlwaysVendored = itemKey and AHVendorList[itemKey] == true

    if isAlreadyAlwaysVendored then
        AHVendorList[itemKey] = nil
        print("|cffffd200[Attune Helper]|r Removed from always vendor list: " .. itemName)
    else
        if ShouldIgnoreAlwaysVendorForLink(cursorLink) then
            print("|cffffd200[Attune Helper]|r " .. (AH.t and AH.t("Always-vendor skipped for Warforged/Lightforged (see options).") or "Always-vendor skipped for Warforged/Lightforged (see options)."))
            ClearCursor()
            return false
        end
        AHVendorList[itemKey] = true
        print("|cffffd200[Attune Helper]|r Added to always vendor list: " .. itemName)
    end

    if AH.InvalidateVendorListCache then
        AH.InvalidateVendorListCache()
    end
    ClearCursor()
    return true
end
_G.AddCursorItemToAlwaysVendor = AH.AddCursorItemToAlwaysVendor

function AH.AddCursorItemToAlwaysVendorAddOnly()
    if not CursorHasItem() then
        return false
    end

    local cursorType, cursorID, cursorLink = GetCursorInfo()
    if cursorType ~= "item" then
        return false
    end

    local itemName = GetItemInfo(cursorLink or cursorID)
    if not itemName or not cursorID then
        return false
    end

    if ShouldIgnoreAlwaysVendorForLink(cursorLink) then
        print("|cffffd200[Attune Helper]|r " .. (AH.t and AH.t("Always-vendor skipped for Warforged/Lightforged (see options).") or "Always-vendor skipped for Warforged/Lightforged (see options)."))
        ClearCursor()
        return false
    end

    AHVendorList = AHVendorList or {}
    local itemKey = GetAlwaysVendorKey(cursorID)
    if not itemKey then
        return false
    end
    if AHVendorList[itemKey] == true then
        ClearCursor()
        return true
    end

    AHVendorList[itemKey] = true
    print("|cffffd200[Attune Helper]|r Added to always vendor list: " .. itemName)

    if AH.InvalidateVendorListCache then
        AH.InvalidateVendorListCache()
    end
    ClearCursor()
    return true
end

function AH.AddCursorItemToIgnore()
    if not CursorHasItem() then
        return false
    end

    local cursorType, cursorID, cursorLink = GetCursorInfo()
    if cursorType ~= "item" then
        return false
    end

    local itemName = GetItemInfo(cursorLink or cursorID)
    if not itemName then
        return false
    end

    local idKey = cursorID and ("id:" .. tostring(cursorID)) or nil
    local isAlreadyIgnored = AHIgnoreList[itemName] or (idKey and AHIgnoreList[idKey])

    if isAlreadyIgnored then
        AHIgnoreList[itemName] = nil
        if idKey then
            AHIgnoreList[idKey] = nil
        end
        print("|cffffd200[Attune Helper]|r Removed from ignore list: " .. itemName)
    else
        AHIgnoreList[itemName] = true
        if idKey then
            AHIgnoreList[idKey] = true
        end
        print("|cffffd200[Attune Helper]|r Added to ignore list: " .. itemName)
    end

    if AH.InvalidateVendorListCache then
        AH.InvalidateVendorListCache()
    end
    ClearCursor()
    return true
end

------------------------------------------------------------------------
-- Actually sell the items
------------------------------------------------------------------------
function AH.SellQualifiedItemsFromDialog(itemsToSellFromDialog)
    if not (AH.IsVendorWindowOpen and AH.IsVendorWindowOpen()) then
        return
    end
    if AH.vendorSellInProgress then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd200[Attune Helper]|r Vendor sell already in progress.")
        return
    end
    if #itemsToSellFromDialog == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd200[Attune Helper]|r No items to vendor based on current settings.")
        return
    end

    local limitSelling = (AttuneHelperDB["Limit Selling to 12 Items?"] == 1)
    local maxItemsPerVendorPass = 85
    local configuredMaxSellCount = limitSelling and 12 or #itemsToSellFromDialog
    local maxSellCount = math.min(configuredMaxSellCount, maxItemsPerVendorPass)
    local soldCount = 0
    local deletedCount = 0
    local processedCount = 0
    local itemsInPass = math.min(#itemsToSellFromDialog, maxSellCount)


    local function FinishVendorSell(stoppedEarly)
        AH.vendorSellInProgress = false

        if AH.InvalidateVendorListCache then
            AH.InvalidateVendorListCache()
        end

        if stoppedEarly then
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd200[Attune Helper]|r Vendor sell stopped because the merchant window closed.")
        end

        if soldCount > 0 or deletedCount > 0 then
            if soldCount > 0 then
                DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffffd200[Attune Helper]|r Sold %d item(s).", soldCount))
            end
            if deletedCount > 0 then
                DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffff6060[Attune Helper]|r Deleted %d no-value always-vendor item(s).", deletedCount))
            end
            if not stoppedEarly and #itemsToSellFromDialog > maxSellCount then
                local remainingCount = #itemsToSellFromDialog - maxSellCount
                if limitSelling then
                    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffffd200[Attune Helper]|r Sell pass limited to %d item(s) by your setting. %d item(s) remain; click again to continue.", maxSellCount, remainingCount))
                else
                    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffffd200[Attune Helper]|r Vendor safeguard: stopped at %d items to prevent packet disconnects. %d item(s) remain; click again to continue.", maxSellCount, remainingCount))
                end
            end
        elseif not stoppedEarly then
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd200[Attune Helper]|r No items were actually sold.")
        end
    end

    local function ProcessVendorSellBatch()
        if not (AH.IsVendorWindowOpen and AH.IsVendorWindowOpen()) then
            FinishVendorSell(true)
            return
        end

        local processedThisBatch = 0
        while processedCount < itemsInPass and processedThisBatch < VENDOR_SELL_BATCH_SIZE do
            processedCount = processedCount + 1
            processedThisBatch = processedThisBatch + 1

            local item = itemsToSellFromDialog[processedCount]
            if item and item.bag and item.slot then
                local currentItemLinkInSlot = GetContainerItemLink(item.bag, item.slot)
                if currentItemLinkInSlot and currentItemLinkInSlot == item.link then
                    if item.deleteInstead then
                        PickupContainerItem(item.bag, item.slot)
                        if CursorHasItem() then
                            DeleteCursorItem()
                            ClearCursor()
                            deletedCount = deletedCount + 1
                        else
                            ClearCursor()
                        end
                    else
                        UseContainerItem(item.bag, item.slot)
                        soldCount = soldCount + 1
                    end
                end
            end
        end

        if processedCount >= itemsInPass then
            FinishVendorSell(false)
            return
        end

        if AH.Wait then
            AH.Wait(VENDOR_SELL_BATCH_DELAY, ProcessVendorSellBatch)
        else
            ProcessVendorSellBatch()
        end
    end

    AH.vendorSellInProgress = true
    ProcessVendorSellBatch()
end
_G.SellQualifiedItemsFromDialog = AH.SellQualifiedItemsFromDialog

------------------------------------------------------------------------
-- Main vendor function called by button clicks
------------------------------------------------------------------------
function AH.VendorAttunedItems(buttonSelf)
    NotifyServer(2, 9, "")
    -- This sends a server packet to deposit all trades goods into resource bank
    
    if not (AH.IsVendorWindowOpen and AH.IsVendorWindowOpen()) then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[Attune Helper]|r You must have a merchant window open to vendor items.")
        return
    end

    local itemsToSell = AH.GetQualifyingVendorItems()
    if #itemsToSell == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd200[Attune Helper]|r No items to vendor based on current settings.")
        return
    end

    local limitSelling = (AttuneHelperDB["Limit Selling to 12 Items?"] == 1)
    local itemsToSellThisPass = itemsToSell
    if limitSelling and #itemsToSell > 12 then
        itemsToSellThisPass = {}
        for i = 1, 12 do
            itemsToSellThisPass[i] = itemsToSell[i]
        end
    end

    if AttuneHelperDB["EnableVendorSellConfirmationDialog"] == 1 then
        local confirmText = "|cffffd200The following items will be sold:|r\n\n"
        local itemCountInPopup = 0
        local previewLimit = 10
        local overflowItems = {}
        for i, itemData in ipairs(itemsToSellThisPass) do
            if i <= previewLimit then -- Limit items shown in popup
                local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemData.link)
                if (not itemTexture) and itemData.bag and itemData.slot then
                    local _, _, _, _, _, _, _, _, _, containerTexture = GetContainerItemInfo(itemData.bag, itemData.slot)
                    itemTexture = containerTexture
                end
                local iconString = ""
                if itemTexture then
                    iconString = string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t ", itemTexture)
                end
                confirmText = confirmText .. iconString .. BuildVendorDisplayName(itemData) .. "\n"
                itemCountInPopup = itemCountInPopup + 1
            else
                table.insert(overflowItems, itemData)
            end
        end
        if #overflowItems > 0 then
            confirmText = confirmText .. "\n|cffcccccc...and " .. #overflowItems .. " more items (hover Sell to preview).|r"
        end
        if limitSelling and #itemsToSell > #itemsToSellThisPass then
            confirmText = confirmText .. "\n|cff80c0ff(12-item sell limit is enabled for this pass.)|r"
        end
        confirmText = confirmText .. "\n\nAre you sure you want to sell these items?"
        StaticPopup_Show("AH_VENDOR_CONFIRM", confirmText, nil, {
            itemsToSell = itemsToSellThisPass,
            overflowItems = overflowItems,
            overflowCount = #overflowItems
        })
    else
        -- Sell directly without confirmation
        AH.SellQualifiedItemsFromDialog(itemsToSellThisPass)
    end
end
_G.VendorAttunedItems = AH.VendorAttunedItems

------------------------------------------------------------------------
-- Setup vendor confirmation dialog
------------------------------------------------------------------------
AH.SetupVendorDialog = function()
    StaticPopupDialogs["AH_VENDOR_CONFIRM"] = {
        text = "%s",
        button1 = "Sell",
        button2 = "Cancel",
        OnShow = function(self, data)
            local hasOverflow = data and data.overflowCount and data.overflowCount > 0
            if hasOverflow then
                self.button1:SetScript("OnEnter", function(button)
                    local overflowItems = data.overflowItems or {}
                    local n = #overflowItems
                    AHVendorOverflowTooltip:SetOwner(button, "ANCHOR_NONE")
                    AHVendorOverflowTooltip:ClearAllPoints()
                    AHVendorOverflowTooltip:ClearLines()
                    AHVendorOverflowTooltipB:Hide()

                    if n >= 2 then
                        local mid = math.floor(n / 2)
                        AHVendorOverflowTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -10, 0)
                        AHVendorOverflowTooltip:SetText(string.format("Additional items (%d–%d of %d)", 1, mid, n), 1, 1, 0)
                        local leftSlice = {}
                        for i = 1, mid do
                            leftSlice[#leftSlice + 1] = overflowItems[i]
                        end
                        AddOverflowItemLinesToTooltip(AHVendorOverflowTooltip, leftSlice)
                        AHVendorOverflowTooltip:Show()

                        AHVendorOverflowTooltipB:SetOwner(button, "ANCHOR_NONE")
                        AHVendorOverflowTooltipB:ClearAllPoints()
                        AHVendorOverflowTooltipB:SetPoint("TOPLEFT", self, "TOPRIGHT", 10, 0)
                        AHVendorOverflowTooltipB:ClearLines()
                        AHVendorOverflowTooltipB:SetText(string.format("Additional items (%d–%d of %d)", mid + 1, n, n), 1, 1, 0)
                        local rightSlice = {}
                        for i = mid + 1, n do
                            rightSlice[#rightSlice + 1] = overflowItems[i]
                        end
                        AddOverflowItemLinesToTooltip(AHVendorOverflowTooltipB, rightSlice)
                        AHVendorOverflowTooltipB:Show()
                    else
                        local anchorRight = AttuneHelperDB["Vendor preview on Right (Default On)"] ~= 0
                        if data.overflowCount > 55 then
                            anchorRight = false
                        end
                        if anchorRight then
                            AHVendorOverflowTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 10, 0)
                        else
                            AHVendorOverflowTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -10, 0)
                        end
                        AHVendorOverflowTooltip:SetText(string.format("Additional items (%d)", data.overflowCount), 1, 1, 0)
                        AddOverflowItemLinesToTooltip(AHVendorOverflowTooltip, overflowItems)
                        AHVendorOverflowTooltip:Show()
                    end
                end)
                self.button1:SetScript("OnLeave", function()
                    AHVendorOverflowTooltip:Hide()
                    AHVendorOverflowTooltipB:Hide()
                end)
            else
                self.button1:SetScript("OnEnter", nil)
                self.button1:SetScript("OnLeave", nil)
            end
        end,
        OnAccept = function(self, data)
            if data and data.itemsToSell then
                AH.SellQualifiedItemsFromDialog(data.itemsToSell)
            end
        end,
        OnCancel = function()
        end,
        OnHide = function(self)
            self.button1:SetScript("OnEnter", nil)
            self.button1:SetScript("OnLeave", nil)
            AHVendorOverflowTooltip:Hide()
            AHVendorOverflowTooltipB:Hide()
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        preferredIndex = 3,
        maxWidth = 450,
        minWidth = 350,
    }
end

-- Initialize the dialog immediately
AH.SetupVendorDialog()

-- ʕ •ᴥ•ʔ✿ Gameplay · Vendor logic & selling ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper
local AHVendorOverflowTooltip = CreateFrame("GameTooltip", "AHVendorOverflowTooltip", UIParent, "GameTooltipTemplate")
AHVendorOverflowTooltip:SetFrameStrata("TOOLTIP")
AHVendorOverflowTooltip:SetClampedToScreen(true)
local vendorListCache = {
    generation = -1,
    timestamp = 0,
    key = "",
    data = {}
}
local VENDOR_LIST_CACHE_TTL = 0.5

local function GetForgeBadgeText(itemLink)
    local forgeLevel = AH.GetForgeLevelFromLink and AH.GetForgeLevelFromLink(itemLink) or 0
    if forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.WARFORGED or 2) then
        return "|cffFFA680[WF]|r"
    elseif forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.LIGHTFORGED or 3) then
        return "|cffFFFFA6[LF]|r"
    elseif forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.TITANFORGED or 1) then
        return "|cff8080FF[TF]|r"
    end
    return ""
end

local function BuildVendorDisplayName(itemData)
    if not itemData then
        return "Unknown Item"
    end

    local badgeText = GetForgeBadgeText(itemData.link)
    local baseName = itemData.link or itemData.name or "Unknown Item"
    if badgeText ~= "" then
        return badgeText .. " " .. baseName
    end
    return baseName
end

------------------------------------------------------------------------
-- Get items that qualify for vendoring based on settings
------------------------------------------------------------------------
function AH.GetQualifyingVendorItems()
    local generation = AH.bagCacheGeneration or 0
    local useGreyWhiteVendorRules = (AttuneHelperDB["Do Not Sell Grey And White Items"] ~= 1)
    local includeBank = (BankFrame and BankFrame:IsShown()) and 1 or 0
    local cacheKey = table.concat({
        tostring(useGreyWhiteVendorRules and 1 or 0),
        tostring(includeBank),
        tostring(AttuneHelperDB["Do Not Sell BoE Items"] or 0),
        tostring(AttuneHelperDB["Sell Attuned Mythic Gear?"] or 0)
    }, ":")
    local now = GetTime()

    if vendorListCache.generation == generation and
       vendorListCache.key == cacheKey and
       (now - (vendorListCache.timestamp or 0)) < VENDOR_LIST_CACHE_TTL then
        return vendorListCache.data
    end

    local itemsToVendor = {}

    --AH.print_debug_vendor_preview("=== GetQualifyingVendorItems: Starting scan ===")

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
        --AH.print_debug_vendor_preview("GetQualifying: Including bank bags in vendor scan.")
    end

    --AH.print_debug_vendor_preview("GetQualifying: Scanning bags: " .. table.concat(bagsToScan, ", "))

    local totalItemsProcessed = 0
    local itemsSkippedCount = 0

    for bagIndex, b in ipairs(bagsToScan) do
        --AH.print_debug_vendor_preview("GetQualifying: === Processing bag " .. b .. " ===")
        
        local bagSlots = GetContainerNumSlots(b)
        --AH.print_debug_vendor_preview("GetQualifying: Bag " .. b .. " has " .. bagSlots .. " slots")
        
        for s = 1, bagSlots do
            totalItemsProcessed = totalItemsProcessed + 1
            
            local link = GetContainerItemLink(b, s)
            local id = GetContainerItemID(b, s)
            
            if link and id then
                local success, n, itemLinkFull, q, _, _, _, _, _, itemTexture, _, sellP = pcall(GetItemInfo, link)
                
                if success and n then
                    --AH.print_debug_vendor_preview("GetQualifying: Processing item: " .. n .. " (ID: " .. id .. ")")
                    
                    local skip = false
                    local skipReason = ""

                    -- Sell price check
                    if not sellP or sellP == 0 then
                        skip = true
                        skipReason = "No/Zero sell price (" .. tostring(sellP) .. ")"
                    end

                    -- Double-check with container item info
                    if not skip then
                        local containerSuccess, _, itemCount, _, _, _, _, cLink = pcall(GetContainerItemInfo, b, s)
                        if containerSuccess and cLink then
                            local linkSuccess, _, _, _, _, _, _, _, _, _, cSellPrice = pcall(GetItemInfo, cLink)
                            if linkSuccess and (not cSellPrice or cSellPrice == 0) then
                                skip = true
                                skipReason = "Container check - No/Zero sell price"
                            end
                        end
                    end

                    if not skip and (AHIgnoreList[n] or AHIgnoreList["id:" .. tostring(id)]) then
                        skip = true
                        skipReason = "In AHIgnore list"
                    end

                    local setIdentifier = AH.CreateItemIdentifier(link, n)
                    if not skip and (AHSetList[setIdentifier] or AHSetList[n]) then
                        skip = true
                        skipReason = "In AHSet list"
                    end

                    if not skip and AH.IsItemInEquipMgrFromNativeBagSlot and AH.IsItemInEquipMgrFromNativeBagSlot(b, s) then
                        skip = true
                        skipReason = "In Equipment Set"
                    end

                    -- Check attunement progress unless grey/white special rules are enabled
                    if not skip and ((q and q > 1) or (not useGreyWhiteVendorRules)) then
                        local thisVariantProgress = 0
                        if _G.GetItemLinkAttuneProgress then
                            local progressSuccess, progress = pcall(GetItemLinkAttuneProgress, link)
                            if progressSuccess and type(progress) == "number" then
                                thisVariantProgress = progress
                            end
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

                        if (not isSoulbound) and isAttunableBySomeone then
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

                        if useGreyWhiteVendorRules and (q == 0 or q == 1) then
                            if shouldSellByQuality then
                                table.insert(itemsToVendor, {
                                    name = n,
                                    link = link,
                                    id = id,
                                    quality = q,
                                    bag = b,
                                    slot = s
                                })
                                --AH.print_debug_vendor_preview("GetQualifying: ✓ ADDING to vendor list: " .. n .. " (" .. qualityReason .. ")")
                            else
                                skip = true
                                skipReason = qualityReason
                            end
                        else
                            local isBoEU, isMSuccess, isM = false, true, false

                            local boeSuccess, boeResult = pcall(IsPotentialBoEUnboundForVendorCheck, id, b, s)
                            if boeSuccess then
                                isBoEU = boeResult
                            end

                            isMSuccess, isM = pcall(AH.IsMythic, id)
                            if not isMSuccess then
                                isM = false
                            end

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
                                    slot = s
                                })
                                --AH.print_debug_vendor_preview("GetQualifying: ✓ ADDING to vendor list: " .. n)
                            else
                                skip = true
                                skipReason = "BoE/Mythic rules (doSell=" .. tostring(doSell) .. ", noSellBoE=" .. tostring(noSellBoE) .. ")"
                            end
                        end
                    end

                    if skip then
                        itemsSkippedCount = itemsSkippedCount + 1
                        --AH.print_debug_vendor_preview("GetQualifying: Skipping " .. n .. " - " .. skipReason)
                    end
                end
            end
        end
    end
    
    --AH.print_debug_vendor_preview("GetQualifying: Scan complete. Found " .. #itemsToVendor .. " items for vendor.")

    vendorListCache.generation = generation
    vendorListCache.key = cacheKey
    vendorListCache.timestamp = now
    vendorListCache.data = itemsToVendor

    return itemsToVendor
end
_G.GetQualifyingVendorItems = AH.GetQualifyingVendorItems

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

    ClearCursor()
    return true
end

------------------------------------------------------------------------
-- Actually sell the items
------------------------------------------------------------------------
function AH.SellQualifiedItemsFromDialog(itemsToSellFromDialog)
    if not (AH.IsVendorWindowOpen and AH.IsVendorWindowOpen()) then
        --AH.print_debug_vendor_preview("SellQualifiedItemsFromDialog: Merchant frame not shown.")
        return
    end
    if #itemsToSellFromDialog == 0 then
        --AH.print_debug_vendor_preview("SellQualifiedItemsFromDialog: No items to sell.")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd200[Attune Helper]|r No items to vendor based on current settings.")
        return
    end

    local limitSelling = (AttuneHelperDB["Limit Selling to 12 Items?"] == 1)
    local maxItemsPerVendorPass = 85
    local configuredMaxSellCount = limitSelling and 12 or #itemsToSellFromDialog
    local maxSellCount = math.min(configuredMaxSellCount, maxItemsPerVendorPass)
    local soldCount = 0

    --AH.print_debug_vendor_preview("SellQualifiedItemsFromDialog: Attempting to sell up to " .. maxSellCount .. " items.")

    for i = 1, math.min(#itemsToSellFromDialog, maxSellCount) do
        local item = itemsToSellFromDialog[i]
        if item and item.bag and item.slot then
            local currentItemLinkInSlot = GetContainerItemLink(item.bag, item.slot)
            if currentItemLinkInSlot and currentItemLinkInSlot == item.link then
                UseContainerItem(item.bag, item.slot)
                soldCount = soldCount + 1
                local displayName = BuildVendorDisplayName(item)
                print("|cffffd200[Attune Helper]|r Sold: " .. displayName)
                --AH.print_debug_vendor_preview("SellQualifiedItemsFromDialog: Sold " .. displayName)
            end
        end
    end

    if soldCount > 0 then
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffffd200[Attune Helper]|r Sold %d item(s).", soldCount))
        if #itemsToSellFromDialog > maxSellCount then
            local remainingCount = #itemsToSellFromDialog - maxSellCount
            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffffd200[Attune Helper]|r Vendor safeguard: stopped at %d items to prevent packet disconnects. %d item(s) remain; click again to continue.", maxSellCount, remainingCount))
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd200[Attune Helper]|r No items were actually sold.")
    end
end
_G.SellQualifiedItemsFromDialog = AH.SellQualifiedItemsFromDialog

------------------------------------------------------------------------
-- Main vendor function called by button clicks
------------------------------------------------------------------------
function AH.VendorAttunedItems(buttonSelf)
    if not (AH.IsVendorWindowOpen and AH.IsVendorWindowOpen()) then
        --AH.print_debug_vendor_preview("VendorAttunedItems: Merchant frame not shown.")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[Attune Helper]|r You must have a merchant window open to vendor items.")
        return
    end

    local itemsToSell = AH.GetQualifyingVendorItems()
    if #itemsToSell == 0 then
        --AH.print_debug_vendor_preview("VendorAttunedItems: No items qualify for vendoring.")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd200[Attune Helper]|r No items to vendor based on current settings.")
        return
    end

    if AttuneHelperDB["EnableVendorSellConfirmationDialog"] == 1 then
        local confirmText = "|cffffd200The following items will be sold:|r\n\n"
        local itemCountInPopup = 0
        local previewLimit = 10
        local overflowItems = {}
        for i, itemData in ipairs(itemsToSell) do
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
        confirmText = confirmText .. "\n\nAre you sure you want to sell these items?"
        StaticPopup_Show("AH_VENDOR_CONFIRM", confirmText, nil, {
            itemsToSell = itemsToSell,
            overflowItems = overflowItems,
            overflowCount = #overflowItems
        })
        --AH.print_debug_vendor_preview("VendorAttunedItems: Showing confirmation dialog for " .. #itemsToSell .. " items.")
    else
        -- Sell directly without confirmation
        --AH.print_debug_vendor_preview("VendorAttunedItems: Selling directly, confirmation dialog disabled.")
        AH.SellQualifiedItemsFromDialog(itemsToSell)
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
                    AHVendorOverflowTooltip:SetOwner(button, "ANCHOR_NONE")
                    AHVendorOverflowTooltip:ClearAllPoints()
                    if AttuneHelperDB["Vendor preview on Right (Default On)"] ~= 0 then
                        AHVendorOverflowTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 10, 0)
                    else
                        AHVendorOverflowTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -10, 0)
                    end
                    AHVendorOverflowTooltip:ClearLines()
                    AHVendorOverflowTooltip:SetText(string.format("Additional items (%d)", data.overflowCount), 1, 1, 0)

                    for _, itemData in ipairs(data.overflowItems or {}) do
                        local _, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemData.link)
                        if (not itemTexture) and itemData.bag and itemData.slot then
                            local _, _, _, _, _, _, _, _, _, containerTexture = GetContainerItemInfo(itemData.bag, itemData.slot)
                            itemTexture = containerTexture
                        end

                        local iconText = itemTexture and string.format("|T%s:14:14:0:0:64:64:4:60:4:60|t ", itemTexture) or ""
                        local displayName = BuildVendorDisplayName(itemData)
                        local _, r, g, b = GetItemQualityColor(itemQuality or 1)
                        r, g, b = r or 1, g or 1, b or 1
                        AHVendorOverflowTooltip:AddLine(iconText .. displayName, r, g, b, true)
                    end
                    AHVendorOverflowTooltip:Show()
                end)
                self.button1:SetScript("OnLeave", function()
                    AHVendorOverflowTooltip:Hide()
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
            --AH.print_debug_vendor_preview("Vendor confirmation cancelled.")
        end,
        OnHide = function(self)
            self.button1:SetScript("OnEnter", nil)
            self.button1:SetScript("OnLeave", nil)
            AHVendorOverflowTooltip:Hide()
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
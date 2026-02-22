-- ʕ •ᴥ•ʔ✿ Gameplay · Vendor logic & selling ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

------------------------------------------------------------------------
-- Get items that qualify for vendoring based on settings
------------------------------------------------------------------------
function AH.GetQualifyingVendorItems()
    local itemsToVendor = {}
    local boeScanTT = nil

    AH.print_debug_vendor_preview("=== GetQualifyingVendorItems: Starting scan ===")

    local function IsBoEUnboundForVendorCheck(itemID, bag, slot_idx)
        if not itemID then return false end
        if not boeScanTT then
            boeScanTT = CreateFrame("GameTooltip", "AHBoEScanVendor", UIParent, "GameTooltipTemplate")
        end
        boeScanTT:SetOwner(UIParent, "ANCHOR_NONE")
        boeScanTT:SetHyperlink("item:" .. itemID)
        local isBoE = false
        for i = 1, boeScanTT:NumLines() do
            local lt = _G[boeScanTT:GetName() .. "TextLeft" .. i]
            if lt and string.find(lt:GetText() or "", _G.ITEM_BIND_ON_EQUIP) then
                isBoE = true
                break
            end
        end
        if isBoE and bag and slot_idx then
            boeScanTT:SetOwner(UIParent, "ANCHOR_NONE")
            boeScanTT:SetBagItem(bag, slot_idx)
            for i = 1, boeScanTT:NumLines() do
                local lt = _G[boeScanTT:GetName() .. "TextLeft" .. i]
                if lt and string.find(lt:GetText() or "", _G.ITEM_SOULBOUND) then
                    boeScanTT:Hide()
                    return false
                end
            end
        end
        boeScanTT:Hide()
        return isBoE
    end

    -- Determine which bags to scan (include bank if open)
    local bagsToScan = {0, 1, 2, 3, 4}
    if BankFrame and BankFrame:IsShown() then
        for bankBag = 5, 11 do
            table.insert(bagsToScan, bankBag)
        end
        AH.print_debug_vendor_preview("GetQualifying: Including bank bags in vendor scan.")
    end

    AH.print_debug_vendor_preview("GetQualifying: Scanning bags: " .. table.concat(bagsToScan, ", "))

    local totalItemsProcessed = 0
    local itemsSkippedCount = 0

    for bagIndex, b in ipairs(bagsToScan) do
        AH.print_debug_vendor_preview("GetQualifying: === Processing bag " .. b .. " ===")
        
        local bagSlots = GetContainerNumSlots(b)
        AH.print_debug_vendor_preview("GetQualifying: Bag " .. b .. " has " .. bagSlots .. " slots")
        
        for s = 1, bagSlots do
            totalItemsProcessed = totalItemsProcessed + 1
            
            local link = GetContainerItemLink(b, s)
            local id = GetContainerItemID(b, s)
            
            if link and id then
                local success, n, itemLinkFull, q, _, _, _, _, _, itemTexture, _, sellP = pcall(GetItemInfo, link)
                
                if success and n then
                    AH.print_debug_vendor_preview("GetQualifying: Processing item: " .. n .. " (ID: " .. id .. ")")
                    
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

                    if not skip and AHIgnoreList[n] then
                        skip = true
                        skipReason = "In AHIgnore list"
                    end

                    if not skip and AHSetList[n] then
                        skip = true
                        skipReason = "In AHSet list"
                    end

                    -- Check equipment sets
                    if not skip then
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
                    
                        if setItems[id] then
                            skip = true
                            skipReason = "In Equipment Set"
                        end
                    end

                    -- Check attunement progress
                    if not skip then
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
					
					-- Check poor or normal quality
					if not skip and (AttuneHelperDB["Do Not Sell Grey And White Items"] == 1) and  ((q == 1) or (q == 0)) then
                        skip = true
                        skipReason = "Item is attunable by other accounts."
                    end

                    -- Final qualification checks
                    if not skip then
                        local isBoEU, isMSuccess, isM = false, true, false
                        
                        local boeSuccess, boeResult = pcall(IsBoEUnboundForVendorCheck, id, b, s)
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
                            AH.print_debug_vendor_preview("GetQualifying: ✓ ADDING to vendor list: " .. n)
                        else
                            skip = true
                            skipReason = "BoE/Mythic rules (doSell=" .. tostring(doSell) .. ", noSellBoE=" .. tostring(noSellBoE) .. ")"
                        end
                    end

                    if skip then
                        itemsSkippedCount = itemsSkippedCount + 1
                        AH.print_debug_vendor_preview("GetQualifying: Skipping " .. n .. " - " .. skipReason)
                    end
                end
            end
        end
    end
    
    AH.print_debug_vendor_preview("GetQualifying: Scan complete. Found " .. #itemsToVendor .. " items for vendor.")
    return itemsToVendor
end
_G.GetQualifyingVendorItems = AH.GetQualifyingVendorItems

------------------------------------------------------------------------
-- Actually sell the items
------------------------------------------------------------------------
function AH.SellQualifiedItemsFromDialog(itemsToSellFromDialog)
    if not MerchantFrame:IsShown() then
        AH.print_debug_vendor_preview("SellQualifiedItemsFromDialog: Merchant frame not shown.")
        return
    end
    if #itemsToSellFromDialog == 0 then
        AH.print_debug_vendor_preview("SellQualifiedItemsFromDialog: No items to sell.")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd200[Attune Helper]|r No items to vendor based on current settings.")
        return
    end

    local limitSelling = (AttuneHelperDB["Limit Selling to 12 Items?"] == 1)
    local maxSellCount = limitSelling and 12 or #itemsToSellFromDialog
    local soldCount = 0

    AH.print_debug_vendor_preview("SellQualifiedItemsFromDialog: Attempting to sell up to " .. maxSellCount .. " items.")

    for i = 1, math.min(#itemsToSellFromDialog, maxSellCount) do
        local item = itemsToSellFromDialog[i]
        if item and item.bag and item.slot then
            local currentItemLinkInSlot = GetContainerItemLink(item.bag, item.slot)
            if currentItemLinkInSlot and currentItemLinkInSlot == item.link then
                UseContainerItem(item.bag, item.slot)
                soldCount = soldCount + 1
                print("|cffffd200[Attune Helper]|r Sold: " .. item.name)
                AH.print_debug_vendor_preview("SellQualifiedItemsFromDialog: Sold " .. item.name)
            end
        end
    end

    if soldCount > 0 then
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffffd200[Attune Helper]|r Sold %d item(s).", soldCount))
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd200[Attune Helper]|r No items were actually sold.")
    end
end
_G.SellQualifiedItemsFromDialog = AH.SellQualifiedItemsFromDialog

------------------------------------------------------------------------
-- Main vendor function called by button clicks
------------------------------------------------------------------------
function AH.VendorAttunedItems(buttonSelf)
    if not MerchantFrame:IsShown() then
        AH.print_debug_vendor_preview("VendorAttunedItems: Merchant frame not shown.")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[Attune Helper]|r You must have a merchant window open to vendor items.")
        return
    end

    local itemsToSell = AH.GetQualifyingVendorItems()
    if #itemsToSell == 0 then
        AH.print_debug_vendor_preview("VendorAttunedItems: No items qualify for vendoring.")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd200[Attune Helper]|r No items to vendor based on current settings.")
        return
    end

    if AttuneHelperDB["EnableVendorSellConfirmationDialog"] == 1 then
        local confirmText = "|cffffd200The following items will be sold:|r\n\n"
        local itemCountInPopup = 0
        for i, itemData in ipairs(itemsToSell) do
            if i <= 10 then -- Limit items shown in popup
                local _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemData.link)
                local iconString = ""
                if itemTexture then
                    iconString = string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t ", itemTexture)
                end
                confirmText = confirmText .. iconString .. (itemData.link or itemData.name) .. "\n"
                itemCountInPopup = itemCountInPopup + 1
            else
                confirmText = confirmText .. "\n|cffcccccc...and " .. (#itemsToSell - itemCountInPopup) .. " more items.|r"
                break
            end
        end
        confirmText = confirmText .. "\n\nAre you sure you want to sell these items?"
        StaticPopup_Show("AH_VENDOR_CONFIRM", confirmText, nil, {itemsToSell = itemsToSell})
        AH.print_debug_vendor_preview("VendorAttunedItems: Showing confirmation dialog for " .. #itemsToSell .. " items.")
    else
        -- Sell directly without confirmation
        AH.print_debug_vendor_preview("VendorAttunedItems: Selling directly, confirmation dialog disabled.")
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
        OnAccept = function(self, data)
            if data and data.itemsToSell then
                AH.SellQualifiedItemsFromDialog(data.itemsToSell)
            end
        end,
        OnCancel = function()
            AH.print_debug_vendor_preview("Vendor confirmation cancelled.")
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
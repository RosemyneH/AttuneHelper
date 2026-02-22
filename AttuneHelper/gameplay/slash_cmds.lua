-- ʕ •ᴥ•ʔ✿ Gameplay · Slash commands ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

------------------------------------------------------------------------
-- Main /ath command
------------------------------------------------------------------------
SLASH_ATTUNEHELPER1 = "/ath"
SlashCmdList["ATTUNEHELPER"] = function(msg)
    -- ʕ •ᴥ•ʔ✿ Ensure UI is initialized before accessing frames ✿ ʕ •ᴥ•ʔ
    if not AH or not AH.UI then
        print("|cffff0000[AttuneHelper]|r UI not yet initialized. Please try again in a moment.")
        return
    end
    
    local cmd = msg:lower():match("^(%S*)")
    if cmd == "reset" then
        if AH.UI.mainFrame then
            AH.UI.mainFrame:ClearAllPoints()
            AH.UI.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            AttuneHelperDB.FramePosition = {"CENTER", UIParent, "CENTER", 0, 0}
        end
        if AH.UI.miniFrame then
            AH.UI.miniFrame:ClearAllPoints()
            AH.UI.miniFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            AttuneHelperDB.MiniFramePosition = {"CENTER", UIParent, "CENTER", 0, 0}
        end
    elseif cmd == "show" then
        if AttuneHelperDB["Mini Mode"] == 1 and AH.UI.miniFrame then
            AH.UI.miniFrame:Show()
        elseif AH.UI.mainFrame then
            AH.UI.mainFrame:Show()
        end
    elseif cmd == "hide" then
        if AttuneHelperDB["Mini Mode"] == 1 and AH.UI.miniFrame then
            AH.UI.miniFrame:Hide()
        elseif AH.UI.mainFrame then
            AH.UI.mainFrame:Hide()
        end
    elseif cmd == "sort" then
        local button = AH.UI.buttons and AH.UI.buttons.sort
        local fn = button and button:GetScript("OnClick")
        if fn then fn() end
    elseif cmd == "equip" then
        local button = AH.UI.buttons and AH.UI.buttons.equipAll
        local fn = button and button:GetScript("OnClick")
        if fn then fn() end
    elseif cmd == "vendor" then
        local buttonToClick = AH.UI.buttons and AH.UI.buttons.vendor
        if AttuneHelperDB["Mini Mode"] == 1 and AH.UI.miniButtons and AH.UI.miniButtons.vendor then
            buttonToClick = AH.UI.miniButtons.vendor
        end
        if buttonToClick and buttonToClick:GetScript("OnClick") then
            buttonToClick:GetScript("OnClick")(buttonToClick)
        end
    else
        print("/ath show|hide|reset|equip|sort|vendor")
    end
end

------------------------------------------------------------------------
-- /AHIgnore command
------------------------------------------------------------------------
SLASH_AHIGNORE1 = "/AHIgnore"
SlashCmdList["AHIGNORE"] = function(msg)
    local itemName = GetItemInfo(msg)
    if not itemName then 
        print("Invalid item link.") 
        return 
    end
    AHIgnoreList[itemName] = not AHIgnoreList[itemName]
    print(itemName .. (AHIgnoreList[itemName] and " is now ignored." or " will no longer be ignored."))
end

------------------------------------------------------------------------
-- /AHSet command
------------------------------------------------------------------------
SLASH_AHSET1 = "/AHSet"
SlashCmdList["AHSET"] = function(msg)
    local itemLinkPart = msg:match("^%s*(.-)%s*$")
    local slotArg = ""
    local msgLower = itemLinkPart:lower()

    -- Build keyword list
    local knownKeywords = {"remove"}
    local slotAliases = {
        oh="SecondaryHandSlot", offhand="SecondaryHandSlot", head="HeadSlot", neck="NeckSlot",
        shoulder="ShoulderSlot", back="BackSlot", chest="ChestSlot", wrist="WristSlot",
        hands="HandsSlot", waist="WaistSlot", legs="LegsSlot", pants="LegsSlot", feet="FeetSlot",
        finger1="Finger0Slot", finger2="Finger1Slot", ring1="Finger0Slot", ring2="Finger1Slot",
        trinket1="Trinket0Slot", trinket2="Trinket1Slot", mh="MainHandSlot", mainhand="MainHandSlot",
        ranged="RangedSlot"
    }
    local allInventorySlots = {
        "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot",
        "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
        "Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot"
    }

    if slotAliases then
        for alias, _ in pairs(slotAliases) do
            table.insert(knownKeywords, alias:lower())
        end
    end
    for _, slotNameValue in ipairs(allInventorySlots) do
        table.insert(knownKeywords, slotNameValue:lower())
    end

    table.sort(knownKeywords, function(a,b) return #a > #b end)

    local foundKeyword = false
    for _, keyword in ipairs(knownKeywords) do
        if msgLower:len() >= (keyword:len() + 1) and msgLower:sub(-(keyword:len() + 1)) == " " .. keyword then
            slotArg = itemLinkPart:sub(-keyword:len())
            itemLinkPart = itemLinkPart:sub(1, itemLinkPart:len() - (keyword:len() + 1))
            itemLinkPart = itemLinkPart:match("^%s*(.-)%s*$") or ""
            foundKeyword = true
            break
        end
    end

    if not itemLinkPart or itemLinkPart == "" then
        print("|cffff0000[AttuneHelper]|r Usage: /ahset <itemlink> [mh|oh|SlotName|remove]")
        return
    end

    local itemName, _, _, _, _, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(itemLinkPart)
    if not itemName then
        print("|cffff0000[AttuneHelper]|r Invalid item link provided.")
        return
    end

    local processedSlotArg = slotArg:lower()

    if processedSlotArg == "remove" then
        if AHSetList[itemName] then
            AHSetList[itemName] = nil
            print("|cffffd200[AttuneHelper]|r '" .. itemName .. "' removed from AHSet.")
            for i=0,4 do AH.UpdateBagCache(i) end
            AH.UpdateItemCountText()
        else
            print("|cffffd200[AttuneHelper]|r '" .. itemName .. "' was not in AHSet.")
        end
        return
    end

    local targetSlotName = nil
    local slotArgIsAliasOrDirect = false

    if processedSlotArg ~= "" then
        if slotAliases and slotAliases[processedSlotArg] then
            targetSlotName = slotAliases[processedSlotArg]
            slotArgIsAliasOrDirect = true
        else
            for _, validSlot in ipairs(allInventorySlots) do
                if string.lower(validSlot) == processedSlotArg then
                    targetSlotName = validSlot
                    slotArgIsAliasOrDirect = true
                    break
                end
            end
        end

        if not slotArgIsAliasOrDirect then
            print("|cffff0000[AttuneHelper]|r Invalid slot argument: '" .. slotArg .. "'.")
            return
        end
    else
        local weaponAndOffhandTypes = {
            INVTYPE_WEAPON = true, INVTYPE_2HWEAPON = true, INVTYPE_WEAPONMAINHAND = true, 
            INVTYPE_WEAPONOFFHAND = true, INVTYPE_HOLDABLE = true, INVTYPE_SHIELD = true,
            INVTYPE_RANGED = true, INVTYPE_THROWN = true, INVTYPE_RANGEDRIGHT = true, 
            INVTYPE_RELIC = true, INVTYPE_WAND = true
        }

        if weaponAndOffhandTypes[itemEquipLoc] then
            print("|cffff0000[AttuneHelper]|r For weapons, please specify the target slot.")
            return
        else
            local unifiedSlots = AH.itemTypeToUnifiedSlot[itemEquipLoc]
            if type(unifiedSlots) == "string" then
                targetSlotName = unifiedSlots
            elseif type(unifiedSlots) == "table" then
                print("|cffff0000[AttuneHelper]|r Item can fit multiple slots. Please specify exactly.")
                return
            else
                print("|cffff0000[AttuneHelper]|r Could not determine slot for item.")
                return
            end
        end
    end

    if AHSetList[itemName] == targetSlotName then
        AHSetList[itemName] = nil
        print("|cffffd200[AttuneHelper]|r '" .. itemName .. "' removed from AHSet for slot " .. targetSlotName .. ".")
    else
        AHSetList[itemName] = targetSlotName
        print("|cffffd200[AttuneHelper]|r '" .. itemName .. "' added to AHSet, designated for slot " .. targetSlotName .. ".")
    end

    for i=0,4 do AH.UpdateBagCache(i) end
    AH.UpdateItemCountText()
end

------------------------------------------------------------------------
-- Other slash commands
------------------------------------------------------------------------
SLASH_ATH2H1 = "/ah2h"
SlashCmdList["ATH2H"] = function()
    AttuneHelperDB["Disable Two-Handers"] = 1 - (AttuneHelperDB["Disable Two-Handers"] or 0)
    print("|cffffd200[AH]|r 2H equipping " .. (AttuneHelperDB["Disable Two-Handers"] == 1 and "disabled." or "enabled."))
end

SLASH_AHTOGGLE1 = "/ahtoggle"
SlashCmdList["AHTOGGLE"] = function()
    AH.ToggleAutoEquip()
end

SLASH_AHSETLIST1 = "/ahsetlist"
SlashCmdList["AHSETLIST"] = function()
    local c = 0
    print("|cffffd200[AH]|r AHSetList Items:")
    for n, s_val in pairs(AHSetList) do
        if s_val then
            print("- " .. n .. " (Slot: " .. tostring(s_val) .. ")")
            c = c + 1
        end
    end
    if c == 0 then
        print("|cffffd200[AH]|r No items in AHSetList.")
    end
end

SLASH_AHSETALL1 = "/ahsetall"
SlashCmdList["AHSETALL"] = function()
    AH.SetAHSetToEquipped()
end

SLASH_AHIGNORELIST1 = "/ahignorelist"
SlashCmdList["AHIGNORELIST"] = function()
    local c = 0
    print("|cffffd200[AH]|r Ignored:")
    for n, enable_flag in pairs(AHIgnoreList) do
        if enable_flag then
            print("- " .. n)
            c = c + 1
        end
    end
    if c == 0 then
        print("|cffffd200[AH]|r No ignored items.")
    end
end

SLASH_AHBL1 = "/ahbl"
SlashCmdList["AHBL"] = function(m)
    local k = m:lower():match("^(%S*)")
    local slotAliases = {
        oh="SecondaryHandSlot", offhand="SecondaryHandSlot", head="HeadSlot", neck="NeckSlot",
        shoulder="ShoulderSlot", back="BackSlot", chest="ChestSlot", wrist="WristSlot",
        hands="HandsSlot", waist="WaistSlot", legs="LegsSlot", pants="LegsSlot", feet="FeetSlot",
        finger1="Finger0Slot", finger2="Finger1Slot", ring1="Finger0Slot", ring2="Finger1Slot",
        trinket1="Trinket0Slot", trinket2="Trinket1Slot", mh="MainHandSlot", mainhand="MainHandSlot",
        ranged="RangedSlot"
    }
    local sV = slotAliases[k]
    if not sV then
        print("|cffff0000[AH]|r Usage: /ahbl <slot_keyword>")
        return
    end
    AttuneHelperDB[sV] = 1 - (AttuneHelperDB[sV] or 0)
    print(string.format("|cffffd200[AH]|r %s %s.", sV, (AttuneHelperDB[sV] == 1 and "blacklisted" or "unblacklisted")))
    AH.ForceSaveSettings()
end

SLASH_AHBLL1 = "/ahbll"
SlashCmdList["AHBLL"] = function()
    local slots = {"HeadSlot","NeckSlot","ShoulderSlot","BackSlot","ChestSlot","WristSlot","HandsSlot","WaistSlot","LegsSlot","FeetSlot","Finger0Slot","Finger1Slot","Trinket0Slot","Trinket1Slot","MainHandSlot","SecondaryHandSlot","RangedSlot"}
    local f = false
    print("|cffffd200[AH]|r Blacklisted Slots:")
    for _, sN in ipairs(slots) do
        if AttuneHelperDB[sN] == 1 then
            print("- " .. sN)
            f = true
        end
    end
    if not f then
        print("|cffffd200[AH]|r No blacklisted slots.")
    end
end

SLASH_AHTOGGLERECYCLE1 = "/ahtogglerecycle"
SlashCmdList["AHTOGGLERECYCLE"] = function()
    AttuneHelperDB["Do Not Sell Grey And White Items"] = 1 - (AttuneHelperDB["Do Not Sell Grey And White Items"] or 0)
    print("|cffffd200[AH]|r Do Not Sell Grey And White Items: " .. (AttuneHelperDB["Do Not Sell Grey And White Items"] == 1 and "|cff00ff00Enabled|r." or "|cffff0000Disabled|r."))
end

-- ʕ •ᴥ•ʔ✿ Performance monitoring commands ✿ ʕ •ᴥ•ʔ
SLASH_AHPERF1 = "/ahperf"
SlashCmdList["AHPERF"] = function()
    if AH.GetCacheStats then
        print("|cffffd200[AH]|r " .. AH.GetCacheStats())
    end
    if AH.GetMemoryUsage then
        print("|cffffd200[AH]|r Memory Usage: " .. AH.GetMemoryUsage())
    end
    if AH.EnhancedCleanupCaches then
        print("|cffffd200[AH]|r Enhanced cleanup available")
    end
end

SLASH_AHCLEANUP1 = "/ahcleanup"
SlashCmdList["AHCLEANUP"] = function()
    if AH.EnhancedCleanupCaches then
        print("|cffffd200[AH]|r Running enhanced cleanup...")
        AH.EnhancedCleanupCaches()
    elseif AH.CleanupCaches then
        print("|cffffd200[AH]|r Running standard cleanup...")
        AH.CleanupCaches()
    else
        print("|cffffd200[AH]|r No cleanup function available")
    end
end

SLASH_AHCACHE1 = "/ahcache"
SlashCmdList["AHCACHE"] = function()
    if AH.EnhancedBagCacheCleanup then
        print("|cffffd200[AH]|r Running bag cache cleanup...")
        AH.EnhancedBagCacheCleanup()
    else
        print("|cffffd200[AH]|r No bag cache cleanup available")
    end
end

function AH.SlashCommand(msg)
    if not msg then return end
    
    msg = msg:lower():trim()
    
    if msg == "help" then
        print("|cff00ff00[AttuneHelper]|r Available commands:")
        print("  |cffffd200/ah show|r - Show AttuneHelper frame")
        print("  |cffffd200/ah hide|r - Hide AttuneHelper frame")
        print("  |cffffd200/ah toggle|r - Toggle auto-equip after combat")
        print("  |cffffd200/ah togglemini|r - Toggle mini/full mode")
        print("  |cffffd200/ah reset|r - Reset frame positions to center")
        print("  |cffffd200/ah bag|r - Toggle disenchant target bag (0 or 1)")
        print("  |cffffd200/ah weapons|r - Show weapon control settings")
        print("  |cffffd200/ah blacklist <slot>|r - Toggle slot blacklist")
        print("  |cffffd200/ahbl <slot>|r - Toggle slot blacklist (short)")
        print("  |cffffd200/ahtoggle|r - Toggle auto-equip (alias)")
        return
    end
    
    if msg == "memory" then
        local memAfter, memFreed = AH.GetMemoryUsage()
        print(string.format("|cff00ff00[AttuneHelper]|r Current memory usage: %.1fKB", memAfter))
        print(string.format("|cff00ff00[AttuneHelper]|r Bag cache entries: %d", AH.bagSlotCache and table.getn(AH.bagSlotCache) or 0))
        print(string.format("|cff00ff00[AttuneHelper]|r ItemInfo cache entries: %d", AH.itemInfoCache and table.getn(AH.itemInfoCache) or 0))
        return
    end
    
    if msg == "cleanup" then
        if AH.EnhancedCleanupCaches then
            print("|cffffd200[AH]|r Running enhanced cleanup...")
            AH.EnhancedCleanupCaches()
        elseif AH.CleanupCaches then
            print("|cffffd200[AH]|r Running standard cleanup...")
            AH.CleanupCaches()
        else
            print("|cffffd200[AH]|r No cleanup function available")
        end
        return
    end

    if msg == "toggle" then
        -- Toggle auto-equip after combat
        AttuneHelperDB["Auto Equip Attunable After Combat"] = 1 - (AttuneHelperDB["Auto Equip Attunable After Combat"] or 0)
        print("|cff00ff00[AttuneHelper]|r Auto-equip after combat " .. (AttuneHelperDB["Auto Equip Attunable After Combat"] == 1 and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
        AH.ForceSaveSettings()
        return
    end
    
    if msg == "togglemini" then
        AttuneHelperDB["Mini Mode"] = 1 - (AttuneHelperDB["Mini Mode"] or 0)
        print("|cffffd200[AH]|r Mini mode: " .. (AttuneHelperDB["Mini Mode"] == 1 and "enabled." or "disabled."))
        
        -- Update display mode to show the correct frame
        if AH.UpdateDisplayMode then
            AH.UpdateDisplayMode()
        else
            -- Fallback if UpdateDisplayMode not available
            if AttuneHelperDB["Mini Mode"] == 1 then
                if AH.UI.mainFrame then AH.UI.mainFrame:Hide() end
                if AH.UI.miniFrame then AH.UI.miniFrame:Show() end
            else
                if AH.UI.miniFrame then AH.UI.miniFrame:Hide() end
                if AH.UI.mainFrame then AH.UI.mainFrame:Show() end
            end
        end
        AH.ForceSaveSettings()
        return
    end

    if msg == "equip" then
        local slot = msg:match("^equip (%S+)$")
        if not slot then
            print("|cffff0000[AttuneHelper]|r Usage: /ah equip <slot>")
            return
        end
        local targetSlotName = AH.slotNameToSlot[slot]
        if not targetSlotName then
            print("|cffff0000[AttuneHelper]|r Invalid slot: " .. slot)
            return
        end
        AH.EquipItemForSlot(targetSlotName)
        return
    end

    if msg == "blacklist" then
        local slot = msg:match("^blacklist (%S+)$")
        if not slot then
            print("|cffff0000[AttuneHelper]|r Usage: /ah blacklist <slot>")
            return
        end
        local targetSlotName = AH.slotNameToSlot[slot]
        if not targetSlotName then
            print("|cffff0000[AttuneHelper]|r Invalid slot: " .. slot)
            return
        end
        AH.ToggleSlotBlacklist(targetSlotName)
        return
    end

    if msg == "show" then
        if AttuneHelperDB["Mini Mode"] == 1 then
            if AH.UI.miniFrame then
                AH.UI.miniFrame:Show()
            end
        else
            if AH.UI.mainFrame then
                AH.UI.mainFrame:Show()
            end
        end
        return
    end

    if msg == "hide" then
        if AttuneHelperDB["Mini Mode"] == 1 then
            if AH.UI.miniFrame then
                AH.UI.miniFrame:Hide()
            end
        else
            if AH.UI.mainFrame then
                AH.UI.mainFrame:Hide()
            end
        end
        return
    end
    
    if msg == "reset" then
        -- Reset frame positions to center
        AttuneHelperDB["FramePosition"] = { "CENTER", UIParent, "CENTER", 0, 0 }
        AttuneHelperDB["MiniFramePosition"] = { "CENTER", UIParent, "CENTER", 0, 0 }
        
        if AH.UI.mainFrame then
            AH.UI.mainFrame:ClearAllPoints()
            AH.UI.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
        if AH.UI.miniFrame then
            AH.UI.miniFrame:ClearAllPoints()
            AH.UI.miniFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
        
        print("|cffffd200[AH]|r Frame positions reset to center.")
        AH.ForceSaveSettings()
        return
    end

    -- ʕ •ᴥ•ʔ✿ Weapon type control commands ✿ ʕ •ᴥ•ʔ
    if msg == "weapons" then
        print("|cff00ff00[AttuneHelper]|r Weapon Type Settings:")
        print("|cff00ff00MainHand 1H:|r " .. (AttuneHelperDB["Allow MainHand 1H Weapons"] == 1 and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"))
        print("|cff00ff00MainHand 2H:|r " .. (AttuneHelperDB["Allow MainHand 2H Weapons"] == 1 and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"))
        print("|cff00ff00OffHand 1H:|r " .. (AttuneHelperDB["Allow OffHand 1H Weapons"] == 1 and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"))
        print("|cff00ff00OffHand 2H:|r " .. (AttuneHelperDB["Allow OffHand 2H Weapons"] == 1 and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"))
        print("|cff00ff00OffHand Shields:|r " .. (AttuneHelperDB["Allow OffHand Shields"] == 1 and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"))
        print("|cff00ff00OffHand Holdables:|r " .. (AttuneHelperDB["Allow OffHand Holdables"] == 1 and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"))
        return
    end
    
    if msg == "mh1h" then
        AttuneHelperDB["Allow MainHand 1H Weapons"] = 1 - (AttuneHelperDB["Allow MainHand 1H Weapons"] or 0)
        print("|cff00ff00[AttuneHelper]|r MainHand 1H weapons " .. (AttuneHelperDB["Allow MainHand 1H Weapons"] == 1 and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
        AH.ForceSaveSettings()
        return
    end
    
    if msg == "mh2h" then
        AttuneHelperDB["Allow MainHand 2H Weapons"] = 1 - (AttuneHelperDB["Allow MainHand 2H Weapons"] or 0)
        print("|cff00ff00[AttuneHelper]|r MainHand 2H weapons " .. (AttuneHelperDB["Allow MainHand 2H Weapons"] == 1 and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
        AH.ForceSaveSettings()
        return
    end
    
    if msg == "oh1h" then
        AttuneHelperDB["Allow OffHand 1H Weapons"] = 1 - (AttuneHelperDB["Allow OffHand 1H Weapons"] or 0)
        print("|cff00ff00[AttuneHelper]|r OffHand 1H weapons " .. (AttuneHelperDB["Allow OffHand 1H Weapons"] == 1 and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
        AH.ForceSaveSettings()
        return
    end
    
    if msg == "oh2h" then
        AttuneHelperDB["Allow OffHand 2H Weapons"] = 1 - (AttuneHelperDB["Allow OffHand 2H Weapons"] or 0)
        print("|cff00ff00[AttuneHelper]|r OffHand 2H weapons " .. (AttuneHelperDB["Allow OffHand 2H Weapons"] == 1 and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
        AH.ForceSaveSettings()
        return
    end
    
    if msg == "ohshield" then
        AttuneHelperDB["Allow OffHand Shields"] = 1 - (AttuneHelperDB["Allow OffHand Shields"] or 0)
        print("|cff00ff00[AttuneHelper]|r OffHand shields " .. (AttuneHelperDB["Allow OffHand Shields"] == 1 and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
        AH.ForceSaveSettings()
        return
    end
    
    if msg == "ohhold" then
        AttuneHelperDB["Allow OffHand Holdables"] = 1 - (AttuneHelperDB["Allow OffHand Holdables"] or 0)
        print("|cff00ff00[AttuneHelper]|r OffHand holdables " .. (AttuneHelperDB["Allow OffHand Holdables"] == 1 and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
        AH.ForceSaveSettings()
        return
    end

    if msg == "bag" then
        AttuneHelperDB["Use Bag 1 for Disenchant"] = 1 - (AttuneHelperDB["Use Bag 1 for Disenchant"] or 0)
        print("|cffffd200[AH]|r Disenchant target bag: " .. (AttuneHelperDB["Use Bag 1 for Disenchant"] == 1 and "Bag 1" or "Bag 0"))
        AH.ForceSaveSettings()
        return
    end

    print("|cffff0000[AttuneHelper]|r Unknown command: " .. msg)
end

-- Register /ahtoggle as an alias for /ah toggle  
SLASH_AHTOGGLE1 = "/ahtoggle"
SlashCmdList["AHTOGGLE"] = function(msg)
    AH.SlashCommand("toggle")
end 
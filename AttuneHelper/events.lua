-- ʕ •ᴥ•ʔ✿ Events · WoW event handling ✿ ʕ •ᴥ•ʔ
-- Language server refresh trigger
local AH = _G.AttuneHelper

local function ScheduleVendorCompatRefresh(retriesLeft, delay)
    if not AH or not AH.Wait or not AH.RefreshVendorCompatButtons then
        return
    end

    retriesLeft = retriesLeft or 1
    delay = delay or 0.1

    AH.Wait(delay, function()
        AH.RefreshVendorCompatButtons()
        if retriesLeft > 1 then
            ScheduleVendorCompatRefresh(retriesLeft - 1, delay)
        end
    end)
end

local function PrimeVendorCompatFromMerchantShow()
    if AH.vendorCompatPrimed then
        return
    end

    AH.vendorCompatPrimed = true
    ScheduleVendorCompatRefresh(12, 0.1)
end

-- Throttling variables
AH.lastAutoEquipTime = 0
AH.AUTO_EQUIP_COOLDOWN = 2.0 -- ʕ •ᴥ•ʔ✿ Prevent spam equipping ✿ ʕ •ᴥ•ʔ
AH.pendingAutoEquipRetry = false
AH.lastUnitKillAccountRefreshTime = AH.lastUnitKillAccountRefreshTime or 0
AH.UNIT_KILL_ACCOUNT_REFRESH_COOLDOWN = AH.UNIT_KILL_ACCOUNT_REFRESH_COOLDOWN or 0.75

-- Session state variables
AH.isSCKLoaded = false
AH.cannotEquipOffHandWeaponThisSession = false
AH.lastAttemptedSlotForEquip = nil
AH.lastAttemptedItemTypeForEquip = nil

-- Export for legacy compatibility
_G.isSCKLoaded = AH.isSCKLoaded
_G.cannotEquipOffHandWeaponThisSession = AH.cannotEquipOffHandWeaponThisSession
_G.lastAttemptedSlotForEquip = AH.lastAttemptedSlotForEquip
_G.lastAttemptedItemTypeForEquip = AH.lastAttemptedItemTypeForEquip

-- ʕ •ᴥ•ʔ✿ Performance helper for auto-equip throttling ✿ ʕ •ᴥ•ʔ
function AH.ShouldTriggerAutoEquip()
    if AttuneHelperDB["Auto Equip Attunable After Combat"] ~= 1 then
        return false
    end

    local currentTime = GetTime()
    local cooldownTime = AH.AUTO_EQUIP_COOLDOWN

    if currentTime - AH.lastAutoEquipTime < cooldownTime then
        return false
    end

    return true
end

function AH.ScheduleAutoEquipRetry()
    if AH.pendingAutoEquipRetry then
        return
    end

    local cooldownTime = AH.AUTO_EQUIP_COOLDOWN or 2.0
    local elapsed = GetTime() - (AH.lastAutoEquipTime or 0)
    local remaining = cooldownTime - elapsed
    if remaining < 0 then
        remaining = 0
    end

    AH.pendingAutoEquipRetry = true
    AH.Wait(remaining + 0.05, function()
        AH.pendingAutoEquipRetry = false
        AH.TriggerThrottledAutoEquip(0.02)
    end)
end

function AH.TriggerThrottledAutoEquip(delay)
    if not AH.ShouldTriggerAutoEquip() then
        if AttuneHelperDB["Auto Equip Attunable After Combat"] == 1 and AH.ScheduleAutoEquipRetry then
            AH.ScheduleAutoEquipRetry()
        end
        return
    end

    delay = delay or 0.05
    AH.lastAutoEquipTime = GetTime()

    local equipButton = AH.UI.buttons and AH.UI.buttons.equipAll
    if equipButton and equipButton:GetScript("OnClick") then
        local fn = equipButton:GetScript("OnClick")
        AH.Wait(delay, fn)
    end
end

local function IsPrestigedCharacter()
    if type(CMCGetMultiClassEnabled) ~= "function" then
        return false
    end
    return (CMCGetMultiClassEnabled() or 1) >= 2
end

local function GetStoredAccountAttuneTotal()
    if not AttuneHelperDB then
        return 0
    end
    return tonumber(AttuneHelperDB["TrackedAccountAttuneTotal"]) or 0
end

local function SetStoredAccountAttuneTotal(value)
    if not AttuneHelperDB then
        return
    end
    AttuneHelperDB["TrackedAccountAttuneTotal"] = math.max(0, tonumber(value) or 0)
end

local function GetCurrentDateKey()
    return date("%Y-%m-%d")
end

function AH.EnsureDailyAttuneSnapshotCurrent()
    if not AttuneHelperDB then
        return
    end

    local todayKey = GetCurrentDateKey()
    local storedTotal = GetStoredAccountAttuneTotal()
    local snapshotDate = AttuneHelperDB["DailyAttuneSnapshotDate"]

    if snapshotDate ~= todayKey then
        AttuneHelperDB["DailyAttuneSnapshotDate"] = todayKey
        AttuneHelperDB["DailyAttuneSnapshotTotal"] = storedTotal
    elseif AttuneHelperDB["DailyAttuneSnapshotTotal"] == nil then
        AttuneHelperDB["DailyAttuneSnapshotTotal"] = storedTotal
    end
end

local function RefreshMerchantAttuneSummary()
    if AH and AH.RefreshVendorCompatButtons and AH.IsVendorWindowOpen and AH.IsVendorWindowOpen() then
        AH.Wait(0.05, AH.RefreshVendorCompatButtons)
    end
end

------------------------------------------------------------------------
-- UI Initialization
------------------------------------------------------------------------
function AH.InitializeUI()
    -- Create main frame first
    if AH.CreateMainFrame then
        AH.CreateMainFrame()
    end

    -- Create mini frame
    if AH.CreateMiniFrame then
        AH.CreateMiniFrame()
    end

    -- Create main buttons
    if AH.CreateMainButtons then
        AH.CreateMainButtons()
    end

    -- Create mini buttons
    if AH.CreateMiniButtons then
        AH.CreateMiniButtons()
    end

    -- Setup mini button handlers (after main buttons exist)
    if AH.SetupMiniButtonHandlers then
        AH.SetupMiniButtonHandlers()
    end

    -- Initialize options panels
    if AH.InitializeAllOptions then
        AH.InitializeAllOptions()
    end

    -- Register events now that UI is ready
    AH.RegisterEvents()
end

------------------------------------------------------------------------
-- Event registration
------------------------------------------------------------------------
function AH.RegisterEvents()
    if not AH.UI.mainFrame then return end

    AH.UI.mainFrame:RegisterEvent("ADDON_LOADED")
    AH.UI.mainFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    AH.UI.mainFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    AH.UI.mainFrame:RegisterEvent("BAG_UPDATE")
    AH.UI.mainFrame:RegisterEvent("UI_ERROR_MESSAGE")
    AH.UI.mainFrame:RegisterEvent("QUEST_COMPLETE")
    AH.UI.mainFrame:RegisterEvent("QUEST_TURNED_IN")
    AH.UI.mainFrame:RegisterEvent("LOOT_CLOSED")
    AH.UI.mainFrame:RegisterEvent("ITEM_PUSH")
    AH.UI.mainFrame:RegisterEvent("MERCHANT_SHOW")
    AH.UI.mainFrame:RegisterEvent("MERCHANT_CLOSED")
    AH.UI.mainFrame:RegisterEvent("CHAT_MSG_SYSTEM")
    AH.UI.mainFrame:RegisterEvent("UNIT_KILL")

    -- Set the event handler
    AH.UI.mainFrame:SetScript("OnEvent", AH.OnEvent)
end

------------------------------------------------------------------------
-- Event handler
------------------------------------------------------------------------
function AH.OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "AttuneHelper" then
        print("|cff00ff00[AttuneHelper]|r ADDON_LOADED event fired, initializing...")
        AH.InitializeDefaultSettings()
        AH.currentAccountAttuneTotal = GetStoredAccountAttuneTotal()
        AH.EnsureDailyAttuneSnapshotCurrent()

        -- Check for SCK addon
        if _G["SCK"] and type(_G["SCK"].loop) == "function" then
            AH.isSCKLoaded = true
        end

        -- Initialize UI components now that saved variables are loaded
        print("|cff00ff00[AttuneHelper]|r Initializing UI...")
        AH.InitializeUI()
        print("|cff00ff00[AttuneHelper]|r UI initialization complete.")

        if AH.LoadAllSettings then
            AH.LoadAllSettings()
        end

        -- Update display mode after everything is loaded
        if AH.UpdateDisplayMode then
            AH.Wait(0.1, AH.UpdateDisplayMode)
        end

        ScheduleVendorCompatRefresh(1, 0.1)

        if self ~= AH.UI.mainFrame then
            self:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN")

        AH.Wait(1, function()
            if AH.LoadAllSettings then
                AH.LoadAllSettings()
            end
        end)

        AH.Wait(0.5, function()
            -- Only update regular bags, not bank
            for b = 0, 4 do
                if AH.UpdateBagCache then
                    AH.UpdateBagCache(b)
                end
            end
            if AH.RebuildEquipSlotCache then
                AH.RebuildEquipSlotCache()
            end
            if AH.UpdateItemCountText then
                AH.UpdateItemCountText()
            end
        end)
    elseif event == "BAG_UPDATE" then
        if not ItemLocIsLoaded() then
            return
        end

        local updateMask = AH.UPDATE_MASK or { FULL_LIST = 1, OBTAINED = 2, ATTUNED_PERCENT = 4 }

        -- Only update regular bags (0-4), skip bank bags (5+)
        if arg1 <= 4 then
            if AH.RequestUpdateList then
                AH.RequestUpdateList(updateMask.OBTAINED, arg1)
            end
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        AH.Wait(0.15, function()
            if AH.RequestUpdateList then
                local updateMask = AH.UPDATE_MASK or { FULL_LIST = 1, OBTAINED = 2, ATTUNED_PERCENT = 4 }
                AH.RequestUpdateList(bit.bor(updateMask.OBTAINED, updateMask.ATTUNED_PERCENT))
            end
        end)
    elseif event == "QUEST_COMPLETE" or event == "QUEST_TURNED_IN" then
        AH.Wait(0.2, function()
            if AH.RequestUpdateList then
                AH.RequestUpdateList((AH.UPDATE_MASK and AH.UPDATE_MASK.FULL_LIST) or 1)
            end
        end)
    elseif event == "LOOT_CLOSED" then
        -- Sometimes loot doesn't trigger BAG_UPDATE properly
        AH.Wait(0.3, function()
            if AH.RequestUpdateList then
                AH.RequestUpdateList((AH.UPDATE_MASK and AH.UPDATE_MASK.FULL_LIST) or 1)
            end
        end)
    elseif event == "ITEM_PUSH" then
        -- Item push events for items being added to bags
        AH.Wait(0.2, function()
            if AH.RequestUpdateList then
                AH.RequestUpdateList((AH.UPDATE_MASK and AH.UPDATE_MASK.OBTAINED) or 2)
            end
        end)
    elseif event == "MERCHANT_SHOW" then
        AH.EnsureDailyAttuneSnapshotCurrent()
        if AH.SetMerchantWindowOpen then
            AH.SetMerchantWindowOpen(true)
        else
            AH.merchantWindowOpen = true
        end
        PrimeVendorCompatFromMerchantShow()
        ScheduleVendorCompatRefresh(2, 0.05)
    elseif event == "MERCHANT_CLOSED" then
        if AH.SetMerchantWindowOpen then
            AH.SetMerchantWindowOpen(false)
        else
            AH.merchantWindowOpen = false
        end
    elseif event == "CHAT_MSG_SYSTEM" then
        local message = arg1
        if message and string.find(message, "You have attuned with", 1, true) then
            AH.EnsureDailyAttuneSnapshotCurrent()
            AH.currentAccountAttuneTotal = (AH.currentAccountAttuneTotal or GetStoredAccountAttuneTotal()) + 1
            SetStoredAccountAttuneTotal(AH.currentAccountAttuneTotal)
            if AH.RequestUpdateList then
                local updateMask = AH.UPDATE_MASK or { FULL_LIST = 1, OBTAINED = 2, ATTUNED_PERCENT = 4 }
                AH.RequestUpdateList(bit.bor(updateMask.OBTAINED, updateMask.ATTUNED_PERCENT))
            end
            RefreshMerchantAttuneSummary()
        end
    elseif event == "UNIT_KILL" then
        if not IsPrestigedCharacter() then
            return
        end

        local now = GetTime()
        local cooldown = AH.UNIT_KILL_ACCOUNT_REFRESH_COOLDOWN or 0.75
        if (now - (AH.lastUnitKillAccountRefreshTime or 0)) < cooldown then
            return
        end
        AH.lastUnitKillAccountRefreshTime = now

        AH.Wait(0.4, function()
            if AH.RequestUpdateList then
                local updateMask = AH.UPDATE_MASK or { FULL_LIST = 1, OBTAINED = 2, ATTUNED_PERCENT = 4 }
                AH.RequestUpdateList(bit.bor(updateMask.OBTAINED, updateMask.ATTUNED_PERCENT))
            end
        end)
    elseif event == "UI_ERROR_MESSAGE" and arg1 == ERR_ITEM_CANNOT_BE_EQUIPPED then
        if AH.lastAttemptedSlotForEquip == "SecondaryHandSlot" and AH.IsWeaponTypeForOffHandCheck and AH.IsWeaponTypeForOffHandCheck(AH.lastAttemptedItemTypeForEquip) then
            AH.cannotEquipOffHandWeaponThisSession = true
        end
        AH.lastAttemptedSlotForEquip = nil
        AH.lastAttemptedItemTypeForEquip = nil
    end
end

------------------------------------------------------------------------
-- Initialize events system
------------------------------------------------------------------------
-- Create initial event frame to handle ADDON_LOADED
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", AH.OnEvent)

------------------------------------------------------------------------
-- Initialize events
------------------------------------------------------------------------
function AH.InitializeEvents()
    if AH.UI.mainFrame then
        AH.UI.mainFrame:SetScript("OnEvent", AH.OnEvent)
        AH.RegisterEvents()
    end
end

-- Events will be initialized after UI is created in ADDON_LOADED

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
AH.lastAttuneChatSystemHandledAt = AH.lastAttuneChatSystemHandledAt or 0
AH.ATTUNE_CHAT_SYSTEM_BURST_WINDOW = AH.ATTUNE_CHAT_SYSTEM_BURST_WINDOW or 0.8 -- ʕ •ᴥ•ʔ✿ De-dupe chat storms during batch attunes ✿ ʕ •ᴥ•ʔ
AH.pendingAttuneRefresh = AH.pendingAttuneRefresh or false
AH.pendingCustomUIBRefresh = AH.pendingCustomUIBRefresh or false
AH.ATTUNE_REFRESH_BATCH_DELAY = AH.ATTUNE_REFRESH_BATCH_DELAY or 0.25

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

local function RefreshAttuneCountsAndSnapshot()
    if AH.GetCurrentAttuneCounts then
        AH.GetCurrentAttuneCounts()
    end
    if AH.EnsureDailyAttuneSnapshotCurrent then
        AH.EnsureDailyAttuneSnapshotCurrent()
    end
end

function AH.ScheduleAttuneRefresh(delay)
    if AH.pendingAttuneRefresh then
        return
    end

    if not AH.Wait then
        RefreshAttuneCountsAndSnapshot()
        return
    end

    AH.pendingAttuneRefresh = true
    AH.Wait(delay or AH.ATTUNE_REFRESH_BATCH_DELAY or 0.25, function()
        AH.pendingAttuneRefresh = false
        if type(ItemLocIsLoaded) == "function" and not ItemLocIsLoaded() then
            return
        end
        RefreshAttuneCountsAndSnapshot()
    end)
end

function AH.ScheduleCustomUIBRefresh()
    if AH.pendingCustomUIBRefresh then
        return
    end

    AH.pendingCustomUIBRefresh = true

    AH.Wait(0.1, function()
        AH.pendingCustomUIBRefresh = false

        if AH.RequestUpdateList then
            local updateMask = AH.UPDATE_MASK or {
                FULL_LIST = 1,
                OBTAINED = 2,
                ATTUNED_PERCENT = 4
            }

            AH.RequestUpdateList(bit.bor(updateMask.OBTAINED, updateMask.ATTUNED_PERCENT))
        end
    end)
end

function AH.HookCustomItemUpdateButton()
    if AH.hookedCustomItemUpdateButton then
        return
    end

    if type(_cu_uib) ~= "function" then
        return
    end

    AH.hookedCustomItemUpdateButton = true
    AH.old_cu_uib = _cu_uib

    _cu_uib = function(...)
        local results = { AH.old_cu_uib(...) }

        if AH.ScheduleCustomUIBRefresh then
            AH.ScheduleCustomUIBRefresh()
        end

        return unpack(results)
    end
end

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

local function SchedulePostAttuneAutoEquipRefresh(attemptsLeft, delay)
    if not AH or not AH.Wait then
        return
    end

    attemptsLeft = attemptsLeft or 1
    delay = delay or 0.75

    AH.Wait(delay, function()
        if AH.ClearRecentlyEquippedSlots then
            AH.ClearRecentlyEquippedSlots()
        end
        if AH.UpdateItemCountText then
            -- ʕ •ᴥ•ʔ✿ Item count text is cached; avoid expensive full refreshes ✿ ʕ •ᴥ•ʔ
            AH.UpdateItemCountText()
        end

        if AttuneHelperDB and AttuneHelperDB["Auto Equip Attunable After Combat"] == 1 and AH.TriggerThrottledAutoEquip then
            AH.TriggerThrottledAutoEquip(0.02)
        end

        if attemptsLeft > 1 then
            SchedulePostAttuneAutoEquipRefresh(attemptsLeft - 1, delay + 0.75)
        end
    end)
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

local RefreshMerchantAttuneSummary

local function CopyAttuneCounts(source)
    source = source or {}
    return {
        account = math.max(0, tonumber(source.account) or tonumber(source[1]) or 0),
        titanforged = math.max(0, tonumber(source.titanforged) or tonumber(source.tf) or tonumber(source[2]) or 0),
        warforged = math.max(0, tonumber(source.warforged) or tonumber(source.wf) or tonumber(source[3]) or 0),
        lightforged = math.max(0, tonumber(source.lightforged) or tonumber(source.lf) or tonumber(source[4]) or 0)
    }
end

local function NormalizeAttuneCounts(...)
    local values = { ... }
    if #values == 1 and type(values[1]) == "table" then
        return CopyAttuneCounts(values[1])
    end
    return CopyAttuneCounts(values)
end

local function AttuneCountsEqual(a, b)
    if not a or not b then
        return false
    end

    return (tonumber(a.account) or 0) == (tonumber(b.account) or 0)
        and (tonumber(a.titanforged) or 0) == (tonumber(b.titanforged) or 0)
        and (tonumber(a.warforged) or 0) == (tonumber(b.warforged) or 0)
        and (tonumber(a.lightforged) or 0) == (tonumber(b.lightforged) or 0)
end

local function GetSnapshotTable(createIfMissing)
    if not AttuneHelperDB then
        return nil
    end

    if type(AttuneHelperDB["DailyAttuneSnapshot"]) ~= "table" then
        if not createIfMissing then
            return nil
        end
        AttuneHelperDB["DailyAttuneSnapshot"] = {}
    end

    return AttuneHelperDB["DailyAttuneSnapshot"]
end

local function StoreDailySnapshot(counts, dateKey)
    if not AttuneHelperDB then
        return
    end

    local snapshot = GetSnapshotTable(true)
    counts = CopyAttuneCounts(counts)
    snapshot.date = dateKey
    snapshot.account = counts.account
    snapshot.titanforged = counts.titanforged
    snapshot.warforged = counts.warforged
    snapshot.lightforged = counts.lightforged

    AttuneHelperDB["DailyAttuneSnapshotDate"] = dateKey
    AttuneHelperDB["DailyAttuneSnapshotTotal"] = counts.account
    AttuneHelperDB["DailyAttuneSnapshotTF"] = counts.titanforged
    AttuneHelperDB["DailyAttuneSnapshotWF"] = counts.warforged
    AttuneHelperDB["DailyAttuneSnapshotLF"] = counts.lightforged
end

local function ReadDailySnapshot()
    if not AttuneHelperDB then
        return nil
    end

    local snapshot = GetSnapshotTable(false)
    if snapshot then
        return {
            date = snapshot.date or AttuneHelperDB["DailyAttuneSnapshotDate"],
            account = tonumber(snapshot.account) or tonumber(AttuneHelperDB["DailyAttuneSnapshotTotal"]) or 0,
            titanforged = tonumber(snapshot.titanforged) or tonumber(AttuneHelperDB["DailyAttuneSnapshotTF"]) or 0,
            warforged = tonumber(snapshot.warforged) or tonumber(AttuneHelperDB["DailyAttuneSnapshotWF"]) or 0,
            lightforged = tonumber(snapshot.lightforged) or tonumber(AttuneHelperDB["DailyAttuneSnapshotLF"]) or 0
        }
    end

    if AttuneHelperDB["DailyAttuneSnapshotDate"] then
        return {
            date = AttuneHelperDB["DailyAttuneSnapshotDate"],
            account = tonumber(AttuneHelperDB["DailyAttuneSnapshotTotal"]) or 0,
            titanforged = tonumber(AttuneHelperDB["DailyAttuneSnapshotTF"]) or 0,
            warforged = tonumber(AttuneHelperDB["DailyAttuneSnapshotWF"]) or 0,
            lightforged = tonumber(AttuneHelperDB["DailyAttuneSnapshotLF"]) or 0
        }
    end

    return nil
end

AH.pendingDailySnapshotCapture = AH.pendingDailySnapshotCapture or false
AH.pendingDailySnapshotReset = AH.pendingDailySnapshotReset or false
AH.DAILY_SNAPSHOT_STABILITY_DELAY = AH.DAILY_SNAPSHOT_STABILITY_DELAY or 0.6
AH.DAILY_SNAPSHOT_STABLE_READS_REQUIRED = AH.DAILY_SNAPSHOT_STABLE_READS_REQUIRED or 2
AH.DAILY_SNAPSHOT_MAX_ATTEMPTS = AH.DAILY_SNAPSHOT_MAX_ATTEMPTS or 8

local function BeginStableDailySnapshotCapture(dateKey, options)
    if not AH or not AH.Wait or not AttuneHelperDB then
        return false
    end

    options = options or {}
    if AH.pendingDailySnapshotCapture then
        return false
    end

    AH.pendingDailySnapshotCapture = true

    local attemptsLeft = tonumber(options.attempts) or AH.DAILY_SNAPSHOT_MAX_ATTEMPTS or 8
    local delay = tonumber(options.delay) or AH.DAILY_SNAPSHOT_STABILITY_DELAY or 0.6
    local stableReadsRequired = tonumber(options.stableReadsRequired) or AH.DAILY_SNAPSHOT_STABLE_READS_REQUIRED or 2
    local onSuccess = options.onSuccess
    local onFailure = options.onFailure
    local previousCounts = nil
    local stableReads = 0

    local function finish(success, counts)
        AH.pendingDailySnapshotCapture = false
        if success then
            StoreDailySnapshot(counts, dateKey)
            if type(onSuccess) == "function" then
                onSuccess(CopyAttuneCounts(counts))
            end
        elseif type(onFailure) == "function" then
            onFailure()
        end
    end

    local function sample()
        local currentCounts = AH.GetCurrentAttuneCounts and AH.GetCurrentAttuneCounts() or nil
        if not currentCounts then
            finish(false)
            return
        end

        if previousCounts and AttuneCountsEqual(previousCounts, currentCounts) then
            stableReads = stableReads + 1
        else
            previousCounts = CopyAttuneCounts(currentCounts)
            stableReads = 1
        end

        if stableReads >= stableReadsRequired then
            finish(true, currentCounts)
            return
        end

        attemptsLeft = attemptsLeft - 1
        if attemptsLeft <= 0 then
            finish(false)
            return
        end

        AH.Wait(delay, sample)
    end

    sample()
    return true
end

function AH.GetCurrentAttuneCounts()
    if type(CalculateAttunedCount) ~= "function" or type(ItemLocIsLoaded) ~= "function" or not ItemLocIsLoaded() then
        return nil
    end

    local counts = NormalizeAttuneCounts(CalculateAttunedCount())
    AH.currentAttuneCounts = counts
    AH.currentAccountAttuneTotal = counts.account
    SetStoredAccountAttuneTotal(counts.account)
    return CopyAttuneCounts(counts)
end

function AH.GetDailyAttuneSnapshot()
    local snapshot = ReadDailySnapshot()
    if not snapshot then
        return nil
    end

    return {
        date = snapshot.date,
        account = snapshot.account,
        titanforged = snapshot.titanforged,
        warforged = snapshot.warforged,
        lightforged = snapshot.lightforged
    }
end

function AH.EnsureDailyAttuneSnapshotCurrent()
    if not AttuneHelperDB then
        return false
    end

    local todayKey = GetCurrentDateKey()
    local snapshot = ReadDailySnapshot()

    if snapshot and snapshot.date == todayKey then
        StoreDailySnapshot(snapshot, todayKey)
        return true
    end

    if AH.pendingDailySnapshotCapture then
        return false
    end

    BeginStableDailySnapshotCapture(todayKey, {
        onSuccess = function()
            if AH.UpdateItemCountText then
                AH.UpdateItemCountText()
            end
            RefreshMerchantAttuneSummary()
        end
    })

    return false
end

function AH.ResetDailyAttuneSnapshot()
    if not AttuneHelperDB then
        return false
    end

    local todayKey = GetCurrentDateKey()
    local currentCounts = AH.GetCurrentAttuneCounts and AH.GetCurrentAttuneCounts() or nil
    if not currentCounts then
        AttuneHelperDB["DailyAttuneSnapshotDate"] = nil
        AttuneHelperDB["DailyAttuneSnapshotTotal"] = nil
        AttuneHelperDB["DailyAttuneSnapshotTF"] = nil
        AttuneHelperDB["DailyAttuneSnapshotWF"] = nil
        AttuneHelperDB["DailyAttuneSnapshotLF"] = nil
        AttuneHelperDB["DailyAttuneSnapshot"] = nil
        return false
    end

    if AH.pendingDailySnapshotCapture then
        return false
    end

    AH.pendingDailySnapshotReset = true
    BeginStableDailySnapshotCapture(todayKey, {
        attempts = math.max(AH.DAILY_SNAPSHOT_MAX_ATTEMPTS or 8, 10),
        onSuccess = function()
            AH.pendingDailySnapshotReset = false
            if AH.UpdateItemCountText then
                AH.UpdateItemCountText()
            end
            if AH.RefreshVendorCompatButtons then
                AH.RefreshVendorCompatButtons()
            end
            print("|cff00ff00[AttuneHelper]|r Daily attune snapshot reset to stable server counts.")
        end,
        onFailure = function()
            AH.pendingDailySnapshotReset = false
        end
    })

    return false
end

function AH.GetTodaysAttuneBreakdown()
    if AH.EnsureDailyAttuneSnapshotCurrent then
        AH.EnsureDailyAttuneSnapshotCurrent()
    end

    local currentCounts = AH.GetCurrentAttuneCounts and AH.GetCurrentAttuneCounts() or nil
    local snapshot = AH.GetDailyAttuneSnapshot and AH.GetDailyAttuneSnapshot() or nil
    if not currentCounts or not snapshot or snapshot.date ~= GetCurrentDateKey() then
        return {
            ready = false,
            account = 0,
            titanforged = 0,
            warforged = 0,
            lightforged = 0
        }
    end

    return {
        ready = true,
        account = math.max(0, currentCounts.account - snapshot.account),
        titanforged = math.max(0, currentCounts.titanforged - snapshot.titanforged),
        warforged = math.max(0, currentCounts.warforged - snapshot.warforged),
        lightforged = math.max(0, currentCounts.lightforged - snapshot.lightforged)
    }
end

local function ScheduleAttuneSnapshotRetry(retriesLeft, delay)
    if not AH or not AH.Wait then
        return
    end

    retriesLeft = retriesLeft or 1
    delay = delay or 0.5

    AH.Wait(delay, function()
        local ready = AH.EnsureDailyAttuneSnapshotCurrent and AH.EnsureDailyAttuneSnapshotCurrent()
        if ready then
            if AH.UpdateItemCountText then
                AH.UpdateItemCountText()
            end
            RefreshMerchantAttuneSummary()
            return
        end

        if retriesLeft > 1 then
            ScheduleAttuneSnapshotRetry(retriesLeft - 1, delay)
        end
    end)
end

RefreshMerchantAttuneSummary = function()
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

    -- Register events now that UI is ready
    AH.RegisterEvents()
end

------------------------------------------------------------------------
-- Event registration
------------------------------------------------------------------------
function AH.RegisterEvents()
    if not AH.UI.mainFrame then return end

    AH.UI.mainFrame:RegisterEvent("ADDON_LOADED")
    AH.UI.mainFrame:RegisterEvent("PLAYER_LOGIN")
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
    AH.UI.mainFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")

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
        ScheduleAttuneSnapshotRetry(20, 0.5)

        if AH.HookCustomItemUpdateButton then
            AH.HookCustomItemUpdateButton()
            if AH.Wait then
                AH.Wait(0.5, AH.HookCustomItemUpdateButton)
                AH.Wait(2, AH.HookCustomItemUpdateButton)
            end
        end

        if self ~= AH.UI.mainFrame then
            self:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN")

        if AH.HookCustomItemUpdateButton and AH.Wait then
            AH.HookCustomItemUpdateButton()
            AH.Wait(0.5, AH.HookCustomItemUpdateButton)
        elseif AH.HookCustomItemUpdateButton then
            AH.HookCustomItemUpdateButton()
        end

        if AH.InitCharProfileAfterLoad then
            AH.InitCharProfileAfterLoad()
        end

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

        AH.ScheduleAttuneRefresh()

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
        AH.GetCurrentAttuneCounts()
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
            local now = GetTime()
            local burstWindow = math.max(AH.CHAT_MSG_SYSTEM_THROTTLE or 0.2, AH.ATTUNE_CHAT_SYSTEM_BURST_WINDOW or 0.8)

            -- If we get multiple attune-complete messages in a tight burst, only do the heavy refresh once.
            if AH.lastAttuneChatSystemHandledAt and (now - AH.lastAttuneChatSystemHandledAt) < burstWindow then
                if AH.UpdateItemCountText then
                    AH.UpdateItemCountText()
                end
                RefreshMerchantAttuneSummary()
                return
            end

            AH.lastAttuneChatSystemHandledAt = now

            AH.Wait(0.25, function()
                if AH.GetCurrentAttuneCounts then
                    AH.GetCurrentAttuneCounts()
                end
                if AH.EnsureDailyAttuneSnapshotCurrent then
                    AH.EnsureDailyAttuneSnapshotCurrent()
                end
                RefreshMerchantAttuneSummary()
            end)

            SchedulePostAttuneAutoEquipRefresh(4, 0.75)
        end
    elseif event == "CHARACTER_POINTS_CHANGED" then
        if AH.InvalidateTitansGripCache then
            AH.InvalidateTitansGripCache()
        end
        if AH.RebuildEquipSlotCache then
            AH.RebuildEquipSlotCache()
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
            AH.GetCurrentAttuneCounts()
            AH.EnsureDailyAttuneSnapshotCurrent()
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

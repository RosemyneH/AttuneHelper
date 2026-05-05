local AH = _G.AH or _G.AttuneHelper
if not AH then return end

local ui = {
    frame = nil,
    content = nil,
    tabs = {},
    sections = {},
    historyRows = {},
    currentTab = nil,
}

local PANEL_TABS = {
    { key = "general", panelKey = "general", label = "General" },
    { key = "theme", panelKey = "theme", label = "Theme" },
    { key = "listManagement", panelKey = "listManagement", label = "List Mgmt" },
    { key = "buttonLayout", panelKey = "buttonLayout", label = "Button Layout" },
    { key = "blacklist", panelKey = "blacklist", label = "Blacklist" },
    { key = "forge", panelKey = "forge", label = "Forge" },
    { key = "weapon", panelKey = "weapon", label = "Weapon" },
    { key = "history", panelKey = nil, label = "Attune History" },
}

local TABS_PER_ROW = 4
local BLUE_THEME = {
    panelBg = { 0.04, 0.07, 0.14, 0.94 },
    panelBorder = { 0.22, 0.48, 0.82, 0.95 },
    shellBg = { 0.02, 0.04, 0.10, 0.97 },
    contentBg = { 0.05, 0.09, 0.18, 0.96 },
    title = { 1, 1, 1.0 },
    subtitle = { 0.68, 0.78, 0.94 },
    tabActive = { 0.62, 0.84, 1.0 },
    tabInactive = { 0.78, 0.83, 0.92 },
}

local function CreatePanel(parent, width, height, point, relativeTo, relativePoint, x, y)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width, height)
    frame:SetPoint(point, relativeTo, relativePoint, x or 0, y or 0)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame:SetBackdropColor(unpack(BLUE_THEME.panelBg))
    frame:SetBackdropBorderColor(unpack(BLUE_THEME.panelBorder))
    return frame
end

local function CreateText(parent, template, point, relativeTo, relativePoint, x, y, width, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
    fs:SetPoint(point, relativeTo, relativePoint, x or 0, y or 0)
    if width then fs:SetWidth(width) end
    if justify then fs:SetJustifyH(justify) end
    return fs
end

local function CreateButton(parent, width, height, label, point, relativeTo, relativePoint, x, y, onClick)
    local button = CreatePanel(parent, width, height, point, relativeTo, relativePoint, x, y)
    button:EnableMouse(true)
    button.text = CreateText(button, "GameFontNormal", "CENTER", button, "CENTER", 0, 0)
    button.text:SetText(label)
    button.text:SetTextColor(unpack(BLUE_THEME.tabInactive))
    button:SetScript("OnMouseUp", function() if onClick then onClick() end end)
    return button
end

local function GetHistoryEntries()
    if AH.GetDailyAttuneHistory then
        return AH.GetDailyAttuneHistory()
    end
    return {}
end

local function RefreshHistoryRows()
    local entries = GetHistoryEntries()
    for i = 1, #ui.historyRows do
        local row = ui.historyRows[i]
        local entry = entries[i]
        if entry then
            row:SetText(string.format("%s  Account:%d  TF:%d  WF:%d  LF:%d", tostring(entry.date), tonumber(entry.account) or 0, tonumber(entry.titanforged) or 0, tonumber(entry.warforged) or 0, tonumber(entry.lightforged) or 0))
            row:Show()
        else
            row:SetText("")
            row:Hide()
        end
    end
end

local function AttachLegacyPanels()
    if not (AH.UI and AH.UI.optionsPanels) then
        return
    end
    for _, tabDef in ipairs(PANEL_TABS) do
        if tabDef.panelKey then
            local panel = AH.UI.optionsPanels[tabDef.panelKey]
            local holder = ui.sections[tabDef.key]
            if panel and holder then
                panel:SetParent(holder)
                panel:ClearAllPoints()
                panel:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
                panel:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 0, 0)
                panel:SetFrameStrata("DIALOG")
                panel:SetFrameLevel(ui.frame:GetFrameLevel() + 3)
            end
        end
    end
end

local function SelectTab(tabKey)
    ui.currentTab = tabKey
    AH._optionsSuspendSave = true
    for key, section in pairs(ui.sections) do
        if key == tabKey then
            section:Show()
        else
            section:Hide()
        end
    end
    for key, tab in pairs(ui.tabs) do
        if key == tabKey then
            tab.text:SetTextColor(unpack(BLUE_THEME.tabActive))
        else
            tab.text:SetTextColor(unpack(BLUE_THEME.tabInactive))
        end
    end
    AH._optionsSuspendSave = false
    if tabKey == "listManagement" then
        if AH.RefreshListManagementPanel then
            AH.RefreshListManagementPanel()
        end
        if AH.Wait then
            AH.Wait(0.05, function()
                if AH.list_management_controls and AH.list_management_controls.Relayout then
                    AH.list_management_controls.Relayout()
                end
                if AH.RefreshListManagementPanel then
                    AH.RefreshListManagementPanel()
                end
            end)
        end
    end
    if tabKey == "history" then
        RefreshHistoryRows()
    end
end

local function BuildHistorySection(parent)
    local section = CreateFrame("Frame", nil, parent)
    section:SetAllPoints(parent)
    local panel = CreatePanel(section, 984, 558, "TOPLEFT", section, "TOPLEFT", 0, 0)
    CreateText(panel, "GameFontNormalLarge", "TOPLEFT", panel, "TOPLEFT", 16, -14):SetText("Attune History")
    CreateText(panel, "GameFontNormalSmall", "TOPLEFT", panel, "TOPLEFT", 16, -42, 940, "LEFT"):SetText("Old daily snapshots are archived by day rollover and remain until manually cleared.")
    local listPanel = CreatePanel(panel, 952, 434, "TOPLEFT", panel, "TOPLEFT", 16, -72)
    for i = 1, 18 do
        local row = CreateText(listPanel, "GameFontNormalSmall", "TOPLEFT", listPanel, "TOPLEFT", 10, -10 - ((i - 1) * 24), 932, "LEFT")
        ui.historyRows[i] = row
    end
    local refreshBtn = CreateButton(panel, 120, 26, "Refresh", "BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16, RefreshHistoryRows)
    local clearBtn = CreateButton(panel, 160, 26, "Clear History", "LEFT", refreshBtn, "RIGHT", 12, 0, function()
        if AH.ClearDailyAttuneHistory then
            AH.ClearDailyAttuneHistory()
            RefreshHistoryRows()
        end
    end)
    CreateButton(panel, 210, 26, "Dump History to Chat", "LEFT", clearBtn, "RIGHT", 12, 0, function()
        local entries = GetHistoryEntries()
        print("|cff00ff00[AttuneHelper]|r Daily Attune History:")
        if #entries == 0 then
            print("  (no history entries)")
            return
        end
        for i = 1, #entries do
            local entry = entries[i]
            print(string.format("  %s | A:%d TF:%d WF:%d LF:%d", tostring(entry.date), tonumber(entry.account) or 0, tonumber(entry.titanforged) or 0, tonumber(entry.warforged) or 0, tonumber(entry.lightforged) or 0))
        end
    end)
    return section
end

local function BuildStandaloneFrame()
    if ui.frame then return end
    local frame = CreateFrame("Frame", "AttuneHelperStandaloneOptionsFrame", UIParent)
    frame:SetSize(1024, 720)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    frame:Hide()
    local shell = CreatePanel(frame, 1024, 720, "TOPLEFT", frame, "TOPLEFT", 0, 0)
    shell:SetBackdropColor(unpack(BLUE_THEME.shellBg))
    tinsert(UISpecialFrames, "AttuneHelperStandaloneOptionsFrame")
    ui.frame = frame

    local title = CreateText(frame, "GameFontHighlightLarge", "TOP", frame, "TOP", 0, -18, 980, "CENTER")
    title:SetText("AttuneHelper Control Center")
    title:SetTextColor(unpack(BLUE_THEME.title))
    local subtitle = CreateText(frame, "GameFontNormalSmall", "TOP", title, "BOTTOM", 0, -8, 980, "CENTER")
    subtitle:SetText("Standalone configuration preserving all previous options categories.")
    subtitle:SetTextColor(unpack(BLUE_THEME.subtitle))
    CreateButton(frame, 28, 24, "X", "TOPRIGHT", frame, "TOPRIGHT", -14, -10, function() frame:Hide() end)

    for i = 1, #PANEL_TABS do
        local tabDef = PANEL_TABS[i]
        local row = math.floor((i - 1) / TABS_PER_ROW)
        local col = (i - 1) % TABS_PER_ROW
        local tab = CreateButton(frame, 236, 26, tabDef.label, "TOPLEFT", frame, "TOPLEFT", 18 + (col * 248), -74 - (row * 30), function()
            SelectTab(tabDef.key)
        end)
        ui.tabs[tabDef.key] = tab
    end

    ui.content = CreateFrame("Frame", nil, frame)
    ui.content:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -142)
    ui.content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 20)
    local contentBg = CreatePanel(ui.content, 984, 558, "TOPLEFT", ui.content, "TOPLEFT", 0, 0)
    contentBg:SetPoint("BOTTOMRIGHT", ui.content, "BOTTOMRIGHT", 0, 0)
    contentBg:SetBackdropColor(unpack(BLUE_THEME.contentBg))
    contentBg:SetFrameStrata("DIALOG")
    contentBg:SetFrameLevel(frame:GetFrameLevel() + 1)

    for _, tabDef in ipairs(PANEL_TABS) do
        if tabDef.key == "history" then
            ui.sections[tabDef.key] = BuildHistorySection(ui.content)
        else
            local section = CreateFrame("Frame", nil, ui.content)
            section:SetAllPoints(ui.content)
            ui.sections[tabDef.key] = section
        end
    end
end

function AH.RefreshStandaloneOptions()
    if AH.EnsureDailyAttuneSnapshotCurrent then
        AH.EnsureDailyAttuneSnapshotCurrent()
    end
    if AH.LoadAllSettings then
        AH.LoadAllSettings()
    end
    RefreshHistoryRows()
end

function AH.ShowStandaloneOptions()
    if AH.InitializeAllOptions then
        AH.InitializeAllOptions()
    end
    if not ui.frame then
        BuildStandaloneFrame()
    end
    AH._optionsSuspendSave = true
    AttachLegacyPanels()
    AH.RefreshStandaloneOptions()
    SelectTab(ui.currentTab or "general")
    AH._optionsSuspendSave = false
    AH.RefreshStandaloneOptions()
    ui.frame:Show()
    ui.frame:Raise()
    if AH.list_management_controls and AH.list_management_controls.Relayout then
        AH.list_management_controls.Relayout()
    end
end

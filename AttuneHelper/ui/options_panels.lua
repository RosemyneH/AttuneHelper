-- ʕ •ᴥ•ʔ✿ UI · Options panels ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

-- Cache tables for UI elements
AH.blacklist_checkboxes = {}
AH.general_option_checkboxes = {}
AH.theme_option_controls = {}
AH.button_layout_option_controls = {}
AH.forge_type_checkboxes = {}
AH.forge_option_controls = {}
AH.weapon_control_checkboxes = {}
AH.list_management_controls = {}

-- Export for legacy compatibility
_G.blacklist_checkboxes = AH.blacklist_checkboxes
_G.general_option_checkboxes = AH.general_option_checkboxes
_G.theme_option_controls = AH.theme_option_controls
_G.button_layout_option_controls = AH.button_layout_option_controls
_G.forge_type_checkboxes = AH.forge_type_checkboxes
_G.forge_option_controls = AH.forge_option_controls
_G.weapon_control_checkboxes = AH.weapon_control_checkboxes
_G.list_management_controls = AH.list_management_controls

local function BuildSortedKeyList(sourceTable, filterFn)
    local entries = {}
    if type(sourceTable) ~= "table" then
        return entries
    end

    for key, value in pairs(sourceTable) do
        if value and (not filterFn or filterFn(key, value)) then
            table.insert(entries, key)
        end
    end

    table.sort(entries, function(a, b)
        return tostring(a):lower() < tostring(b):lower()
    end)
    return entries
end

local function GetAHIgnoreEntries()
    return BuildSortedKeyList(AHIgnoreList)
end

local function GetAlwaysVendorEntries()
    return BuildSortedKeyList(AHVendorList)
end

local function GetAHSetEntries()
    local entries = {}
    if type(AHSetList) ~= "table" then
        return entries
    end

    for key, targetSlot in pairs(AHSetList) do
        if targetSlot then
            table.insert(entries, { key = key, value = targetSlot })
        end
    end

    table.sort(entries, function(a, b)
        return tostring(a.key):lower() < tostring(b.key):lower()
    end)
    return entries
end

local function FormatListEntryLabel(listType, entry)
    if listType == "ahset" then
        local itemKey = type(entry) == "table" and entry.key or entry
        local slotName = type(entry) == "table" and entry.value or nil
        return string.format("%s  ->  %s", tostring(itemKey), tostring(slotName or ""))
    end
    return tostring(entry)
end

local function RemoveListEntry(listType, entry)
    if listType == "ahset" then
        if type(entry) == "table" and entry.key then
            AHSetList[entry.key] = nil
        end
    elseif listType == "ignore" then
        AHIgnoreList[entry] = nil
        if AH.InvalidateVendorListCache then
            AH.InvalidateVendorListCache()
        end
    elseif listType == "vendor" then
        AHVendorList[entry] = nil
        if AH.InvalidateVendorListCache then
            AH.InvalidateVendorListCache()
        end
    end

    if AH.ForceSaveSettings then
        AH.ForceSaveSettings()
    end
    if AH.RefreshListManagementPanel then
        AH.RefreshListManagementPanel()
    end
end

local function CreateManagedListSection(parent, titleText, topAnchor, listType, entryProvider)
    local section = CreateFrame("Frame", nil, parent)
    section:SetWidth(540)
    section:SetHeight(150)
    section:SetPoint("TOPLEFT", topAnchor, "BOTTOMLEFT", 0, -18)

    local title = section:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", 0, 0)
    title:SetText(titleText)

    local baseName = string.format("%s%s", parent:GetName() or "AttuneHelperListManagementPanel", listType or "Section")
    local scrollFrame = CreateFrame("ScrollFrame", baseName .. "ScrollFrame", section, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", section, "BOTTOMRIGHT", -28, 0)

    local content = CreateFrame("Frame", baseName .. "Content", scrollFrame)
    content:SetWidth(500)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)
    section.content = content
    section.rows = {}
    section.entryProvider = entryProvider
    section.listType = listType

    return section
end

local function RefreshManagedListSection(section)
    if not section or not section.entryProvider then
        return
    end

    local entries = section.entryProvider() or {}
    local content = section.content
    local rowHeight = 24
    local visibleRows = math.max(#entries, 1)
    content:SetHeight(visibleRows * rowHeight)

    for i = 1, visibleRows do
        local row = section.rows[i]
        if not row then
            row = CreateFrame("Frame", nil, content)
            row:SetWidth(500)
            row:SetHeight(rowHeight)
            if i == 1 then
                row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            else
                row:SetPoint("TOPLEFT", section.rows[i - 1], "BOTTOMLEFT", 0, 0)
            end

            local label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
            label:SetPoint("LEFT", row, "LEFT", 4, 0)
            label:SetWidth(400)
            label:SetJustifyH("LEFT")
            row.label = label

            local removeButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            removeButton:SetSize(72, 20)
            removeButton:SetPoint("RIGHT", row, "RIGHT", -6, 0)
            removeButton:SetText("Remove")
            row.removeButton = removeButton

            section.rows[i] = row
        end

        local entry = entries[i]
        if entry then
            row.label:SetText(FormatListEntryLabel(section.listType, entry))
            row.removeButton:SetScript("OnClick", function()
                RemoveListEntry(section.listType, entry)
            end)
            row:Show()
        else
            row.label:SetText("No entries.")
            row.removeButton:SetScript("OnClick", nil)
            row.removeButton:Hide()
            row:Show()
        end

        if entry then
            row.removeButton:Show()
        end
    end

    for i = visibleRows + 1, #section.rows do
        section.rows[i]:Hide()
    end
end

------------------------------------------------------------------------
-- Slot and option configuration
------------------------------------------------------------------------
AH.slots = {
    "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "WristSlot",
    "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
    "Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot"
}

AH.general_options_list_for_checkboxes = {
    {text = "Sell Attuned Mythic Gear?", dbKey = "Sell Attuned Mythic Gear?"},
    {text = "Auto Equip Attunable After Combat", dbKey = "Auto Equip Attunable After Combat"},
    {text = "Do Not Sell BoE Items", dbKey = "Do Not Sell BoE Items"},
	{text = "Do Not Sell Grey And White Items", dbKey = "Do Not Sell Grey And White Items"},
    {text = "Limit Selling to 12 Items?", dbKey = "Limit Selling to 12 Items?"},
    {text = "Disable Auto-Equip Mythic BoE", dbKey = "Disable Auto-Equip Mythic BoE"},
    {text = "Equip BoE Bountied Items", dbKey = "Equip BoE Bountied Items"},
    {text = "Equip Attunable Affixes up to:", dbKey = "EquipNewAffixesOnly"},
    {text = "Prioritize Low iLvl for Auto-Equip", dbKey = "Prioritize Low iLvl for Auto-Equip"},
    {text = "Enable Vendor Sell Confirmation Dialog", dbKey = "EnableVendorSellConfirmationDialog"},
    {text = "Vendor preview on Right (Default On)", dbKey = "Vendor preview on Right (Default On)"},
    {text = "Draggable by Right Click", dbKey = "Draggable by Right Click"},
    {text = "Lock AH in Place (Buttons Only Mouse)", dbKey = "Lock AH in Place (Buttons Only Mouse)"},
    {text = "Use Bag 1 for Disenchant", dbKey = "Use Bag 1 for Disenchant"}
}

-- ʕ •ᴥ•ʔ✿ Weapon control options (separate panel) ✿ ʕ •ᴥ•ʔ
AH.weapon_options_list_for_checkboxes = {
    {text = "Allow MainHand 1H Weapons", dbKey = "Allow MainHand 1H Weapons"},
    {text = "Allow MainHand 2H Weapons", dbKey = "Allow MainHand 2H Weapons"},
    {text = "Allow OffHand 1H Weapons", dbKey = "Allow OffHand 1H Weapons"},
    {text = "Allow OffHand 2H Weapons", dbKey = "Allow OffHand 2H Weapons"},
    {text = "Allow OffHand Shields", dbKey = "Allow OffHand Shields"},
    {text = "Allow OffHand Holdables", dbKey = "Allow OffHand Holdables"}
}

AH.button_layout_button_choices = {
    { key = "equipAll",       label = "Equip Attunables" },
    { key = "vendor",         label = "Vendor Attuned" },
    { key = "openSettings",   label = "Open Settings" },
    { key = "toggleAutoEquip", label = "Toggle Auto-Equip" },
    { key = "AHSetUpdate",    label = "Update AHSet" },
    { key = "sort",           label = "Prepare Disenchant" },
    { key = "equipAHSet",     label = "Equip AHSet" }
}

-- Export for legacy compatibility
_G.slots = AH.slots
_G.general_options_list_for_checkboxes = AH.general_options_list_for_checkboxes

------------------------------------------------------------------------
-- Checkbox creation helper
------------------------------------------------------------------------
function AH.CreateCheckbox(t, p, x, y, iG, dkO)
    local cN, idK = t, dkO or t
    
    if not iG and not dkO then
        cN = "AttuneHelperBlacklist_" .. t .. "Checkbox"
    elseif dkO and iG then
        if string.match(idK, "BASE") or string.match(idK, "FORGED") then
            cN = "AttuneHelperForgeType_" .. dkO .. "_Checkbox"
        else
            cN = "AttuneHelperGeneral_" .. idK:gsub("[^%w]", "") .. "Checkbox"
        end
    elseif iG then
        cN = "AttuneHelperGeneral_" .. idK:gsub("[^%w]", "") .. "Checkbox"
    end
    
    local cb = CreateFrame("CheckButton", cN, p, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", x, y)
    
    local txt = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    txt:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    txt:SetText(AH.t(t))
    
    cb.dbKey = idK
    return cb
end

function AH.ApplyGeneralOptionTooltip(cb, dbKey)
    if not cb or not dbKey then
        return
    end

    if dbKey == "Sell Attuned Mythic Gear?" then
        cb:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetText(AH.t("Sell Attuned Mythic Gear?"))
            GameTooltip:AddLine(
                AH.t("This setting is recommended to be off due to the fact that disenchanting Mythic Gear results in honor and arena points."),
                1, 0.82, 0.2, true
            )
            GameTooltip:Show()
        end)
        cb:SetScript("OnLeave", GameTooltip_Hide)
    elseif dbKey == "Do Not Sell Grey And White Items" then
        cb:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetText(AH.t("Do Not Sell Grey And White Items"))
            GameTooltip:AddLine(
                AH.t("With this setting off, it will not vendor non-BoP white/grey items if the item can be attuned."),
                1, 0.82, 0.2, true
            )
            GameTooltip:Show()
        end)
        cb:SetScript("OnLeave", GameTooltip_Hide)
    elseif dbKey == "EquipNewAffixesOnly" then
        cb:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetText(AH.t("Equip Attunable Affixes up to:"))
            GameTooltip:AddLine(
                AH.t("Quick rules:"),
                1, 0.82, 0.2, true
            )
            GameTooltip:AddLine(
                AH.t("- Below selected tier: lenient."),
                0.85, 0.85, 0.85, true
            )
            GameTooltip:AddLine(
                AH.t("- Selected tier and up: unattuned variant only."),
                0.85, 0.85, 0.85, true
            )
            GameTooltip:AddLine(
                AH.t("- Existing variant: only higher tier can equip."),
                0.85, 0.85, 0.85, true
            )
            GameTooltip:AddLine(
                AH.t("- Does not check extra affix unlocks."),
                0.85, 0.85, 0.85, true
            )
            GameTooltip:AddLine(
                " ",
                1, 1, 1, true
            )
            GameTooltip:AddLine(
                AH.t("Example (Warforged):"),
                1, 0.82, 0.2, true
            )
            GameTooltip:AddLine(
                AH.t("- Base and TF - Equips all if Affix is attunable."),
                0.85, 0.85, 0.85, true
            )
            GameTooltip:AddLine(
                AH.t("- Warforged duplicate: blocked. (Max 1)"),
                0.85, 0.85, 0.85, true
            )
            GameTooltip:AddLine(
                AH.t("- Lightforged: can still equip. (Max 1)"),
                0.85, 0.85, 0.85, true
            )
            GameTooltip:Show()
        end)
        cb:SetScript("OnLeave", GameTooltip_Hide)
    end
end

-- Export for legacy compatibility
_G.CreateCheckbox = AH.CreateCheckbox

------------------------------------------------------------------------
-- Settings save/load functions
------------------------------------------------------------------------
function AH.SaveAllSettings()
    if not InterfaceOptionsFrame or not InterfaceOptionsFrame:IsShown() then return end
    
    -- Save blacklist checkboxes
    for _, cb in ipairs(AH.blacklist_checkboxes) do
        if cb and cb:IsShown() then
            AttuneHelperDB[cb:GetName():gsub("AttuneHelperBlacklist_", ""):gsub("Checkbox", "")] = cb:GetChecked() and 1 or 0
        end
    end
    
    -- Save general option checkboxes
    for _, cb in ipairs(AH.general_option_checkboxes) do
        if cb and cb:IsShown() then
            AttuneHelperDB[cb.dbKey or cb:GetName()] = cb:GetChecked() and 1 or 0
        end
    end
    
    -- ʕ •ᴥ•ʔ✿ Save weapon control checkboxes ✿ ʕ •ᴥ•ʔ
    for _, cb in ipairs(AH.weapon_control_checkboxes) do
        if cb and cb:IsShown() then
            AH.SetWeaponControlSetting(cb.dbKey or cb:GetName(), cb:GetChecked() and 1 or 0)
        end
    end
    
    -- Save forge type settings
    if type(AttuneHelperDB.AllowedForgeTypes) ~= "table" then
        AttuneHelperDB.AllowedForgeTypes = {}
    end
    for _, cb in ipairs(AH.forge_type_checkboxes) do
        if cb and cb:IsShown() and cb.dbKey then
            if cb:GetChecked() then
                AttuneHelperDB.AllowedForgeTypes[cb.dbKey] = true
            else
                AttuneHelperDB.AllowedForgeTypes[cb.dbKey] = nil
            end
        end
    end
end

function AH.LoadAllSettings()
    AH.InitializeDefaultSettings()

    -- Load frame positions (handled in main_frame and mini_frame modules)
    
    -- Load forge types
    if type(AttuneHelperDB.AllowedForgeTypes) ~= "table" then
        AttuneHelperDB.AllowedForgeTypes = {}
        for k, v in pairs(AH.defaultForgeKeysAndValues) do
            AttuneHelperDB.AllowedForgeTypes[k] = v
        end
    end

    for _, cbW in ipairs(AH.forge_type_checkboxes) do
        if cbW and cbW.dbKey then
            cbW:SetChecked(AttuneHelperDB.AllowedForgeTypes[cbW.dbKey] == true)
        end
    end

    -- Load background style dropdown
    local ddBgStyle = _G["AttuneHelperBgDropdown"]
    if ddBgStyle then
        UIDropDownMenu_SetSelectedValue(ddBgStyle, AttuneHelperDB["Background Style"])
        UIDropDownMenu_SetText(ddBgStyle, AttuneHelperDB["Background Style"])
    end

    -- Apply background style
    if AH.BgStyles[AttuneHelperDB["Background Style"]] then
        local cs = AttuneHelperDB["Background Style"]
        local nt = (cs == "Atunament" or cs == "Always Bee Attunin'")
        if AH.UI.mainFrame then
            AH.UI.mainFrame:SetBackdrop({
                bgFile = AH.BgStyles[cs],
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = (not nt),
                tileSize = (nt and 0 or 16),
                edgeSize = 16,
                insets = {left = 4, right = 4, top = 4, bottom = 4}
            })
            AH.UI.mainFrame:SetBackdropColor(unpack(AttuneHelperDB["Background Color"]))
        end
    end

    -- Load mini frame colors
    if AH.UI.miniFrame then
        AH.UI.miniFrame:SetBackdropColor(
            AttuneHelperDB["Background Color"][1],
            AttuneHelperDB["Background Color"][2],
            AttuneHelperDB["Background Color"][3],
            AttuneHelperDB["Background Color"][4]
        )
    end

    -- Load button theme
    local th = AttuneHelperDB["Button Theme"] or "Normal"
    local ddBtnTheme = _G["AttuneHelperButtonThemeDropdown"]
    if ddBtnTheme then
        UIDropDownMenu_SetSelectedValue(ddBtnTheme, th)
        UIDropDownMenu_SetText(ddBtnTheme, th)
    end
    AH.ApplyButtonTheme(th)

    local layoutPreset = AttuneHelperDB["Button Layout Preset"] or "Standard"
    if layoutPreset == "Compact" then
        layoutPreset = "Standard"
        AttuneHelperDB["Button Layout Preset"] = "Standard"
    end
    local ddLayoutPreset = _G["AttuneHelperButtonLayoutDropdown"]
    if ddLayoutPreset then
        UIDropDownMenu_SetSelectedValue(ddLayoutPreset, layoutPreset)
        UIDropDownMenu_SetText(ddLayoutPreset, layoutPreset)
    end
    if AH.RefreshButtonLayoutOptionVisibility then
        AH.RefreshButtonLayoutOptionVisibility()
    end
    if AH.RefreshButtonLayoutEditor then
        AH.RefreshButtonLayoutEditor()
    end

    -- Load color swatch
    local bgcT = AttuneHelperDB["Background Color"]
    local csf = _G["AttuneHelperBgColorSwatch"]
    if csf then
        csf:SetBackdropColor(bgcT[1], bgcT[2], bgcT[3], 1)
    end

    -- Load alpha slider
    local asf = _G["AttuneHelperAlphaSlider"]
    if asf then
        asf:SetValue(bgcT[4])
    end

    -- Load checkbox states
    for _, cb in ipairs(AH.blacklist_checkboxes) do
        cb:SetChecked(AttuneHelperDB[cb:GetName():gsub("AttuneHelperBlacklist_", ""):gsub("Checkbox", "")] == 1)
    end

    for _, cb in ipairs(AH.general_option_checkboxes) do
        cb:SetChecked(AttuneHelperDB[cb.dbKey or cb:GetName()] == 1)
    end

    -- Load forge affix threshold dropdown
    local affixDD = AH.forge_option_controls and AH.forge_option_controls.affixMinForgeDropdown
    if affixDD then
        local value = AttuneHelperDB["AffixOnlyMinForgeLevel"]
        if type(value) ~= "number" then
            value = AH.FORGE_LEVEL_MAP.WARFORGED
        end

        local labelMap = {
            [-1] = "All Items",
            [AH.FORGE_LEVEL_MAP.TITANFORGED] = "Titanforged",
            [AH.FORGE_LEVEL_MAP.WARFORGED] = "Warforged",
            [AH.FORGE_LEVEL_MAP.LIGHTFORGED] = "Lightforged"
        }

        UIDropDownMenu_SetSelectedValue(affixDD, value)
        UIDropDownMenu_SetText(affixDD, labelMap[value] or "Warforged")
    end

    -- ʕ •ᴥ•ʔ✿ Load weapon control checkbox states ✿ ʕ •ᴥ•ʔ
    for _, cb in ipairs(AH.weapon_control_checkboxes) do
        cb:SetChecked(AH.GetWeaponControlSetting(cb.dbKey or cb:GetName()) == 1)
    end

    -- Load language dropdown selection
    if AH.language_option_controls and AH.language_option_controls.dropdown then
        local sel = AttuneHelperDB["Language"] or "default"
        local textMap = {
            ["default"] = AH.t("System Default"),
            ["enUS"] = AH.t("English (US)"),
            ["deDE"] = AH.t("Deutsch"),
            ["esES"] = AH.t("Español"),
            ["frFR"] = AH.t("Français"),
            ["itIT"] = AH.t("Italiano"),
            ["ptBR"] = AH.t("Português (BR)"),
            ["ruRU"] = AH.t("Русский"),
            ["zhCN"] = AH.t("简体中文"),
            ["zhTW"] = AH.t("繁體中文"),
            ["koKR"] = AH.t("한국어"),
        }
        UIDropDownMenu_SetSelectedValue(AH.language_option_controls.dropdown, sel)
        UIDropDownMenu_SetText(AH.language_option_controls.dropdown, textMap[sel] or sel)
    end

    if AH.UpdateDisplayMode then
        AH.UpdateDisplayMode()
    end
end

-- ʕ •ᴥ•ʔ✿ Force save for UI checkboxes (bypasses Interface Options check) ✿ ʕ •ᴥ•ʔ
function AH.SaveSettingsForced()
    -- This version saves settings even when Interface Options isn't open
    -- Used by UI checkboxes that need immediate saving
    
    -- Save blacklist checkboxes
    for _, cb in ipairs(AH.blacklist_checkboxes) do
        if cb and cb:IsShown() then
            AttuneHelperDB[cb:GetName():gsub("AttuneHelperBlacklist_", ""):gsub("Checkbox", "")] = cb:GetChecked() and 1 or 0
        end
    end
    
    -- Save general option checkboxes
    for _, cb in ipairs(AH.general_option_checkboxes) do
        if cb and cb:IsShown() then
            AttuneHelperDB[cb.dbKey or cb:GetName()] = cb:GetChecked() and 1 or 0
        end
    end
    
    -- ʕ •ᴥ•ʔ✿ Save weapon control checkboxes ✿ ʕ •ᴥ•ʔ
    for _, cb in ipairs(AH.weapon_control_checkboxes) do
        if cb and cb:IsShown() then
            AH.SetWeaponControlSetting(cb.dbKey or cb:GetName(), cb:GetChecked() and 1 or 0)
        end
    end
    
    -- Save forge type settings
    if type(AttuneHelperDB.AllowedForgeTypes) ~= "table" then
        AttuneHelperDB.AllowedForgeTypes = {}
    end
    for _, cb in ipairs(AH.forge_type_checkboxes) do
        if cb and cb:IsShown() and cb.dbKey then
            if cb:GetChecked() then
                AttuneHelperDB.AllowedForgeTypes[cb.dbKey] = true
            else
                AttuneHelperDB.AllowedForgeTypes[cb.dbKey] = nil
            end
        end
    end
    
    -- Force WoW to write saved variables to disk
    if SavedVariables then
        SavedVariables()
    end
end

-- ʕ •ᴥ•ʔ✿ Force save for slash commands (bypasses Interface Options check) ✿ ʕ •ᴥ•ʔ
function AH.ForceSaveSettings()
    -- This version saves settings even when Interface Options isn't open
    -- Used by slash commands and other programmatic changes
    
    -- ʕ •ᴥ•ʔ✿ Check if all blacklist settings are empty and restore defaults if needed ✿ ʕ •ᴥ•ʔ
    local hasAnyBlacklistSetting = false
    local blacklistSlots = {
        "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "WristSlot",
        "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
        "Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot"
    }
    
    for _, slotName in ipairs(blacklistSlots) do
        if AttuneHelperDB[slotName] ~= nil then
            hasAnyBlacklistSetting = true
            break
        end
    end
    
    -- If no blacklist settings exist, restore defaults (all enabled)
    if not hasAnyBlacklistSetting then
        for _, slotName in ipairs(blacklistSlots) do
            AttuneHelperDB[slotName] = 0  -- 0 = not blacklisted (enabled)
        end
        print("|cffffd200[AH]|r Blacklist settings restored to defaults (all slots enabled).")
    end
    
    -- ʕ •ᴥ•ʔ✿ Only reset general options if the database is completely empty or corrupted ✿ ʕ •ᴥ•ʔ
    -- This prevents unnecessary resets during normal slash command usage
    if not AttuneHelperDB or type(AttuneHelperDB) ~= "table" then
        AttuneHelperDB = {}
        print("|cffffd200[AH]|r Database was corrupted, initializing defaults.")
        AH.InitializeDefaultSettings()
    end
    
    -- Force WoW to write saved variables to disk
    if SavedVariables then
        SavedVariables()
    end
end

-- Export for legacy compatibility
_G.SaveAllSettings = AH.SaveAllSettings
_G.LoadAllSettings = AH.LoadAllSettings
_G.ForceSaveSettings = AH.ForceSaveSettings
_G.SaveSettingsForced = AH.SaveSettingsForced

------------------------------------------------------------------------
-- Create option panels
------------------------------------------------------------------------
function AH.CreateOptionPanels()
    -- Main panel
    local mainPanel = CreateFrame("Frame", "AttuneHelperOptionsPanel", UIParent)
    mainPanel.name = "AttuneHelper"
    InterfaceOptions_AddCategory(mainPanel)
    
    local title_ah = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title_ah:SetPoint("TOPLEFT", 16, -16)
    title_ah:SetText("AttuneHelper Options")
    
    local description_ah = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    description_ah:SetPoint("TOPLEFT", title_ah, "BOTTOMLEFT", 0, -8)
    description_ah:SetPoint("RIGHT", -32, 0)
    description_ah:SetJustifyH("LEFT")
    description_ah:SetText("Main options for AttuneHelper.")

    -- General Options Panel
	
	local generalOptionsPanel = CreateFrame("Frame", "AttuneHelperGeneralOptionsPanel", mainPanel)
    generalOptionsPanel.name = "General Logic - AttuneHelper"
    generalOptionsPanel.parent = mainPanel.name
    InterfaceOptions_AddCategory(generalOptionsPanel)
    
    local titleG = generalOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleG:SetPoint("TOPLEFT", 16, -16)
    titleG:SetText("General Logic Settings")
    
    local descG = generalOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    descG:SetPoint("TOPLEFT", titleG, "BOTTOMLEFT", 0, -8)
    descG:SetPoint("RIGHT", -32, 0)
    descG:SetJustifyH("LEFT")
    descG:SetText("Configure core addon behavior and equip logic.")

    -- Theme Options Panel
    local themeOptionsPanel = CreateFrame("Frame", "AttuneHelperThemeOptionsPanel", mainPanel)
    themeOptionsPanel.name = "Theme Settings"
    themeOptionsPanel.parent = mainPanel.name
    InterfaceOptions_AddCategory(themeOptionsPanel)
    
    local titleT = themeOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleT:SetPoint("TOPLEFT", 16, -16)
    titleT:SetText("Theme Settings")
    
    local descT = themeOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    descT:SetPoint("TOPLEFT", titleT, "BOTTOMLEFT", 0, -8)
    descT:SetPoint("RIGHT", -32, 0)
    descT:SetJustifyH("LEFT")
    descT:SetText("Customize the appearance of the AttuneHelper frame.")

    -- Blacklist Panel
    local blacklistPanel = CreateFrame("Frame", "AttuneHelperBlacklistOptionsPanel", mainPanel)
    blacklistPanel.name = "Blacklisting"
    blacklistPanel.parent = mainPanel.name
    InterfaceOptions_AddCategory(blacklistPanel)
    
    local titleB = blacklistPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleB:SetPoint("TOPLEFT", 16, -16)
    titleB:SetText("Blacklisting")
    
    local descB = blacklistPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    descB:SetPoint("TOPLEFT", titleB, "BOTTOMLEFT", 0, -8)
    descB:SetPoint("RIGHT", -32, 0)
    descB:SetJustifyH("LEFT")
    descB:SetText("Choose which equipment slots to blacklist for auto-equipping.")

    -- Forge Options Panel
    local forgeOptionsPanel = CreateFrame("Frame", "AttuneHelperForgeOptionsPanel", mainPanel)
    forgeOptionsPanel.name = "Forge Equipping"
    forgeOptionsPanel.parent = mainPanel.name
    InterfaceOptions_AddCategory(forgeOptionsPanel)
    
    local titleF = forgeOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleF:SetPoint("TOPLEFT", 16, -16)
    titleF:SetText("Forge Equip Settings")
    
    local descF = forgeOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    descF:SetPoint("TOPLEFT", titleF, "BOTTOMLEFT", 0, -8)
    descF:SetPoint("RIGHT", -32, 0)
    descF:SetJustifyH("LEFT")
    descF:SetText("Configure which types of forged items are allowed for auto-equipping.")

    -- Store panel references
    AH.UI.panels = {
        main = mainPanel,
        general = generalOptionsPanel,
        theme = themeOptionsPanel,
        blacklist = blacklistPanel,
        forge = forgeOptionsPanel
    }

    return mainPanel, generalOptionsPanel, themeOptionsPanel, blacklistPanel, forgeOptionsPanel
end

------------------------------------------------------------------------
-- Initialize option checkboxes
------------------------------------------------------------------------
function AH.InitializeOptionCheckboxes()
    wipe(AH.blacklist_checkboxes)
    wipe(AH.general_option_checkboxes)

    local blacklistPanel = AH.UI.panels.blacklist
    local generalOptionsPanel = AH.UI.panels.general

    -- Blacklist checkboxes
    local x, y, r, c = 16, -60, 0, 0
    for _, sN in ipairs(AH.slots) do
        local cb = AH.CreateCheckbox(sN, blacklistPanel, x + 120 * c, y - 33 * r, false, sN)
        table.insert(AH.blacklist_checkboxes, cb)
        cb:SetScript("OnClick", AH.SaveSettingsForced)
        r = r + 1
        if r == 6 then
            r = 0
            c = c + 1
        end
    end

    -- General option checkboxes
    local gYO = -60
    for _, oD in ipairs(AH.general_options_list_for_checkboxes) do
        local cb = AH.CreateCheckbox(oD.text, generalOptionsPanel, 16, gYO, true, oD.dbKey)
        AH.ApplyGeneralOptionTooltip(cb, oD.dbKey)
        table.insert(AH.general_option_checkboxes, cb)
        
        if oD.dbKey == "EquipNewAffixesOnly" then
            cb:SetScript("OnClick", function(s)
                AH.SaveAllSettings()
                if AH.UpdateItemCountText then
                    AH.UpdateItemCountText()
                end
            end)
        elseif oD.dbKey == "Lock AH in Place (Buttons Only Mouse)" then
            cb:SetScript("OnClick", function()
                AH.SaveAllSettings()
                if AH.ApplyFrameInteractivity then
                    AH.ApplyFrameInteractivity()
                end
            end)
        else
            cb:SetScript("OnClick", AH.SaveAllSettings)
        end
        gYO = gYO - 33
    end
end

------------------------------------------------------------------------
-- Initialize forge option checkboxes
------------------------------------------------------------------------
function AH.InitializeForgeOptionCheckboxes()
    wipe(AH.forge_type_checkboxes)
    local forgePanel = AH.UI.panels.forge
    if not forgePanel then return end
    
    local fTSL = forgePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fTSL:SetPoint("TOPLEFT", 16, -60)
    fTSL:SetText("Allowed Forge Types for Auto-Equip:")
    
    local lA, yO, xIO = fTSL, -8, 16
    for i, fO in ipairs(AH.forgeTypeOptionsList) do
        local cb = AH.CreateCheckbox(fO.label, forgePanel, 0, 0, true, fO.dbKey)
        if i == 1 then
            cb:SetPoint("TOPLEFT", lA, "BOTTOMLEFT", xIO, yO - 5)
        else
            cb:SetPoint("TOPLEFT", lA, "BOTTOMLEFT", 0, yO)
        end
        lA = cb
        
        cb:SetScript("OnClick", AH.SaveSettingsForced)
        
        table.insert(AH.forge_type_checkboxes, cb)
    end

    local disableBoe284Cb = AH.CreateCheckbox(
        "Disable Auto Equip on 284 BoE Forges if Base Attuned",
        forgePanel,
        16,
        -220,
        true,
        "Disable Auto Equip 284 BoE Forges if Base Attuned"
    )
    disableBoe284Cb:SetScript("OnClick", AH.SaveSettingsForced)
    table.insert(AH.general_option_checkboxes, disableBoe284Cb)
end

------------------------------------------------------------------------
-- Initialize theme options
------------------------------------------------------------------------
function AH.InitializeThemeOptions()
    wipe(AH.theme_option_controls)
    local yOffset = -60
    local themePanel = AH.UI.panels.theme
    if not themePanel then
        --AH.print_debug_general("Theme panel not found for init!")
        return
    end

    -- Background Style Label
    local bgL = themePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    bgL:SetPoint("TOPLEFT", 16, yOffset)
    bgL:SetText("Background Style:")
    AH.theme_option_controls.bgLabel = bgL
    local lastAnchor = bgL
    yOffset = yOffset - 10

    -- Background Style Dropdown
    local bgDD = CreateFrame("Frame", "AttuneHelperBgDropdown", themePanel, "UIDropDownMenuTemplate")
    bgDD:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -8)
    UIDropDownMenu_SetWidth(bgDD, 160)
    AH.theme_option_controls.bgDropdown = bgDD
    
    UIDropDownMenu_Initialize(bgDD, function(s)
        for sN, _ in pairs(AH.BgStyles) do
            if sN ~= "MiniModeBg" then
                local i = UIDropDownMenu_CreateInfo()
                i.text = sN
                i.value = sN
                i.func = function(self)
                    UIDropDownMenu_SetSelectedValue(bgDD, self.value)
                    AttuneHelperDB["Background Style"] = self.value
                    UIDropDownMenu_SetText(bgDD, self.value)
                    if AH.UpdateDisplayMode then
                        AH.UpdateDisplayMode()
                    end
                    AH.SaveAllSettings()
                end
                i.checked = (sN == AttuneHelperDB["Background Style"])
                UIDropDownMenu_AddButton(i)
            end
        end
    end)
    lastAnchor = bgDD
    yOffset = yOffset - 30

    -- Color Swatch
    local sw = CreateFrame("Button", "AttuneHelperBgColorSwatch", themePanel)
    sw:SetSize(16, 16)
    sw:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -15)
    sw:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 4,
        edgeSize = 4,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    sw:SetBackdropBorderColor(0, 0, 0, 1)
    AH.theme_option_controls.bgColorSwatch = sw
    
    sw:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
        GameTooltip:SetText(AH.t("Background Color"))
        GameTooltip:Show()
    end)
    sw:SetScript("OnLeave", GameTooltip_Hide)
    
    sw:SetScript("OnClick", function(s)
        local c = AttuneHelperDB["Background Color"]
        ColorPickerFrame.func = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            c[1], c[2], c[3] = r, g, b
            sw:SetBackdropColor(r, g, b, 1)
            if AH.UpdateDisplayMode then
                AH.UpdateDisplayMode()
            end
            AH.SaveAllSettings()
        end
        
        ColorPickerFrame.opacityFunc = function()
            local nA
            if _G.ColorPickerFrameOpacitySlider then
                nA = _G.ColorPickerFrameOpacitySlider:GetValue()
            else
                nA = ColorPickerFrame.opacity
            end
            if type(nA) == "number" then
                if ColorPickerFrame.previousValues then
                    ColorPickerFrame.previousValues.a = nA
                end
                AttuneHelperDB["Background Color"][4] = nA
                if AH.UpdateDisplayMode then
                    AH.UpdateDisplayMode()
                end
                AH.SaveAllSettings()
            end
        end
        
        ColorPickerFrame.cancelFunc = function(pV)
            if pV then
                AttuneHelperDB["Background Color"] = {pV.r, pV.g, pV.b, pV.a}
                if AH.UpdateDisplayMode then
                    AH.UpdateDisplayMode()
                end
                sw:SetBackdropColor(pV.r, pV.g, pV.b, 1)
                if _G.AttuneHelperAlphaSlider then
                    _G.AttuneHelperAlphaSlider:SetValue(pV.a)
                end
            end
        end
        
        ColorPickerFrame.hasOpacity = true
        ColorPickerFrame.opacity = AttuneHelperDB["Background Color"][4]
        ColorPickerFrame.previousValues = {
            r = AttuneHelperDB["Background Color"][1],
            g = AttuneHelperDB["Background Color"][2],
            b = AttuneHelperDB["Background Color"][3],
            a = AttuneHelperDB["Background Color"][4]
        }
        ColorPickerFrame:SetColorRGB(c[1], c[2], c[3])
        ColorPickerFrame:Show()
    end)

    local swL = themePanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    swL:SetPoint("LEFT", sw, "RIGHT", 4, 0)
    swL:SetText("BG Color")
    AH.theme_option_controls.bgColorLabel = swL
    lastAnchor = swL
    yOffset = yOffset - 20

    -- Alpha Label
    local alpL = themePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    alpL:SetPoint("TOPLEFT", sw, "BOTTOMLEFT", -2, -10)
    alpL:SetText("BG Transparency:")
    AH.theme_option_controls.alphaLabel = alpL
    lastAnchor = alpL
    yOffset = yOffset - 10

    -- Alpha Slider
    local alpS = CreateFrame("Slider", "AttuneHelperAlphaSlider", themePanel, "OptionsSliderTemplate")
    alpS:SetOrientation("HORIZONTAL")
    alpS:SetMinMaxValues(0, 1)
    alpS:SetValueStep(0.01)
    alpS:SetWidth(150)
    alpS:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -8)
    AH.theme_option_controls.alphaSlider = alpS
    
    _G.AttuneHelperAlphaSliderLow:SetText("0")
    _G.AttuneHelperAlphaSliderHigh:SetText("1")
    _G.AttuneHelperAlphaSliderText:SetText("")
    
    alpS:SetScript("OnValueChanged", function(s, v)
        AttuneHelperDB["Background Color"][4] = v
        if AH.UpdateDisplayMode then
            AH.UpdateDisplayMode()
        end
        AH.SaveAllSettings()
    end)
    lastAnchor = alpS
    yOffset = yOffset - 35

    -- Button Theme Label
    local btL = themePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    btL:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -20)
    btL:SetText("Button Theme:")
    AH.theme_option_controls.buttonThemeLabel = btL
    lastAnchor = btL
    yOffset = yOffset - 10

    -- Button Theme Dropdown
    local btDD = CreateFrame("Frame", "AttuneHelperButtonThemeDropdown", themePanel, "UIDropDownMenuTemplate")
    btDD:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -8)
    UIDropDownMenu_SetWidth(btDD, 160)
    AH.theme_option_controls.buttonThemeDropdown = btDD
    
    UIDropDownMenu_Initialize(btDD, function(s)
        for _, th in ipairs({"Normal", "Blue", "Grey"}) do
            local i = UIDropDownMenu_CreateInfo()
            i.text = th
            i.value = th
            i.func = function(self)
                local v = self.value
                UIDropDownMenu_SetSelectedValue(btDD, v)
                UIDropDownMenu_SetText(btDD, v)
                AttuneHelperDB["Button Theme"] = v
                AH.ApplyButtonTheme(v)
                AH.SaveAllSettings()
            end
            i.checked = (th == AttuneHelperDB["Button Theme"])
            UIDropDownMenu_AddButton(i)
        end
    end)
    lastAnchor = btDD
    yOffset = yOffset - 30

    local miniModeCheckbox = AH.CreateCheckbox("Mini Mode", themePanel, 16, yOffset - 5, true, "Mini Mode")
    miniModeCheckbox:SetPoint("TOPLEFT", btDD, "BOTTOMLEFT", 16, -10)
    miniModeCheckbox:SetScript("OnClick", function(self)
        AttuneHelperDB["Mini Mode"] = self:GetChecked() and 1 or 0
        AH.SaveAllSettings()
        if AH.UpdateDisplayMode then
            AH.UpdateDisplayMode()
        end
    end)
    table.insert(AH.general_option_checkboxes, miniModeCheckbox)
    AH.theme_option_controls.miniModeCheckbox = miniModeCheckbox
    yOffset = yOffset - 33

    -- ʕ •ᴥ•ʔ✿ Language Selection (Theme Panel) ✿ ʕ •ᴥ•ʔ
    local langLabelT = themePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    langLabelT:SetPoint("TOPLEFT", miniModeCheckbox, "BOTTOMLEFT", 0, -20)
    langLabelT:SetText(AH.t("Select Language:"))

    local langDDT = CreateFrame("Frame", "AttuneHelperLanguageDropdownTheme", themePanel, "UIDropDownMenuTemplate")
    langDDT:SetPoint("TOPLEFT", langLabelT, "BOTTOMLEFT", -16, -8)
    UIDropDownMenu_SetWidth(langDDT, 180)

    local localeOptions2 = {
        { code = "default", text = AH.t("System Default") },
        { code = "enUS",    text = AH.t("English (US)") },
        { code = "deDE",    text = AH.t("Deutsch") },
        { code = "esES",    text = AH.t("Español") },
        { code = "frFR",    text = AH.t("Français") },
        { code = "itIT",    text = AH.t("Italiano") },
        { code = "ptBR",    text = AH.t("Português (BR)") },
        { code = "ruRU",    text = AH.t("Русский") },
        { code = "zhCN",    text = AH.t("简体中文") },
        { code = "zhTW",    text = AH.t("繁體中文") },
        { code = "koKR",    text = AH.t("한국어") },
    }

    UIDropDownMenu_Initialize(langDDT, function(self)
        for _, opt in ipairs(localeOptions2) do
            local info = UIDropDownMenu_CreateInfo()
            info.text  = opt.text
            info.value = opt.code
            info.func  = function(btn)
                UIDropDownMenu_SetSelectedValue(langDDT, btn.value)
                UIDropDownMenu_SetText(langDDT, btn.text)
                AH.SetLocale(btn.value)
                AH.SaveAllSettings()
				--Reloading some texts that are generally only loaded on startup
				AH.ReCreateButtons()
				AH.LoadPopUps()
            end
            info.checked = (opt.code == (AttuneHelperDB["Language"] or "default"))
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Register for later LoadAllSettings
    AH.language_option_controls = AH.language_option_controls or {}
    AH.language_option_controls.dropdown = langDDT
end

------------------------------------------------------------------------
-- Setup panel event handlers
------------------------------------------------------------------------
function AH.SetupPanelHandlers()
    -- Settings save on panel close
    local function SaveOnClose()
        AH.SaveAllSettings()
    end
    
    -- Set handlers for all panels
    if AH.UI.optionsPanels then
        for _, panel in pairs(AH.UI.optionsPanels) do
            if panel then
                panel:SetScript("OnHide", SaveOnClose)
            end
        end
    end
end

------------------------------------------------------------------------
-- Create main options panel
------------------------------------------------------------------------
function AH.CreateMainOptionsPanel()
    local mainPanel = CreateFrame("Frame", "AttuneHelperOptionsPanel", UIParent)
    mainPanel.name = "AttuneHelper"
    InterfaceOptions_AddCategory(mainPanel)

    local title = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("AttuneHelper")

    local subtitle = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Automated equipment management for attunement progression.")

    return mainPanel
end

------------------------------------------------------------------------
-- Create general options panel
------------------------------------------------------------------------
function AH.CreateGeneralOptionsPanel(mainPanel)
    local generalOptionsPanel = CreateFrame("Frame", "AttuneHelperGeneralOptionsPanel", mainPanel)
    generalOptionsPanel.name = "General Logic - AttuneHelper"
    generalOptionsPanel.parent = mainPanel.name
    InterfaceOptions_AddCategory(generalOptionsPanel)

    local title = generalOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("General Logic Options")

    local yOffset = -50
    for i, opt in ipairs(AH.general_options_list_for_checkboxes) do
        local cb = AH.CreateCheckbox(opt.text, generalOptionsPanel, 16, yOffset, true, opt.dbKey)
        AH.ApplyGeneralOptionTooltip(cb, opt.dbKey)
        table.insert(AH.general_option_checkboxes, cb)
        
        -- ʕ •ᴥ•ʔ✿ Add click handlers for general option checkboxes ✿ ʕ •ᴥ•ʔ
        if opt.dbKey == "EquipNewAffixesOnly" then
            AH.forge_option_controls = AH.forge_option_controls or {}

            local affixDD = CreateFrame("Frame", "AttuneHelperAffixMinForgeDropdown", generalOptionsPanel, "UIDropDownMenuTemplate")
            affixDD:SetPoint("LEFT", cb, "RIGHT", 180, -1)
            UIDropDownMenu_SetWidth(affixDD, 140)
            AH.forge_option_controls.affixMinForgeDropdown = affixDD

            UIDropDownMenu_Initialize(affixDD, function()
                local options = {
                    { text = "All Items", value = -1 },
                    { text = "Titanforged", value = AH.FORGE_LEVEL_MAP.TITANFORGED },
                    { text = "Warforged", value = AH.FORGE_LEVEL_MAP.WARFORGED },
                    { text = "Lightforged", value = AH.FORGE_LEVEL_MAP.LIGHTFORGED },
                }

                for _, optData in ipairs(options) do
                    local optText = optData.text
                    local optValue = optData.value
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = optText
                    info.value = optValue
                    info.func = function(btn)
                        UIDropDownMenu_SetSelectedValue(affixDD, btn.value)
                        UIDropDownMenu_SetText(affixDD, optText)
                        AttuneHelperDB["AffixOnlyMinForgeLevel"] = btn.value
                        AH.SaveSettingsForced()
                        if AH.UpdateItemCountText then
                            AH.UpdateItemCountText()
                        end
                    end
                    info.checked = (AttuneHelperDB["AffixOnlyMinForgeLevel"] == optValue)
                    UIDropDownMenu_AddButton(info)
                end
            end)

            local function ShowAffixDropdownTooltip(owner)
                GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
                GameTooltip:SetText(AH.t("Equip Attunable Affixes up to:"))
                GameTooltip:AddLine(AH.t("Quick rules:"), 1, 0.82, 0.2, true)
                GameTooltip:AddLine(AH.t("- Below selected tier: lenient."), 0.85, 0.85, 0.85, true)
                GameTooltip:AddLine(AH.t("- Selected tier and up: unattuned variant only."), 0.85, 0.85, 0.85, true)
                GameTooltip:AddLine(AH.t("- Does not check extra affix unlocks."), 0.85, 0.85, 0.85, true)
                GameTooltip:AddLine(AH.t("- 'All Items': strict at all tiers."), 0.85, 0.85, 0.85, true)
                GameTooltip:Show()
            end

            affixDD:SetScript("OnEnter", function(s)
                ShowAffixDropdownTooltip(s)
            end)
            affixDD:SetScript("OnLeave", GameTooltip_Hide)

            local affixDDButton = _G[affixDD:GetName() .. "Button"]
            if affixDDButton then
                affixDDButton:SetScript("OnEnter", function(s)
                    ShowAffixDropdownTooltip(s)
                end)
                affixDDButton:SetScript("OnLeave", GameTooltip_Hide)
            end

            cb:SetScript("OnClick", function(s)
                AH.SaveSettingsForced()
                if AH.UpdateItemCountText then
                    AH.UpdateItemCountText()
                end
            end)
        elseif opt.dbKey == "Lock AH in Place (Buttons Only Mouse)" then
            cb:SetScript("OnClick", function()
                AH.SaveSettingsForced()
                if AH.ApplyFrameInteractivity then
                    AH.ApplyFrameInteractivity()
                end
            end)
        else
            cb:SetScript("OnClick", AH.SaveSettingsForced)
        end
        
        yOffset = yOffset - 25
    end

    return generalOptionsPanel
end

------------------------------------------------------------------------
-- Create blacklist options panel
------------------------------------------------------------------------
function AH.CreateBlacklistOptionsPanel(mainPanel)
    local blacklistPanel = CreateFrame("Frame", "AttuneHelperBlacklistOptionsPanel", mainPanel)
    blacklistPanel.name = "Blacklisting"
    blacklistPanel.parent = mainPanel.name
    InterfaceOptions_AddCategory(blacklistPanel)

    local title = blacklistPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Slot Blacklisting")

    local subtitle = blacklistPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Disable auto-equipping for specific equipment slots.")

    local yOffset = -60
    for i, slot in ipairs(AH.slots) do
        local cb = AH.CreateCheckbox(slot, blacklistPanel, 16, yOffset)
        table.insert(AH.blacklist_checkboxes, cb)
        
        -- ʕ •ᴥ•ʔ✿ Add click handler for blacklist checkboxes ✿ ʕ •ᴥ•ʔ
        cb:SetScript("OnClick", AH.SaveSettingsForced)
        
        yOffset = yOffset - 25
        
        -- Create second column if needed
        if i == 9 then
            yOffset = -60
        elseif i > 9 then
            cb:SetPoint("TOPLEFT", blacklistPanel, "TOPLEFT", 250, yOffset)
        end
    end

    return blacklistPanel
end

------------------------------------------------------------------------
-- Create theme options panel
------------------------------------------------------------------------
function AH.CreateThemeOptionsPanel(mainPanel)
    local themePanel = CreateFrame("Frame", "AttuneHelperThemeOptionsPanel", mainPanel)
    themePanel.name = "Theme Settings"
    themePanel.parent = mainPanel.name
    InterfaceOptions_AddCategory(themePanel)

    local title = themePanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Theme Settings")

    local subtitle = themePanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Customize the appearance of AttuneHelper interface.")

    -- Store panel reference for InitializeThemeOptions
    AH.UI.panels = AH.UI.panels or {}
    AH.UI.panels.theme = themePanel
    
    -- Initialize theme controls using the existing working function
    AH.InitializeThemeOptions()

    return themePanel
end

------------------------------------------------------------------------
-- Create list management panel
------------------------------------------------------------------------
function AH.CreateListManagementPanel(mainPanel)
    local listPanel = CreateFrame("Frame", "AttuneHelperListManagementPanel", mainPanel)
    listPanel.name = "List Management"
    listPanel.parent = mainPanel.name
    InterfaceOptions_AddCategory(listPanel)

    local title = listPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("List Management")

    local subtitle = listPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Review and remove entries from AHSet, AHIgnore, and Always Vendored.")

    local ahSetSection = CreateManagedListSection(listPanel, "AHSet", subtitle, "ahset", GetAHSetEntries)
    local ignoreSection = CreateManagedListSection(listPanel, "AHIgnore", ahSetSection, "ignore", GetAHIgnoreEntries)
    local vendorSection = CreateManagedListSection(listPanel, "Always Vendored", ignoreSection, "vendor", GetAlwaysVendorEntries)

    AH.list_management_controls = {
        panel = listPanel,
        ahset = ahSetSection,
        ignore = ignoreSection,
        vendor = vendorSection
    }

    AH.RefreshListManagementPanel = function()
        if not AH.list_management_controls then
            return
        end
        RefreshManagedListSection(AH.list_management_controls.ahset)
        RefreshManagedListSection(AH.list_management_controls.ignore)
        RefreshManagedListSection(AH.list_management_controls.vendor)
    end

    listPanel:SetScript("OnShow", function()
        if AH.RefreshListManagementPanel then
            AH.RefreshListManagementPanel()
        end
    end)

    return listPanel
end

------------------------------------------------------------------------
-- Create button layout options panel
------------------------------------------------------------------------
function AH.CreateButtonLayoutOptionsPanel(mainPanel)
    local buttonLayoutPanel = CreateFrame("Frame", "AttuneHelperButtonLayoutOptionsPanel", mainPanel)
    buttonLayoutPanel.name = "Button Layout"
    buttonLayoutPanel.parent = mainPanel.name
    InterfaceOptions_AddCategory(buttonLayoutPanel)

    AH.UI.panels = AH.UI.panels or {}
    AH.UI.panels.buttonLayout = buttonLayoutPanel

    local title = buttonLayoutPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Button Layout")

    local subtitle = buttonLayoutPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Configure which action buttons appear for Normal, Shift, and Ctrl views.")

    AH.button_layout_option_controls = {}

    local modeLabel = buttonLayoutPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    modeLabel:SetPoint("TOPLEFT", 16, -60)
    modeLabel:SetText("Layout Mode:")

    local modeDD = CreateFrame("Frame", "AttuneHelperButtonLayoutDropdown", buttonLayoutPanel, "UIDropDownMenuTemplate")
    modeDD:SetPoint("TOPLEFT", modeLabel, "BOTTOMLEFT", -16, -8)
    UIDropDownMenu_SetWidth(modeDD, 180)
    AH.button_layout_option_controls.layoutModeDropdown = modeDD

    UIDropDownMenu_Initialize(modeDD, function()
        for _, preset in ipairs({ "Standard", "Custom" }) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = preset
            info.value = preset
            info.func = function(btn)
                UIDropDownMenu_SetSelectedValue(modeDD, btn.value)
                UIDropDownMenu_SetText(modeDD, btn.value)
                AttuneHelperDB["Button Layout Preset"] = btn.value
                AH.SaveAllSettings()
                if AH.RefreshButtonLayoutOptionVisibility then
                    AH.RefreshButtonLayoutOptionVisibility()
                end
                if AH.RefreshButtonLayoutEditor then
                    AH.RefreshButtonLayoutEditor()
                end
                if AH.UpdateModifierButtonVisibility then
                    AH.UpdateModifierButtonVisibility()
                end
            end
            info.checked = (preset == (AttuneHelperDB["Button Layout Preset"] or "Standard"))
            UIDropDownMenu_AddButton(info)
        end
    end)

    local hideCenterCheckbox = AH.CreateCheckbox(
        "Hide Center Button in Normal Mode",
        buttonLayoutPanel,
        16,
        -118,
        true,
        "Hide Center Button in Normal Mode"
    )
    hideCenterCheckbox:SetScript("OnClick", function()
        AH.SaveAllSettings()
        if AH.RefreshButtonLayoutEditor then
            AH.RefreshButtonLayoutEditor()
        end
        if AH.UpdateModifierButtonVisibility then
            AH.UpdateModifierButtonVisibility()
        end
    end)
    hideCenterCheckbox:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
        GameTooltip:SetText(AH.t("Hide Center Button in Normal Mode"))
        GameTooltip:AddLine(AH.t("Hides the center action button in normal view."), 1, 1, 1, true)
        GameTooltip:AddLine(AH.t("Hold Ctrl to show Open Settings and Update AHSet."), 0.75, 0.9, 1, true)
        GameTooltip:Show()
    end)
    hideCenterCheckbox:SetScript("OnLeave", GameTooltip_Hide)
    table.insert(AH.general_option_checkboxes, hideCenterCheckbox)
    AH.button_layout_option_controls.hideCenterButtonCheckbox = hideCenterCheckbox

    local visualHeader = buttonLayoutPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    visualHeader:SetPoint("TOPLEFT", 16, -152)
    visualHeader:SetText("Custom Modifier Layout")
    AH.button_layout_option_controls.visualHeader = visualHeader

    local modifierLabel = buttonLayoutPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    modifierLabel:SetPoint("TOPLEFT", visualHeader, "BOTTOMLEFT", 0, -10)
    modifierLabel:SetText("Modifier View:")
    AH.button_layout_option_controls.modifierLabel = modifierLabel

    local activeModifier = "Normal"
    local modifierButtons = {}
    local actionButtons = {}
    local actionTitles = {}
    local actionTexts = {}

    local function GetLayoutDbKey(modifierName, slotType)
        return "Layout " .. modifierName .. " " .. slotType
    end

    local function GetChoicePool()
        local list = {}
        for _, choice in ipairs(AH.button_layout_button_choices or {}) do
            table.insert(list, choice)
        end
        return list
    end

    local iconMap = {
        equipAll = "Interface\\Addons\\AttuneHelper\\assets\\icon_equip_attunables.blp",
        vendor = "Interface\\Addons\\AttuneHelper\\assets\\icon_vendor-attuned.blp",
        openSettings = "Interface\\Addons\\AttuneHelper\\assets\\icon_settings.blp",
        toggleAutoEquip = "Interface\\Addons\\AttuneHelper\\assets\\icon_auto_equip_off.blp",
        AHSetUpdate = "Interface\\Addons\\AttuneHelper\\assets\\icon_ahsetall.blp",
        sort = "Interface\\Addons\\AttuneHelper\\assets\\icon_prepare_disenchant.blp",
        equipAHSet = "Interface\\Addons\\AttuneHelper\\assets\\icon_equip_ahset.blp"
    }

    local function GetChoiceMeta(choiceKey)
        for _, choice in ipairs(AH.button_layout_button_choices or {}) do
            if choice.key == choiceKey then
                return AH.t(choice.label), iconMap[choice.key]
            end
        end
        return tostring(choiceKey or ""), nil
    end

    local function SetActiveModifier(modifierName)
        activeModifier = modifierName or "Normal"
        for key, btn in pairs(modifierButtons) do
            if key == activeModifier then
                btn:SetNormalFontObject("GameFontHighlightLarge")
            else
                btn:SetNormalFontObject("GameFontHighlight")
            end
        end
    end

    local actionDropDown = CreateFrame("Frame", "AttuneHelperButtonLayoutActionDropdown", buttonLayoutPanel, "UIDropDownMenuTemplate")
    actionDropDown.currentDbKey = nil
    AH.button_layout_option_controls.actionDropdown = actionDropDown

    UIDropDownMenu_Initialize(actionDropDown, function()
        if not actionDropDown.currentDbKey then
            return
        end
        local currentValue = AttuneHelperDB[actionDropDown.currentDbKey]
        for _, choice in ipairs(GetChoicePool()) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = AH.t(choice.label)
            info.value = choice.key
            info.func = function(btn)
                AttuneHelperDB[actionDropDown.currentDbKey] = btn.value
                AH.SaveAllSettings()
                if AH.RefreshButtonLayoutEditor then
                    AH.RefreshButtonLayoutEditor()
                end
                if AH.UpdateModifierButtonVisibility then
                    AH.UpdateModifierButtonVisibility()
                end
            end
            info.checked = (currentValue == choice.key)
            UIDropDownMenu_AddButton(info)
        end
    end)

    local normalBtn = CreateFrame("Button", nil, buttonLayoutPanel, "UIPanelButtonTemplate")
    normalBtn:SetPoint("TOPLEFT", modifierLabel, "BOTTOMLEFT", 0, -6)
    normalBtn:SetSize(68, 22)
    normalBtn:SetText("Normal")
    normalBtn:SetScript("OnClick", function()
        SetActiveModifier("Normal")
        if AH.RefreshButtonLayoutEditor then
            AH.RefreshButtonLayoutEditor()
        end
    end)
    modifierButtons.Normal = normalBtn

    local shiftBtn = CreateFrame("Button", nil, buttonLayoutPanel, "UIPanelButtonTemplate")
    shiftBtn:SetPoint("LEFT", normalBtn, "RIGHT", 6, 0)
    shiftBtn:SetSize(62, 22)
    shiftBtn:SetText("Shift")
    shiftBtn:SetScript("OnClick", function()
        SetActiveModifier("Shift")
        if AH.RefreshButtonLayoutEditor then
            AH.RefreshButtonLayoutEditor()
        end
    end)
    modifierButtons.Shift = shiftBtn

    local ctrlBtn = CreateFrame("Button", nil, buttonLayoutPanel, "UIPanelButtonTemplate")
    ctrlBtn:SetPoint("LEFT", shiftBtn, "RIGHT", 6, 0)
    ctrlBtn:SetSize(54, 22)
    ctrlBtn:SetText("Ctrl")
    ctrlBtn:SetScript("OnClick", function()
        SetActiveModifier("Ctrl")
        if AH.RefreshButtonLayoutEditor then
            AH.RefreshButtonLayoutEditor()
        end
    end)
    modifierButtons.Ctrl = ctrlBtn

    local function CreateActionPicker(slotType, titleText, anchor, yOffset)
        local title = buttonLayoutPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOffset)
        title:SetText(titleText)
        actionTitles[slotType] = title

        local btn = CreateFrame("Button", nil, buttonLayoutPanel)
        btn:SetSize(26, 26)
        btn:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 2, -6)
        btn:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Buttons\\UI-Quickslot-Depress",
            edgeSize = 2,
            insets = { left = -1, right = -1, top = -1, bottom = -1 }
        })
        btn:SetBackdropColor(0, 0, 0, 0.6)
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints(btn)
        btn.icon = icon
        actionButtons[slotType] = btn

        local txt = buttonLayoutPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        txt:SetPoint("LEFT", btn, "RIGHT", 8, 0)
        txt:SetJustifyH("LEFT")
        txt:SetWidth(220)
        actionTexts[slotType] = txt

        btn:SetScript("OnClick", function(self)
            actionDropDown.currentDbKey = GetLayoutDbKey(activeModifier, slotType)
            ToggleDropDownMenu(1, nil, actionDropDown, self, 0, 0)
        end)
    end

    CreateActionPicker("Top", "Top Button", normalBtn, -14)
    CreateActionPicker("Center", "Center Button", actionButtons.Top, -12)
    CreateActionPicker("Bottom", "Bottom Button", actionButtons.Center, -12)

    local function RefreshCustomLayoutVisibility()
        local preset = (AttuneHelperDB and AttuneHelperDB["Button Layout Preset"]) or "Standard"
        local showCustom = (preset == "Custom")
        if visualHeader then if showCustom then visualHeader:Show() else visualHeader:Hide() end end
        if modifierLabel then if showCustom then modifierLabel:Show() else modifierLabel:Hide() end end
        for _, btn in pairs(modifierButtons) do
            if showCustom then btn:Show() else btn:Hide() end
        end
        for _, btn in pairs(actionButtons) do
            if showCustom then btn:Show() else btn:Hide() end
        end
        for _, fs in pairs(actionTitles) do
            if showCustom then fs:Show() else fs:Hide() end
        end
        for _, fs in pairs(actionTexts) do
            if showCustom then fs:Show() else fs:Hide() end
        end
    end

    local function RefreshButtonLayoutEditor()
        local inMiniMode = (AttuneHelperDB and AttuneHelperDB["Mini Mode"] == 1)
        if hideCenterCheckbox then
            if inMiniMode then
                if AttuneHelperDB["Hide Center Button in Normal Mode"] == 1 then
                    AttuneHelperDB["Hide Center Button in Normal Mode"] = 0
                    hideCenterCheckbox:SetChecked(false)
                    AH.SaveAllSettings()
                    if AH.UpdateModifierButtonVisibility then
                        AH.UpdateModifierButtonVisibility()
                    end
                end
                hideCenterCheckbox:Disable()
                hideCenterCheckbox:SetAlpha(0.45)
            else
                hideCenterCheckbox:Enable()
                hideCenterCheckbox:SetAlpha(1)
            end
        end

        local preset = (AttuneHelperDB and AttuneHelperDB["Button Layout Preset"]) or "Standard"
        if preset ~= "Custom" then
            for _, btn in pairs(modifierButtons) do
                btn:Hide()
            end
            for _, btn in pairs(actionButtons) do
                btn:Hide()
            end
            for _, fs in pairs(actionTitles) do
                fs:Hide()
            end
            for _, fs in pairs(actionTexts) do
                fs:Hide()
            end
            if visualHeader then visualHeader:Hide() end
            if modifierLabel then modifierLabel:Hide() end
            return
        end

        local hideCenterEnabled = (AttuneHelperDB and AttuneHelperDB["Hide Center Button in Normal Mode"] == 1)
        local showCenter = not hideCenterEnabled

        if modifierButtons.Ctrl then
            if hideCenterEnabled then
                modifierButtons.Ctrl:Enable()
                modifierButtons.Ctrl:SetAlpha(1)
            else
                modifierButtons.Ctrl:Disable()
                modifierButtons.Ctrl:SetAlpha(0.45)
                if activeModifier == "Ctrl" then
                    activeModifier = "Normal"
                end
            end
        end

        SetActiveModifier(activeModifier)
        if actionButtons.Center then
            if showCenter then actionButtons.Center:Show() else actionButtons.Center:Hide() end
        end
        if actionTitles.Center then
            if showCenter then actionTitles.Center:Show() else actionTitles.Center:Hide() end
        end
        if actionTexts.Center then
            if showCenter then actionTexts.Center:Show() else actionTexts.Center:Hide() end
        end

        local slotList = showCenter and { "Top", "Center", "Bottom" } or { "Top", "Bottom" }
        for _, slotType in ipairs(slotList) do
            local dbKey = GetLayoutDbKey(activeModifier, slotType)
            local value = AttuneHelperDB[dbKey]
            local displayText, iconPath = GetChoiceMeta(value)
            local btn = actionButtons[slotType]
            if btn and btn.icon then
                btn.icon:SetTexture(iconPath or "Interface\\Icons\\INV_Misc_QuestionMark")
            end
            local txt = actionTexts[slotType]
            if txt then
                txt:SetText(displayText)
            end
        end
    end

    AH.RefreshButtonLayoutOptionVisibility = RefreshCustomLayoutVisibility
    AH.RefreshButtonLayoutEditor = RefreshButtonLayoutEditor
    buttonLayoutPanel:SetScript("OnShow", RefreshCustomLayoutVisibility)
    buttonLayoutPanel:HookScript("OnShow", RefreshButtonLayoutEditor)
    SetActiveModifier("Normal")
    RefreshButtonLayoutEditor()
    RefreshCustomLayoutVisibility()

    return buttonLayoutPanel
end

------------------------------------------------------------------------
-- Create forge options panel
------------------------------------------------------------------------
function AH.CreateForgeOptionsPanel(mainPanel)
    local forgeOptionsPanel = CreateFrame("Frame", "AttuneHelperForgeOptionsPanel", mainPanel)
    forgeOptionsPanel.name = "Forge Equipping"
    forgeOptionsPanel.parent = mainPanel.name
    InterfaceOptions_AddCategory(forgeOptionsPanel)

    local title = forgeOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Forge Type Settings")

    local subtitle = forgeOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Control which forge types are allowed for auto-equipping.")

    local yOffset = -60
    for i, opt in ipairs(AH.forgeTypeOptionsList) do
        local cb = AH.CreateCheckbox(opt.label, forgeOptionsPanel, 16, yOffset, true, opt.dbKey)
        table.insert(AH.forge_type_checkboxes, cb)
        
        -- ʕ •ᴥ•ʔ✿ Add click handler for forge type checkboxes ✿ ʕ •ᴥ•ʔ
        cb:SetScript("OnClick", AH.SaveSettingsForced)
        
        yOffset = yOffset - 25
    end

    yOffset = yOffset - 12
    local disableBoe284Cb = AH.CreateCheckbox(
        "Disable Auto Equip on 284 BoE Forges if Base Attuned",
        forgeOptionsPanel,
        16,
        yOffset,
        true,
        "Disable Auto Equip 284 BoE Forges if Base Attuned"
    )
    disableBoe284Cb:SetScript("OnClick", AH.SaveSettingsForced)
    table.insert(AH.general_option_checkboxes, disableBoe284Cb)

    return forgeOptionsPanel
end

------------------------------------------------------------------------
-- Create weapon controls panel
------------------------------------------------------------------------
function AH.CreateWeaponControlsPanel(mainPanel)
    local weaponPanel = CreateFrame("Frame", "AttuneHelperWeaponControlsPanel", mainPanel)
    weaponPanel.name = "Weapon Controls"
    weaponPanel.parent = mainPanel.name
    InterfaceOptions_AddCategory(weaponPanel)

    local title = weaponPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Weapon Type Controls")

    local subtitle = weaponPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Control which weapon types can be auto-equipped to MainHand and OffHand slots.")

    -- MainHand Section
    local mhHeader = weaponPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    mhHeader:SetPoint("TOPLEFT", 16, -80)
    mhHeader:SetText("MainHand Weapons")
    mhHeader:SetTextColor(0.8, 0.8, 1)

    local mh1hCB = AH.CreateCheckbox("Allow MainHand 1H Weapons", weaponPanel, 16, -110, true, "Allow MainHand 1H Weapons")
    local mh2hCB = AH.CreateCheckbox("Allow MainHand 2H Weapons", weaponPanel, 16, -135, true, "Allow MainHand 2H Weapons")
    
    -- Add MainHand checkboxes to the weapon control array
    table.insert(AH.weapon_control_checkboxes, mh1hCB)
    table.insert(AH.weapon_control_checkboxes, mh2hCB)
    
    -- Set click handlers for MainHand checkboxes
    mh1hCB:SetScript("OnClick", AH.SaveSettingsForced)
    mh2hCB:SetScript("OnClick", AH.SaveSettingsForced)

    -- OffHand Section  
    local ohHeader = weaponPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    ohHeader:SetPoint("TOPLEFT", 16, -170)
    ohHeader:SetText("OffHand Items")
    ohHeader:SetTextColor(0.8, 0.8, 1)

    local oh1hCB = AH.CreateCheckbox("Allow OffHand 1H Weapons", weaponPanel, 16, -200, true, "Allow OffHand 1H Weapons")
    local oh2hCB = AH.CreateCheckbox("Allow OffHand 2H Weapons", weaponPanel, 16, -225, true, "Allow OffHand 2H Weapons")
    local ohShieldCB = AH.CreateCheckbox("Allow OffHand Shields", weaponPanel, 16, -250, true, "Allow OffHand Shields")
    local ohHoldCB = AH.CreateCheckbox("Allow OffHand Holdables", weaponPanel, 16, -275, true, "Allow OffHand Holdables")
    
    -- Add OffHand checkboxes to the weapon control array
    table.insert(AH.weapon_control_checkboxes, oh1hCB)
    table.insert(AH.weapon_control_checkboxes, oh2hCB)
    table.insert(AH.weapon_control_checkboxes, ohShieldCB)
    table.insert(AH.weapon_control_checkboxes, ohHoldCB)
    
    -- Set click handlers for OffHand checkboxes
    oh1hCB:SetScript("OnClick", AH.SaveSettingsForced)
    oh2hCB:SetScript("OnClick", AH.SaveSettingsForced)
    ohShieldCB:SetScript("OnClick", AH.SaveSettingsForced)
    ohHoldCB:SetScript("OnClick", AH.SaveSettingsForced)

    return weaponPanel
end

------------------------------------------------------------------------
-- Initialize option control arrays and data structures
------------------------------------------------------------------------
function AH.InitializeOptionControls()
    -- Clear existing arrays
    wipe(AH.blacklist_checkboxes)
    wipe(AH.general_option_checkboxes)
    wipe(AH.forge_type_checkboxes)
    wipe(AH.weapon_control_checkboxes)
    AH.forge_option_controls = {}
    
    -- Initialize theme controls table
    AH.theme_option_controls = {}
    AH.button_layout_option_controls = {}
    
    print("|cff00ff00[AttuneHelper]|r Option control arrays initialized")
end

------------------------------------------------------------------------
-- Initialize all options panels
------------------------------------------------------------------------
function AH.InitializeAllOptions()
    if AH.UI and AH.UI.optionsPanels and AH.UI.optionsPanels.main and AH.UI.optionsPanels.main:IsObjectType("Frame") then
        return
    end

    -- Initialize the data structures first
    AH.InitializeOptionControls()
    
    -- Create main panel
    local mainPanel = AH.CreateMainOptionsPanel()
    
    -- Create sub-panels
    local generalPanel = AH.CreateGeneralOptionsPanel(mainPanel)
    local themePanel = AH.CreateThemeOptionsPanel(mainPanel)
    local listManagementPanel = AH.CreateListManagementPanel(mainPanel)
    local buttonLayoutPanel = AH.CreateButtonLayoutOptionsPanel(mainPanel)
    local blacklistPanel = AH.CreateBlacklistOptionsPanel(mainPanel)
    local forgePanel = AH.CreateForgeOptionsPanel(mainPanel)
    local weaponPanel = AH.CreateWeaponControlsPanel(mainPanel)
    
    -- Store panel references
    AH.UI.optionsPanels = {
        main = mainPanel,
        general = generalPanel,
        theme = themePanel,
        listManagement = listManagementPanel,
        buttonLayout = buttonLayoutPanel,
        blacklist = blacklistPanel,
        forge = forgePanel,
        weapon = weaponPanel
    }
    
    -- Setup event handlers
    AH.SetupPanelHandlers()
    
    print("|cff00ff00[AttuneHelper]|r Options panels initialized successfully")
end

-- Export all functions
_G.SaveAllSettings = AH.SaveAllSettings
_G.LoadAllSettings = AH.LoadAllSettings
_G.InitializeAllOptions = AH.InitializeAllOptions 

-- ʕ •ᴥ•ʔ✿ UI · Main buttons ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper
local todaysAttunesTooltipOverlays = setmetatable({}, { __mode = "k" })
--ʕ •ᴥ•ʔ✿ Button layouts ✿ ʕ •ᴥ•ʔ
local allButtons = { "equipAll", "openSettings", "vendor", "toggleAutoEquip", "AHSetUpdate", "sort", "equipAHSet", "nextAHPreset" }
local FORGE_BADGE_COLORS = {
    TF = "|cff8080FF",
    WF = "|cffFFA680",
    LF = "|cffFFFFA6"
}
local DAILY_ATTUNES_THRESHOLDS = {
    account = {
        normal = { 20, 60, 80, 120, 180, 220 },
        prestiged = { 40, 110, 150, 220, 320, 420 }
    },
    titanforged = {
        normal = { 12, 20, 28, 36, 44, 52 },
        prestiged = { 20, 32, 45, 60, 80, 100 }
    },
    warforged = {
        normal = { 2, 3, 4, 5, 6, 8 },
        prestiged = { 3, 5, 7, 10, 13, 16 }
    },
    lightforged = {
        normal = { 1, 2, 3, 4, 5, 7 },
        prestiged = { 2, 3, 5, 7, 9, 12 }
    }
}

local function IsEquipAHSetReferencedInLayout()
    if not AttuneHelperDB then
        return false
    end
    for _, modifierName in ipairs({ "Normal", "Shift", "Ctrl" }) do
        for _, slotType in ipairs({ "Top", "Center", "Bottom" }) do
            if AttuneHelperDB["Layout " .. modifierName .. " " .. slotType] == "equipAHSet" then
                return true
            end
        end
    end
    return false
end

local function IsEquipAHSetButtonEnabled()
    return IsEquipAHSetReferencedInLayout()
end

local function GetButtonLayoutPreset()
    if not AttuneHelperDB then
        return "Standard"
    end
    local preset = AttuneHelperDB["Button Layout Preset"] or "Standard"
    if preset == "Compact" then
        return "Standard"
    end
    return preset
end

local function NormalizeLayoutButtonKey(key, fallback, showEquipAHSet)
    if key == "equipAHSet" and not showEquipAHSet then
        return fallback
    end
    for _, knownKey in ipairs(allButtons) do
        if key == knownKey then
            return key
        end
    end
    return fallback
end

local function GetAllowedLayoutButtons(showEquipAHSet)
    local allowed = {}
    for _, key in ipairs(allButtons) do
        if key ~= "equipAHSet" or showEquipAHSet then
            table.insert(allowed, key)
        end
    end
    return allowed
end

local function PickUniqueLayoutButton(preferred, fallback, used, allowed, showEquipAHSet)
    local normalizedPreferred = NormalizeLayoutButtonKey(preferred, fallback, showEquipAHSet)
    if normalizedPreferred and not used[normalizedPreferred] then
        used[normalizedPreferred] = true
        return normalizedPreferred
    end

    local normalizedFallback = NormalizeLayoutButtonKey(fallback, fallback, showEquipAHSet)
    if normalizedFallback and not used[normalizedFallback] then
        used[normalizedFallback] = true
        return normalizedFallback
    end

    for _, key in ipairs(allowed) do
        if not used[key] then
            used[key] = true
            return key
        end
    end

    return normalizedFallback or fallback
end

local function GetCustomLayoutPair(stateKey, showEquipAHSet)
    local dbTopKey = "Layout " .. stateKey .. " Top"
    local dbBottomKey = "Layout " .. stateKey .. " Bottom"
    local defaults = {
        Normal = { top = "equipAll", bottom = "vendor" },
        Shift = { top = "toggleAutoEquip", bottom = "sort" },
        Ctrl = { top = "AHSetUpdate", bottom = "openSettings" }
    }
    local stateDefaults = defaults[stateKey] or defaults.Normal
    local used = {}
    local allowed = GetAllowedLayoutButtons(showEquipAHSet)
    local topKey = PickUniqueLayoutButton(AttuneHelperDB and AttuneHelperDB[dbTopKey], stateDefaults.top, used, allowed, showEquipAHSet)
    local bottomKey = PickUniqueLayoutButton(AttuneHelperDB and AttuneHelperDB[dbBottomKey], stateDefaults.bottom, used, allowed, showEquipAHSet)
    return topKey, bottomKey
end

local function GetCustomLayoutTrio(stateKey, showEquipAHSet)
    local dbTopKey = "Layout " .. stateKey .. " Top"
    local dbCenterKey = "Layout " .. stateKey .. " Center"
    local dbBottomKey = "Layout " .. stateKey .. " Bottom"
    local defaults = {
        Normal = { top = "equipAll", center = "openSettings", bottom = "vendor" },
        Shift = { top = "toggleAutoEquip", center = "AHSetUpdate", bottom = "sort" },
        Ctrl = { top = "AHSetUpdate", center = "openSettings", bottom = "sort" }
    }
    local stateDefaults = defaults[stateKey] or defaults.Normal
    local used = {}
    local allowed = GetAllowedLayoutButtons(showEquipAHSet)
    local topKey = PickUniqueLayoutButton(AttuneHelperDB and AttuneHelperDB[dbTopKey], stateDefaults.top, used, allowed, showEquipAHSet)
    local centerKey = PickUniqueLayoutButton(AttuneHelperDB and AttuneHelperDB[dbCenterKey], stateDefaults.center, used, allowed, showEquipAHSet)
    local bottomKey = PickUniqueLayoutButton(AttuneHelperDB and AttuneHelperDB[dbBottomKey], stateDefaults.bottom, used, allowed, showEquipAHSet)
    return topKey, centerKey, bottomKey
end

-- ʕ •ᴥ•ʔ Standard (non-Custom) layout: Shift row = the trio
-- toggleAutoEquip, AHSetUpdate, sort, plus equipAHSet only if that control is layout-enabled.
-- nextAHPreset is not in this row; show it by assigning it in Custom layout, and keep it hidden
-- in UpdateButtonGroupVisibility. hideOnShift = the Normal row (equipAll, openSettings, vendor).
local function BuildShiftVisibilityLists()
    local showOnShift = { "toggleAutoEquip", "AHSetUpdate", "sort" }
    if IsEquipAHSetButtonEnabled() then
        table.insert(showOnShift, "equipAHSet")
    end
    local hideOnShift = { "equipAll", "openSettings", "vendor" }
    return showOnShift, hideOnShift
end

local function ApplyMainDefaultLayout(buttons)
    local frame = AH.UI and AH.UI.mainFrame
    if not frame or not buttons then
        return
    end

    if buttons.equipAll then
        buttons.equipAll:ClearAllPoints()
        buttons.equipAll:SetPoint("TOP", frame, "TOP", 0, -5)
    end
    if buttons.openSettings and buttons.equipAll then
        buttons.openSettings:ClearAllPoints()
        buttons.openSettings:SetPoint("BOTTOM", buttons.equipAll, "BOTTOM", 0, -27)
    end
    if buttons.vendor and buttons.openSettings then
        buttons.vendor:ClearAllPoints()
        buttons.vendor:SetPoint("BOTTOM", buttons.openSettings, "BOTTOM", 0, -27)
    end
    if buttons.toggleAutoEquip then
        buttons.toggleAutoEquip:ClearAllPoints()
        buttons.toggleAutoEquip:SetPoint("TOP", frame, "TOP", 0, -5)
    end
    if buttons.AHSetUpdate and buttons.toggleAutoEquip then
        buttons.AHSetUpdate:ClearAllPoints()
        buttons.AHSetUpdate:SetPoint("BOTTOM", buttons.toggleAutoEquip, "BOTTOM", 0, -27)
    end
    if buttons.sort and buttons.AHSetUpdate then
        buttons.sort:ClearAllPoints()
        buttons.sort:SetPoint("BOTTOM", buttons.AHSetUpdate, "BOTTOM", 0, -27)
    end
    if buttons.equipAHSet and buttons.sort then
        buttons.equipAHSet:ClearAllPoints()
        buttons.equipAHSet:SetPoint("BOTTOM", buttons.sort, "BOTTOM", 0, -27)
    end
    if buttons.nextAHPreset then
        buttons.nextAHPreset:ClearAllPoints()
        if buttons.equipAHSet then
            buttons.nextAHPreset:SetPoint("BOTTOM", buttons.equipAHSet, "BOTTOM", 0, -27)
        elseif buttons.sort then
            buttons.nextAHPreset:SetPoint("BOTTOM", buttons.sort, "BOTTOM", 0, -27)
        end
    end
end

local function ApplyMiniDefaultLayout(buttons)
    local frame = AH.UI and AH.UI.miniFrame
    if not frame or not buttons then
        return
    end

    local size = (buttons.equipAll and buttons.equipAll:GetHeight()) or 24
    local spacing = 4
    local padding = (frame:GetHeight() - size) / 2

    if buttons.equipAll then
        buttons.equipAll:ClearAllPoints()
        buttons.equipAll:SetPoint("LEFT", frame, "LEFT", padding, 0)
    end
    if buttons.openSettings and buttons.equipAll then
        buttons.openSettings:ClearAllPoints()
        buttons.openSettings:SetPoint("LEFT", buttons.equipAll, "RIGHT", spacing, 0)
    end
    if buttons.vendor and buttons.openSettings then
        buttons.vendor:ClearAllPoints()
        buttons.vendor:SetPoint("LEFT", buttons.openSettings, "RIGHT", spacing, 0)
    end
    if buttons.toggleAutoEquip then
        buttons.toggleAutoEquip:ClearAllPoints()
        buttons.toggleAutoEquip:SetPoint("LEFT", frame, "LEFT", padding, 0)
    end
    if buttons.AHSetUpdate and buttons.toggleAutoEquip then
        buttons.AHSetUpdate:ClearAllPoints()
        buttons.AHSetUpdate:SetPoint("LEFT", buttons.toggleAutoEquip, "RIGHT", spacing, 0)
    end
    if buttons.sort and buttons.AHSetUpdate then
        buttons.sort:ClearAllPoints()
        buttons.sort:SetPoint("LEFT", buttons.AHSetUpdate, "RIGHT", spacing, 0)
    end
    if buttons.equipAHSet and buttons.sort then
        buttons.equipAHSet:ClearAllPoints()
        buttons.equipAHSet:SetPoint("LEFT", buttons.sort, "RIGHT", spacing, 0)
    end
    if buttons.nextAHPreset then
        buttons.nextAHPreset:ClearAllPoints()
        if buttons.equipAHSet then
            buttons.nextAHPreset:SetPoint("LEFT", buttons.equipAHSet, "RIGHT", spacing, 0)
        elseif buttons.sort then
            buttons.nextAHPreset:SetPoint("LEFT", buttons.sort, "RIGHT", spacing, 0)
        end
    end
end

local function SetMiniFrameButtonCapacity(buttons, buttonCount)
    local frame = AH.UI and AH.UI.miniFrame
    if not frame then
        return
    end
    local size = (buttons and buttons.equipAll and buttons.equipAll:GetHeight()) or 24
    local spacing = 4
    local padding = (frame:GetHeight() - size) / 2
    local width = (padding * 2) + (size * buttonCount) + (spacing * math.max(buttonCount - 1, 0))
    frame:SetWidth(width)
end

local function ApplyTwoButtonLayout(buttons, isMini, topKey, bottomKey)
    if not buttons then
        return
    end

    local topButton = buttons[topKey]
    local bottomButton = buttons[bottomKey]

    if isMini then
        local frame = AH.UI and AH.UI.miniFrame
        if not frame then
            return
        end
        local size = (topButton and topButton:GetHeight()) or 24
        local spacing = 4
        local padding = (frame:GetHeight() - size) / 2

        if topButton then
            topButton:ClearAllPoints()
            topButton:SetPoint("LEFT", frame, "LEFT", padding, 0)
        end
        if bottomButton and topButton then
            bottomButton:ClearAllPoints()
            bottomButton:SetPoint("LEFT", topButton, "RIGHT", size + (spacing * 2), 0)
        end
        return
    end

    local frame = AH.UI and AH.UI.mainFrame
    if not frame then
        return
    end
    if topButton then
        topButton:ClearAllPoints()
        topButton:SetPoint("TOP", frame, "TOP", 0, -5)
    end
    if bottomButton and topButton then
        bottomButton:ClearAllPoints()
        bottomButton:SetPoint("BOTTOM", topButton, "BOTTOM", 0, -54)
    end
end

local function ApplyThreeButtonLayout(buttons, isMini, topKey, centerKey, bottomKey)
    if not buttons then
        return
    end
    local topButton = buttons[topKey]
    local centerButton = buttons[centerKey]
    local bottomButton = buttons[bottomKey]

    if isMini then
        local frame = AH.UI and AH.UI.miniFrame
        if not frame then
            return
        end
        local size = (topButton and topButton:GetHeight()) or 24
        local spacing = 4
        local padding = (frame:GetHeight() - size) / 2
        if topButton then
            topButton:ClearAllPoints()
            topButton:SetPoint("LEFT", frame, "LEFT", padding, 0)
        end
        if centerButton and topButton and centerButton ~= topButton then
            centerButton:ClearAllPoints()
            centerButton:SetPoint("LEFT", topButton, "RIGHT", spacing, 0)
        end
        if bottomButton and centerButton and bottomButton ~= centerButton and bottomButton ~= topButton then
            bottomButton:ClearAllPoints()
            bottomButton:SetPoint("LEFT", centerButton, "RIGHT", spacing, 0)
        end
        return
    end

    local frame = AH.UI and AH.UI.mainFrame
    if not frame then
        return
    end
    if topButton then
        topButton:ClearAllPoints()
        topButton:SetPoint("TOP", frame, "TOP", 0, -5)
    end
    if centerButton and topButton and centerButton ~= topButton then
        centerButton:ClearAllPoints()
        centerButton:SetPoint("BOTTOM", topButton, "BOTTOM", 0, -27)
    end
    if bottomButton and centerButton and bottomButton ~= centerButton and bottomButton ~= topButton then
        bottomButton:ClearAllPoints()
        bottomButton:SetPoint("BOTTOM", centerButton, "BOTTOM", 0, -27)
    end
end

local function UpdateButtonGroupVisibility(buttons, isMini)
    if not buttons then
        return
    end

    local shiftDown = IsShiftKeyDown()
    local ctrlDown = IsControlKeyDown()
    local hideCenterEnabled = AttuneHelperDB and AttuneHelperDB["Hide Center Button in Normal Mode"] == 1
    local hideCenterInNormalMode = (not isMini) and hideCenterEnabled
    local showEquipAHSet = IsEquipAHSetButtonEnabled()
    local layoutPreset = GetButtonLayoutPreset()

    local useCustomLayout = (layoutPreset == "Custom")
    local useCustomTwoButtonLayout = (useCustomLayout and hideCenterEnabled)

    if isMini then
        local miniCapacity = 3
        if useCustomLayout then
            miniCapacity = useCustomTwoButtonLayout and 2 or 3
        elseif hideCenterInNormalMode then
            miniCapacity = 2
        elseif shiftDown then
            miniCapacity = showEquipAHSet and 4 or 3
        end
        SetMiniFrameButtonCapacity(buttons, miniCapacity)
    end

    if isMini then
        ApplyMiniDefaultLayout(buttons)
    else
        ApplyMainDefaultLayout(buttons)
    end

    if useCustomLayout then
        local stateKey = "Normal"
        if ctrlDown and hideCenterEnabled then
            stateKey = "Ctrl"
        elseif shiftDown then
            stateKey = "Shift"
        end
        local topKey, centerKey, bottomKey
        if useCustomTwoButtonLayout then
            topKey, bottomKey = GetCustomLayoutPair(stateKey, showEquipAHSet)
        else
            topKey, centerKey, bottomKey = GetCustomLayoutTrio(stateKey, showEquipAHSet)
        end
        for _, key in ipairs(allButtons) do
            local btn = buttons[key]
            if btn then
                btn:Hide()
            end
        end
        if useCustomTwoButtonLayout then
            ApplyTwoButtonLayout(buttons, isMini, topKey, bottomKey)
            if buttons[topKey] then
                buttons[topKey]:Show()
            end
            if buttons[bottomKey] then
                buttons[bottomKey]:Show()
            end
        else
            ApplyThreeButtonLayout(buttons, isMini, topKey, centerKey, bottomKey)
            if buttons[topKey] then
                buttons[topKey]:Show()
            end
            if buttons[centerKey] then
                buttons[centerKey]:Show()
            end
            if buttons[bottomKey] then
                buttons[bottomKey]:Show()
            end
        end
        return
    end

    if hideCenterInNormalMode then
        local topKey, bottomKey
        if ctrlDown then
            topKey = "AHSetUpdate"
            bottomKey = "openSettings"
        elseif shiftDown then
            topKey = "toggleAutoEquip"
            bottomKey = showEquipAHSet and "equipAHSet" or "sort"
        else
            topKey = "equipAll"
            bottomKey = "vendor"
        end

        ApplyTwoButtonLayout(buttons, isMini, topKey, bottomKey)
        for _, key in ipairs(allButtons) do
            local btn = buttons[key]
            if btn then
                btn:Hide()
            end
        end
        if buttons[topKey] then
            buttons[topKey]:Show()
        end
        if buttons[bottomKey] then
            buttons[bottomKey]:Show()
        end
        return
    end

    local showOnShift, hideOnShift = BuildShiftVisibilityLists()

    for _, key in ipairs(showOnShift) do
        local btn = buttons[key]
        if btn then
            if shiftDown then btn:Show() else btn:Hide() end
        end
    end

    for _, key in ipairs(hideOnShift) do
        local btn = buttons[key]
        if btn then
            if not shiftDown then btn:Show() else btn:Hide() end
        end
    end

    if buttons.nextAHPreset then
        buttons.nextAHPreset:Hide()
    end

    if buttons.equipAHSet and not showEquipAHSet then
        buttons.equipAHSet:Hide()
    end

end

function AH.UpdateModifierButtonVisibility()
    if not AH or not AH.UI then
        return
    end

    if AttuneHelperDB and AttuneHelperDB["Mini Mode"] == 1 then
        UpdateButtonGroupVisibility(AH.UI.miniButtons, true)
    else
        UpdateButtonGroupVisibility(AH.UI.buttons, false)
    end
end

local function AttachRightClickDrag(button)
    if not button then return end
    if button.AHRightClickDragAttached then return end

    button:HookScript("OnMouseDown", function(s, mouseButton)
        AH.StartRightClickDragFromWidget(s, mouseButton)
    end)
    button:HookScript("OnMouseUp", function(_, mouseButton)
        AH.StopRightClickDrag(mouseButton)
    end)
    button.AHRightClickDragAttached = true
end

------------------------------------------------------------------------
-- Button creation helper
------------------------------------------------------------------------
function AH.CreateButton(name, parentFrame, text, relativeFrame, point, x, y, width, height, c, scale)
    scale = scale or 1
    local x1, y1, x2, y2 = 65, 176, 457, 290
    local rw, rh = x2 - x1, y2 - y1
    local u1, u2, v1, v2 = x1 / 512, x2 / 512, y1 / 512, y2 / 512

    if width and not height then
        height = width * rh / rw
    elseif height and not width then
        width = height * rw / rh
    else
        height = 24
        width = height * rw / rh * 1.5
    end

    local b = _G[name]
    if not b then
        b = CreateFrame("Button", name, parentFrame, "UIPanelButtonTemplate")
    elseif b:GetParent() ~= parentFrame then
        b:SetParent(parentFrame)
    end
    b:ClearAllPoints()
    b:SetSize(width, height)
    b:SetScale(scale)
    b:SetPoint(point, relativeFrame, point, x, y)
    b:SetText(AH.t(text))

    local thA = AttuneHelperDB["Button Theme"] or "Normal"
    if AH.themePaths[thA] then
        b:SetNormalTexture(AH.themePaths[thA].normal)
        b:SetPushedTexture(AH.themePaths[thA].pushed)
        b:SetHighlightTexture(AH.themePaths[thA].pushed, "ADD")

        for _, st in ipairs({ "Normal", "Pushed", "Highlight" }) do
            local tx = b["Get" .. st .. "Texture"](b)
            if tx then
                tx:SetTexCoord(u1, u2, v1, v2)
            end
            local cl = c and c[st:lower()]
            if cl and tx then
                tx:SetVertexColor(cl[1], cl[2], cl[3], cl[4] or 1)
            end
        end
    end

    local fo = b:GetFontString()
    if fo then
        fo:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    end

    b:SetBackdropColor(0, 0, 0, 0.5)
    b:SetBackdropBorderColor(1, 1, 1, 1)
    b:Show()

    AttachRightClickDrag(b)

    return b
end

------------------------------------------------------------------------
-- Mini icon button creation helper
------------------------------------------------------------------------
function AH.CreateMiniIconButton(name, parent, iconPath, size, tooltipText)
    local btn = _G[name]
    if not btn then
        btn = CreateFrame("Button", name, parent)
    elseif btn:GetParent() ~= parent then
        btn:SetParent(parent)
    end
    btn:ClearAllPoints()
    btn:SetSize(size, size)
    btn:SetNormalTexture(iconPath)
    btn:SetBackdrop({
        edgeFile = "Interface\\Buttons\\UI-Quickslot-Depress",
        edgeSize = 2,
        insets = { left = -1, right = -1, top = -1, bottom = -1 }
    })
    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.6)

    local hl = btn.AHHighlightTexture
    if not hl then
        hl = btn:CreateTexture(nil, "HIGHLIGHT")
        btn.AHHighlightTexture = hl
    end
    hl:SetAllPoints(btn)
    hl:SetTexture(iconPath)
    hl:SetBlendMode("ADD")
    hl:SetVertexColor(0.2, 0.2, 0.2, 0.3)

    btn:SetScript("OnMouseDown", function(s, mouseButton)
        s:GetNormalTexture():SetVertexColor(0.75, 0.75, 0.75)
        AH.StartRightClickDragFromWidget(s, mouseButton)
    end)
    btn:SetScript("OnMouseUp", function(s, mouseButton)
        s:GetNormalTexture():SetVertexColor(1, 1, 1)
        AH.StopRightClickDrag(mouseButton)
    end)

    btn:SetScript("OnEnter", nil)
    btn:SetScript("OnLeave", nil)
    -- Only add simple tooltip for non-equip/non-vendor buttons initially
    if tooltipText and name ~= "AttuneHelperMiniEquipButton" and name ~= "AttuneHelperMiniVendorButton" then
        btn:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetText(AH.t(tooltipText))
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", GameTooltip_Hide)
    end
    btn:Show()

    return btn
end

local function AddVendorPreviewLines(tooltip, itemsToVendor)
    if #itemsToVendor > 0 then
        tooltip:AddLine(string.format(AH.t("Items to be sold (%d):"), #itemsToVendor), 1, 1, 0)
        for i = 1, #itemsToVendor do
            local itemData = itemsToVendor[i]
            local _, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemData.link)
            if (not itemTexture) and itemData.bag and itemData.slot then
                local _, _, _, _, _, _, _, _, _, containerTexture = GetContainerItemInfo(itemData.bag, itemData.slot)
                itemTexture = containerTexture
            end
            local iconText = ""
            if itemTexture then
                iconText = string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t ", itemTexture)
            end
            local qualityColor = ITEM_QUALITY_COLORS[itemQuality or 1]
            local r, g, b = 0.8, 0.8, 0.8
            if qualityColor then r, g, b = qualityColor.r, qualityColor.g, qualityColor.b end
            local itemLabel = itemData.name
            if itemData.alwaysVendored then
                itemLabel = itemLabel .. " |cff80ff80[Always]|r"
            end
            if itemData.deleteInstead then
                itemLabel = itemLabel .. " |cffff6060[Delete]|r"
            end
            tooltip:AddLine(iconText .. itemLabel, r, g, b, true)
        end
    else
        tooltip:AddLine(AH.t("No items will be sold based on current settings."), 0.8, 0.8, 0.8, true)
    end
end

local function SetVendorTooltip(button, tooltipAnchor)
    GameTooltip:SetOwner(button, tooltipAnchor or "ANCHOR_RIGHT")
    GameTooltip:SetText(AH.t("Vendor Attuned Items"))
    local itemsToVendor = AH.GetQualifyingVendorItems and AH.GetQualifyingVendorItems() or {}
    AddVendorPreviewLines(GameTooltip, itemsToVendor)

    if not (AH.IsVendorWindowOpen and AH.IsVendorWindowOpen()) then
        GameTooltip:AddLine(AH.t("Open merchant window to sell these items."), 1, 0.8, 0.2, true)
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(AH.t("Drag an item and left-click to add it to AHIgnore."), 0.6, 0.9, 1, true)
    GameTooltip:AddLine(AH.t("Hold Shift for additional options"), 0.7, 0.9, 1, true)
    GameTooltip:Show()
end

local function SetAddToVendorTooltip(button, tooltipAnchor)
    GameTooltip:SetOwner(button, tooltipAnchor or "ANCHOR_RIGHT")
    GameTooltip:SetText(AH.t("Add To Vendor"))

    GameTooltip:AddLine(AH.t("Drag an item here or pick it up and click to toggle always-vendor."), 1, 1, 1, true)
    GameTooltip:AddLine(AH.t("Items added here are always included in AH vendor previews and selling."), 0.7, 0.9, 1, true)
    GameTooltip:Show()
end

local function GetForgeBadgeColorCode(forgeShortName)
    return FORGE_BADGE_COLORS[forgeShortName] or "|cffffffff"
end

local function GetTodaysAttunesColorCode(count, attuneType, isPrestiged)
    count = tonumber(count) or 0
    local bucket = DAILY_ATTUNES_THRESHOLDS[attuneType or "account"] or DAILY_ATTUNES_THRESHOLDS.account
    local thresholds = (isPrestiged and bucket.prestiged) or bucket.normal
    if count < thresholds[1] then
        return "|cffff4040"
    elseif count < thresholds[2] then
        return "|cffff9a3d"
    elseif count < thresholds[3] then
        return "|cffffff40"
    elseif count < thresholds[4] then
        return "|cff40ff40"
    elseif count < thresholds[5] then
        return "|cff4da6ff"
    elseif count < thresholds[6] then
        return "|cffb266ff"
    end
    return "|cffd98cff"
end

local function BuildColoredTodaysAttunesValue(count, attuneType, isPrestiged)
    local value = math.max(0, tonumber(count) or 0)
    return string.format("%s%d|r", GetTodaysAttunesColorCode(value, attuneType, isPrestiged), value)
end

local function IsPrestigedForDailyBreakdown()
    return type(CMCGetMultiClassEnabled) == "function" and (CMCGetMultiClassEnabled() or 1) >= 2
end

function AH.GetTodaysAttunesBreakdownForDisplay()
    local breakdown = AH.GetTodaysAttuneBreakdown and AH.GetTodaysAttuneBreakdown() or {}
    local isPrestiged = IsPrestigedForDailyBreakdown()
    return {
        ready = breakdown.ready == true,
        account = tonumber(breakdown.account) or 0,
        titanforged = tonumber(breakdown.titanforged) or 0,
        warforged = tonumber(breakdown.warforged) or 0,
        lightforged = tonumber(breakdown.lightforged) or 0,
        isPrestiged = isPrestiged
    }
end

function AH.GetTodaysAttunesDelta()
    local breakdown = AH.GetTodaysAttunesBreakdownForDisplay and AH.GetTodaysAttunesBreakdownForDisplay() or {}
    return math.max(0, tonumber(breakdown.account) or 0)
end

function AH.GetTodaysAttunesMerchantLabel()
    local delta = AH.GetTodaysAttunesDelta and AH.GetTodaysAttunesDelta() or 0
    local breakdown = AH.GetTodaysAttunesBreakdownForDisplay and AH.GetTodaysAttunesBreakdownForDisplay() or {}
    local colorCode = GetTodaysAttunesColorCode(delta, "account", breakdown.isPrestiged)
    return string.format("%s\n%s%d|r", AH.t("Daily Attuned"), colorCode, delta)
end

function AH.AddTodaysAttunesTooltipLines(tooltip)
    if not tooltip then
        return
    end

    local breakdown = AH.GetTodaysAttunesBreakdownForDisplay and AH.GetTodaysAttunesBreakdownForDisplay() or {}
    tooltip:AddLine(AH.t("Daily Attuned"), 1, 0.82, 0.2)

    if not breakdown.ready then
        tooltip:AddLine(AH.t("Daily snapshot pending item data load."), 0.85, 0.85, 0.85, true)
        return
    end

    local isPrestiged = breakdown.isPrestiged == true
    tooltip:AddLine(string.format("Account: %s", BuildColoredTodaysAttunesValue(breakdown.account or 0, "account", isPrestiged)), 1, 1, 1, true)
    tooltip:AddLine(string.format("Titanforged: %s", BuildColoredTodaysAttunesValue(breakdown.titanforged or 0, "titanforged", isPrestiged)), 1, 1, 1, true)
    tooltip:AddLine(string.format("Warforged: %s", BuildColoredTodaysAttunesValue(breakdown.warforged or 0, "warforged", isPrestiged)), 1, 1, 1, true)
    tooltip:AddLine(string.format("Lightforged: %s", BuildColoredTodaysAttunesValue(breakdown.lightforged or 0, "lightforged", isPrestiged)), 1, 1, 1, true)
end

function AH.AttachTodaysAttunesTooltip(region, tooltipAnchor)
    if not region then
        return
    end

    local target = region
    if not region.EnableMouse then
        local overlay = todaysAttunesTooltipOverlays[region]
        local parent = region.GetParent and region:GetParent() or nil
        if not overlay and parent then
            overlay = CreateFrame("Frame", nil, parent)
            overlay:SetFrameStrata(parent:GetFrameStrata() or "MEDIUM")
            overlay:SetFrameLevel((parent:GetFrameLevel() or 1) + 10)
            todaysAttunesTooltipOverlays[region] = overlay
        end
        if not overlay then
            return
        end

        local width = math.max(1, math.ceil((region.GetStringWidth and region:GetStringWidth()) or 0) + 8)
        local height = math.max(1, math.ceil((region.GetStringHeight and region:GetStringHeight()) or 0) + 6)
        overlay:ClearAllPoints()
        overlay:SetPoint("CENTER", region, "CENTER", 0, 0)
        overlay:SetSize(width, height)
        overlay:EnableMouse(true)
        overlay:Show()
        target = overlay
    else
        region:EnableMouse(true)
    end

    target:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, tooltipAnchor or "ANCHOR_RIGHT")
        AH.AddTodaysAttunesTooltipLines(GameTooltip)
        GameTooltip:Show()
    end)
    target:SetScript("OnLeave", GameTooltip_Hide)
end

local function EnsureScootsQuickBuybackLabelHooks(quickBuyback)
    if not quickBuyback or quickBuyback.AHQuickBuybackLabelHooks then
        return
    end
    quickBuyback.AHQuickBuybackLabelHooks = true
    quickBuyback:HookScript("OnShow", function()
        if AH.RefreshVendorCompatButtons then
            AH.Wait(0, AH.RefreshVendorCompatButtons)
        end
    end)
    quickBuyback:HookScript("OnHide", function()
        if AH.RefreshVendorCompatButtons then
            AH.Wait(0, AH.RefreshVendorCompatButtons)
        end
    end)
end

local function EnsureScootsTodaysAttunesLabel(parentFrame)
    if not parentFrame then
        return nil
    end

    local label = _G.AttuneHelperScootsTodaysAttunesText
    if not label then
        label = parentFrame:CreateFontString("AttuneHelperScootsTodaysAttunesText", "ARTWORK", "GameFontNormal")
        label:SetJustifyH("LEFT")
        label:SetSpacing(2)
    elseif label:GetParent() ~= parentFrame then
        label:SetParent(parentFrame)
    end

    label:ClearAllPoints()
    local quickBuyback = _G["ScootsVendor-QuickBuyback"]
    if quickBuyback and quickBuyback.IsShown and quickBuyback:IsShown() then
        label:SetPoint("TOPLEFT", quickBuyback, "TOPRIGHT", 8, 0)
    else
        label:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 76, -35)
    end
    label:SetText((AH.GetTodaysAttunesMerchantLabel and AH.GetTodaysAttunesMerchantLabel()) or AH.t("Vendor Attuned"))
    if AH.AttachTodaysAttunesTooltip then
        AH.AttachTodaysAttunesTooltip(label, "ANCHOR_TOPRIGHT")
    end
    label:Show()
    return label
end

function AH.ApplyVendorButtonBehavior(button, tooltipAnchor)
    if not button then
        return
    end

    button:RegisterForClicks("LeftButtonUp")
    button:SetScript("OnClick", function(self)
        if CursorHasItem() and AH.AddCursorItemToIgnore and AH.AddCursorItemToIgnore() then
            return
        end
        AH.VendorAttunedItems(self)
    end)
    button:SetScript("OnReceiveDrag", function()
        if AH.AddCursorItemToIgnore then
            AH.AddCursorItemToIgnore()
        end
    end)
    button:SetScript("OnEnter", function(self)
        SetVendorTooltip(self, tooltipAnchor)
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
end

function AH.ApplyAddToVendorButtonBehavior(button, tooltipAnchor)
    if not button then
        return
    end

    button:RegisterForClicks("LeftButtonUp")
    button:SetScript("OnClick", function()
        if AH.AddCursorItemToAlwaysVendor then
            AH.AddCursorItemToAlwaysVendor()
        end
    end)
    button:SetScript("OnReceiveDrag", function()
        if AH.AddCursorItemToAlwaysVendor then
            AH.AddCursorItemToAlwaysVendor()
        end
    end)
    button:SetScript("OnEnter", function(self)
        SetAddToVendorTooltip(self, tooltipAnchor)
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
end

local function ApplyCompatMicroButtonStyle(button, iconPath, styleVariant)
    if not button then
        return
    end

    button:SetScale(1)

    local normal = button.AHNormalTexture or button:CreateTexture(nil, "BACKGROUND")
    normal:SetTexture("Interface\\Buttons\\UI-MicroButton-Character-Up")
    normal:SetAllPoints(button)
    button:SetNormalTexture(normal)
    button.AHNormalTexture = normal

    local pushed = button.AHPushedTexture or button:CreateTexture(nil, "BACKGROUND")
    pushed:SetTexture("Interface\\Buttons\\UI-MicroButton-Character-Down")
    pushed:SetAllPoints(button)
    button:SetPushedTexture(pushed)
    button.AHPushedTexture = pushed

    local highlight = button.AHHighlightTexture or button:CreateTexture(nil, "HIGHLIGHT")
    highlight:ClearAllPoints()
    if styleVariant == "scoots" then
        highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
        highlight:SetVertexColor(1, 0.82, 0, 0.18)
        highlight:SetBlendMode("ADD")
        highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
        highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    else
        highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
        highlight:SetVertexColor(1, 0.82, 0, 0.14)
        highlight:SetBlendMode("ADD")
        highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
        highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    end
    button:SetHighlightTexture(highlight)
    button.AHHighlightTexture = highlight

    local disabled = button.AHDisabledTexture or button:CreateTexture(nil, "BACKGROUND")
    disabled:SetTexture("Interface\\Buttons\\UI-MicroButton-Character-Disabled")
    disabled:SetAllPoints(button)
    button:SetDisabledTexture(disabled)
    button.AHDisabledTexture = disabled

    local icon = button.AHCompatIcon or button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(iconPath or "Interface\\AddOns\\AttuneHelper\\assets\\icon_vendor-attuned.blp")
    icon:ClearAllPoints()
    local iconSize = math.max(16, math.floor(math.min(button:GetWidth(), button:GetHeight()) * 0.85))
    icon:SetSize(iconSize, iconSize)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.AHCompatIcon = icon
end

local function CreateOrReuseCompatButton(name, parent, tooltipAnchor, iconPath, applyBehavior)
    if not parent then
        return nil
    end

    local button = _G[name]
    if not button then
        button = CreateFrame("Button", name, parent)
    elseif button:GetParent() ~= parent then
        button:SetParent(parent)
    end

    button:SetFrameStrata(parent:GetFrameStrata())
    button:SetFrameLevel(parent:GetFrameLevel() + 10)
    ApplyCompatMicroButtonStyle(button, iconPath, button.AHStyleVariant)
    if applyBehavior then
        applyBehavior(button, tooltipAnchor)
    end
    button:Show()
    return button
end

local function GetScootsVendorFrames()
    local master = _G["ScootsVendor-Master"] or _G.ScootsVendorMaster or _G.ScootsVendor
    local closeButton = _G["ScootsVendor-CloseButton"] or _G.ScootsVendorCloseButton

    if not closeButton and master and master.GetName then
        local masterName = master:GetName()
        if masterName then
            closeButton = _G[masterName .. "-CloseButton"] or _G[masterName .. "CloseButton"]
        end
    end

    return master, closeButton
end

function AH.EnsureScootsVendorHooks()
    if AH.scootsVendorHooksInstalled then
        return true
    end

    local master = GetScootsVendorFrames()
    if not master then
        return false
    end

    master:HookScript("OnShow", function()
        if AH.RefreshVendorCompatButtons then
            AH.Wait(0.05, AH.RefreshVendorCompatButtons)
        end
    end)
    master:HookScript("OnHide", function()
        if _G.AttuneHelperScootsVendorButton then
            _G.AttuneHelperScootsVendorButton:Hide()
        end
        if _G.AttuneHelperScootsAddToVendorButton then
            _G.AttuneHelperScootsAddToVendorButton:Hide()
        end
        if _G.AttuneHelperScootsTodaysAttunesText then
            _G.AttuneHelperScootsTodaysAttunesText:Hide()
        end
    end)

    AH.scootsVendorHooksInstalled = true
    return true
end

function AH.RefreshVendorCompatButtons()
    local merchantFrame = _G.MerchantFrame
    local repairButton = _G.MerchantRepairAllButton
    local merchantButton = _G.AttuneHelperMerchantVendorButton
    local addToVendorButton = _G.AttuneHelperMerchantAddToVendorButton

    if merchantFrame and repairButton then
        merchantButton = CreateOrReuseCompatButton("AttuneHelperMerchantVendorButton", merchantFrame, "ANCHOR_RIGHT", "Interface\\AddOns\\AttuneHelper\\assets\\icon_vendor-attuned.blp", AH.ApplyVendorButtonBehavior)
        addToVendorButton = CreateOrReuseCompatButton("AttuneHelperMerchantAddToVendorButton", merchantFrame, "ANCHOR_RIGHT", "Interface\\AddOns\\AttuneHelper\\assets\\addToVendor.blp", AH.ApplyAddToVendorButtonBehavior)
        if _G.MerchantRepairText then
            _G.MerchantRepairText:SetText((AH.GetTodaysAttunesMerchantLabel and AH.GetTodaysAttunesMerchantLabel()) or AH.t("Vendor Attuned"))
            _G.MerchantRepairText:ClearAllPoints()
            _G.MerchantRepairText:SetPoint("CENTER", repairButton, "CENTER", -95, 0)
            if AH.AttachTodaysAttunesTooltip then
                AH.AttachTodaysAttunesTooltip(_G.MerchantRepairText, "ANCHOR_TOPRIGHT")
            end
        end
        if merchantButton then
            merchantButton:ClearAllPoints()
            merchantButton:SetParent(repairButton:GetParent())
            merchantButton:SetAllPoints(repairButton)
            merchantButton:SetWidth(repairButton:GetWidth())
            merchantButton:SetHeight(repairButton:GetHeight())
            merchantButton:SetScale(repairButton:GetScale() or 1)
            merchantButton:SetFrameLevel(repairButton:GetFrameLevel() + 5)
            ApplyCompatMicroButtonStyle(merchantButton, "Interface\\AddOns\\AttuneHelper\\assets\\icon_vendor-attuned.blp")
            merchantButton:Show()
        end
        if addToVendorButton and merchantButton then
            addToVendorButton:ClearAllPoints()
            addToVendorButton:SetParent(repairButton:GetParent())
            addToVendorButton:SetWidth(repairButton:GetWidth())
            addToVendorButton:SetHeight(repairButton:GetHeight())
            addToVendorButton:SetScale(repairButton:GetScale() or 1)
            addToVendorButton:SetFrameLevel(repairButton:GetFrameLevel() + 5)
            addToVendorButton:SetPoint("RIGHT", merchantButton, "LEFT", -4, 0)
            ApplyCompatMicroButtonStyle(addToVendorButton, "Interface\\AddOns\\AttuneHelper\\assets\\addToVendor.blp")
            addToVendorButton:Show()
        end
    elseif merchantButton then
        merchantButton:Hide()
        if addToVendorButton then
            addToVendorButton:Hide()
        end
    end

    local scootsVendorMaster, scootsCloseButton = GetScootsVendorFrames()
    local scootsButton = _G.AttuneHelperScootsVendorButton
    local scootsAddToVendorButton = _G.AttuneHelperScootsAddToVendorButton
    local scootsTodaysAttunesText = _G.AttuneHelperScootsTodaysAttunesText

    if scootsVendorMaster and scootsCloseButton then
        AH.EnsureScootsVendorHooks()
        local scootsQuickBuyback = _G["ScootsVendor-QuickBuyback"]
        if scootsQuickBuyback then
            EnsureScootsQuickBuybackLabelHooks(scootsQuickBuyback)
        end
        scootsTodaysAttunesText = EnsureScootsTodaysAttunesLabel(scootsVendorMaster)
        scootsButton = CreateOrReuseCompatButton("AttuneHelperScootsVendorButton", scootsCloseButton:GetParent() or scootsVendorMaster, "ANCHOR_LEFT", "Interface\\AddOns\\AttuneHelper\\assets\\icon_vendor-attuned.blp", AH.ApplyVendorButtonBehavior)
        scootsAddToVendorButton = CreateOrReuseCompatButton("AttuneHelperScootsAddToVendorButton", scootsCloseButton:GetParent() or scootsVendorMaster, "ANCHOR_LEFT", "Interface\\AddOns\\AttuneHelper\\assets\\addToVendor.blp", AH.ApplyAddToVendorButtonBehavior)
        if scootsButton then
            scootsButton:ClearAllPoints()
            scootsButton:SetParent(scootsCloseButton:GetParent() or scootsVendorMaster)
            scootsButton.AHStyleVariant = "scoots"
            scootsButton:SetWidth(scootsCloseButton:GetWidth())
            scootsButton:SetHeight(scootsCloseButton:GetHeight())
            scootsButton:SetScale(scootsCloseButton:GetScale() or 1)
            scootsButton:SetFrameLevel(scootsCloseButton:GetFrameLevel() + 5)
            scootsButton:SetPoint("TOP", scootsCloseButton, "BOTTOM", -4, 8)
            ApplyCompatMicroButtonStyle(scootsButton, "Interface\\AddOns\\AttuneHelper\\assets\\icon_vendor-attuned.blp", "scoots")
            scootsButton:Show()
        end
        if scootsAddToVendorButton and scootsButton then
            scootsAddToVendorButton:ClearAllPoints()
            scootsAddToVendorButton:SetParent(scootsCloseButton:GetParent() or scootsVendorMaster)
            scootsAddToVendorButton.AHStyleVariant = "scoots"
            scootsAddToVendorButton:SetWidth(scootsCloseButton:GetWidth())
            scootsAddToVendorButton:SetHeight(scootsCloseButton:GetHeight())
            scootsAddToVendorButton:SetScale(scootsCloseButton:GetScale() or 1)
            scootsAddToVendorButton:SetFrameLevel(scootsCloseButton:GetFrameLevel() + 5)
            scootsAddToVendorButton:SetPoint("RIGHT", scootsButton, "LEFT", -4, 0)
            ApplyCompatMicroButtonStyle(scootsAddToVendorButton, "Interface\\AddOns\\AttuneHelper\\assets\\addToVendor.blp", "scoots")
            scootsAddToVendorButton:Show()
        end
    elseif scootsButton then
        scootsButton:Hide()
        if scootsAddToVendorButton then
            scootsAddToVendorButton:Hide()
        end
        if scootsTodaysAttunesText then
            scootsTodaysAttunesText:Hide()
        end
    end
end

-- Export for legacy compatibility
_G.CreateButton = AH.CreateButton
_G.CreateMiniIconButton = AH.CreateMiniIconButton

------------------------------------------------------------------------
-- Create main frame buttons
------------------------------------------------------------------------
function AH.CreateMainButtons()
    local mainFrame = AH.UI.mainFrame
    if not mainFrame then return end

    -- Default Buttons
    -- Equip All Button
    local equipButton = AH.CreateButton(
        "AttuneHelperEquipAllButton",
        mainFrame,
        "Equip Attunables",
        mainFrame,
        "TOP",
        0, -5,
        nil, nil, nil, 1.3
    )

    -- Open Settings Button (now in normal view)
    local openSettingsButton = AH.CreateButton(
        "AttuneHelperOpenSettingsButton",
        mainFrame,
        "Open Settings",
        equipButton,
        "BOTTOM",
        0, -27,
        nil, nil, nil, 1.3
    )

    -- Vendor Attuned Button
    local vendorButton = AH.CreateButton(
        "AttuneHelperVendorAttunedButton",
        mainFrame,
        "Vendor Attuned",
        openSettingsButton,
        "BOTTOM",
        0, -27,
        nil, nil, nil, 1.3
    )

    --SHIFT Buttons
    -- Toggle Auto-equip Button
    local toggleAutoEquipButton = AH.CreateButton(
        "AttuneHelperToggleAutoEquipButton",
        mainFrame,
        "Toggle Auto-Equip",
        mainFrame,
        "TOP",
        0, -5,
        nil, nil, nil, 1.3
    )

    -- AHSet Update Button (now in shift view)
    local AHSetUpdateButton = AH.CreateButton(
        "AttuneHelperAHSetUpdateButton",
        mainFrame,
        "Update AHSet",
        toggleAutoEquipButton,
        "BOTTOM",
        0, -27,
        nil, nil, nil, 1.3
    )

    -- Sort Inventory Button
    local sortButton = AH.CreateButton(
        "AttuneHelperSortInventoryButton",
        mainFrame,
        "Prepare Disenchant",
        AHSetUpdateButton,
        "BOTTOM",
        0, -27,
        nil, nil, nil, 1.3
    )

    local equipAHSetButton = AH.CreateButton(
        "AttuneHelperEquipAHSetButton",
        mainFrame,
        "Equip AHSet",
        sortButton,
        "BOTTOM",
        0, -27,
        nil, nil, nil, 1.3
    )

    local nextAHPresetButton = AH.CreateButton(
        "AttuneHelperNextAHPresetButton",
        mainFrame,
        "Next AHSet Preset",
        equipAHSetButton,
        "BOTTOM",
        0, -27,
        nil, nil, nil, 1.3
    )

    -- Store references
    AH.UI.buttons = AH.UI.buttons or {}
    AH.UI.buttons.equipAll = equipButton
    AH.UI.buttons.AHSetUpdate = AHSetUpdateButton
    AH.UI.buttons.vendor = vendorButton
    AH.UI.buttons.toggleAutoEquip = toggleAutoEquipButton
    AH.UI.buttons.openSettings = openSettingsButton
    AH.UI.buttons.sort = sortButton
    AH.UI.buttons.equipAHSet = equipAHSetButton
    AH.UI.buttons.nextAHPreset = nextAHPresetButton

    -- Export for legacy compatibility
    _G.EquipAllButton = equipButton
    _G.AHSetButton = AHSetUpdateButton
    _G.VendorAttunedButton = vendorButton
    _G.ToggleAutoEquipButton = toggleAutoEquipButton
    _G.SettingsButton = openSettingsButton
    _G.SortInventoryButton = sortButton
    _G.EquipAHSetButton = equipAHSetButton
    _G.NextAHPresetButton = nextAHPresetButton

    -- Set up button click handlers
    AH.SetupMainButtonHandlers()
    -- Apply initial button theme
    AH.ApplyButtonTheme(AttuneHelperDB["Button Theme"])
    -- Immediately update visibility after button creation
    if AH.UpdateModifierButtonVisibility then
        AH.UpdateModifierButtonVisibility()
    end
end

------------------------------------------------------------------------
-- Create mini frame buttons
------------------------------------------------------------------------
function AH.CreateMiniButtons()
    local frame = AH.UI.miniFrame
    if not frame then return end

    local mBS = 24                           -- button size
    local mS = 4                             -- spacing
    local fP = (frame:GetHeight() - mBS) / 2 -- frame padding

    -- Default Buttons
    -- Equip button
    local equipButton = AH.CreateMiniIconButton(
        "AttuneHelperMiniEquipButton",
        frame,
        "Interface\\Addons\\AttuneHelper\\assets\\icon_equip_attunables.blp",
        mBS,
        "Equip Attunables"
    )
    equipButton:SetPoint("LEFT", frame, "LEFT", fP, 0)

    -- Open Settings Button (now in normal view)
    local openSettingsButton = AH.CreateMiniIconButton(
        "AttuneHelperMiniOpenSettingsButton",
        frame,
        "Interface\\Addons\\AttuneHelper\\assets\\icon_settings.blp",
        mBS,
        "Open Settings"
    )
    openSettingsButton:SetPoint("LEFT", equipButton, "RIGHT", mS, 0)

    -- Vendor button
    local vendorButton = AH.CreateMiniIconButton(
        "AttuneHelperMiniVendorButton",
        frame,
        "Interface\\Addons\\AttuneHelper\\assets\\icon_vendor-attuned.blp",
        mBS,
        "Vendor Attuned"
    )
    vendorButton:SetPoint("LEFT", openSettingsButton, "RIGHT", mS, 0)

    --SHIFT Buttons
    -- Toggle Auto-equip Button
    local toggleAutoEquipButton = AH.CreateMiniIconButton(
        "AttuneHelperMiniToggleAutoEquipButton",
        frame,
        "Interface\\Addons\\AttuneHelper\\assets\\icon_auto_equip_off.blp",
        mBS,
        "Toggle Auto-Equip"
    )
    toggleAutoEquipButton:SetPoint("LEFT", frame, "LEFT", fP, 0)

    -- AHSet Update Button (now in shift view)
    local AHSetUpdateButton = AH.CreateMiniIconButton(
        "AttuneHelperMiniAHSetUpdateButton",
        frame,
        "Interface\\Addons\\AttuneHelper\\assets\\icon_ahsetall.blp",
        mBS,
        "Update AHSet"
    )
    AHSetUpdateButton:SetPoint("LEFT", toggleAutoEquipButton, "RIGHT", mS, 0)

    -- Sort button
    local sortButton = AH.CreateMiniIconButton(
        "AttuneHelperMiniSortButton",
        frame,
        "Interface\\Addons\\AttuneHelper\\assets\\icon_prepare_disenchant.blp",
        mBS,
        "Prepare Disenchant"
    )
    sortButton:SetPoint("LEFT", AHSetUpdateButton, "RIGHT", mS, 0)

    local equipAHSetButton = AH.CreateMiniIconButton(
        "AttuneHelperMiniEquipAHSetButton",
        frame,
        "Interface\\Addons\\AttuneHelper\\assets\\icon_equip_ahset.blp",
        mBS,
        "Equip AHSet"
    )
    equipAHSetButton:SetPoint("LEFT", sortButton, "RIGHT", mS, 0)

    local nextAHPresetButton = AH.CreateMiniIconButton(
        "AttuneHelperMiniNextAHPresetButton",
        frame,
        "Interface\\Addons\\AttuneHelper\\assets\\icon_ahsetall.blp",
        mBS,
        "Next AHSet Preset"
    )
    nextAHPresetButton:SetPoint("LEFT", equipAHSetButton, "RIGHT", mS, 0)

    -- Store references
    AH.UI.miniButtons = AH.UI.miniButtons or {}
    AH.UI.miniButtons.equipAll = equipButton
    AH.UI.miniButtons.AHSetUpdate = AHSetUpdateButton
    AH.UI.miniButtons.vendor = vendorButton
    AH.UI.miniButtons.toggleAutoEquip = toggleAutoEquipButton
    AH.UI.miniButtons.openSettings = openSettingsButton
    AH.UI.miniButtons.sort = sortButton
    AH.UI.miniButtons.equipAHSet = equipAHSetButton
    AH.UI.miniButtons.nextAHPreset = nextAHPresetButton

    -- Export for legacy compatibility
    _G.AttuneHelperMiniEquipButton = equipButton
    _G.AttuneHelperMiniAHSetButton = AHSetUpdateButton
    _G.AttuneHelperMiniVendorButton = vendorButton
    _G.AttuneHelperMiniToggleAutoEquipButton = toggleAutoEquipButton
    _G.AttuneHelperMiniOpenSettingsButton = openSettingsButton
    _G.AttuneHelperMiniSortButton = sortButton
    _G.AttuneHelperMiniEquipAHSetButton = equipAHSetButton
    _G.AttuneHelperMiniNextAHPresetButton = nextAHPresetButton

    -- Immediately update visibility after button creation
    if AH.UpdateModifierButtonVisibility then
        AH.UpdateModifierButtonVisibility()
    end
end

------------------------------------------------------------------------
-- Setup button click handlers
------------------------------------------------------------------------
function AH.SetupMainButtonHandlers()
    if not AH.UI.buttons.equipAll then
        --AH.print_debug_general("SetupMainButtonHandlers: equipAll button not found")
        return
    end

    -- Default buttons
    -- ʕ •ᴥ•ʔ✿ Equip All Button - uses comprehensive equip logic ✿ ʕ •ᴥ•ʔ
    AH.UI.buttons.equipAll:SetScript("OnClick", function()
        AH.EquipAllAttunables()
    end)
    AH.UI.buttons.equipAll:SetScript("OnReceiveDrag", function()
        if AH.AddCursorItemToAHSet then
            AH.AddCursorItemToAHSet()
        end
    end)

    -- Equip All Button tooltip
    AH.UI.buttons.equipAll:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(AH.t("Equip Attunables"))

        -- Add detailed list with icons
        local attunableData = AH.GetAttunableItemNamesList()
        local count = #attunableData
        local counts = AH.GetBagAttunableTooltipCounts and AH.GetBagAttunableTooltipCounts() or {}
        local isPrestiged = counts.prestiged == true
        local accountCount = counts.accountAttunableInBag or 0

        local attunableLine = string.format(AH.t("Attunable Items: %d"), count)
        if isPrestiged and accountCount > 0 then
            attunableLine = attunableLine .. string.format(" (%d)", accountCount)
        end
        GameTooltip:AddLine(attunableLine, 1, 1, 0)

        if count > 0 then
            GameTooltip:AddLine(" ") -- Empty line for spacing
            for _, itemData in ipairs(attunableData) do
                -- Get item info including quality and texture
                local _, itemLinkFull, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemData.link)
                local iconText = ""

                if itemTexture then
                    iconText = string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t ", itemTexture)
                end

                -- Get item quality color
                local qualityColor = ITEM_QUALITY_COLORS[itemQuality or 1]
                local r, g, b = 0.8, 0.8, 0.8 -- default color
                if qualityColor then
                    r, g, b = qualityColor.r, qualityColor.g, qualityColor.b
                end

                -- Build item name with forge/mythic indicators
                local itemName = itemData.name
                local indicators = {}

                -- Check if mythic
                if itemData.id and itemData.id >= (AH.MYTHIC_MIN_ITEMID or 52203) then
                    table.insert(indicators, "|cffFF6600[Mythic]|r")
                end

                -- Check forge level
                local forgeLevel = AH.GetForgeLevelFromLink and AH.GetForgeLevelFromLink(itemData.link) or 0
                if forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.WARFORGED or 2) then
                    table.insert(indicators, string.format("%s[WF]|r", GetForgeBadgeColorCode("WF")))
                elseif forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.LIGHTFORGED or 3) then
                    table.insert(indicators, string.format("%s[LF]|r", GetForgeBadgeColorCode("LF")))
                elseif forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.TITANFORGED or 1) then
                    table.insert(indicators, string.format("%s[TF]|r", GetForgeBadgeColorCode("TF")))
                end

                -- Combine name with indicators
                local displayName = itemName
                if #indicators > 0 then
                    displayName = displayName .. " " .. table.concat(indicators, " ")
                end

                GameTooltip:AddLine(iconText .. displayName, r, g, b, true)
            end
        end



        GameTooltip:AddLine(" ") -- Empty line for spacing
        GameTooltip:AddLine(AH.t("Drag an item here to assign its slot in AHSet."), 0.6, 0.9, 1, true)
        GameTooltip:AddLine(AH.t("Hold Shift for additional options"), 0.7, 0.9, 1, true)
        GameTooltip:Show()
    end)
    AH.UI.buttons.equipAll:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- ʕ •ᴥ•ʔ✿ Update AHSet Button - makes AHSet equal to currently equiped items ✿ ʕ •ᴥ•ʔ
    AH.UI.buttons.AHSetUpdate:SetScript("OnClick", function()
        StaticPopup_Show("ATTUNEHELPER_CONFIRM_UPDATE_AHSET")
    end)

    -- Update AHSet Button tooltip
    AH.UI.buttons.AHSetUpdate:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(AH.t("Update AHSet"))
        GameTooltip:AddLine(AH.t("Sets AHSet to be equal to your currently equiped items."), 1, 1, 1, true)
        GameTooltip:AddLine(AH.t("This will delete your current AHSet."), 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    AH.UI.buttons.AHSetUpdate:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- ʕ •ᴥ•ʔ✿ Vendor button - sells attuned items ✿ ʕ •ᴥ•ʔ
    AH.ApplyVendorButtonBehavior(AH.UI.buttons.vendor, "ANCHOR_RIGHT")

    -- SHIFT Buttons
    -- ʕ •ᴥ•ʔ✿ Toggle Auto-equip Button - toggles Auto-equip atunables setting ✿ ʕ •ᴥ•ʔ
    AH.UI.buttons.toggleAutoEquip:SetScript("OnClick", function(button)
        AH.ToggleAutoEquip()
        -- If the mouse is still over the button, refresh the tooltip
        if GameTooltip:GetOwner() == button then
            button:GetScript("OnEnter")(button)
        end
    end)

    -- Toggle Auto-equip  tooltip
    AH.UI.buttons.toggleAutoEquip:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if AttuneHelperDB["Auto Equip Attunable After Combat"] == 1 then
            GameTooltip:SetText(AH.t("Disable Auto-Equip"))
            GameTooltip:AddLine(AH.t("Currently enabled."), 0, 1, 0, true)
        else
            GameTooltip:SetText(AH.t("Enable Auto-Equip"))
            GameTooltip:AddLine(AH.t("Currently disabled."), 1, 0, 0, true)
        end
        GameTooltip:Show()
    end)
    AH.UI.buttons.toggleAutoEquip:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- ʕ •ᴥ•ʔ✿ Open Settings Button - opens Attune Helper settings ✿ ʕ •ᴥ•ʔ
    AH.UI.buttons.openSettings:SetScript("OnClick", function()
        InterfaceOptionsFrame_OpenToCategory("General Logic - AttuneHelper")
    end)

    --Settings tooltip
    AH.UI.buttons.openSettings:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(AH.t("Open Settings"))
        GameTooltip:AddLine(AH.t("Opens the General Logic Options settings page."), 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine(" ") -- Empty line for spacing
        GameTooltip:AddLine(AH.t("Hold Shift for additional options"), 0.7, 0.9, 1, true)
        GameTooltip:Show()
    end)
    AH.UI.buttons.openSettings:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- ʕ •ᴥ•ʔ✿ Sort Button - moves mythic items to bag 0 ✿ ʕ •ᴥ•ʔ
    AH.UI.buttons.sort:SetScript("OnClick", function()
        AH.SortInventoryItems()
    end)

    -- Sort Inventory Button tooltip
    AH.UI.buttons.sort:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(AH.t("Prepare Disenchant"))
        local targetBag = (AttuneHelperDB["Use Bag 1 for Disenchant"] == 1) and 1 or 0
        GameTooltip:AddLine(string.format(AH.t("Moves fully attuned mythic items to bag %d."), targetBag), 1, 1, 1, true)
        GameTooltip:AddLine(AH.t("Clears target bag first, then fills with disenchant-ready items."), 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    AH.UI.buttons.sort:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    AH.UI.buttons.equipAHSet:SetScript("OnClick", function()
        AH.EquipAHSetOnly()
    end)
    AH.UI.buttons.equipAHSet:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(AH.t("Equip AHSet"))
        GameTooltip:AddLine(AH.t("Equips your AHSet items without checking attunables."), 1, 1, 1, true)
        GameTooltip:Show()
    end)
    AH.UI.buttons.equipAHSet:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    AH.UI.buttons.nextAHPreset:SetScript("OnClick", function()
        local ok, newPreset = AH.SwitchToNextAHPreset and AH.SwitchToNextAHPreset()
        if ok and newPreset then
            print(string.format("|cff00ff00[AttuneHelper]|r Active AHSet preset: %s", tostring(newPreset)))
        end
    end)
    AH.UI.buttons.nextAHPreset:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(AH.t("Next AHSet Preset"))
        GameTooltip:AddLine(AH.t("Switches to the next AHSet preset in order."), 1, 1, 1, true)
        GameTooltip:Show()
    end)
    AH.UI.buttons.nextAHPreset:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    --AH.print_debug_general("Main button handlers set up successfully")
end

------------------------------------------------------------------------
-- Setup mini button click handlers and detailed tooltips
------------------------------------------------------------------------
function AH.SetupMiniButtonHandlers()
    -- These will be called after the main buttons are created
    AH.Wait(0.1, function()
        -- Default mini buttons
        --EquipAll
        if AH.UI.miniButtons and AH.UI.miniButtons.equipAll and _G.EquipAllButton then
            AH.UI.miniButtons.equipAll:SetScript("OnClick", function()
                if _G.EquipAllButton:GetScript("OnClick") then
                    _G.EquipAllButton:GetScript("OnClick")()
                end
            end)
            AH.UI.miniButtons.equipAll:SetScript("OnReceiveDrag", function()
                if _G.EquipAllButton and _G.EquipAllButton:GetScript("OnReceiveDrag") then
                    _G.EquipAllButton:GetScript("OnReceiveDrag")()
                elseif AH.AddCursorItemToAHSet then
                    AH.AddCursorItemToAHSet()
                end
            end)

            -- Setup detailed tooltip for mini equip button
            AH.UI.miniButtons.equipAll:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(AH.t("Equip Attunables"))

                local attunableData = AH.GetAttunableItemNamesList()
                local count = #attunableData
                local counts = AH.GetBagAttunableTooltipCounts and AH.GetBagAttunableTooltipCounts() or {}
                local isPrestiged = counts.prestiged == true
                local accountCount = counts.accountAttunableInBag or 0

                local attunableLine = string.format(AH.t("Attunable Items: %d"), count)
                if isPrestiged and accountCount > 0 then
                    attunableLine = attunableLine .. string.format(" (%d)", accountCount)
                end
                GameTooltip:AddLine(attunableLine, 1, 1, 0)

                if count > 0 then
                    GameTooltip:AddLine(" ") -- Empty line for spacing
                    for _, itemData in ipairs(attunableData) do
                        -- Get item info including quality and texture
                        local _, itemLinkFull, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemData.link)
                        local iconText = ""

                        if itemTexture then
                            iconText = string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t ", itemTexture)
                        end

                        -- Get item quality color
                        local qualityColor = ITEM_QUALITY_COLORS[itemQuality or 1]
                        local r, g, b = 0.8, 0.8, 0.8 -- default color
                        if qualityColor then
                            r, g, b = qualityColor.r, qualityColor.g, qualityColor.b
                        end

                        -- Build item name with forge/mythic indicators
                        local itemName = itemData.name
                        local indicators = {}

                        -- Check if mythic
                        if itemData.id and itemData.id >= (AH.MYTHIC_MIN_ITEMID or 52203) then
                            table.insert(indicators, "|cffFF6600[Mythic]|r")
                        end

                        -- Check forge level
                        local forgeLevel = AH.GetForgeLevelFromLink and AH.GetForgeLevelFromLink(itemData.link) or 0
                        if forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.WARFORGED or 2) then
                            table.insert(indicators, string.format("%s[WF]|r", GetForgeBadgeColorCode("WF")))
                        elseif forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.LIGHTFORGED or 3) then
                            table.insert(indicators, string.format("%s[LF]|r", GetForgeBadgeColorCode("LF")))
                        elseif forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.TITANFORGED or 1) then
                            table.insert(indicators, string.format("%s[TF]|r", GetForgeBadgeColorCode("TF")))
                        end

                        -- Combine name with indicators
                        local displayName = itemName
                        if #indicators > 0 then
                            displayName = displayName .. " " .. table.concat(indicators, " ")
                        end

                        -- Add the line with icon and colored item name
                        GameTooltip:AddLine(iconText .. displayName, r, g, b, true)
                    end
                else
                    GameTooltip:AddLine(AH.t("No qualifying attunables in bags."), 1, 0.5, 0.5, true) -- Reddish if none
                end

                GameTooltip:AddLine(" ") -- Empty line for spacing
                GameTooltip:AddLine(AH.t("Drag an item here to assign its slot in AHSet."), 0.6, 0.9, 1, true)
                GameTooltip:AddLine(AH.t("Hold Shift for additional options"), 0.7, 0.9, 1, true)
                GameTooltip:Show()
            end)
            AH.UI.miniButtons.equipAll:SetScript("OnLeave", GameTooltip_Hide)
        end

        -- AHSet
        if AH.UI.miniButtons and AH.UI.miniButtons.AHSetUpdate and _G.AHSetButton then
            AH.UI.miniButtons.AHSetUpdate:SetScript("OnClick", function(self)
                if _G.AHSetButton:GetScript("OnClick") then
                    _G.AHSetButton:GetScript("OnClick")(self)
                end
            end)

            -- Setup detailed tooltip for AHSet button
            AH.UI.miniButtons.AHSetUpdate:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(AH.t("Update AHSet"))
                GameTooltip:AddLine(AH.t("Sets AHSet to be equal to your currently equiped items."), 1, 1, 1, true)
                GameTooltip:AddLine(AH.t("This will delete your current AHSet."), 0.7, 0.7, 0.7, true)
                GameTooltip:Show()
            end)
            AH.UI.miniButtons.AHSetUpdate:SetScript("OnLeave", GameTooltip_Hide)
        end

        --Vendor
        if AH.UI.miniButtons and AH.UI.miniButtons.vendor and _G.VendorAttunedButton then
            AH.UI.miniButtons.vendor:SetScript("OnClick", function(self)
                if _G.VendorAttunedButton:GetScript("OnClick") then
                    _G.VendorAttunedButton:GetScript("OnClick")(self)
                end
            end)
            AH.UI.miniButtons.vendor:SetScript("OnReceiveDrag", function(self)
                if _G.VendorAttunedButton and _G.VendorAttunedButton:GetScript("OnReceiveDrag") then
                    _G.VendorAttunedButton:GetScript("OnReceiveDrag")(self)
                elseif AH.AddCursorItemToIgnore then
                    AH.AddCursorItemToIgnore()
                end
            end)

            -- Setup detailed tooltip for mini vendor button
            AH.UI.miniButtons.vendor:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(AH.t("Vendor Attuned Items"))
                local itemsToVendor = AH.GetQualifyingVendorItems and AH.GetQualifyingVendorItems() or {}
                AddVendorPreviewLines(GameTooltip, itemsToVendor)

                if not (AH.IsVendorWindowOpen and AH.IsVendorWindowOpen()) then
                    GameTooltip:AddLine(AH.t("Open merchant window to sell these items."), 1, 0.8, 0.2, true)
                end
                GameTooltip:AddLine(" ") -- Empty line for spacing
                GameTooltip:AddLine(AH.t("Drag an item and left-click to add it to AHIgnore."), 0.6, 0.9, 1, true)
                GameTooltip:AddLine(AH.t("Hold Shift for additional options"), 0.7, 0.9, 1, true)
                GameTooltip:Show()
            end)
            AH.UI.miniButtons.vendor:SetScript("OnLeave", GameTooltip_Hide)
        end

        -- SHIFT mini buttons

        --Toggle Auto-equip
        if AH.UI.miniButtons and AH.UI.miniButtons.toggleAutoEquip and _G.AttuneHelperMiniToggleAutoEquipButton then
            AH.UI.miniButtons.toggleAutoEquip:SetScript("OnClick", function(self)
                if _G.ToggleAutoEquipButton:GetScript("OnClick") then
                    _G.ToggleAutoEquipButton:GetScript("OnClick")(self)
                end
            end)

            -- Setup detailed tooltip for AHSet button
            AH.UI.miniButtons.toggleAutoEquip:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                if AttuneHelperDB["Auto Equip Attunable After Combat"] == 1 then
                    GameTooltip:SetText(AH.t("Disable Auto-Equip"))
                    GameTooltip:AddLine(AH.t("Currently enabled."), 0, 1, 0, true)
                else
                    GameTooltip:SetText(AH.t("Enable Auto-Equip"))
                    GameTooltip:AddLine(AH.t("Currently disabled."), 1, 0, 0, true)
                end
                GameTooltip:Show()
            end)
            AH.UI.miniButtons.toggleAutoEquip:SetScript("OnLeave", GameTooltip_Hide)
        end

        --Open Settings
        if AH.UI.miniButtons and AH.UI.miniButtons.openSettings and _G.AttuneHelperMiniOpenSettingsButton then
            AH.UI.miniButtons.openSettings:SetScript("OnClick", function(self)
                if _G.SettingsButton:GetScript("OnClick") then
                    _G.SettingsButton:GetScript("OnClick")(self)
                end
            end)

            -- Setup detailed tooltip for Settings button
            AH.UI.miniButtons.openSettings:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(AH.t("Open Settings"))
                GameTooltip:AddLine(AH.t("Opens the General Logic Options settings page."), 0.7, 0.7, 0.7, true)
                GameTooltip:AddLine(" ") -- Empty line for spacing
                GameTooltip:AddLine(AH.t("Hold Shift for additional options"), 0.7, 0.9, 1, true)
                GameTooltip:Show()
            end)
            AH.UI.miniButtons.openSettings:SetScript("OnLeave", GameTooltip_Hide)
        end

        -- Sort Inventory
        if AH.UI.miniButtons and AH.UI.miniButtons.sort and _G.SortInventoryButton then
            AH.UI.miniButtons.sort:SetScript("OnClick", function()
                if _G.SortInventoryButton:GetScript("OnClick") then
                    _G.SortInventoryButton:GetScript("OnClick")()
                end
            end)

            -- Setup detailed tooltip for mini sort button
            AH.UI.miniButtons.sort:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(AH.t("Prepare Disenchant"))
                local targetBag = (AttuneHelperDB["Use Bag 1 for Disenchant"] == 1) and 1 or 0
                GameTooltip:AddLine(string.format(AH.t("Moves fully attuned mythic items to bag %d."), targetBag), 1, 1,
                    1, true)
                GameTooltip:AddLine(AH.t("Clears target bag first, then fills with disenchant-ready items."), 0.7, 0.7,
                    0.7, true)
                GameTooltip:AddLine(AH.t("Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."),
                    0.6, 0.8, 1, true)
                GameTooltip:Show()
            end)
            AH.UI.miniButtons.sort:SetScript("OnLeave", GameTooltip_Hide)
        end

        if AH.UI.miniButtons and AH.UI.miniButtons.equipAHSet and _G.EquipAHSetButton then
            AH.UI.miniButtons.equipAHSet:SetScript("OnClick", function()
                if _G.EquipAHSetButton:GetScript("OnClick") then
                    _G.EquipAHSetButton:GetScript("OnClick")()
                end
            end)
            AH.UI.miniButtons.equipAHSet:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(AH.t("Equip AHSet"))
                GameTooltip:AddLine(AH.t("Equips your AHSet items without checking attunables."), 1, 1, 1, true)
                GameTooltip:Show()
            end)
            AH.UI.miniButtons.equipAHSet:SetScript("OnLeave", GameTooltip_Hide)
        end

        if AH.UI.miniButtons and AH.UI.miniButtons.nextAHPreset and _G.NextAHPresetButton then
            AH.UI.miniButtons.nextAHPreset:SetScript("OnClick", function()
                if _G.NextAHPresetButton:GetScript("OnClick") then
                    _G.NextAHPresetButton:GetScript("OnClick")()
                end
            end)
            AH.UI.miniButtons.nextAHPreset:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(AH.t("Next AHSet Preset"))
                GameTooltip:AddLine(AH.t("Switches to the next AHSet preset in order."), 1, 1, 1, true)
                GameTooltip:Show()
            end)
            AH.UI.miniButtons.nextAHPreset:SetScript("OnLeave", GameTooltip_Hide)
        end
    end)
end

------------------------------------------------------------------------
-- Setup shift button switches
------------------------------------------------------------------------

local shiftWatcher = CreateFrame("Frame", "AttuneHelperShiftWatcher", UIParent)
shiftWatcher:RegisterEvent("MODIFIER_STATE_CHANGED")
shiftWatcher:SetScript("OnEvent", function(_, event, key, state)
    if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" then
        if AH and AH.UpdateModifierButtonVisibility then
            AH.UpdateModifierButtonVisibility()
        end
    end
end)

------------------------------------------------------------------------
-- Button Reload Function
------------------------------------------------------------------------

function AH.ReCreateButtons()
    if AH and AH.UI then
        if AH.UI.buttons then
            AH.DeleteButtons()
            AH.CreateMainButtons()
        elseif AH.UI.miniButtons then
        end
    end
end

function AH.DeleteButtons()
    local buttons = AH.UI.buttons
    for _, key in ipairs(allButtons) do
        local btn = buttons[key]
        if btn then btn:Hide() else AH.print_debug_general("button not found") end
    end
    AH.UI.buttons = {}
end

-- ʕ •ᴥ•ʔ✿ Legacy function removed - using new comprehensive handlers ✿ ʕ •ᴥ•ʔ

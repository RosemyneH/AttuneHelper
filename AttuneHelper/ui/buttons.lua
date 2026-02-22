-- ʕ •ᴥ•ʔ✿ UI · Main buttons ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper
--ʕ •ᴥ•ʔ✿ Button layouts ✿ ʕ •ᴥ•ʔ
local showOnShift = { "toggleAutoEquip", "AHSetUpdate", "sort" }
local hideOnShift = { "equipAll", "openSettings", "vendor" }

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

    local b = CreateFrame("Button", name, parentFrame, "UIPanelButtonTemplate")
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

    return b
end

------------------------------------------------------------------------
-- Mini icon button creation helper
------------------------------------------------------------------------
function AH.CreateMiniIconButton(name, parent, iconPath, size, tooltipText)
    local btn = CreateFrame("Button", name, parent)
    btn:SetSize(size, size)
    btn:SetNormalTexture(iconPath)
    btn:SetBackdrop({
        edgeFile = "Interface\\Buttons\\UI-Quickslot-Depress",
        edgeSize = 2,
        insets = { left = -1, right = -1, top = -1, bottom = -1 }
    })
    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.6)

    local hl = btn:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(btn)
    hl:SetTexture(iconPath)
    hl:SetBlendMode("ADD")
    hl:SetVertexColor(0.2, 0.2, 0.2, 0.3)

    btn:SetScript("OnMouseDown", function(s)
        s:GetNormalTexture():SetVertexColor(0.75, 0.75, 0.75)
    end)
    btn:SetScript("OnMouseUp", function(s)
        s:GetNormalTexture():SetVertexColor(1, 1, 1)
    end)

    -- Only add simple tooltip for non-equip/non-vendor buttons initially
    if tooltipText and name ~= "AttuneHelperMiniEquipButton" and name ~= "AttuneHelperMiniVendorButton" then
        btn:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetText(AH.t(tooltipText))
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", GameTooltip_Hide)
    end

    return btn
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

    -- Store references
    AH.UI.buttons = AH.UI.buttons or {}
    AH.UI.buttons.equipAll = equipButton
    AH.UI.buttons.AHSetUpdate = AHSetUpdateButton
    AH.UI.buttons.vendor = vendorButton
    AH.UI.buttons.toggleAutoEquip = toggleAutoEquipButton
    AH.UI.buttons.openSettings = openSettingsButton
    AH.UI.buttons.sort = sortButton

    -- Export for legacy compatibility
    _G.EquipAllButton = equipButton
    _G.AHSetButton = AHSetUpdateButton
    _G.VendorAttunedButton = vendorButton
    _G.ToggleAutoEquipButton = toggleAutoEquipButton
    _G.SettingsButton = openSettingsButton
    _G.SortInventoryButton = sortButton

    -- Set up button click handlers
    AH.SetupMainButtonHandlers()
    -- Apply initial button theme
    AH.ApplyButtonTheme(AttuneHelperDB["Button Theme"])
    -- Immediately update visibility after button creation
    if AH.UI.buttons then
        local shiftDown = IsShiftKeyDown()
        local buttons = AH.UI.buttons
        for _, key in ipairs(showOnShift) do
            local btn = buttons[key]
            if btn then if shiftDown then btn:Show() else btn:Hide() end else print("button not found") end
        end
        for _, key in ipairs(hideOnShift) do
            local btn = buttons[key]
            if btn then if not (shiftDown) then btn:Show() else btn:Hide() end else print("button not found") end
        end
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

    -- Store references
    AH.UI.miniButtons = AH.UI.miniButtons or {}
    AH.UI.miniButtons.equipAll = equipButton
    AH.UI.miniButtons.AHSetUpdate = AHSetUpdateButton
    AH.UI.miniButtons.vendor = vendorButton
    AH.UI.miniButtons.toggleAutoEquip = toggleAutoEquipButton
    AH.UI.miniButtons.openSettings = openSettingsButton
    AH.UI.miniButtons.sort = sortButton

    -- Export for legacy compatibility
    _G.AttuneHelperMiniEquipButton = equipButton
    _G.AttuneHelperMiniAHSetButton = AHSetUpdateButton
    _G.AttuneHelperMiniVendorButton = vendorButton
    _G.AttuneHelperMiniToggleAutoEquipButton = toggleAutoEquipButton
    _G.AttuneHelperMiniOpenSettingsButton = openSettingsButton
    _G.AttuneHelperMiniSortButton = sortButton

    -- Immediately update visibility after button creation
    if AH.UI.miniButtons then
        local shiftDown = IsShiftKeyDown()
        local buttons = AH.UI.miniButtons
        for _, key in ipairs(showOnShift) do
            local btn = buttons[key]
            if btn then if shiftDown then btn:Show() else btn:Hide() end else print("button not found") end
        end
        for _, key in ipairs(hideOnShift) do
            local btn = buttons[key]
            if btn then if not (shiftDown) then btn:Show() else btn:Hide() end else print("button not found") end
        end
    end
end

------------------------------------------------------------------------
-- Setup button click handlers
------------------------------------------------------------------------
function AH.SetupMainButtonHandlers()
    if not AH.UI.buttons.equipAll then
        AH.print_debug_general("SetupMainButtonHandlers: equipAll button not found")
        return
    end

    -- Default buttons
    -- ʕ •ᴥ•ʔ✿ Equip All Button - uses comprehensive equip logic ✿ ʕ •ᴥ•ʔ
    AH.UI.buttons.equipAll:SetScript("OnClick", function()
        AH.EquipAllAttunables()
    end)

    -- Equip All Button tooltip
    AH.UI.buttons.equipAll:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(AH.t("Equip Attunables"))

        -- Add detailed list with icons
        local attunableData = AH.GetAttunableItemNamesList()
        local count = #attunableData
        GameTooltip:AddLine(string.format(AH.t("Attunable Items: %d"), count), 1, 1, 0)

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
                    table.insert(indicators, "|cffFFA680[WF]|r")
                elseif forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.LIGHTFORGED or 3) then
                    table.insert(indicators, "|cffFFFFA6[LF]|r")
                elseif forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.TITANFORGED or 1) then
                    table.insert(indicators, "|cff8080FF[TF]|r")
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
    AH.UI.buttons.vendor:SetScript("OnClick", function(self)
        AH.VendorAttunedItems(self)
    end)

    -- Vendor Attuned Button tooltip
    AH.UI.buttons.vendor:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(AH.t("Vendor Attuned Items"))
        local itemsToVendor = AH.GetQualifyingVendorItems and AH.GetQualifyingVendorItems() or {}

        if #itemsToVendor > 0 then
            GameTooltip:AddLine(string.format(AH.t("Items to be sold (%d):"), #itemsToVendor), 1, 1, 0) -- Yellow
            for _, itemData in ipairs(itemsToVendor) do
                local _, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemData.link)
                local iconText = ""
                if itemTexture then
                    iconText = string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t ", itemTexture)
                end
                local qualityColor = ITEM_QUALITY_COLORS[itemQuality or 1]
                local r, g, b = 0.8, 0.8, 0.8
                if qualityColor then r, g, b = qualityColor.r, qualityColor.g, qualityColor.b end
                GameTooltip:AddLine(iconText .. itemData.name, r, g, b, true)
            end
        else
            GameTooltip:AddLine(AH.t("No items will be sold based on current settings."), 0.8, 0.8, 0.8, true)
        end

        if not (MerchantFrame and MerchantFrame:IsShown()) then
            GameTooltip:AddLine(AH.t("Open merchant window to sell these items."), 1, 0.8, 0.2, true)
        end
        GameTooltip:AddLine(" ") -- Empty line for spacing
        GameTooltip:AddLine(AH.t("Hold Shift for additional options"), 0.7, 0.9, 1, true)
        GameTooltip:Show()
    end)
    AH.UI.buttons.vendor:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

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

    AH.print_debug_general("Main button handlers set up successfully")
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

            -- Setup detailed tooltip for mini equip button
            AH.UI.miniButtons.equipAll:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(AH.t("Equip Attunables"))

                local attunableData = AH.GetAttunableItemNamesList()
                local count = #attunableData

                if count > 0 then
                    GameTooltip:AddLine(string.format(AH.t("Qualifying Attunables (%d):"), count), 1, 1, 0) -- Yellow text
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
                            table.insert(indicators, "|cffFFA680[WF]|r")
                        elseif forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.LIGHTFORGED or 3) then
                            table.insert(indicators, "|cffFFFFA6[LF]|r")
                        elseif forgeLevel == (AH.FORGE_LEVEL_MAP and AH.FORGE_LEVEL_MAP.TITANFORGED or 1) then
                            table.insert(indicators, "|cff8080FF[TF]|r")
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

            -- Setup detailed tooltip for mini vendor button
            AH.UI.miniButtons.vendor:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(AH.t("Vendor Attuned Items"))
                local itemsToVendor = AH.GetQualifyingVendorItems and AH.GetQualifyingVendorItems() or {}

                if #itemsToVendor > 0 then
                    GameTooltip:AddLine(string.format(AH.t("Items to be sold (%d):"), #itemsToVendor), 1, 1, 0) -- Yellow
                    for _, itemData in ipairs(itemsToVendor) do
                        local _, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemData.link)
                        local iconText = ""
                        if itemTexture then
                            iconText = string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t ", itemTexture)
                        end
                        local qualityColor = ITEM_QUALITY_COLORS[itemQuality or 1]
                        local r, g, b = 0.8, 0.8, 0.8
                        if qualityColor then r, g, b = qualityColor.r, qualityColor.g, qualityColor.b end
                        GameTooltip:AddLine(iconText .. itemData.name, r, g, b, true)
                    end
                else
                    GameTooltip:AddLine(AH.t("No items will be sold based on current settings."), 0.8, 0.8, 0.8, true)
                end

                if not (MerchantFrame and MerchantFrame:IsShown()) then
                    GameTooltip:AddLine(AH.t("Open merchant window to sell these items."), 1, 0.8, 0.2, true)
                end
                GameTooltip:AddLine(" ") -- Empty line for spacing
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
    end)
end

------------------------------------------------------------------------
-- Setup shift button switches
------------------------------------------------------------------------

local shiftWatcher = CreateFrame("Frame", "AttuneHelperShiftWatcher", UIParent)
shiftWatcher:RegisterEvent("MODIFIER_STATE_CHANGED")
shiftWatcher:SetScript("OnEvent", function(_, event, key, state)
    if key == "LSHIFT" or key == "RSHIFT" then
        if AH and AH.UI then
            -- Toggle visibility
            local shiftDown = IsShiftKeyDown()
            local buttons
            if AttuneHelperDB["Mini Mode"] == 0 then
                buttons = AH.UI.buttons
            elseif AttuneHelperDB["Mini Mode"] == 1 then
                buttons = AH.UI.miniButtons
            end

            for _, key in ipairs(showOnShift) do
                local btn = buttons[key]
                if btn then
                    if shiftDown then btn:Show() else btn:Hide() end
                else
                    AH.print_debug_general("button not found")
                end
            end
            for _, key in ipairs(hideOnShift) do
                local btn = buttons[key]
                if btn then
                    if not (shiftDown) then btn:Show() else btn:Hide() end
                else
                    AH.print_debug_general("button not found")
                end
            end
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
    buttons = AH.UI.buttons
    for _, key in ipairs(showOnShift) do
        local btn = buttons[key]
        if btn then btn:Hide() else AH.print_debug_general("button not found") end
    end
    for _, key in ipairs(hideOnShift) do
        local btn = buttons[key]
        if btn then btn:Hide() else AH.print_debug_general("button not found") end
    end
    AH.UI.buttons = {}
end

-- ʕ •ᴥ•ʔ✿ Legacy function removed - using new comprehensive handlers ✿ ʕ •ᴥ•ʔ

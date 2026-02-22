-- ʕ •ᴥ•ʔ✿ UI · Main frame setup ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

-- Store UI elements in the addon table for other modules to access
AH.UI = AH.UI or {}

------------------------------------------------------------------------
-- Background styles and theme paths
------------------------------------------------------------------------
AH.BgStyles = {
    Tooltip = "Interface\\Tooltips\\UI-Tooltip-Background",
    Guild = "Interface\\Addons\\AttuneHelper\\assets\\UI-GuildAchievement-AchievementBackground",
    Atunament = "Interface\\Addons\\AttuneHelper\\assets\\atunament-bg",
    ["Always Bee Attunin'"] = "Interface\\Addons\\AttuneHelper\\assets\\always-bee-attunin",
    MiniModeBg = "Interface\\Addons\\AttuneHelper\\assets\\white8x8.blp"
}

AH.themePaths = {
    Normal = {
        normal = "Interface\\AddOns\\AttuneHelper\\assets\\nicebutton.blp",
        pushed = "Interface\\AddOns\\AttuneHelper\\assets\\nicebutton_pressed.blp"
    },
    Blue = {
        normal = "Interface\\AddOns\\AttuneHelper\\assets\\nicebutton_blue.blp",
        pushed = "Interface\\AddOns\\AttuneHelper\\assets\\nicebutton_blue_pressed.blp"
    },
    Grey = {
        normal = "Interface\\AddOns\\AttuneHelper\\assets\\nicebutton_gray.blp",
        pushed = "Interface\\AddOns\\AttuneHelper\\assets\\nicebutton_gray_pressed.blp"
    }
}

-- Export for legacy compatibility
_G.BgStyles = AH.BgStyles
_G.themePaths = AH.themePaths

------------------------------------------------------------------------
-- Main frame creation and setup
------------------------------------------------------------------------
function AH.CreateMainFrame()
    print("|cff00ff00[AttuneHelper]|r Creating main frame...")
    local frame = CreateFrame("Frame", "AttuneHelperFrame", UIParent)
    frame:SetSize(185, 125)

    -- Position restoration
    if AttuneHelperDB.FramePosition then
        local pos = AttuneHelperDB.FramePosition
        if pos and #pos >= 5 and pos[1] and pos[3] and pos[4] ~= nil and pos[5] ~= nil then
            local success, err = pcall(function()
                frame:SetPoint(pos[1], UIParent, pos[3], pos[4], pos[5])
            end)
            if not success then
                AH.print_debug_general("Failed to restore frame position, using default: " .. tostring(err))
                frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                AttuneHelperDB.FramePosition = { "CENTER", UIParent, "CENTER", 0, 0 }
            end
        else
            frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            AttuneHelperDB.FramePosition = { "CENTER", UIParent, "CENTER", 0, 0 }
        end
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        AttuneHelperDB.FramePosition = { "CENTER", UIParent, "CENTER", 0, 0 }
    end

    -- Make it draggable
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", function(s)
        if s:IsMovable() then
            s:StartMoving()
        end
    end)

    frame:SetScript("OnDragStop", function(s)
        s:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOfs, yOfs = s:GetPoint()
        AttuneHelperDB.FramePosition = {point, UIParent, relativePoint, xOfs, yOfs}
    end)

    -- Initial backdrop setup
    frame:SetBackdrop({
        bgFile = AH.BgStyles[AttuneHelperDB["Background Style"]],
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })

    frame:SetBackdropColor(unpack(AttuneHelperDB["Background Color"]))
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4)

    -- Create item count text
    local itemCountText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemCountText:SetPoint("BOTTOM", 0, 6)
    itemCountText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    itemCountText:SetTextColor(1, 1, 1, 1)
    itemCountText:SetText("Attunables in Inventory: 0")

    -- Store references
    AH.UI.mainFrame = frame
    AH.UI.itemCountText = itemCountText

    -- Export for legacy compatibility
    _G.AttuneHelper = frame
    _G.AttuneHelperItemCountText = itemCountText
    
    print("|cff00ff00[AttuneHelper]|r Main frame created successfully. Frame: " .. tostring(frame))
    
    -- Show the frame by default (unless in mini mode)
    if AttuneHelperDB["Mini Mode"] ~= 1 then
        frame:Show()
    end
    
    return frame
end

------------------------------------------------------------------------
-- Apply button theme to all main frame buttons
------------------------------------------------------------------------
function AH.ApplyButtonTheme(theme)
    if not AH.themePaths[theme] then return end
    if AH.UI.mainFrame and AH.UI.mainFrame:IsShown() then
        local btns = {
            _G.AttuneHelperSortInventoryButton,
            _G.AttuneHelperEquipAllButton,
            _G.AttuneHelperVendorAttunedButton
        }
        for _, b in ipairs(btns) do
            if b then
                b:SetNormalTexture(AH.themePaths[theme].normal)
                b:SetPushedTexture(AH.themePaths[theme].pushed)
                b:SetHighlightTexture(AH.themePaths[theme].pushed, "ADD")
            end
        end
    end
end
_G.ApplyButtonTheme = AH.ApplyButtonTheme

------------------------------------------------------------------------
-- Display mode update function
------------------------------------------------------------------------
function AH.UpdateDisplayMode()
    if not AH.UI.mainFrame or not AH.UI.miniFrame then return end
    
    local bgC = AttuneHelperDB["Background Color"]
    if AttuneHelperDB["Mini Mode"] == 1 then
        AH.UI.mainFrame:Hide()
        AH.UI.miniFrame:Show()
        AH.UI.miniFrame:SetBackdropColor(bgC[1], bgC[2], bgC[3], bgC[4])
    else
        AH.UI.miniFrame:Hide()
        AH.UI.mainFrame:Show()
        local cS = AttuneHelperDB["Background Style"] or "Tooltip"
        local bfU = AH.BgStyles[cS] or AH.BgStyles["Tooltip"]
        local nT = (cS == "Atunament" or cS == "Always Bee Attunin'")
        
        AH.UI.mainFrame:SetBackdrop({
            bgFile = bfU,
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = (not nT),
            tileSize = (nT and 0 or 16),
            edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        AH.UI.mainFrame:SetBackdropColor(unpack(bgC))
    end
    
    if AH.UpdateItemCountText then
        AH.UpdateItemCountText()
    end
    AH.ApplyButtonTheme(AttuneHelperDB["Button Theme"])
end

-- Export for legacy compatibility
_G.AttuneHelper_UpdateDisplayMode = AH.UpdateDisplayMode

-- Don't initialize immediately - wait for ADDON_LOADED
-- AH.CreateMainFrame() will be called from events.lua after saved variables are loaded 
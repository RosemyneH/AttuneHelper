-- ʕ •ᴥ•ʔ✿ UI · Main frame setup ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

-- Store UI elements in the addon table for other modules to access
AH.UI = AH.UI or {}

local function IsRightClickDragEnabled()
    return AttuneHelperDB and AttuneHelperDB["Draggable by Right Click"] == 1
end

local function IsAHFrameLocked()
    return AttuneHelperDB and AttuneHelperDB["Lock AH in Place (Buttons Only Mouse)"] == 1
end

function AH.ApplyFrameInteractivity()
    local locked = IsAHFrameLocked()
    local frames = { AH.UI and AH.UI.mainFrame, AH.UI and AH.UI.miniFrame }

    for _, frame in ipairs(frames) do
        if frame then
            frame:SetMovable(not locked)
            frame:EnableMouse(not locked)
        end
    end

    if locked and AH.UI and AH.UI.activeRightDragFrame then
        AH.StopRightClickDrag()
    end
end

function AH.ResolveDragTarget(widget)
    local current = widget
    while current do
        if current == AH.UI.mainFrame or current == AH.UI.miniFrame then
            return current
        end
        if not current.GetParent then
            break
        end
        current = current:GetParent()
    end
    return nil
end

function AH.SaveFramePosition(frame)
    if not frame then return end

    local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
    if frame == AH.UI.miniFrame then
        AttuneHelperDB.MiniFramePosition = { point, UIParent, relativePoint, xOfs, yOfs }
    else
        AttuneHelperDB.FramePosition = { point, UIParent, relativePoint, xOfs, yOfs }
    end
end

function AH.StartRightClickDragFromWidget(widget, mouseButton)
    if mouseButton ~= "RightButton" or not IsRightClickDragEnabled() then
        return
    end

    local target = AH.ResolveDragTarget(widget)
    if target and target:IsMovable() then
        target:StartMoving()
        AH.UI.activeRightDragFrame = target
    end
end

function AH.StopRightClickDrag(mouseButton)
    if mouseButton and mouseButton ~= "RightButton" then
        return
    end

    local target = AH.UI.activeRightDragFrame
    if target then
        target:StopMovingOrSizing()
        AH.SaveFramePosition(target)
        AH.UI.activeRightDragFrame = nil
    end
end

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
    local frame = _G.AttuneHelperFrame
    if not frame then
        frame = CreateFrame("Frame", "AttuneHelperFrame", UIParent)
    elseif frame:GetParent() ~= UIParent then
        frame:SetParent(UIParent)
    end
    frame:SetSize(185, 125)

    -- Position restoration
    if AttuneHelperDB.FramePosition then
        local pos = AttuneHelperDB.FramePosition
        if pos and #pos >= 5 and pos[1] and pos[3] and pos[4] ~= nil and pos[5] ~= nil then
            local success, err = pcall(function()
                frame:SetPoint(pos[1], UIParent, pos[3], pos[4], pos[5])
            end)
            if not success then
                --AH.print_debug_general("Failed to restore frame position, using default: " .. tostring(err))
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
        AH.SaveFramePosition(s)
    end)

    if not frame.AHRightClickDragHooksAdded then
        frame:HookScript("OnMouseDown", function(s, mouseButton)
            AH.StartRightClickDragFromWidget(s, mouseButton)
        end)
        frame:HookScript("OnMouseUp", function(_, mouseButton)
            AH.StopRightClickDrag(mouseButton)
        end)
        frame.AHRightClickDragHooksAdded = true
    end

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
    local itemCountText = _G.AttuneHelperItemCountText
    if not itemCountText then
        itemCountText = frame:CreateFontString("AttuneHelperItemCountText", "OVERLAY", "GameFontNormal")
    elseif itemCountText:GetParent() ~= frame then
        itemCountText:SetParent(frame)
    end
    itemCountText:SetPoint("BOTTOM", 0, 6)
    itemCountText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
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

    AH.ApplyFrameInteractivity()
    
    return frame
end

------------------------------------------------------------------------
-- Apply button theme to all main frame buttons
------------------------------------------------------------------------
function AH.ApplyButtonTheme(theme)
    if not AH.themePaths[theme] then return end
    local x1, y1, x2, y2 = 65, 176, 457, 290
    local u1, u2, v1, v2 = x1 / 512, x2 / 512, y1 / 512, y2 / 512
    local btns = {}

    if AH.UI and AH.UI.buttons then
        for _, b in pairs(AH.UI.buttons) do
            if b then
                table.insert(btns, b)
            end
        end
    end

    if #btns == 0 then
        btns = {
            _G.AttuneHelperEquipAllButton,
            _G.AttuneHelperOpenSettingsButton,
            _G.AttuneHelperVendorAttunedButton,
            _G.AttuneHelperToggleAutoEquipButton,
            _G.AttuneHelperAHSetUpdateButton,
            _G.AttuneHelperSortInventoryButton,
            _G.AttuneHelperEquipAHSetButton
        }
    end

    for _, b in ipairs(btns) do
        if b then
            b:SetNormalTexture(AH.themePaths[theme].normal)
            b:SetPushedTexture(AH.themePaths[theme].pushed)
            b:SetHighlightTexture(AH.themePaths[theme].pushed, "ADD")

            for _, st in ipairs({"Normal", "Pushed", "Highlight"}) do
                local tx = b["Get" .. st .. "Texture"](b)
                if tx then
                    tx:SetTexCoord(u1, u2, v1, v2)
                end
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
    if AH.UpdateModifierButtonVisibility then
        AH.UpdateModifierButtonVisibility()
    end
    if AH.ApplyFrameInteractivity then
        AH.ApplyFrameInteractivity()
    end
end

function AH.IsDisplayVisible()
    local mainShown = AH.UI and AH.UI.mainFrame and AH.UI.mainFrame:IsShown()
    local miniShown = AH.UI and AH.UI.miniFrame and AH.UI.miniFrame:IsShown()
    return mainShown or miniShown
end

-- Export for legacy compatibility
_G.AttuneHelper_UpdateDisplayMode = AH.UpdateDisplayMode

-- Don't initialize immediately - wait for ADDON_LOADED
-- AH.CreateMainFrame() will be called from events.lua after saved variables are loaded 
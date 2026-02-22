-- ʕ •ᴥ•ʔ✿ UI · Mini frame setup ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

------------------------------------------------------------------------
-- Mini frame creation and setup
------------------------------------------------------------------------
function AH.CreateMiniFrame()
    local frame = CreateFrame("Frame", "AttuneHelperMiniFrame", UIParent)
    frame:SetSize(88, 32)

    -- Position restoration
    if AttuneHelperDB.MiniFramePosition then
        local pos = AttuneHelperDB.MiniFramePosition
        if pos and #pos >= 5 and pos[1] and pos[3] and pos[4] ~= nil and pos[5] ~= nil then
            local success, err = pcall(function()
                frame:SetPoint(pos[1], UIParent, pos[3], pos[4], pos[5])
            end)
            if not success then
                AH.print_debug_general("Failed to restore mini frame position, using default: " .. tostring(err))
                frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                AttuneHelperDB.MiniFramePosition = { "CENTER", UIParent, "CENTER", 0, 0 }
            end
        else
            frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            AttuneHelperDB.MiniFramePosition = { "CENTER", UIParent, "CENTER", 0, 0 }
        end
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        AttuneHelperDB.MiniFramePosition = { "CENTER", UIParent, "CENTER", 0, 0 }
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
        AttuneHelperDB.MiniFramePosition = {point, UIParent, relativePoint, xOfs, yOfs}
    end)

    -- Setup backdrop
    frame:SetBackdrop({
        bgFile = AH.BgStyles.MiniModeBg,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 16,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })

    frame:SetBackdropColor(
        AttuneHelperDB["Background Color"][1],
        AttuneHelperDB["Background Color"][2],
        AttuneHelperDB["Background Color"][3],
        AttuneHelperDB["Background Color"][4]
    )

    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    frame:Hide()

    -- Store reference
    AH.UI.miniFrame = frame

    -- Export for legacy compatibility
    _G.AttuneHelperMiniFrame = frame

    return frame
end


-- Don't initialize immediately - wait for ADDON_LOADED
-- These will be called from events.lua after saved variables are loaded 
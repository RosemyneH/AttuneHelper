-- ʕ •ᴥ•ʔ✿ Debug helpers (core/debug.lua) ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper
local debugMode = false
-- Centralised flags so every module sees the same switches
AH.flags = AH.flags or {}
local flags = AH.flags

-- Provide sane defaults if they haven't been tweaked yet
if flags.GENERAL_DEBUG_MODE == nil then flags.GENERAL_DEBUG_MODE = false end
if flags.AHSET_DEBUG_MODE == nil then flags.AHSET_DEBUG_MODE = false end
if flags.VENDOR_PREVIEW_DEBUG_MODE == nil then flags.VENDOR_PREVIEW_DEBUG_MODE = false end

-- Generic printer – usage: AH.print_debug_general("message")
function AH.print_debug_general(msg)
    if debugMode then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFD700[AH_DEBUG_GEN]|r " .. tostring(msg))
    end
end

-- Legacy-compat alias kept for the monolithic file until it is split
_G.print_debug_general = AH.print_debug_general

function AH.print_debug(msg)
    if debugMode then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFD700[AH_DEBUG]|r " .. tostring(msg))
    end
end

_G.print_debug = AH.print_debug

function AH.print_debug_ahset(slotName, msg)
    if debugMode then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF8C00[AHSET_DEBUG]|cffFFD700[" ..
            tostring(slotName) .. "]|r " .. tostring(msg))
    end
end

_G.print_debug_ahset = AH.print_debug_ahset

function AH.print_debug_vendor_preview(msg)
    if debugMode then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33CCFF[AH_VENDOR_CONFIRM]|r " .. tostring(msg))
    end
end

_G.print_debug_vendor_preview = AH.print_debug_vendor_preview

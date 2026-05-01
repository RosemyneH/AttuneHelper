-- ʕ •ᴥ•ʔ✿ Load-on-demand Interface Options bridge ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper
local OPTIONS_ADDON = "AttuneHelper_Options"

function AH.EnsureOptionsAddonLoaded()
    if AH.__lodOptionsAddonLoaded then
        return true
    end
    local ok = LoadAddOn(OPTIONS_ADDON)
    if (not ok) and IsAddonLoaded and IsAddonLoaded(OPTIONS_ADDON) then
        ok = true
    end
    if ok then
        AH.__lodOptionsAddonLoaded = true
    end
    return ok and true or false
end

function AH.OpenAttuneHelperSettingsCategory()
    if not AH.EnsureOptionsAddonLoaded() then
        print("|cffff0000[AttuneHelper]|r Could not load AttuneHelper_Options (enable it in the AddOns list).")
        return
    end
    if AH.InitializeAllOptions then
        AH.InitializeAllOptions()
    end
    if AH.LoadAllSettings then
        AH.LoadAllSettings()
    end
    if InterfaceOptionsFrame_Show then
        InterfaceOptionsFrame_Show()
    end
    local generalPanel = AH.UI and AH.UI.optionsPanels and AH.UI.optionsPanels.general
    if InterfaceOptionsFrame_OpenToCategory then
        if generalPanel then
            InterfaceOptionsFrame_OpenToCategory(generalPanel)
        else
            InterfaceOptionsFrame_OpenToCategory("General Logic - AttuneHelper")
        end
    end
end

AH.OpenSettings = AH.OpenAttuneHelperSettingsCategory

function AH.LoadAllSettingsMinimal()
    if AH.InitializeDefaultSettings then
        AH.InitializeDefaultSettings()
    end
    if type(AttuneHelperDB.AllowedForgeTypes) ~= "table" then
        AttuneHelperDB.AllowedForgeTypes = {}
        local defs = AH.defaultForgeKeysAndValues or {}
        for k, v in pairs(defs) do
            AttuneHelperDB.AllowedForgeTypes[k] = v
        end
    end
    local cs = AttuneHelperDB["Background Style"]
    if cs and AH.BgStyles and AH.BgStyles[cs] and AH.UI and AH.UI.mainFrame then
        local nt = (cs == "Atunament" or cs == "Always Bee Attunin'")
        AH.UI.mainFrame:SetBackdrop({
            bgFile = AH.BgStyles[cs],
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = (not nt),
            tileSize = (nt and 0 or 16),
            edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        if AttuneHelperDB["Background Color"] then
            AH.UI.mainFrame:SetBackdropColor(unpack(AttuneHelperDB["Background Color"]))
        end
    end
    if AH.UI and AH.UI.miniFrame and AttuneHelperDB["Background Color"] then
        local bgc = AttuneHelperDB["Background Color"]
        AH.UI.miniFrame:SetBackdropColor(bgc[1], bgc[2], bgc[3], bgc[4])
    end
    local th = AttuneHelperDB["Button Theme"] or "Normal"
    if AH.ApplyButtonTheme then
        AH.ApplyButtonTheme(th)
    end
    if AH.RefreshButtonLayoutOptionVisibility then
        AH.RefreshButtonLayoutOptionVisibility()
    end
    if AH.RefreshButtonLayoutEditor then
        AH.RefreshButtonLayoutEditor()
    end
    if AH.UpdateDisplayMode then
        AH.UpdateDisplayMode()
    end
end

function AH.LoadAllSettings()
    if AH.__lodOptionsAddonLoaded and type(AH.__loadAllSettingsFull) == "function" then
        return AH.__loadAllSettingsFull()
    end
    return AH.LoadAllSettingsMinimal()
end

function AH.SaveAllSettings() end

function AH.InitializeAllOptions() end

function AH.InitializeOptionCheckboxes() end
function AH.InitializeForgeOptionCheckboxes() end
function AH.InitializeThemeOptions() end

do
    local forwardCreateCheckbox
    forwardCreateCheckbox = function(...)
        if not AH.EnsureOptionsAddonLoaded() then
            return nil
        end
        local impl = AH.CreateCheckbox
        if impl == forwardCreateCheckbox then
            return nil
        end
        return impl(...)
    end
    AH.CreateCheckbox = forwardCreateCheckbox
end

function AH.ForceSaveSettings()
    if AH.__lodOptionsAddonLoaded and type(AH.SaveSettingsForced) == "function" then
        AH.SaveSettingsForced()
        return
    end
    if SavedVariables then
        SavedVariables()
    end
end

_G.LoadAllSettings = AH.LoadAllSettings
_G.SaveAllSettings = AH.SaveAllSettings
_G.ForceSaveSettings = AH.ForceSaveSettings

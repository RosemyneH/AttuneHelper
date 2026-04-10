-- ʕ •ᴥ•ʔ✿ Per-character data keyed by player GUID (Synastria duplicate names) ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

local DEFAULT_PRESET = "Default"

function AH.GetActivePlayerGUID()
    return UnitGUID("player") or "unknown"
end

local function defaultCharProfile()
    return {
        weapon = {},
        ah = {
            active = DEFAULT_PRESET,
            order = { DEFAULT_PRESET },
            sets = {
                [DEFAULT_PRESET] = {},
            },
        },
    }
end

function AH.EnsureCharProfilesRoot()
    AttuneHelperDB.CharProfiles = AttuneHelperDB.CharProfiles or {}
    return AttuneHelperDB.CharProfiles
end

function AH.GetCharProfile()
    local root = AH.EnsureCharProfilesRoot()
    local guid = AH.GetActivePlayerGUID()
    if not root[guid] then
        root[guid] = defaultCharProfile()
    end
    local p = root[guid]
    p.weapon = p.weapon or {}
    p.ah = p.ah or defaultCharProfile().ah
    p.ah.sets = p.ah.sets or {}
    p.ah.order = p.ah.order or {}
    p.ah.active = p.ah.active or DEFAULT_PRESET
    if not p.ah.sets[p.ah.active] then
        p.ah.sets[p.ah.active] = {}
    end
    if not p.ah.sets[DEFAULT_PRESET] then
        p.ah.sets[DEFAULT_PRESET] = {}
    end
    local hasDefault = false
    for i = 1, #p.ah.order do
        if p.ah.order[i] == DEFAULT_PRESET then
            hasDefault = true
        end
    end
    if not hasDefault then
        table.insert(p.ah.order, 1, DEFAULT_PRESET)
    end
    return p
end

function AH.BindAHSetListToActivePreset()
    local p = AH.GetCharProfile()
    local name = p.ah.active
    if not p.ah.sets[name] then
        p.ah.sets[name] = {}
    end
    AHSetList = p.ah.sets[name]
    _G.AHSetList = AHSetList
end

function AH.MigrateLegacyCharDataIfNeeded()
    local p = AH.GetCharProfile()
    if p.migratedFromPerCharVars then
        AH.BindAHSetListToActivePreset()
        return
    end
    local active = p.ah.active
    local t = p.ah.sets[active]
    if type(AHSetList) == "table" and next(AHSetList) ~= nil and type(t) == "table" and next(t) == nil then
        for k, v in pairs(AHSetList) do
            t[k] = v
        end
    end
    if type(AHCharSettings) == "table" then
        for k, v in pairs(AHCharSettings) do
            if p.weapon[k] == nil then
                p.weapon[k] = v
            end
        end
    end
    p.migratedFromPerCharVars = true
    AH.BindAHSetListToActivePreset()
end

local function applyWeaponDefaults()
    local weaponControlDefaults = {
        ["Allow MainHand 1H Weapons"] = 1,
        ["Allow MainHand 2H Weapons"] = 1,
        ["Allow OffHand 1H Weapons"] = 1,
        ["Allow OffHand 2H Weapons"] = 0,
        ["Allow OffHand Shields"] = 1,
        ["Allow OffHand Holdables"] = 1,
    }
    local p = AH.GetCharProfile()
    for settingName, defaultValue in pairs(weaponControlDefaults) do
        if p.weapon[settingName] == nil then
            if AttuneHelperDB[settingName] ~= nil then
                p.weapon[settingName] = AttuneHelperDB[settingName]
            else
                p.weapon[settingName] = defaultValue
            end
        end
    end
    AHCharSettings = AHCharSettings or {}
    for k, v in pairs(p.weapon) do
        AHCharSettings[k] = v
    end
end

function AH.InitCharProfileAfterLoad()
    AH.EnsureCharProfilesRoot()
    AH.GetCharProfile()
    AH.MigrateLegacyCharDataIfNeeded()
    applyWeaponDefaults()
    AH.BindAHSetListToActivePreset()
end

function AH.GetActiveAHPresetName()
    return AH.GetCharProfile().ah.active
end

function AH.GetAHPresetOrder()
    local p = AH.GetCharProfile()
    local out = {}
    for _, n in ipairs(p.ah.order) do
        if p.ah.sets[n] then
            table.insert(out, n)
        end
    end
    return out
end

local function normalizePresetName(name)
    if not name then
        return nil
    end
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    if name == "" then
        return nil
    end
    if string.len(name) > 32 then
        name = string.sub(name, 1, 32)
    end
    return name
end

function AH.SwitchAHPreset(presetName)
    presetName = normalizePresetName(presetName)
    if not presetName then
        return false
    end
    local p = AH.GetCharProfile()
    if not p.ah.sets[presetName] then
        return false
    end
    p.ah.active = presetName
    AH.BindAHSetListToActivePreset()
    if AH.ForceSaveSettings then
        AH.ForceSaveSettings()
    end
    return true
end

function AH.CreateAHPreset(rawName)
    local name = normalizePresetName(rawName)
    if not name then
        return false, "invalid"
    end
    local p = AH.GetCharProfile()
    if p.ah.sets[name] then
        return false, "duplicate"
    end
    p.ah.sets[name] = {}
    table.insert(p.ah.order, name)
    p.ah.active = name
    AH.BindAHSetListToActivePreset()
    if AH.ForceSaveSettings then
        AH.ForceSaveSettings()
    end
    return true
end

function AH.DeleteAHPreset(presetName)
    presetName = normalizePresetName(presetName)
    if not presetName or presetName == DEFAULT_PRESET then
        return false
    end
    local p = AH.GetCharProfile()
    if not p.ah.sets[presetName] then
        return false
    end
    local order = p.ah.order
    local idx
    for i = 1, #order do
        if not idx and order[i] == presetName then
            idx = i
        end
    end
    if idx then
        table.remove(order, idx)
    end
    p.ah.sets[presetName] = nil
    if p.ah.active == presetName then
        p.ah.active = DEFAULT_PRESET
        if not p.ah.sets[DEFAULT_PRESET] then
            p.ah.sets[DEFAULT_PRESET] = {}
        end
    end
    AH.BindAHSetListToActivePreset()
    if AH.ForceSaveSettings then
        AH.ForceSaveSettings()
    end
    return true
end

function AH.EnsureAHSetListTable()
    if type(AHSetList) ~= "table" then
        AH.BindAHSetListToActivePreset()
    end
end

-- ʕ •ᴥ•ʔ✿ Per-character data keyed by player GUID (Synastria duplicate names) ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper

local DEFAULT_PRESET = "Default"
local UNKNOWN_GUID = "unknown"
local WEAPON_CONTROL_DEFAULTS = {
    ["Allow MainHand 1H Weapons"] = 1,
    ["Allow MainHand 2H Weapons"] = 1,
    ["Allow OffHand 1H Weapons"] = 1,
    ["Allow OffHand 2H Weapons"] = 0,
    ["Allow OffHand Shields"] = 1,
    ["Allow OffHand Holdables"] = 1,
}

local function isKnownGuid(guid)
    return type(guid) == "string" and guid ~= "" and guid ~= UNKNOWN_GUID
end

local function isZeroLike(value)
    return value == 0 or value == "0" or value == false
end

local function repairLegacyAllZeroWeaponProfile(profile)
    if type(profile) ~= "table" or type(profile.weapon) ~= "table" then
        return false
    end

    local hasAnyWeaponKeys = false
    local allZero = true
    for settingName, _ in pairs(WEAPON_CONTROL_DEFAULTS) do
        local currentValue = profile.weapon[settingName]
        if currentValue ~= nil then
            hasAnyWeaponKeys = true
        else
            allZero = false
            break
        end
        if not isZeroLike(currentValue) then
            allZero = false
            break
        end
    end

    if not hasAnyWeaponKeys or not allZero then
        return false
    end

    local hasTopLevelSignal = false
    for settingName, _ in pairs(WEAPON_CONTROL_DEFAULTS) do
        local topLevelValue = AttuneHelperDB and AttuneHelperDB[settingName]
        if topLevelValue ~= nil and not isZeroLike(topLevelValue) then
            hasTopLevelSignal = true
            break
        end
    end
    if not hasTopLevelSignal then
        return false
    end

    for settingName, defaultValue in pairs(WEAPON_CONTROL_DEFAULTS) do
        local topLevelValue = AttuneHelperDB and AttuneHelperDB[settingName]
        if topLevelValue ~= nil then
            profile.weapon[settingName] = topLevelValue
        else
            profile.weapon[settingName] = defaultValue
        end
    end
    return true
end

function AH.GetActivePlayerGUID()
    local guid = UnitGUID("player")
    if isKnownGuid(guid) then
        AH._lastKnownPlayerGUID = guid
        return guid
    end
    if isKnownGuid(AH._lastKnownPlayerGUID) then
        return AH._lastKnownPlayerGUID
    end
    return UNKNOWN_GUID
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
    local function shouldImportLegacyWeaponSettings(legacySettings)
        if type(legacySettings) ~= "table" then
            return false
        end

        local expectedKeyCount = 0
        local zeroCount = 0
        for settingName, _ in pairs(WEAPON_CONTROL_DEFAULTS) do
            expectedKeyCount = expectedKeyCount + 1
            local value = legacySettings[settingName]
            if value == nil then
                return true
            end
            if value == 0 or value == "0" then
                zeroCount = zeroCount + 1
            end
        end

        if zeroCount == expectedKeyCount then
            for keyName, _ in pairs(legacySettings) do
                if WEAPON_CONTROL_DEFAULTS[keyName] == nil then
                    return true
                end
            end
            return false
        end
        return true
    end

    if shouldImportLegacyWeaponSettings(AHCharSettings) then
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
    local p = AH.GetCharProfile()
    for settingName, defaultValue in pairs(WEAPON_CONTROL_DEFAULTS) do
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
    local root = AH.EnsureCharProfilesRoot()
    local activeGuid = AH.GetActivePlayerGUID()
    if isKnownGuid(activeGuid) and root[UNKNOWN_GUID] and not root[activeGuid] then
        root[activeGuid] = root[UNKNOWN_GUID]
        root[UNKNOWN_GUID] = nil
    end
    local profile = AH.GetCharProfile()
    AH.MigrateLegacyCharDataIfNeeded()
    repairLegacyAllZeroWeaponProfile(profile)
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

local function presetSetHasMappings(setTable)
    return type(setTable) == "table" and next(setTable) ~= nil
end

local function queueEquipAHPresetAfterSwitch(previousActive, newActive)
    if not previousActive or not newActive or previousActive == newActive then
        return
    end
    local p = AH.GetCharProfile()
    if not presetSetHasMappings(p.ah.sets[newActive]) then
        return
    end
    if not AH.Wait then
        return
    end
    AH.Wait(0, function()
        if not AH.EquipAHSetOnly then
            return
        end
        if AH.GetActiveAHPresetName() ~= newActive then
            return
        end
        AH.EquipAHSetOnly()
    end)
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
    local previousActive = p.ah.active
    p.ah.active = presetName
    AH.BindAHSetListToActivePreset()
    if AH.ForceSaveSettings then
        AH.ForceSaveSettings()
    end
    queueEquipAHPresetAfterSwitch(previousActive, presetName)
    return true
end

function AH.SwitchToNextAHPreset()
    local order = AH.GetAHPresetOrder and AH.GetAHPresetOrder() or {}
    if #order == 0 then
        return false
    end

    local active = AH.GetActiveAHPresetName and AH.GetActiveAHPresetName() or nil
    local currentIndex = 1
    for i = 1, #order do
        if order[i] == active then
            currentIndex = i
            break
        end
    end

    local nextIndex = currentIndex + 1
    if nextIndex > #order then
        nextIndex = 1
    end

    local nextPreset = order[nextIndex]
    if not nextPreset then
        return false
    end

    if AH.SwitchAHPreset and AH.SwitchAHPreset(nextPreset) then
        return true, nextPreset
    end
    return false
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
    local previousActive = p.ah.active
    p.ah.active = name
    AH.BindAHSetListToActivePreset()
    if AH.ForceSaveSettings then
        AH.ForceSaveSettings()
    end
    queueEquipAHPresetAfterSwitch(previousActive, name)
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

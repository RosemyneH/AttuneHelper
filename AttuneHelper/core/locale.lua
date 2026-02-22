-- ʕ •ᴥ•ʔ✿ Localization module ✿ ʕ •ᴥ•ʔ
local AH = _G.AttuneHelper or {}
_G.AttuneHelper = AH

-- Ensure saved variable table exists
AttuneHelperDB = AttuneHelperDB or {}

------------------------------------------------------------------------
-- Determine active locale
------------------------------------------------------------------------
local savedLocale = AttuneHelperDB["Language"] -- "default" | nil | texture code
local systemLocale = GetLocale()
local activeLocale = (savedLocale and savedLocale ~= "default") and savedLocale or systemLocale

-- Normalise variants that share same translation table
if activeLocale == "enGB" then activeLocale = "enUS" end -- fall back to US English

------------------------------------------------------------------------
-- Translation dictionaries (expand over time)
------------------------------------------------------------------------
local enUS = {
    ["Equip Attunables"]                                                              = "Equip Attunables",
    ["Prepare Disenchant"]                                                            = "Prepare Disenchant",
    ["Vendor Attuned"]                                                                = "Vendor Attuned",
    ["Vendor Attuned Items"]                                                          = "Vendor Attuned Items",
    ["System Default"]                                                                = "System Default",
    ["English (US)"]                                                                  = "English (US)",
    ["Español"]                                                                       = "Español",
    ["Deutsch"]                                                                       = "Deutsch",
    ["Select Language:"]                                                              = "Select Language:",
    ["Moves fully attuned mythic items to bag %d."]                                   = "Moves fully attuned mythic items to bag %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]              =
    "Clears target bag first, then fills with disenchant-ready items.",
    ["Attunable Items: %d"]                                                           = "Attunable Items: %d",
    ["Qualifying Attunables (%d):"]                                                   = "Qualifying Attunables (%d):",
    ["No qualifying attunables in bags."]                                             = "No qualifying attunables in bags.",
    ["Items to be sold (%d):"]                                                        = "Items to be sold (%d):",
    ["No items will be sold based on current settings."]                              = "No items will be sold based on current settings.",
    ["Open merchant window to sell these items."]                                     = "Open merchant window to sell these items.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."]     =
    "Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists.",
    ["Update AHSet"]                                                                  = "Update AHSet",
    ["Sets AHSet to be equal to your currently equiped items."]                       =
    "Sets AHSet to be equal to your currently equiped items.",
    ["This will delete your current AHSet."]                                          = "This will delete your current AHSet.",
    ["Are you sure you want to update AHSet to match your currently equipped items?"] =
    "Are you sure you want to update AHSet to match your currently equipped items?",
    ["Yes"]                                                                           = "Yes",
    ["Cancel"]                                                                        = "Cancel",
    ["Toggle Auto-Equip"]                                                             = "Toggle Auto-Equip",
    ["Disable Auto-Equip"]                                                            = "Disable Auto-Equip",
    ["Enable Auto-Equip"]                                                             = "Enable Auto-Equip",
    ["Currently enabled."]                                                            = "Currently enabled.",
    ["Currently disabled."]                                                           = "Currently disabled.",
    ["Open Settings"]                                                                 = "Open Settings",
    ["Opens the General Logic Options settings page."]                                = "Opens the General Logic Options settings page.",
    ["Hold Shift for additional options"]                                             = "Hold Shift for additional options"
}

local esES = { -- Reviewed by LiquidAP and Moonlight
    ["Equip Attunables"]                                                              = "Equipar sincronizables",
    ["Prepare Disenchant"]                                                            = "Preparar desencantar",
    ["Vendor Attuned"]                                                                = "Vender sincronizados",
    ["Vendor Attuned Items"]                                                          = "Vender objetos sincronizados",
    ["System Default"]                                                                = "Predeterminado del sistema",
    ["English (US)"]                                                                  = "Inglés (EE.UU.)",
    ["Español"]                                                                       = "Español",
    ["Deutsch"]                                                                       = "Alemán",
    ["Select Language:"]                                                              = "Seleccionar idioma:",
    ["Moves fully attuned mythic items to bag %d."]                                   = "Mueve los objetos míticos totalmente sincronizados a la bolsa %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]              =
    "Vacía primero la bolsa objetivo y luego la llena con objetos listos para desencantar.",
    ["Attunable Items: %d"]                                                           = "Objetos sincronizables: %d",
    ["Qualifying Attunables (%d):"]                                                   = "Sincronizables elegibles (%d):",
    ["No qualifying attunables in bags."]                                             = "No hay sincronizables elegibles en las bolsas.",
    ["Items to be sold (%d):"]                                                        = "Objetos a vender (%d):",
    ["No items will be sold based on current settings."]                              = "No se venderán objetos según la configuración actual.",
    ["Open merchant window to sell these items."]                                     = "Abre la ventana del vendedor para vender estos objetos.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."]     =
    "Los objetos deben ser míticos y estar: 100% sincronizados, ligados, fuera de conjuntos/listas de ignorados.",
    ["Update AHSet"]                                                                  = "Sobreescribir AHSet",
    ["Sets AHSet to be equal to your currently equiped items."]                       = "Sobreescribe AHSet con tus obejtos equipados.",
    ["This will delete your current AHSet."]                                          = "Esto borrará el AHSet actual.",
    ["Are you sure you want to update AHSet to match your currently equipped items?"] =
    "¿De verdad quieres sobreescribir AHSet con tus objetos equipados?",
    ["Yes"]                                                                           = "Sí",
    ["Cancel"]                                                                        = "Cancelar",
    ["Toggle Auto-Equip"]                                                             = "Auto-Equipar",
    ["Disable Auto-Equip"]                                                            = "Desactivar Auto-Equipar",
    ["Enable Auto-Equip"]                                                             = "Activar Auto-Equipar",
    ["Currently enabled."]                                                            = "Ahora está activado",
    ["Currently disabled."]                                                           = "Ahora está desactivado",
    ["Open Settings"]                                                                 = "Ajustes",
    ["Opens the General Logic Options settings page."]                                = "Abre la pagina de ajustes de Opciones Generales de Lógica.",
    ["Hold Shift for additional options"]                                             = "Mantén Shift presionado para opciones adicionales"
}

local deDE = { -- AI GENERATED NO VERIFICATION
    ["Equip Attunables"]                                                          = "Abstimmbare ausrüsten",
    ["Prepare Disenchant"]                                                        = "Entzaubern vorbereiten",
    ["Vendor Attuned"]                                                            = "Abgestimmte verkaufen",
    ["Vendor Attuned Items"]                                                      = "Abgestimmte Gegenstände verkaufen",
    ["System Default"]                                                            = "Systemstandard",
    ["English (US)"]                                                              = "Englisch (US)",
    ["Español"]                                                                   = "Spanisch",
    ["Deutsch"]                                                                   = "Deutsch",
    ["Select Language:"]                                                          = "Sprache wählen:",
    ["Moves fully attuned mythic items to bag %d."]                               =
    "Bewegt vollständig abgestimmte mythische Gegenstände in Tasche %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]          =
    "Leert zuerst die Zieltasche und füllt sie dann mit entzauberbereiten Gegenständen.",
    ["Attunable Items: %d"]                                                       = "Abstimmbare Gegenstände: %d",
    ["Qualifying Attunables (%d):"]                                               = "Qualifizierte abstimmbare Gegenstände (%d):",
    ["No qualifying attunables in bags."]                                         = "Keine geeigneten abstimmbaren Gegenstände in den Taschen.",
    ["Items to be sold (%d):"]                                                    = "Zu verkaufende Gegenstände (%d):",
    ["No items will be sold based on current settings."]                          =
    "Gemäß den aktuellen Einstellungen werden keine Gegenstände verkauft.",
    ["Open merchant window to sell these items."]                                 = "Öffne das Händlerfenster, um diese Gegenstände zu verkaufen.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."] =
    "Gegenstände müssen sein: Mythisch, 100% abgestimmt, seelengebunden, nicht in Sets/Ignore-Listen.",
    ["Hold Shift for additional options"]                                         = "Halte Umschalt für zusätzliche Optionen gedrückt",
}

-- [Rest of the language tables remain the same...]

local frFR = { -- AI GENERATED NO VERIFICATION
    ["Equip Attunables"]                                                          = "Équiper les objets accordés",
    ["Prepare Disenchant"]                                                        = "Préparer le désenchantement",
    ["Vendor Attuned"]                                                            = "Vendre les objets accordés",
    ["Vendor Attuned Items"]                                                      = "Vendre les objets accordés",
    ["System Default"]                                                            = "Système par défaut",
    ["English (US)"]                                                              = "Anglais (US)",
    ["Français"]                                                                  = "Français",
    ["Select Language:"]                                                          = "Choisir la langue :",
    ["Moves fully attuned mythic items to bag %d."]                               = "Déplace les objets mythiques totalement accordés dans le sac %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]          =
    "Vide d'abord le sac cible, puis le remplit avec les objets prêts à désenchanter.",
    ["Attunable Items: %d"]                                                       = "Objets accordables : %d",
    ["Qualifying Attunables (%d):"]                                               = "Objets accordables éligibles (%d) :",
    ["No qualifying attunables in bags."]                                         = "Aucun objet accordable éligible dans les sacs.",
    ["Items to be sold (%d):"]                                                    = "Objets à vendre (%d) :",
    ["No items will be sold based on current settings."]                          = "Aucun objet ne sera vendu selon les réglages actuels.",
    ["Open merchant window to sell these items."]                                 = "Ouvrez la fenêtre du marchand pour vendre ces objets.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."] =
    "Objets requis : mythiques, 100 % accordés, liés, non présents dans les ensembles/listes d'ignorés.",
    ["Hold Shift for additional options"]                                         = "Maintenez Shift pour des options supplémentaires",
}

local itIT = { -- AI GENERATED NO VERIFICATION
    ["Equip Attunables"]                                                          = "Equipaggia Oggetti Sintonizzati",
    ["Prepare Disenchant"]                                                        = "Prepara Disincantamento",
    ["Vendor Attuned"]                                                            = "Vendi Sintonizzato",
    ["Vendor Attuned Items"]                                                      = "Vendi Oggetti Sintonizzati",
    ["System Default"]                                                            = "Sistema predefinito",
    ["English (US)"]                                                              = "Inglese (US)",
    ["Italiano"]                                                                  = "Italiano",
    ["Select Language:"]                                                          = "Seleziona lingua:",
    ["Moves fully attuned mythic items to bag %d."]                               =
    "Sposta gli oggetti mitici completamente sintonizzati nella borsa %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]          =
    "Svuota prima la borsa di destinazione, poi la riempie con gli oggetti da disincantare.",
    ["Attunable Items: %d"]                                                       = "Oggetti sintonizzabili: %d",
    ["Qualifying Attunables (%d):"]                                               = "Oggetti sintonizzabili idonei (%d):",
    ["No qualifying attunables in bags."]                                         = "Nessun oggetto sintonizzabile idoneo nelle borse.",
    ["Items to be sold (%d):"]                                                    = "Oggetti da vendere (%d):",
    ["No items will be sold based on current settings."]                          =
    "Nessun oggetto sarà venduto in base alle impostazioni correnti.",
    ["Open merchant window to sell these items."]                                 = "Apri la finestra del mercante per vendere questi oggetti.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."] =
    "Gli oggetti devono essere: mitici, sintonizzati al 100%, vincolati, non in set/liste ignorate.",
    ["Hold Shift for additional options"]                                         = "Tieni premuto Shift per opzioni aggiuntive",
}

local ptBR = { -- AI GENERATED NO VERIFICATION
    ["Equip Attunables"]                                                          = "Equipar Sintonizáveis",
    ["Prepare Disenchant"]                                                        = "Preparar Desencantamento",
    ["Vendor Attuned"]                                                            = "Vender Sintonizado",
    ["Vendor Attuned Items"]                                                      = "Vender Itens Sintonizados",
    ["System Default"]                                                            = "Padrão do sistema",
    ["English (US)"]                                                              = "Inglês (US)",
    ["Português (BR)"]                                                            = "Português (BR)",
    ["Select Language:"]                                                          = "Selecionar idioma:",
    ["Moves fully attuned mythic items to bag %d."]                               = "Move itens míticos totalmente sintonizados para a bolsa %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]          =
    "Esvazia primeiro a bolsa destino e depois a preenche com itens prontos para desencantar.",
    ["Attunable Items: %d"]                                                       = "Itens sintonizáveis: %d",
    ["Qualifying Attunables (%d):"]                                               = "Sintonizáveis qualificados (%d):",
    ["No qualifying attunables in bags."]                                         = "Nenhum sintonizável qualificado nas bolsas.",
    ["Items to be sold (%d):"]                                                    = "Itens a serem vendidos (%d):",
    ["No items will be sold based on current settings."]                          = "Nenhum item será vendido conforme as configurações atuais.",
    ["Open merchant window to sell these items."]                                 = "Abra a janela do vendedor para vender estes itens.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."] =
    "Itens devem ser: Míticos, 100% sintonizados, vinculados, não em conjuntos/listas de ignorados.",
    ["Hold Shift for additional options"]                                         = "Segure Shift para opções adicionais",
}

local ruRU = { -- AI GENERATED NO VERIFICATION
    ["Equip Attunables"] = "Надеть предметы настройки",
    ["Prepare Disenchant"] = "Подготовить распыление",
    ["Vendor Attuned"] = "Продать настроенное",
    ["Vendor Attuned Items"] = "Продать настроенные предметы",
    ["System Default"] = "Системный по умолчанию",
    ["English (US)"] = "Английский (US)",
    ["Русский"] = "Русский",
    ["Select Language:"] = "Выбор языка:",
    ["Moves fully attuned mythic items to bag %d."] = "Перемещает полностью настроенные мифические предметы в сумку %d.",
    ["Clears target bag first, then fills with disenchant-ready items."] =
    "Сначала очищает целевую сумку, затем заполняет её предметами для распыления.",
    ["Attunable Items: %d"] = "Предметы для настройки: %d",
    ["Qualifying Attunables (%d):"] = "Подходящие предметы (%d):",
    ["No qualifying attunables in bags."] = "Подходящих предметов в сумках нет.",
    ["Items to be sold (%d):"] = "Предметы для продажи (%d):",
    ["No items will be sold based on current settings."] = "Предметы не будут проданы согласно текущим настройкам.",
    ["Open merchant window to sell these items."] = "Откройте окно торговца, чтобы продать эти предметы.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."] =
    "Предметы должны быть: мифическими, 100% настроенными, персональными, не в наборах/списках игнора.",
    ["Hold Shift for additional options"] = "Удерживайте Shift для дополнительных опций",
}

local zhCN = { -- AI GENERATED NO VERIFICATION
    ["Equip Attunables"] = "装备可调谐物品",
    ["Prepare Disenchant"] = "准备分解",
    ["Vendor Attuned"] = "出售已调谐",
    ["Vendor Attuned Items"] = "出售已调谐物品",
    ["System Default"] = "系统默认",
    ["English (US)"] = "英语 (US)",
    ["简体中文"] = "简体中文",
    ["Select Language:"] = "选择语言：",
    ["Moves fully attuned mythic items to bag %d."] = "将完全调谐的史诗物品移动到背包%d。",
    ["Clears target bag first, then fills with disenchant-ready items."] = "先清空目标背包，然后填充待分解物品。",
    ["Attunable Items: %d"] = "可调谐物品：%d",
    ["Qualifying Attunables (%d):"] = "符合条件的可调谐物品（%d）：",
    ["No qualifying attunables in bags."] = "背包中没有符合条件的可调谐物品。",
    ["Items to be sold (%d):"] = "待出售物品（%d）：",
    ["No items will be sold based on current settings."] = "根据当前设置不会出售任何物品。",
    ["Open merchant window to sell these items."] = "打开商人窗口以出售这些物品。",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."] = "物品要求：史诗，100%调谐，已绑定，不在套装/忽略列表。",
    ["Hold Shift for additional options"] = "按住Shift键查看其他选项",
}

local zhTW = { -- AI GENERATED NO VERIFICATION
    ["Equip Attunables"] = "裝備可調諧物品",
    ["Prepare Disenchant"] = "準備分解",
    ["Vendor Attuned"] = "出售已調諧",
    ["Vendor Attuned Items"] = "出售已調諧物品",
    ["System Default"] = "系統預設",
    ["English (US)"] = "英語 (US)",
    ["繁體中文"] = "繁體中文",
    ["Select Language:"] = "選擇語言：",
    ["Moves fully attuned mythic items to bag %d."] = "將完全調諧的史詩物品移至背包%d。",
    ["Clears target bag first, then fills with disenchant-ready items."] = "先清空目標背包，再填入待分解物品。",
    ["Attunable Items: %d"] = "可調諧物品：%d",
    ["Qualifying Attunables (%d):"] = "符合條件的可調諧物品（%d）：",
    ["No qualifying attunables in bags."] = "背包中沒有符合條件的可調諧物品。",
    ["Items to be sold (%d):"] = "待販售物品（%d）：",
    ["No items will be sold based on current settings."] = "依目前設定不會販售任何物品。",
    ["Open merchant window to sell these items."] = "打開商人視窗來出售這些物品。",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."] = "物品需為：史詩、100%調諧、已綁定，不在套裝/忽略列表。",
    ["Hold Shift for additional options"] = "按住Shift鍵查看其他選項",
}

local koKR = { -- AI GENERATED NO VERIFICATION
    ["Equip Attunables"] = "조율 아이템 장비",
    ["Prepare Disenchant"] = "마력 추출 준비",
    ["Vendor Attuned"] = "조율 아이템 판매",
    ["Vendor Attuned Items"] = "조율 아이템 판매",
    ["System Default"] = "시스템 기본값",
    ["English (US)"] = "영어 (US)",
    ["한국어"] = "한국어",
    ["Select Language:"] = "언어 선택:",
    ["Moves fully attuned mythic items to bag %d."] = "완전히 조율된 신화 아이템을 가방 %d번으로 이동합니다.",
    ["Clears target bag first, then fills with disenchant-ready items."] = "대상 가방을 비운 후 분해 준비 아이템으로 채웁니다.",
    ["Attunable Items: %d"] = "조율 가능 아이템: %d",
    ["Qualifying Attunables (%d):"] = "해당 조율 아이템(%d):",
    ["No qualifying attunables in bags."] = "가방에 해당 조율 아이템이 없습니다.",
    ["Items to be sold (%d):"] = "판매 아이템(%d):",
    ["No items will be sold based on current settings."] = "현재 설정으로 판매할 아이템이 없습니다.",
    ["Open merchant window to sell these items."] = "상인 창을 열어 이 아이템을 판매하세요.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."] =
    "아이템 조건: 신화, 100% 조율, 귀속, 세트/제외 목록에 없음.",
    ["Hold Shift for additional options"] = "추가 옵션을 보려면 Shift를 누르고 계세요",
}

local esMX = esES -- share table

-- Map missing translations to English automatically via setmetatable later

local dictionaries = {
    enUS = enUS,
    enGB = enUS,
    esES = esES,
    esMX = esES,
    deDE = deDE,
    frFR = frFR,
    itIT = itIT,
    ptBR = ptBR,
    ptPT = ptBR,
    ruRU = ruRU,
    zhCN = zhCN,
    zhTW = zhTW,
    koKR = koKR,
}

------------------------------------------------------------------------
-- Core helper functions
------------------------------------------------------------------------
local function activateLocale(localeCode)
    local dict = dictionaries[localeCode] or dictionaries["enUS"]
    -- Metatable fallback: return the key itself if not translated yet
    setmetatable(dict, { __index = function(_, k) return k end })
    AH.L = dict
end

function AH.SetLocale(localeCode)
    if not localeCode then return end
    if localeCode == "default" then
        localeCode = GetLocale()
    end
    if localeCode == "enGB" then localeCode = "enUS" end
    AttuneHelperDB["Language"] = localeCode
    activateLocale(localeCode)
end

-- Simple wrapper similar to Blizzard _G["BINDING_NAME"] usage
function AH.t(key, ...)
    local str = (AH.L and AH.L[key]) or key
    if select("#", ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

-- Initialise on load
activateLocale(activeLocale)

-- Re-apply selected locale after all addon files are loaded, just in case other
-- modules (or default settings) modified the table during startup.
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, addonName)
    if addonName == "AttuneHelper" then
        AH.SetLocale(AttuneHelperDB and AttuneHelperDB["Language"] or "default")
        f:UnregisterEvent("ADDON_LOADED")
    end
end)

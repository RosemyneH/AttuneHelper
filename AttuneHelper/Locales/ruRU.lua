-- ʕ •ᴥ•ʔ✿ Locale (Russian) ✿ ʕ •ᴥ•ʔ
local AH_LOCALES = _G.AH_LOCALES or {}
_G.AH_LOCALES = AH_LOCALES

AH_LOCALES["ruRU"] = {
    ["Equip Attunables"]                                                              = "Надеть Attunables",
    ["Prepare Disenchant"]                                                            = "Подготовить распыление",
    ["Vendor Attuned"]                                                                = "Продать Attuned",
    ["Vendor Attuned Items"]                                                          = "Продать предметы Attuned",
    ["Add To Vendor"]                                                                 = "Добавить в список продажи",
    ["System Default"]                                                                = "По умолчанию (система)",
    ["English (US)"]                                                                  = "English (US)",
    ["Español"]                                                                       = "Español",
    ["Deutsch"]                                                                       = "Deutsch",
    ["Select Language:"]                                                              = "Выбор языка:",
    ["Moves fully attuned mythic items to bag %d."]                                   = "Перемещает полностью Attuned мифические предметы в сумку %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]              =
    "Сначала очищает целевую сумку, затем заполняет её предметами для распыления.",
    ["Attunable Items: %d"]                                                           = "Предметы Attunable: %d",
    ["Qualifying Attunables (%d):"]                                                   = "Подходящие Attunables (%d):",
    ["No qualifying attunables in bags."]                                             = "В сумках нет подходящих Attunables.",
    ["Items to be sold (%d):"]                                                        = "Предметы на продажу (%d):",
    ["Always-vendor entries: %d"]                                                     = "Записей Always-Vendor: %d",
    ["No items will be sold based on current settings."]                              = "С текущими настройками ни один предмет продан не будет.",
    ["Open merchant window to sell these items."]                                     = "Откройте окно торговца, чтобы продать эти предметы.",
    ["Drag an item here or pick it up and click to toggle always-vendor."]            = "Перетащите предмет сюда или возьмите его и щёлкните, чтобы переключить Always-Vendor.",
    ["Items added here are always included in AH vendor previews and selling."]       = "Предметы, добавленные сюда, всегда включаются в предпросмотр и продажу AH.",
    ["Hold left 1s on this button for bulk add mode (cursor items add-only)."]        = "Удерживайте ЛКМ 1 с на этой кнопке для режима массового добавления (предметы с курсора только добавляются).",
    ["Bulk mode: click this button again or close the vendor to exit."]               = "Режим массового добавления: щёлкните по кнопке ещё раз или закройте торговца, чтобы выйти.",
    ["Bulk add mode is ON."]                                                          = "Режим массового добавления ВКЛЮЧЁН.",
    ["Always-vendor skipped for Warforged/Lightforged (see options)."]                = "Always-Vendor пропущен для WF/LF (см. настройки).",
    ["Ignore Always-Vendor for Warforged and Lightforged"]                            = "Игнорировать Always-Vendor для Warforged и Lightforged",
    ["When enabled, Warforged and Lightforged variants cannot be added to the always-vendor list and do not use the always-vendor bypass when selling."] =
    "Если включено, варианты Warforged и Lightforged нельзя добавить в список Always-Vendor, и они не используют обход Always-Vendor при продаже.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."]     =
    "Предметы должны быть: мифическими, Attuned на 100%%, персональными, не входить в наборы/списки игнора.",
    ["Prepare Disenchant Include BoE Mythic Weapons"]                                  =
    "Подготовка распыления: BoE мифическое оружие (ур. предмета 245)",
    ["Update AHSet"]                                                                  = "Обновить AHSet",
    ["Sets AHSet to be equal to your currently equiped items."]                       =
    "Задаёт AHSet равным вашим текущим надетым предметам.",
    ["This will delete your current AHSet."]                                          = "Это удалит ваш текущий AHSet.",
    ["Are you sure you want to update AHSet to match your currently equipped items?"] =
    "Вы уверены, что хотите обновить AHSet, чтобы он соответствовал текущим надетым предметам?",
    ["AHSet 1H pre-swap for off-hand attune"] =
    "AHSet: предварительная замена 1H для Attune во вторую руку (мультикласс воина)",
    ["AHSet 1h2h swap"] = "Мультикласс воина · замена 1H / 2H",
    ["AHSet 1h2h swap tip line 1"] =
    "В мультиклассе в стиле Хроми ваш UI-класс часто не Воин, даже если играете как воин. Если эта опция включена и установлен флаг замены пресета, Equip All может заменить 2H в основной руке на ваше одноручное оружие из AHSet, чтобы Attunable во вторую руку можно было надеть.",
    ["AHSet 1h2h swap tip line 2"] = "Нужны: 2H в основной руке, которое не находится в активном Attuning, Attunable во вторую руку в сумках и 1H в сумках, привязанное к Main Hand или к строке '1H Weapon Swaps' в управлении списками.",
    ["AHSet 1h2h swap tip line 3"] = "Titan's Grip играется с двуручным оружием в основной руке и либо ещё одним TG-двуручным, либо одноручным топором во второй руке (например, билд Неистовства типа flurry) — это ваша реальная пара оружия, а не строки '1H Weapon Swaps' / prep. Equip All обычно пропускает замену 2H→одноручное в основной руке, пока обнаружен TG, чтобы работа с сумками могла использовать вашу вторую руку. Исключение: одноручное только для основной руки нельзя надеть во вторую руку, поэтому такая замена всё равно может произойти. Флаг замены включается, когда основная рука привязана к двуручному и вы привязываете одноручное к Main Hand или к строке '1H Weapon Swaps'; /ahset 1hspecial2h всё ещё может принудительно включить его до этого.",
    ["AHSet 1h2h swap tip line 4"] = "Определение второй руки является строгим, когда этот пресет привязывает что-либо к Off Hand или к prep-ячейке второй руки (неоднозначные одноручные требуют /ahset … oh). Иначе режим свободный.",
    ["AHSet 1h2h swap tip line 5"] = "/ahset 1hspecial2h remove очищает необязательный флаг принудительного включения; 'Set AHSet' обнуляет весь пресет.",
    ["Off-hand swap trigger"] = "Триггер замены второй руки",
    ["AHSet OH trigger strict"] = "Только AHSet / нативная вторая рука (строго)",
    ["AHSet OH trigger loose"] = "Любое 1H, пригодное для второй руки (свободно)",
    ["AHSet OH trigger strict tip"] =
    "Строго: щиты, удерживаемые в руке предметы и оружие второй руки засчитываются всегда. Неоднозначные одноручные засчитываются только если вы привязали их через /ahset <link> oh (вторая рука AHSet).",
    ["AHSet OH trigger loose tip"] =
    "Свободно: любое Attunable одноручное в сумках считается основанием для замены, даже без привязки второй руки в AHSet (замены могут происходить чаще).",
    ["AHSet 1h2h preset button title"] = "Замена 1H/2H мультикласса воина (пресет)",
    ["AHSet 1h2h preset tip line 1"] =
    "Переключает флаг замены пресета (то же, что /ahset 1hspecial2h). Это не общий тумблер: он существует, потому что мультиклассовые воины часто используют 2H-профиль, пока предметы второй руки ещё нуждаются в Attuning.",
    ["AHSet 1h2h preset tip line 2"] = "Equip All выполняет замену только когда этот флаг включён (On), флажок выше включён и выполнены остальные условия из подсказки.",
    ["AHSet 1h2h preset tip line 3"] = "Щёлкните ещё раз, чтобы выключить (Off) и снять флаг только с этого пресета.",
    ["MC 1h2h: On"] = "MC 1h2h: Вкл.",
    ["MC 1h2h: Off"] = "MC 1h2h: Выкл.",
    ["AHSet 1h2h list title"] = "MC воин · 1H/2H (этот пресет)",
    ["AHSet prep paper strip label"] = "1H Weapon Swaps",
    ["AHSet prep paper strip drag hint"] = "Подготовить оружие",
    ["AHSet prep MH slot label"] = "1H · ряд основной руки",
    ["AHSet prep OH slot label"] = "Ряд второй руки",
    ["AHSet prep slot empty slash hint"] = "'Set AHSet', /ahset prepmh, /ahset prep1h или /ahset prepoh тоже работают.",
    ["AHSet keep item in bags for instance signature"] =
    "Оставьте предмет в сумках при добавлении в AHSet, чтобы можно было сохранить его уникальную сигнатуру. Если у вас всего одна копия, ссылки только надетого предмета может не хватить.",
    ["AHSet usage signature reminder"] =
    "Уникальные предметы: положите их в сумки перед /ahset, чтобы можно было сохранить сигнатуры экземпляра, когда доступен Custom_GetItemGuid.",
    ["AHSet 2h swap strip explanation"] =
    "Здесь нет отдельного тумблера: Equip All использует ваши привязки оружия в этом пресете. Привяжите одноручное к Main Hand или к ячейкам ниже, когда основная рука пресета — двуручное.",
    ["AHSet auto status swap on"] = "Маршрут замены prep 1H: активен для этого пресета.",
    ["AHSet auto status swap off"] = "Маршрут замены prep 1H: неактивен (привяжите одноручное к Main Hand или к ячейкам ниже, либо принудительно через /ahset 1hspecial2h).",
    ["AHSet auto status oh fmt"] = "Определение Attunable во второй руке: %s.",
    ["AHSet OH trigger strict short"] = "строго",
    ["AHSet OH trigger loose short"] = "свободно",
    ["Weapon panel multiclass header"] = "Мультикласс воина · замена AHSet",
    ["Weapon panel TG detection note"] = "Titan's Grip определяется по вашим талантам (включая мультиклассовые вкладки талантов в стиле Хроми). Логика двойного 2H в сумках/экипировке применяется только к двуручным топорам, булавам и мечам — не к посохам и древковому оружию.",
    ["AHSet 2h swap section title"] = "1H Weapon Swaps",
    ["AHSet 1h2h preset row label"] = "Замена 1H/2H для этого пресета",
    ["AHSet swap flag on"] = "Вкл.",
    ["AHSet swap flag off"] = "Выкл.",
    ["Yes"]                                                                           = "Да",
    ["No"]                                                                            = "Нет",
    ["Cancel"]                                                                        = "Отмена",
    ["Toggle Auto-Equip"]                                                             = "Переключить автонадевание",
    ["Disable Auto-Equip"]                                                            = "Отключить автонадевание",
    ["Enable Auto-Equip"]                                                             = "Включить автонадевание",
    ["Currently enabled."]                                                            = "Сейчас включено.",
    ["Currently disabled."]                                                           = "Сейчас отключено.",
    ["Open Settings"]                                                                 = "Открыть настройки",
    ["Opens the General Logic Options settings page."]                                = "Открывает страницу настроек 'General Logic Options'.",
    ["Hold Shift for additional options"]                                             = "Удерживайте Shift для дополнительных опций",
    ["Background Color"]                                                              = "Цвет фона",
    ["Equip Attunable Affixes up to:"]                                                = "Надевать Attunable аффиксы до:",
    ["Affix-Only Minimum Forge"]                                                      = "Минимальная forge для Affix-Only",
    ["Works only when 'Equip New Affixes Only' is enabled."]                          =
    "Работает только если включено 'Equip New Affixes Only'.",
    ["'All Items' disables the forge threshold behavior."]                            =
    "'All Items' отключает поведение порога forge.",
    ["When enabled, this setting favors affixes you have not attuned yet."]           =
    "Если включено, этот параметр отдаёт предпочтение аффиксам, которые вы ещё не Attuned.",
    ["Use the dropdown to choose where lenient behavior ends."]                       =
    "С помощью выпадающего списка выберите, где заканчивается мягкое поведение.",
    ["Items below the selected forge tier can equip even if already seen."]           =
    "Предметы ниже выбранного уровня forge можно надеть, даже если они уже встречались.",
    ["At the selected tier and above, the addon prefers truly new affixes."]          =
    "На выбранном уровне и выше аддон предпочитает действительно новые аффиксы.",
    ["If a variant is already attuned, only higher forge tiers can still auto-equip."] =
    "Если вариант уже Attuned, только более высокие уровни forge могут автоматически надеваться.",
    ["Example: with 'Warforged', duplicate Warforged is blocked, but Lightforged can still equip."] =
    "Пример: при 'Warforged' дубликат WF блокируется, но LF всё ещё может быть надет.",
    ["Below this tier: lenient equip behavior."]                                      = "Ниже этого уровня: мягкое поведение надевания.",
    ["At this tier and above: strict new-affix behavior."]                            = "На этом уровне и выше: строгое поведение новых аффиксов.",
    ["When a variant already exists, only higher forge tiers can override."]          =
    "Когда вариант уже существует, перезаписать его могут только более высокие уровни forge.",
    ["'All Items' applies strict behavior to every forge tier."]                      =
    "'All Items' применяет строгое поведение ко всем уровням forge.",
    ["Use the dropdown to set the highest forge tier that ignores attunement history (inclusive)."] =
    "С помощью выпадающего списка задайте наивысший уровень forge, игнорирующий историю Attunement (включительно).",
    ["Example: 'Warforged' allows Base/Titanforged/Warforged to equip even if already seen; Lightforged still requires a new affix or no prior variant."] =
    "Пример: 'Warforged' позволяет надевать Base/TF/WF даже если они уже встречались; LF всё ещё требует нового аффикса или отсутствия предыдущего варианта.",
    ["'All Items' removes this forge-tier limit while keeping the strict new-affix preference."] =
    "'All Items' убирает это ограничение по уровню forge, сохраняя строгое предпочтение новых аффиксов.",
    ["Select the highest forge tier that can equip regardless of prior attunement history."] =
    "Выберите наивысший уровень forge, который можно надеть независимо от истории Attunement.",
    ["This applies only while the checkbox is enabled."]                              =
    "Применяется только пока флажок включён.",
    ["Tiers above your selected value still require a truly new affix (or no variant attuned yet)."] =
    "Уровни выше выбранного значения по-прежнему требуют действительно новый аффикс (или отсутствие Attuned варианта).",
    ["'All Items' removes the forge-tier cap."]                                       = "'All Items' убирает ограничение по уровню forge.",
    ["- Selected tier and up: unattuned variant only."]                               = "- С выбранного уровня и выше: только не Attuned вариант.",
    ["- Does not check extra affix unlocks."]                                         = "- Не проверяет дополнительные разблокировки аффиксов.",
    ["- Base and TF - Equips all if Affix is attunable."]                             = "- Base и TF — надевает всё, если аффикс Attunable.",
    ["Hide Center Button in Normal Mode"]                                             = "Скрывать центральную кнопку в обычном режиме",
    ["Hides the center action button in normal view."]                                = "Скрывает центральную кнопку действия в обычном виде.",
    ["Hold Ctrl to show Open Settings and Update AHSet."]                             =
    "Удерживайте Ctrl, чтобы показать 'Открыть настройки' и 'Обновить AHSet'.",
    ["Sell Attuned Mythic Gear?"]                                                     = "Продавать мифическое снаряжение Attuned?",
    ["Auto Equip Attunables Automaticly"]                                             = "Автоматически надевать Attunables",
    ["Do Not Sell BoE Items"]                                                         = "Не продавать предметы BoE",
    ["Do Not Sell Grey And White Items"]                                              = "Не продавать серые и белые предметы",
    ["Limit Selling to 12 Items?"]                                                    = "Ограничить продажу 12 предметами?",
    ["Disable Auto-Equip Mythic BoE"]                                                 = "Отключить автонадевание мифических BoE",
    ["Equip BoE Bountied Items"]                                                      = "Надевать BoE-предметы награды",
    ["Prioritize Low iLvl for Auto-Equip"]                                            = "Приоритизировать низкий iLvl для автонадевания",
    ["Enable Vendor Sell Confirmation Dialog"]                                        = "Включить подтверждение продажи у торговца",
    ["Vendor preview on Right (Default On)"]                                          = "Предпросмотр продажи справа (по умолчанию включён)",
    ["Draggable by Right Click"]                                                      = "Перетаскивание правым кликом",
    ["Lock AH in Place (Buttons Only Mouse)"]                                         = "Зафиксировать AH (кнопки только мышью)",
    ["Use Bag 1 for Disenchant"]                                                      = "Использовать сумку 1 для распыления",
    ["This setting is recommended to be off due to the fact that disenchanting Mythic Gear results in honor and arena points."] =
    "Рекомендуется держать эту настройку выключенной, поскольку распыление мифического снаряжения даёт честь и очки арены.",
    ["With this setting off, it will not vendor non-BoP white/grey items if the item can be attuned."] =
    "При выключенной настройке не будет продавать белые/серые не-BoP предметы, если предмет может быть Attuned.",
    ["Quick rules:"]                                                                  = "Краткие правила:",
    ["- Below selected tier: lenient."]                                               = "- Ниже выбранного уровня: мягкий режим.",
    ["- Existing variant: only higher tier can equip."]                               = "- Существующий вариант: надеваться может только более высокий уровень.",
    ["Example (Warforged):"]                                                          = "Пример (Warforged):",
    ["- Warforged duplicate: blocked. (Max 1)"]                                       = "- Дубликат Warforged: заблокирован. (Макс. 1)",
    ["- Lightforged: can still equip. (Max 1)"]                                       = "- Lightforged: всё ещё можно надеть. (Макс. 1)",
    ["- 'All Items': strict at all tiers."]                                           = "- 'All Items': строгий режим на всех уровнях.",
    ["Drag an item here to assign its slot in AHSet."]                                = "Перетащите предмет сюда, чтобы назначить ему слот в AHSet.",
    ["Empty slot — drag an item here, Set AHSet, or /ahset."]                         = "Пустой слот: перетащите сюда предмет, используйте Set AHSet или /ahset.",
    ["Drag an item and left-click to add it to AHIgnore."]                            = "Перетащите предмет и щёлкните левой кнопкой, чтобы добавить его в AHIgnore.",
    ["Right-click to remove from this preset."]                                        = "Щёлкните правой кнопкой, чтобы удалить из этого пресета.",
    ["Item ID %s"]                                                                     = "ID предмета %s",
    ["Enter a name for the new AHSet preset:"]                                         = "Введите имя для нового пресета AHSet:",
    ["A preset with that name already exists."]                                        = "Пресет с таким именем уже существует.",
    ["Invalid preset name."]                                                           = "Недопустимое имя пресета.",
    ["Delete AHSet preset \"%s\"?"]                                                    = "Удалить пресет AHSet \"%s\"?",
    ["List Management"]                                                                = "Управление списками",
    ["AHSet is stored per character (GUID). Presets swap the saved item-to-slot map. AHIgnore / Always Vendored are account-wide."] =
    "AHSet хранится отдельно для каждого персонажа (GUID). Пресеты переключают сохранённую привязку предметов к слотам. AHIgnore / Always Vendored общие для аккаунта.",
    ["AHSet preset"]                                                                   = "Пресет AHSet",
    ["New"]                                                                            = "Новый",
    ["Delete"]                                                                         = "Удалить",
    ["Set AHSet"]                                                                      = "Set AHSet",
    ["Set AHSet (/ahsetall)"]                                                          = "Set AHSet (/ahsetall)",
    ["After confirmation, copies your equipped items into this preset."]               = "После подтверждения копирует надетые предметы в этот пресет.",
    ["Option control arrays initialized"]                                              = "Массивы контролов опций инициализированы",
    ["Options panels initialized successfully"]                                        = "Панели опций успешно инициализированы",
    ["'%s' added to AHSet, designated for slot %s."]                                   = "'%s' добавлен в AHSet, назначен на слот %s.",
    ["'%s' (ID: %s) added to AHSet, designated for slot %s."]                          = "'%s' (ID: %s) добавлен в AHSet, назначен на слот %s.",
}

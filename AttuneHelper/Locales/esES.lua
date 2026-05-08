-- ʕ •ᴥ•ʔ✿ Locale (Spanish) ✿ ʕ •ᴥ•ʔ
local AH_LOCALES = _G.AH_LOCALES or {}
_G.AH_LOCALES = AH_LOCALES

AH_LOCALES["esES"] = {
    ["Equip Attunables"]                                                              = "Equipar Attunables",
    ["Prepare Disenchant"]                                                            = "Preparar desencantar",
    ["Vendor Attuned"]                                                                = "Vender Attuned",
    ["Vendor Attuned Items"]                                                          = "Vender objetos Attuned",
    ["Add To Vendor"]                                                                 = "Añadir a la lista de venta",
    ["System Default"]                                                                = "Predeterminado del sistema",
    ["English (US)"]                                                                  = "English (US)",
    ["Español"]                                                                       = "Español",
    ["Deutsch"]                                                                       = "Deutsch",
    ["Select Language:"]                                                              = "Seleccionar idioma:",
    ["Moves fully attuned mythic items to bag %d."]                                   = "Mueve los objetos míticos totalmente attuned a la bolsa %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]              =
    "Vacía primero la bolsa de destino y luego la rellena con objetos listos para desencantar.",
    ["Attunable Items: %d"]                                                           = "Objetos Attunable: %d",
    ["Qualifying Attunables (%d):"]                                                   = "Attunables que cumplen los requisitos (%d):",
    ["No qualifying attunables in bags."]                                             = "No hay Attunables que cumplan los requisitos en las bolsas.",
    ["Items to be sold (%d):"]                                                        = "Objetos a vender (%d):",
    ["Always-vendor entries: %d"]                                                     = "Entradas de Always-Vendor: %d",
    ["No items will be sold based on current settings."]                              = "No se venderán objetos según la configuración actual.",
    ["Open merchant window to sell these items."]                                     = "Abre la ventana del comerciante para vender estos objetos.",
    ["Drag an item here or pick it up and click to toggle always-vendor."]            = "Arrastra un objeto aquí o cógelo y haz clic para activar/desactivar Always-Vendor.",
    ["Items added here are always included in AH vendor previews and selling."]       = "Los objetos añadidos aquí siempre se incluyen en las vistas previas y en la venta de AH.",
    ["Hold left 1s on this button for bulk add mode (cursor items add-only)."]        = "Mantén pulsado el clic izquierdo 1 s en este botón para el modo de añadido masivo (los objetos del cursor solo se añaden).",
    ["Bulk mode: click this button again or close the vendor to exit."]               = "Modo masivo: haz clic en este botón otra vez o cierra el comerciante para salir.",
    ["Bulk add mode is ON."]                                                          = "El modo de añadido masivo está ACTIVADO.",
    ["Always-vendor skipped for Warforged/Lightforged (see options)."]                = "Always-Vendor omitido para WF/LF (consulta las opciones).",
    ["Ignore Always-Vendor for Warforged and Lightforged"]                            = "Ignorar Always-Vendor para Warforged y Lightforged",
    ["When enabled, Warforged and Lightforged variants cannot be added to the always-vendor list and do not use the always-vendor bypass when selling."] =
    "Cuando se activa, las variantes Warforged y Lightforged no pueden añadirse a la lista Always-Vendor y no usan la excepción de Always-Vendor al vender.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."]     =
    "Los objetos deben ser: míticos, 100%% attuned, ligados, y no estar en conjuntos/listas ignoradas.",
    ["Prepare Disenchant Include BoE Mythic Weapons"]                                  =
    "Preparar desencantar: armas míticas BoE (nivel de objeto 245)",
    ["Update AHSet"]                                                                  = "Actualizar AHSet",
    ["Sets AHSet to be equal to your currently equiped items."]                       =
    "Define AHSet igual a tus objetos equipados actualmente.",
    ["This will delete your current AHSet."]                                          = "Esto borrará tu AHSet actual.",
    ["Are you sure you want to update AHSet to match your currently equipped items?"] =
    "¿Seguro que quieres actualizar AHSet para que coincida con tus objetos equipados actualmente?",
    ["AHSet 1H pre-swap for off-hand attune"] =
    "AHSet: cambio previo de 1H para Attune de mano secundaria (multiclase Guerrero)",
    ["AHSet 1h2h swap"] = "Multiclase Guerrero · cambio 1H / 2H",
    ["AHSet 1h2h swap tip line 1"] =
    "En multiclase estilo Chromie, tu clase de UI a menudo no es Guerrero aunque juegues como uno. Con esta opción activada y la marca de cambio del preset puesta, Equip All puede sustituir un arma a 2H en mano principal por tu Una Mano de AHSet para que un Attunable de mano secundaria pueda equiparse.",
    ["AHSet 1h2h swap tip line 2"] = "Necesitas una 2H en la mano principal que no esté Attuning activamente, un Attunable de mano secundaria en las bolsas y una 1H en las bolsas asignada a Main Hand o a la fila '1H Weapon Swaps' en Gestión de listas.",
    ["AHSet 1h2h swap tip line 3"] = "Titan's Grip se juega con un arma a 2H en la mano principal y otra 2H de TG o un hacha de una mano en la mano secundaria (por ejemplo, un build de Furia tipo flurry); ese es tu par de armas real, no las filas '1H Weapon Swaps' / prep. Equip All normalmente omite este cambio 2H→Una Mano principal mientras se detecta TG, para que el trabajo en bolsas pueda usar tu mano secundaria. Excepción: las una mano de solo mano principal no pueden equiparse en mano secundaria, así que ese cambio puede ejecutarse igualmente. La marca de cambio se activa cuando la mano principal apunta a un arma a 2H y asignas una una mano a Main Hand o a la fila '1H Weapon Swaps'; /ahset 1hspecial2h aún puede forzarla antes de que existan.",
    ["AHSet 1h2h swap tip line 4"] = "La detección de mano secundaria es estricta cuando este preset asigna algo a Off Hand o al cuadro de prep de mano secundaria (las una mano ambiguas requieren /ahset … oh). En caso contrario es flexible.",
    ["AHSet 1h2h swap tip line 5"] = "/ahset 1hspecial2h remove borra la marca opcional de forzado; 'Set AHSet' borra todo el preset.",
    ["Off-hand swap trigger"] = "Disparador de cambio de mano secundaria",
    ["AHSet OH trigger strict"] = "Solo AHSet / mano secundaria nativa (estricto)",
    ["AHSet OH trigger loose"] = "Cualquier 1H apta para mano secundaria (flexible)",
    ["AHSet OH trigger strict tip"] =
    "Estricto: escudos, sostenibles y armas de mano secundaria siempre cuentan. Las una mano ambiguas solo cuentan si las has asignado con /ahset <link> oh (mano secundaria de AHSet).",
    ["AHSet OH trigger loose tip"] =
    "Flexible: cualquier una mano Attunable en las bolsas cuenta como motivo para cambiar, incluso sin asignación de mano secundaria de AHSet (puede cambiar más a menudo).",
    ["AHSet 1h2h preset button title"] = "Cambio 1H/2H multiclase Guerrero (preset)",
    ["AHSet 1h2h preset tip line 1"] =
    "Activa/desactiva la marca de cambio del preset (igual que /ahset 1hspecial2h). No es un interruptor genérico: existe porque los Guerreros multiclase suelen llevar un perfil principal a 2H mientras los objetos de mano secundaria aún necesitan Attuning.",
    ["AHSet 1h2h preset tip line 2"] = "Equip All solo realiza el cambio cuando esta marca está Activada, la casilla de arriba está habilitada y se cumplen las demás condiciones del tooltip.",
    ["AHSet 1h2h preset tip line 3"] = "Haz clic de nuevo para Desactivar y eliminar la marca solo de este preset.",
    ["MC 1h2h: On"] = "MC 1h2h: Activado",
    ["MC 1h2h: Off"] = "MC 1h2h: Desactivado",
    ["AHSet 1h2h list title"] = "MC Guerrero · 1H/2H (este preset)",
    ["AHSet prep paper strip label"] = "1H Weapon Swaps",
    ["AHSet prep paper strip drag hint"] = "Preparar armas",
    ["AHSet prep MH slot label"] = "1H · fila de mano principal",
    ["AHSet prep OH slot label"] = "Fila de mano secundaria",
    ["AHSet prep slot empty slash hint"] = "'Set AHSet', /ahset prepmh, /ahset prep1h o /ahset prepoh también funcionan.",
    ["AHSet keep item in bags for instance signature"] =
    "Mantén el objeto en las bolsas al añadirlo a AHSet para que se pueda guardar su firma única. Si solo tienes una copia, el enlace del objeto equipado puede no bastar.",
    ["AHSet usage signature reminder"] =
    "Objetos únicos: ponlos en las bolsas antes de /ahset para que se puedan guardar las firmas de instancia cuando Custom_GetItemGuid esté disponible.",
    ["AHSet 2h swap strip explanation"] =
    "Aquí no hay un interruptor aparte: Equip All usa tus asignaciones de armas en este preset. Asigna una una mano a Main Hand o a los cuadros de abajo cuando la mano principal del preset sea un arma a 2H.",
    ["AHSet auto status swap on"] = "Ruta de cambio prep 1H: activa para este preset.",
    ["AHSet auto status swap off"] = "Ruta de cambio prep 1H: inactiva (asigna una una mano a Main Hand o a los cuadros de abajo, o usa /ahset 1hspecial2h para forzarla).",
    ["AHSet auto status oh fmt"] = "Detección de Attunable de mano secundaria: %s.",
    ["AHSet OH trigger strict short"] = "estricto",
    ["AHSet OH trigger loose short"] = "flexible",
    ["Weapon panel multiclass header"] = "Multiclase Guerrero · cambio AHSet",
    ["Weapon panel TG detection note"] = "Titan's Grip se detecta a partir de tus talentos (incluyendo pestañas de talentos multiclase tipo Chromie). La lógica de doble 2H en bolsas/equipo solo se aplica a hachas, mazas y espadas a dos manos, no a bastones ni armas de asta.",
    ["AHSet 2h swap section title"] = "1H Weapon Swaps",
    ["AHSet 1h2h preset row label"] = "Cambio 1H/2H en este preset",
    ["AHSet swap flag on"] = "Activado",
    ["AHSet swap flag off"] = "Desactivado",
    ["Yes"]                                                                           = "Sí",
    ["No"]                                                                            = "No",
    ["Cancel"]                                                                        = "Cancelar",
    ["Toggle Auto-Equip"]                                                             = "Activar/desactivar autoequipar",
    ["Disable Auto-Equip"]                                                            = "Desactivar autoequipar",
    ["Enable Auto-Equip"]                                                             = "Activar autoequipar",
    ["Currently enabled."]                                                            = "Actualmente activado.",
    ["Currently disabled."]                                                           = "Actualmente desactivado.",
    ["Open Settings"]                                                                 = "Abrir ajustes",
    ["Opens the General Logic Options settings page."]                                = "Abre la página de ajustes 'General Logic Options'.",
    ["Hold Shift for additional options"]                                             = "Mantén Mayús para ver más opciones",
    ["Background Color"]                                                              = "Color de fondo",
    ["Equip Attunable Affixes up to:"]                                                = "Equipar afijos Attunable hasta:",
    ["Affix-Only Minimum Forge"]                                                      = "Forge mínima de Affix-Only",
    ["Works only when 'Equip New Affixes Only' is enabled."]                          =
    "Solo funciona cuando 'Equip New Affixes Only' está activado.",
    ["'All Items' disables the forge threshold behavior."]                            =
    "'All Items' desactiva el comportamiento de umbral de forge.",
    ["When enabled, this setting favors affixes you have not attuned yet."]           =
    "Cuando se activa, este ajuste prioriza los afijos que aún no has attuned.",
    ["Use the dropdown to choose where lenient behavior ends."]                       =
    "Usa el desplegable para elegir dónde termina el comportamiento permisivo.",
    ["Items below the selected forge tier can equip even if already seen."]           =
    "Los objetos por debajo del nivel de forge seleccionado pueden equiparse aunque ya se hayan visto.",
    ["At the selected tier and above, the addon prefers truly new affixes."]          =
    "Desde el nivel seleccionado en adelante, el addon prefiere afijos realmente nuevos.",
    ["If a variant is already attuned, only higher forge tiers can still auto-equip."] =
    "Si una variante ya está attuned, solo los niveles de forge superiores pueden autoequiparse.",
    ["Example: with 'Warforged', duplicate Warforged is blocked, but Lightforged can still equip."] =
    "Ejemplo: con 'Warforged', un WF duplicado se bloquea, pero LF aún puede equiparse.",
    ["Below this tier: lenient equip behavior."]                                      = "Por debajo de este nivel: comportamiento de equipado permisivo.",
    ["At this tier and above: strict new-affix behavior."]                            = "En este nivel y superiores: comportamiento estricto de afijos nuevos.",
    ["When a variant already exists, only higher forge tiers can override."]          =
    "Cuando ya existe una variante, solo los niveles de forge superiores pueden sustituirla.",
    ["'All Items' applies strict behavior to every forge tier."]                      =
    "'All Items' aplica el comportamiento estricto a todos los niveles de forge.",
    ["Use the dropdown to set the highest forge tier that ignores attunement history (inclusive)."] =
    "Usa el desplegable para fijar el nivel de forge más alto que ignora el historial de Attunement (incluido).",
    ["Example: 'Warforged' allows Base/Titanforged/Warforged to equip even if already seen; Lightforged still requires a new affix or no prior variant."] =
    "Ejemplo: 'Warforged' permite que Base/TF/WF se equipen aunque ya se hayan visto; LF aún requiere un afijo nuevo o ninguna variante previa.",
    ["'All Items' removes this forge-tier limit while keeping the strict new-affix preference."] =
    "'All Items' elimina este límite de nivel de forge manteniendo la preferencia estricta por afijos nuevos.",
    ["Select the highest forge tier that can equip regardless of prior attunement history."] =
    "Selecciona el nivel de forge más alto que puede equiparse independientemente del historial de Attunement.",
    ["This applies only while the checkbox is enabled."]                              =
    "Esto solo se aplica mientras la casilla esté activada.",
    ["Tiers above your selected value still require a truly new affix (or no variant attuned yet)."] =
    "Los niveles por encima del valor seleccionado siguen requiriendo un afijo realmente nuevo (o ninguna variante attuned aún).",
    ["'All Items' removes the forge-tier cap."]                                       = "'All Items' elimina el límite de nivel de forge.",
    ["- Selected tier and up: unattuned variant only."]                               = "- Desde el nivel seleccionado: solo variante no attuned.",
    ["- Does not check extra affix unlocks."]                                         = "- No comprueba desbloqueos de afijos adicionales.",
    ["- Base and TF - Equips all if Affix is attunable."]                             = "- Base y TF: equipa todo si el afijo es Attunable.",
    ["Hide Center Button in Normal Mode"]                                             = "Ocultar el botón central en modo normal",
    ["Hides the center action button in normal view."]                                = "Oculta el botón de acción central en la vista normal.",
    ["Hold Ctrl to show Open Settings and Update AHSet."]                             =
    "Mantén Ctrl para mostrar 'Abrir ajustes' y 'Actualizar AHSet'.",
    ["Sell Attuned Mythic Gear?"]                                                     = "¿Vender equipo mítico Attuned?",
    ["Auto Equip Attunables Automaticly"]                                             = "Equipar Attunables automáticamente",
    ["Do Not Sell BoE Items"]                                                         = "No vender objetos BoE",
    ["Do Not Sell Grey And White Items"]                                              = "No vender objetos grises ni blancos",
    ["Limit Selling to 12 Items?"]                                                    = "¿Limitar la venta a 12 objetos?",
    ["Disable Auto-Equip Mythic BoE"]                                                 = "Desactivar autoequipar BoE mítico",
    ["Equip BoE Bountied Items"]                                                      = "Equipar objetos BoE de recompensa",
    ["Prioritize Low iLvl for Auto-Equip"]                                            = "Priorizar iLvl bajo para autoequipar",
    ["Enable Vendor Sell Confirmation Dialog"]                                        = "Activar confirmación al vender al comerciante",
    ["Vendor preview on Right (Default On)"]                                          = "Vista previa de venta a la derecha (activado por defecto)",
    ["Draggable by Right Click"]                                                      = "Arrastrable con clic derecho",
    ["Lock AH in Place (Buttons Only Mouse)"]                                         = "Bloquear AH en su lugar (botones solo ratón)",
    ["Use Bag 1 for Disenchant"]                                                      = "Usar la bolsa 1 para desencantar",
    ["This setting is recommended to be off due to the fact that disenchanting Mythic Gear results in honor and arena points."] =
    "Se recomienda mantener esta opción desactivada, ya que desencantar equipo mítico otorga honor y puntos de arena.",
    ["With this setting off, it will not vendor non-BoP white/grey items if the item can be attuned."] =
    "Con esta opción desactivada, no venderá objetos blancos/grises no BoP si el objeto puede Attune.",
    ["Quick rules:"]                                                                  = "Reglas rápidas:",
    ["- Below selected tier: lenient."]                                               = "- Por debajo del nivel seleccionado: permisivo.",
    ["- Existing variant: only higher tier can equip."]                               = "- Variante existente: solo un nivel superior puede equiparse.",
    ["Example (Warforged):"]                                                          = "Ejemplo (Warforged):",
    ["- Warforged duplicate: blocked. (Max 1)"]                                       = "- Warforged duplicado: bloqueado. (Máx. 1)",
    ["- Lightforged: can still equip. (Max 1)"]                                       = "- Lightforged: todavía puede equiparse. (Máx. 1)",
    ["- 'All Items': strict at all tiers."]                                           = "- 'All Items': estricto en todos los niveles.",
    ["Drag an item here to assign its slot in AHSet."]                                = "Arrastra un objeto aquí para asignarle su hueco en AHSet.",
    ["Empty slot — drag an item here, Set AHSet, or /ahset."]                         = "Hueco vacío: arrastra un objeto aquí, usa Set AHSet o /ahset.",
    ["Drag an item and left-click to add it to AHIgnore."]                            = "Arrastra un objeto y haz clic izquierdo para añadirlo a AHIgnore.",
    ["Right-click to remove from this preset."]                                        = "Haz clic derecho para quitarlo de este preset.",
    ["Item ID %s"]                                                                     = "ID del objeto %s",
    ["Enter a name for the new AHSet preset:"]                                         = "Introduce un nombre para el nuevo preset de AHSet:",
    ["A preset with that name already exists."]                                        = "Ya existe un preset con ese nombre.",
    ["Invalid preset name."]                                                           = "Nombre de preset no válido.",
    ["Delete AHSet preset \"%s\"?"]                                                    = "¿Eliminar el preset de AHSet \"%s\"?",
    ["List Management"]                                                                = "Gestión de listas",
    ["AHSet is stored per character (GUID). Presets swap the saved item-to-slot map. AHIgnore / Always Vendored are account-wide."] =
    "AHSet se guarda por personaje (GUID). Los presets cambian el mapa guardado de objeto a hueco. AHIgnore / Always Vendored son de cuenta.",
    ["AHSet preset"]                                                                   = "Preset de AHSet",
    ["New"]                                                                            = "Nuevo",
    ["Delete"]                                                                         = "Eliminar",
    ["Set AHSet"]                                                                      = "Set AHSet",
    ["Set AHSet (/ahsetall)"]                                                          = "Set AHSet (/ahsetall)",
    ["After confirmation, copies your equipped items into this preset."]               = "Tras confirmar, copia tus objetos equipados a este preset.",
    ["Option control arrays initialized"]                                              = "Matrices de controles de opciones inicializadas",
    ["Options panels initialized successfully"]                                        = "Paneles de opciones inicializados correctamente",
    ["'%s' added to AHSet, designated for slot %s."]                                   = "'%s' añadido a AHSet, asignado al hueco %s.",
    ["'%s' (ID: %s) added to AHSet, designated for slot %s."]                          = "'%s' (ID: %s) añadido a AHSet, asignado al hueco %s.",
}

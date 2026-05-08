-- ʕ •ᴥ•ʔ✿ Locale (German) ✿ ʕ •ᴥ•ʔ
local AH_LOCALES = _G.AH_LOCALES or {}
_G.AH_LOCALES = AH_LOCALES

AH_LOCALES["deDE"] = {
    ["Equip Attunables"]                                                              = "Attunables anlegen",
    ["Prepare Disenchant"]                                                            = "Entzaubern vorbereiten",
    ["Vendor Attuned"]                                                                = "Attuned verkaufen",
    ["Vendor Attuned Items"]                                                          = "Attuned Gegenstände verkaufen",
    ["Add To Vendor"]                                                                 = "Zur Verkaufsliste hinzufügen",
    ["System Default"]                                                                = "Systemstandard",
    ["English (US)"]                                                                  = "English (US)",
    ["Español"]                                                                       = "Español",
    ["Deutsch"]                                                                       = "Deutsch",
    ["Select Language:"]                                                              = "Sprache wählen:",
    ["Moves fully attuned mythic items to bag %d."]                                   = "Verschiebt vollständig attuned mythische Gegenstände in Tasche %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]              =
    "Leert zuerst die Zieltasche und füllt sie dann mit zum Entzaubern bereiten Gegenständen.",
    ["Attunable Items: %d"]                                                           = "Attunable Gegenstände: %d",
    ["Qualifying Attunables (%d):"]                                                   = "Geeignete Attunables (%d):",
    ["No qualifying attunables in bags."]                                             = "Keine geeigneten Attunables in den Taschen.",
    ["Items to be sold (%d):"]                                                        = "Zu verkaufende Gegenstände (%d):",
    ["Always-vendor entries: %d"]                                                     = "Always-Vendor Einträge: %d",
    ["No items will be sold based on current settings."]                              = "Mit den aktuellen Einstellungen werden keine Gegenstände verkauft.",
    ["Open merchant window to sell these items."]                                     = "Öffne das Händlerfenster, um diese Gegenstände zu verkaufen.",
    ["Drag an item here or pick it up and click to toggle always-vendor."]            = "Ziehe einen Gegenstand hierher oder nimm ihn auf und klicke, um Always-Vendor umzuschalten.",
    ["Items added here are always included in AH vendor previews and selling."]       = "Hier hinzugefügte Gegenstände werden immer in AH-Verkaufsvorschauen und beim Verkauf berücksichtigt.",
    ["Hold left 1s on this button for bulk add mode (cursor items add-only)."]        = "Halte die linke Maustaste 1 Sek. auf diesem Button für den Massen-Hinzufügen-Modus (nur Hinzufügen mit Cursor-Gegenständen).",
    ["Bulk mode: click this button again or close the vendor to exit."]               = "Massenmodus: klicke erneut auf diesen Button oder schließe den Händler, um zu beenden.",
    ["Bulk add mode is ON."]                                                          = "Massen-Hinzufügen-Modus ist AN.",
    ["Always-vendor skipped for Warforged/Lightforged (see options)."]                = "Always-Vendor für Warforged/Lightforged übersprungen (siehe Optionen).",
    ["Ignore Always-Vendor for Warforged and Lightforged"]                            = "Always-Vendor für Warforged und Lightforged ignorieren",
    ["When enabled, Warforged and Lightforged variants cannot be added to the always-vendor list and do not use the always-vendor bypass when selling."] =
    "Wenn aktiviert, können Warforged- und Lightforged-Varianten nicht zur Always-Vendor-Liste hinzugefügt werden und nutzen beim Verkauf nicht die Always-Vendor-Umgehung.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."]     =
    "Gegenstände müssen sein: mythisch, 100%% attuned, seelengebunden, nicht in Sets/Ignorierlisten.",
    ["Prepare Disenchant Include BoE Mythic Weapons"]                                  =
    "Entzaubern vorbereiten: BoE mythische Waffen (Gegenstandsstufe 245)",
    ["Update AHSet"]                                                                  = "AHSet aktualisieren",
    ["Sets AHSet to be equal to your currently equiped items."]                       =
    "Setzt AHSet auf deine aktuell angelegten Gegenstände.",
    ["This will delete your current AHSet."]                                          = "Dies löscht dein aktuelles AHSet.",
    ["Are you sure you want to update AHSet to match your currently equipped items?"] =
    "Möchtest du AHSet wirklich auf deine aktuell angelegten Gegenstände aktualisieren?",
    ["AHSet 1H pre-swap for off-hand attune"] =
    "AHSet: 1H Vorab-Wechsel für Off-Hand Attune (Krieger-Multiclass)",
    ["AHSet 1h2h swap"] = "Krieger-Multiclass · 1H / 2H Wechsel",
    ["AHSet 1h2h swap tip line 1"] =
    "Beim Chromie-Multiclass-Spiel ist deine UI-Klasse oft nicht Krieger, auch wenn du wie einer spielst. Mit dieser Option und gesetztem Preset-Flag kann Equip All eine 2H-Hauptwaffe durch deinen AHSet-Einhänder ersetzen, damit ein Off-Hand Attunable angelegt werden kann.",
    ["AHSet 1h2h swap tip line 2"] = "Du brauchst eine 2H in der Haupthand, die nicht aktiv attuned, ein Off-Hand Attunable in den Taschen und einen 1H in den Taschen, der auf Main Hand oder die Reihe '1H Weapon Swaps' in der Listenverwaltung verweist.",
    ["AHSet 1h2h swap tip line 3"] = "Titan's Grip wird mit einem Zweihänder in der Haupthand und entweder einem weiteren TG-Zweihänder oder einer Einhandaxt in der Off-Hand gespielt (z. B. ein Furor-Build) – das ist dein eigentliches Waffenpaar, nicht die '1H Weapon Swaps' / Prep-Reihen. Equip All überspringt diesen 2H→Einhänder-Hauptwechsel normalerweise, solange TG erkannt wird, damit das Taschenmanagement deine Off-Hand nutzen kann. Ausnahme: nur-Haupthand-Einhänder können nicht in die Off-Hand, daher kann der Wechsel trotzdem ausgeführt werden. Das Wechsel-Flag wird gesetzt, wenn die Haupthand auf einen Zweihänder verweist und du einen Einhänder auf Main Hand oder die '1H Weapon Swaps'-Reihe legst; /ahset 1hspecial2h kann es davor manuell erzwingen.",
    ["AHSet 1h2h swap tip line 4"] = "Off-Hand-Erkennung ist strikt, wenn dieses Preset etwas auf Off Hand oder das Prep-Off-Hand-Feld legt (mehrdeutige Einhänder benötigen /ahset … oh). Andernfalls ist sie locker.",
    ["AHSet 1h2h swap tip line 5"] = "/ahset 1hspecial2h remove löscht das optionale Force-Flag; 'Set AHSet' überschreibt das gesamte Preset.",
    ["Off-hand swap trigger"] = "Off-Hand Wechsel-Auslöser",
    ["AHSet OH trigger strict"] = "Nur AHSet / native Off-Hand (strikt)",
    ["AHSet OH trigger loose"] = "Jeder Off-Hand-fähige 1H (locker)",
    ["AHSet OH trigger strict tip"] =
    "Strikt: Schilde, Anhängsel und Off-Hand-Waffen zählen immer. Mehrdeutige Einhänder zählen nur, wenn du sie mit /ahset <link> oh (AHSet Off-Hand) zugewiesen hast.",
    ["AHSet OH trigger loose tip"] =
    "Locker: jeder Attunable-Einhänder in den Taschen zählt als Grund für einen Wechsel, auch ohne AHSet Off-Hand-Zuordnung (kann öfter wechseln).",
    ["AHSet 1h2h preset button title"] = "Krieger-Multiclass 1H/2H Wechsel (Preset)",
    ["AHSet 1h2h preset tip line 1"] =
    "Schaltet das Preset-Wechsel-Flag um (entspricht /ahset 1hspecial2h). Dies ist kein generischer Schalter: es existiert, weil Multiclass-Krieger oft ein 2H-Hauptprofil führen, während Off-Hand-Gegenstände noch attuned werden müssen.",
    ["AHSet 1h2h preset tip line 2"] = "Equip All führt den Wechsel nur durch, wenn dieses Flag An ist, die Checkbox darüber aktiviert ist und die übrigen Bedingungen aus dem Tooltip erfüllt sind.",
    ["AHSet 1h2h preset tip line 3"] = "Erneut klicken, um auf Aus zu stellen und das Flag nur in diesem Preset zu entfernen.",
    ["MC 1h2h: On"] = "MC 1h2h: An",
    ["MC 1h2h: Off"] = "MC 1h2h: Aus",
    ["AHSet 1h2h list title"] = "Krieger MC · 1H/2H (dieses Preset)",
    ["AHSet prep paper strip label"] = "1H Weapon Swaps",
    ["AHSet prep paper strip drag hint"] = "Waffen vorbereiten",
    ["AHSet prep MH slot label"] = "1H · Haupthand-Reihe",
    ["AHSet prep OH slot label"] = "Off-Hand-Reihe",
    ["AHSet prep slot empty slash hint"] = "'Set AHSet', /ahset prepmh, /ahset prep1h oder /ahset prepoh funktionieren ebenfalls.",
    ["AHSet keep item in bags for instance signature"] =
    "Lasse den Gegenstand beim Hinzufügen zu AHSet in deinen Taschen, damit seine eindeutige Signatur gespeichert werden kann. Bei nur einer Kopie reicht ein angelegter Link allein eventuell nicht aus.",
    ["AHSet usage signature reminder"] =
    "Einzigartige Gegenstände: lege sie vor /ahset in deine Taschen, damit Instanz-Signaturen gespeichert werden können, sofern Custom_GetItemGuid verfügbar ist.",
    ["AHSet 2h swap strip explanation"] =
    "Hier ist nichts ein eigener Schalter: Equip All nutzt deine Waffenzuordnungen in diesem Preset. Lege einen Einhänder auf Main Hand oder die Felder unten, wenn die Preset-Haupthand ein Zweihänder ist.",
    ["AHSet auto status swap on"] = "1H Prep-Wechselpfad: aktiv für dieses Preset.",
    ["AHSet auto status swap off"] = "1H Prep-Wechselpfad: inaktiv (lege einen Einhänder auf Main Hand oder die Felder unten, oder erzwinge mit /ahset 1hspecial2h).",
    ["AHSet auto status oh fmt"] = "Off-Hand Attunable-Erkennung: %s.",
    ["AHSet OH trigger strict short"] = "strikt",
    ["AHSet OH trigger loose short"] = "locker",
    ["Weapon panel multiclass header"] = "Krieger-Multiclass · AHSet Wechsel",
    ["Weapon panel TG detection note"] = "Titan's Grip wird anhand deiner Talente erkannt (einschließlich Chromie-Multiclass-Talentbäume). Die Logik für duale 2H in Taschen/Ausrüstung gilt nur für zweihändige Äxte, Streitkolben und Schwerter – nicht für Stäbe oder Stangenwaffen.",
    ["AHSet 2h swap section title"] = "1H Weapon Swaps",
    ["AHSet 1h2h preset row label"] = "1H/2H Wechsel in diesem Preset",
    ["AHSet swap flag on"] = "An",
    ["AHSet swap flag off"] = "Aus",
    ["Yes"]                                                                           = "Ja",
    ["No"]                                                                            = "Nein",
    ["Cancel"]                                                                        = "Abbrechen",
    ["Toggle Auto-Equip"]                                                             = "Auto-Anlegen umschalten",
    ["Disable Auto-Equip"]                                                            = "Auto-Anlegen deaktivieren",
    ["Enable Auto-Equip"]                                                             = "Auto-Anlegen aktivieren",
    ["Currently enabled."]                                                            = "Derzeit aktiviert.",
    ["Currently disabled."]                                                           = "Derzeit deaktiviert.",
    ["Open Settings"]                                                                 = "Einstellungen öffnen",
    ["Opens the General Logic Options settings page."]                                = "Öffnet die Einstellungsseite 'General Logic Options'.",
    ["Hold Shift for additional options"]                                             = "Halte Umschalt für zusätzliche Optionen",
    ["Background Color"]                                                              = "Hintergrundfarbe",
    ["Equip Attunable Affixes up to:"]                                                = "Attunable Affixe anlegen bis:",
    ["Affix-Only Minimum Forge"]                                                      = "Affix-Only Mindest-Forge",
    ["Works only when 'Equip New Affixes Only' is enabled."]                          =
    "Funktioniert nur, wenn 'Equip New Affixes Only' aktiviert ist.",
    ["'All Items' disables the forge threshold behavior."]                            =
    "'All Items' deaktiviert das Forge-Schwellenwertverhalten.",
    ["When enabled, this setting favors affixes you have not attuned yet."]           =
    "Wenn aktiviert, bevorzugt diese Einstellung Affixe, die du noch nicht attuned hast.",
    ["Use the dropdown to choose where lenient behavior ends."]                       =
    "Wähle im Dropdown, wo das nachsichtige Verhalten endet.",
    ["Items below the selected forge tier can equip even if already seen."]           =
    "Gegenstände unterhalb der gewählten Forge-Stufe können angelegt werden, auch wenn bereits gesehen.",
    ["At the selected tier and above, the addon prefers truly new affixes."]          =
    "Ab der gewählten Stufe bevorzugt das Addon wirklich neue Affixe.",
    ["If a variant is already attuned, only higher forge tiers can still auto-equip."] =
    "Ist eine Variante bereits attuned, können nur höhere Forge-Stufen noch automatisch angelegt werden.",
    ["Example: with 'Warforged', duplicate Warforged is blocked, but Lightforged can still equip."] =
    "Beispiel: mit 'Warforged' wird ein doppeltes WF blockiert, aber LF kann weiterhin angelegt werden.",
    ["Below this tier: lenient equip behavior."]                                      = "Unter dieser Stufe: nachsichtiges Anlege-Verhalten.",
    ["At this tier and above: strict new-affix behavior."]                            = "Ab dieser Stufe: striktes 'neue Affixe'-Verhalten.",
    ["When a variant already exists, only higher forge tiers can override."]          =
    "Existiert bereits eine Variante, können nur höhere Forge-Stufen sie überschreiben.",
    ["'All Items' applies strict behavior to every forge tier."]                      =
    "'All Items' wendet striktes Verhalten auf jede Forge-Stufe an.",
    ["Use the dropdown to set the highest forge tier that ignores attunement history (inclusive)."] =
    "Wähle im Dropdown die höchste Forge-Stufe, die den Attunement-Verlauf ignoriert (einschließlich).",
    ["Example: 'Warforged' allows Base/Titanforged/Warforged to equip even if already seen; Lightforged still requires a new affix or no prior variant."] =
    "Beispiel: 'Warforged' erlaubt Base/TF/WF auch dann anzulegen, wenn bereits gesehen; LF benötigt weiterhin einen neuen Affix oder keine vorherige Variante.",
    ["'All Items' removes this forge-tier limit while keeping the strict new-affix preference."] =
    "'All Items' entfernt diese Forge-Stufen-Grenze und behält die strikte 'neue Affixe'-Präferenz bei.",
    ["Select the highest forge tier that can equip regardless of prior attunement history."] =
    "Wähle die höchste Forge-Stufe, die unabhängig vom Attunement-Verlauf angelegt werden kann.",
    ["This applies only while the checkbox is enabled."]                              =
    "Dies gilt nur, solange die Checkbox aktiviert ist.",
    ["Tiers above your selected value still require a truly new affix (or no variant attuned yet)."] =
    "Stufen über deinem gewählten Wert benötigen weiterhin einen wirklich neuen Affix (oder noch keine attuned Variante).",
    ["'All Items' removes the forge-tier cap."]                                       = "'All Items' entfernt die Forge-Stufen-Grenze.",
    ["- Selected tier and up: unattuned variant only."]                               = "- Ab gewählter Stufe: nur nicht attuned Variante.",
    ["- Does not check extra affix unlocks."]                                         = "- Prüft keine zusätzlichen Affix-Freischaltungen.",
    ["- Base and TF - Equips all if Affix is attunable."]                             = "- Base und TF – legt alle an, wenn der Affix attunable ist.",
    ["Hide Center Button in Normal Mode"]                                             = "Mittleren Button im Normalmodus ausblenden",
    ["Hides the center action button in normal view."]                                = "Blendet den mittleren Aktionsbutton in der Normalansicht aus.",
    ["Hold Ctrl to show Open Settings and Update AHSet."]                             =
    "Halte Strg, um 'Einstellungen öffnen' und 'AHSet aktualisieren' anzuzeigen.",
    ["Sell Attuned Mythic Gear?"]                                                     = "Attuned mythische Ausrüstung verkaufen?",
    ["Auto Equip Attunables Automaticly"]                                             = "Attunables automatisch anlegen",
    ["Do Not Sell BoE Items"]                                                         = "BoE-Gegenstände nicht verkaufen",
    ["Do Not Sell Grey And White Items"]                                              = "Graue und weiße Gegenstände nicht verkaufen",
    ["Limit Selling to 12 Items?"]                                                    = "Verkauf auf 12 Gegenstände begrenzen?",
    ["Disable Auto-Equip Mythic BoE"]                                                 = "Auto-Anlegen für mythische BoE deaktivieren",
    ["Equip BoE Bountied Items"]                                                      = "BoE-Bounty-Gegenstände anlegen",
    ["Prioritize Low iLvl for Auto-Equip"]                                            = "Niedrige iLvl für Auto-Anlegen bevorzugen",
    ["Enable Vendor Sell Confirmation Dialog"]                                        = "Verkaufsbestätigung beim Händler aktivieren",
    ["Vendor preview on Right (Default On)"]                                          = "Verkaufsvorschau rechts (standardmäßig an)",
    ["Draggable by Right Click"]                                                      = "Per Rechtsklick verschiebbar",
    ["Lock AH in Place (Buttons Only Mouse)"]                                         = "AH fixieren (Buttons nur per Maus)",
    ["Use Bag 1 for Disenchant"]                                                      = "Tasche 1 für Entzaubern verwenden",
    ["This setting is recommended to be off due to the fact that disenchanting Mythic Gear results in honor and arena points."] =
    "Diese Einstellung sollte ausgeschaltet bleiben, da Entzaubern von mythischer Ausrüstung Ehre und Arenapunkte gibt.",
    ["With this setting off, it will not vendor non-BoP white/grey items if the item can be attuned."] =
    "Wenn diese Einstellung aus ist, werden nicht-BoP weiße/graue Gegenstände nicht verkauft, falls sie attuned werden können.",
    ["Quick rules:"]                                                                  = "Kurzregeln:",
    ["- Below selected tier: lenient."]                                               = "- Unter der gewählten Stufe: nachsichtig.",
    ["- Existing variant: only higher tier can equip."]                               = "- Vorhandene Variante: nur höhere Stufen können anlegen.",
    ["Example (Warforged):"]                                                          = "Beispiel (Warforged):",
    ["- Warforged duplicate: blocked. (Max 1)"]                                       = "- Warforged-Duplikat: blockiert. (Max 1)",
    ["- Lightforged: can still equip. (Max 1)"]                                       = "- Lightforged: kann weiterhin angelegt werden. (Max 1)",
    ["- 'All Items': strict at all tiers."]                                           = "- 'All Items': strikt auf allen Stufen.",
    ["Drag an item here to assign its slot in AHSet."]                                = "Ziehe einen Gegenstand hierher, um ihm in AHSet einen Slot zuzuweisen.",
    ["Empty slot — drag an item here, Set AHSet, or /ahset."]                         = "Leerer Slot — ziehe einen Gegenstand hierher, nutze Set AHSet oder /ahset.",
    ["Drag an item and left-click to add it to AHIgnore."]                            = "Ziehe einen Gegenstand und klicke links, um ihn zu AHIgnore hinzuzufügen.",
    ["Right-click to remove from this preset."]                                        = "Rechtsklick, um es aus diesem Preset zu entfernen.",
    ["Item ID %s"]                                                                     = "Gegenstands-ID %s",
    ["Enter a name for the new AHSet preset:"]                                         = "Gib einen Namen für das neue AHSet-Preset ein:",
    ["A preset with that name already exists."]                                        = "Ein Preset mit diesem Namen existiert bereits.",
    ["Invalid preset name."]                                                           = "Ungültiger Preset-Name.",
    ["Delete AHSet preset \"%s\"?"]                                                    = "AHSet-Preset \"%s\" löschen?",
    ["List Management"]                                                                = "Listenverwaltung",
    ["AHSet is stored per character (GUID). Presets swap the saved item-to-slot map. AHIgnore / Always Vendored are account-wide."] =
    "AHSet wird pro Charakter (GUID) gespeichert. Presets wechseln die gespeicherte Gegenstand-zu-Slot-Zuordnung. AHIgnore / Always Vendored sind accountweit.",
    ["AHSet preset"]                                                                   = "AHSet-Preset",
    ["New"]                                                                            = "Neu",
    ["Delete"]                                                                         = "Löschen",
    ["Set AHSet"]                                                                      = "Set AHSet",
    ["Set AHSet (/ahsetall)"]                                                          = "Set AHSet (/ahsetall)",
    ["After confirmation, copies your equipped items into this preset."]               = "Nach der Bestätigung werden deine angelegten Gegenstände in dieses Preset kopiert.",
    ["Option control arrays initialized"]                                              = "Options-Steuerungsarrays initialisiert",
    ["Options panels initialized successfully"]                                        = "Options-Panels erfolgreich initialisiert",
    ["'%s' added to AHSet, designated for slot %s."]                                   = "'%s' zu AHSet hinzugefügt, zugewiesen zu Slot %s.",
    ["'%s' (ID: %s) added to AHSet, designated for slot %s."]                          = "'%s' (ID: %s) zu AHSet hinzugefügt, zugewiesen zu Slot %s.",
}

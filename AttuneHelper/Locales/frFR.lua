-- ʕ •ᴥ•ʔ✿ Locale (French) ✿ ʕ •ᴥ•ʔ
local AH_LOCALES = _G.AH_LOCALES or {}
_G.AH_LOCALES = AH_LOCALES

AH_LOCALES["frFR"] = {
    ["Equip Attunables"]                                                              = "Équiper les Attunables",
    ["Prepare Disenchant"]                                                            = "Préparer le désenchantement",
    ["Vendor Attuned"]                                                                = "Vendre les Attuned",
    ["Vendor Attuned Items"]                                                          = "Vendre les objets Attuned",
    ["Add To Vendor"]                                                                 = "Ajouter à la liste de vente",
    ["System Default"]                                                                = "Valeur par défaut du système",
    ["English (US)"]                                                                  = "English (US)",
    ["Español"]                                                                       = "Español",
    ["Deutsch"]                                                                       = "Deutsch",
    ["Select Language:"]                                                              = "Choisir la langue :",
    ["Moves fully attuned mythic items to bag %d."]                                   = "Déplace les objets épiques entièrement Attuned dans le sac %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]              =
    "Vide d'abord le sac cible, puis le remplit avec les objets prêts à désenchanter.",
    ["Attunable Items: %d"]                                                           = "Objets Attunable : %d",
    ["Qualifying Attunables (%d):"]                                                   = "Attunables éligibles (%d) :",
    ["No qualifying attunables in bags."]                                             = "Aucun Attunable éligible dans les sacs.",
    ["Items to be sold (%d):"]                                                        = "Objets à vendre (%d) :",
    ["Always-vendor entries: %d"]                                                     = "Entrées Always-Vendor : %d",
    ["No items will be sold based on current settings."]                              = "Aucun objet ne sera vendu avec les réglages actuels.",
    ["Open merchant window to sell these items."]                                     = "Ouvrez la fenêtre du marchand pour vendre ces objets.",
    ["Drag an item here or pick it up and click to toggle always-vendor."]            = "Faites glisser un objet ici ou prenez-le puis cliquez pour activer/désactiver Always-Vendor.",
    ["Items added here are always included in AH vendor previews and selling."]       = "Les objets ajoutés ici sont toujours inclus dans les aperçus et la vente du marchand AH.",
    ["Hold left 1s on this button for bulk add mode (cursor items add-only)."]        = "Maintenez le clic gauche 1 s sur ce bouton pour activer le mode d'ajout en masse (les objets du curseur sont uniquement ajoutés).",
    ["Bulk mode: click this button again or close the vendor to exit."]               = "Mode masse : cliquez à nouveau sur ce bouton ou fermez le marchand pour quitter.",
    ["Bulk add mode is ON."]                                                          = "Le mode d'ajout en masse est ACTIVÉ.",
    ["Always-vendor skipped for Warforged/Lightforged (see options)."]                = "Always-Vendor ignoré pour WF/LF (voir les options).",
    ["Ignore Always-Vendor for Warforged and Lightforged"]                            = "Ignorer Always-Vendor pour Warforged et Lightforged",
    ["When enabled, Warforged and Lightforged variants cannot be added to the always-vendor list and do not use the always-vendor bypass when selling."] =
    "Quand activé, les variantes Warforged et Lightforged ne peuvent pas être ajoutées à la liste Always-Vendor et n'utilisent pas le contournement Always-Vendor lors de la vente.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."]     =
    "Les objets doivent être : épiques, 100%% Attuned, liés à l'âme, et absents des ensembles/listes ignorées.",
    ["Prepare Disenchant Include BoE Mythic Weapons"]                                  =
    "Préparer le désenchantement : armes épiques BoE (niveau d'objet 245)",
    ["Update AHSet"]                                                                  = "Mettre à jour AHSet",
    ["Sets AHSet to be equal to your currently equiped items."]                       =
    "Définit AHSet sur vos objets actuellement équipés.",
    ["This will delete your current AHSet."]                                          = "Cela supprimera votre AHSet actuel.",
    ["Are you sure you want to update AHSet to match your currently equipped items?"] =
    "Voulez-vous vraiment mettre à jour AHSet pour correspondre à vos objets actuellement équipés ?",
    ["AHSet 1H pre-swap for off-hand attune"] =
    "AHSet : pré-échange 1H pour Attune en main secondaire (multi-classe Guerrier)",
    ["AHSet 1h2h swap"] = "Multi-classe Guerrier · échange 1H / 2H",
    ["AHSet 1h2h swap tip line 1"] =
    "En multi-classe à la Chromie, votre classe d'interface n'est souvent pas Guerrier même si vous jouez comme tel. Avec cette option activée et le drapeau d'échange du préréglage défini, Equip All peut remplacer une 2H en main principale par votre une-main d'AHSet pour qu'un Attunable de main secondaire puisse s'équiper.",
    ["AHSet 1h2h swap tip line 2"] = "Il vous faut une 2H équipée en main principale qui n'est pas en cours d'Attuning, un Attunable de main secondaire dans les sacs et une 1H dans les sacs assignée à Main Hand ou à la rangée '1H Weapon Swaps' dans la Gestion des listes.",
    ["AHSet 1h2h swap tip line 3"] = "Titan's Grip se joue avec une arme à 2H en main principale et soit une autre 2H TG soit une hache à une main en main secondaire (par exemple un build Furie style flurry) — c'est votre vraie paire d'armes, pas les rangées '1H Weapon Swaps' / prep. Equip All ignore normalement cet échange 2H→une-main en main principale tant que TG est détecté afin que la gestion des sacs puisse utiliser votre main secondaire. Exception : les une-main de main principale uniquement ne peuvent pas s'équiper en main secondaire, donc cet échange peut tout de même s'exécuter. Le drapeau d'échange s'active quand la main principale pointe sur une arme à 2H et que vous assignez une une-main à Main Hand ou à la rangée '1H Weapon Swaps' ; /ahset 1hspecial2h peut encore le forcer avant que cela n'existe.",
    ["AHSet 1h2h swap tip line 4"] = "La détection de main secondaire est stricte quand ce préréglage assigne quelque chose à Off Hand ou à la case prep main secondaire (les une-main ambiguës nécessitent /ahset … oh). Sinon elle est souple.",
    ["AHSet 1h2h swap tip line 5"] = "/ahset 1hspecial2h remove efface le drapeau de forçage optionnel ; 'Set AHSet' efface le préréglage entier.",
    ["Off-hand swap trigger"] = "Déclencheur d'échange en main secondaire",
    ["AHSet OH trigger strict"] = "AHSet / main secondaire native uniquement (strict)",
    ["AHSet OH trigger loose"] = "Toute 1H utilisable en main secondaire (souple)",
    ["AHSet OH trigger strict tip"] =
    "Strict : les boucliers, objets tenus en main et armes de main secondaire comptent toujours. Les une-main ambiguës ne comptent que si vous les avez mappées avec /ahset <link> oh (main secondaire AHSet).",
    ["AHSet OH trigger loose tip"] =
    "Souple : toute une-main Attunable dans les sacs compte comme raison d'échanger, même sans mappage de main secondaire AHSet (peut échanger plus souvent).",
    ["AHSet 1h2h preset button title"] = "Échange 1H/2H multi-classe Guerrier (préréglage)",
    ["AHSet 1h2h preset tip line 1"] =
    "Active/désactive le drapeau d'échange du préréglage (équivalent à /ahset 1hspecial2h). Ce n'est pas un interrupteur générique : il existe parce que les Guerriers multi-classe utilisent souvent un profil principal à 2H alors que les objets de main secondaire ont encore besoin d'Attuning.",
    ["AHSet 1h2h preset tip line 2"] = "Equip All n'effectue l'échange que lorsque ce drapeau est Activé, la case ci-dessus est cochée et les autres conditions du tooltip sont remplies.",
    ["AHSet 1h2h preset tip line 3"] = "Cliquez à nouveau pour Désactiver et retirer le drapeau de ce préréglage uniquement.",
    ["MC 1h2h: On"] = "MC 1h2h : Activé",
    ["MC 1h2h: Off"] = "MC 1h2h : Désactivé",
    ["AHSet 1h2h list title"] = "MC Guerrier · 1H/2H (ce préréglage)",
    ["AHSet prep paper strip label"] = "1H Weapon Swaps",
    ["AHSet prep paper strip drag hint"] = "Préparer les armes",
    ["AHSet prep MH slot label"] = "1H · rangée main principale",
    ["AHSet prep OH slot label"] = "Rangée main secondaire",
    ["AHSet prep slot empty slash hint"] = "'Set AHSet', /ahset prepmh, /ahset prep1h ou /ahset prepoh fonctionnent aussi.",
    ["AHSet keep item in bags for instance signature"] =
    "Gardez l'objet dans vos sacs lorsque vous l'ajoutez à AHSet pour que sa signature unique puisse être enregistrée. Si vous n'avez qu'un seul exemplaire, un lien d'objet équipé seul peut ne pas suffire.",
    ["AHSet usage signature reminder"] =
    "Objets uniques : mettez-les dans vos sacs avant /ahset pour que les signatures d'instance puissent être enregistrées quand Custom_GetItemGuid est disponible.",
    ["AHSet 2h swap strip explanation"] =
    "Rien ici n'est un interrupteur séparé : Equip All utilise vos mappages d'armes sur ce préréglage. Mappez une une-main à Main Hand ou aux cases ci-dessous quand la main principale du préréglage est une 2H.",
    ["AHSet auto status swap on"] = "Voie d'échange prep 1H : active pour ce préréglage.",
    ["AHSet auto status swap off"] = "Voie d'échange prep 1H : inactive (mappez une une-main à Main Hand ou aux cases ci-dessous, ou utilisez /ahset 1hspecial2h pour forcer).",
    ["AHSet auto status oh fmt"] = "Détection d'Attunable en main secondaire : %s.",
    ["AHSet OH trigger strict short"] = "strict",
    ["AHSet OH trigger loose short"] = "souple",
    ["Weapon panel multiclass header"] = "Multi-classe Guerrier · échange AHSet",
    ["Weapon panel TG detection note"] = "Titan's Grip est détecté à partir de vos talents (y compris des onglets de talents multi-classe à la Chromie). La logique de double 2H dans les sacs/équipement ne s'applique qu'aux haches, masses et épées à deux mains, pas aux bâtons ni aux armes d'hast.",
    ["AHSet 2h swap section title"] = "1H Weapon Swaps",
    ["AHSet 1h2h preset row label"] = "Échange 1H/2H sur ce préréglage",
    ["AHSet swap flag on"] = "Activé",
    ["AHSet swap flag off"] = "Désactivé",
    ["Yes"]                                                                           = "Oui",
    ["No"]                                                                            = "Non",
    ["Cancel"]                                                                        = "Annuler",
    ["Toggle Auto-Equip"]                                                             = "Activer/désactiver l'auto-équipement",
    ["Disable Auto-Equip"]                                                            = "Désactiver l'auto-équipement",
    ["Enable Auto-Equip"]                                                             = "Activer l'auto-équipement",
    ["Currently enabled."]                                                            = "Actuellement activé.",
    ["Currently disabled."]                                                           = "Actuellement désactivé.",
    ["Open Settings"]                                                                 = "Ouvrir les réglages",
    ["Opens the General Logic Options settings page."]                                = "Ouvre la page de réglages 'General Logic Options'.",
    ["Hold Shift for additional options"]                                             = "Maintenez Maj pour des options supplémentaires",
    ["Background Color"]                                                              = "Couleur de fond",
    ["Equip Attunable Affixes up to:"]                                                = "Équiper les affixes Attunable jusqu'à :",
    ["Affix-Only Minimum Forge"]                                                      = "Forge minimum Affix-Only",
    ["Works only when 'Equip New Affixes Only' is enabled."]                          =
    "Ne fonctionne que lorsque 'Equip New Affixes Only' est activé.",
    ["'All Items' disables the forge threshold behavior."]                            =
    "'All Items' désactive le comportement de seuil de forge.",
    ["When enabled, this setting favors affixes you have not attuned yet."]           =
    "Quand activé, ce réglage favorise les affixes que vous n'avez pas encore Attuned.",
    ["Use the dropdown to choose where lenient behavior ends."]                       =
    "Utilisez la liste déroulante pour choisir où le comportement permissif s'arrête.",
    ["Items below the selected forge tier can equip even if already seen."]           =
    "Les objets sous le palier de forge sélectionné peuvent s'équiper même s'ils ont déjà été vus.",
    ["At the selected tier and above, the addon prefers truly new affixes."]          =
    "À partir du palier sélectionné, l'addon préfère les affixes réellement nouveaux.",
    ["If a variant is already attuned, only higher forge tiers can still auto-equip."] =
    "Si une variante est déjà Attuned, seuls les paliers de forge supérieurs peuvent encore s'auto-équiper.",
    ["Example: with 'Warforged', duplicate Warforged is blocked, but Lightforged can still equip."] =
    "Exemple : avec 'Warforged', un WF en double est bloqué, mais LF peut toujours s'équiper.",
    ["Below this tier: lenient equip behavior."]                                      = "Sous ce palier : comportement d'équipement permissif.",
    ["At this tier and above: strict new-affix behavior."]                            = "À ce palier et au-dessus : comportement strict de nouveaux affixes.",
    ["When a variant already exists, only higher forge tiers can override."]          =
    "Quand une variante existe déjà, seuls les paliers de forge supérieurs peuvent l'écraser.",
    ["'All Items' applies strict behavior to every forge tier."]                      =
    "'All Items' applique le comportement strict à chaque palier de forge.",
    ["Use the dropdown to set the highest forge tier that ignores attunement history (inclusive)."] =
    "Utilisez la liste déroulante pour définir le palier de forge le plus élevé qui ignore l'historique d'Attunement (inclus).",
    ["Example: 'Warforged' allows Base/Titanforged/Warforged to equip even if already seen; Lightforged still requires a new affix or no prior variant."] =
    "Exemple : 'Warforged' permet à Base/TF/WF de s'équiper même s'ils ont déjà été vus ; LF nécessite encore un nouvel affixe ou aucune variante préalable.",
    ["'All Items' removes this forge-tier limit while keeping the strict new-affix preference."] =
    "'All Items' retire cette limite de palier de forge tout en conservant la préférence stricte pour les nouveaux affixes.",
    ["Select the highest forge tier that can equip regardless of prior attunement history."] =
    "Sélectionnez le palier de forge le plus élevé pouvant s'équiper indépendamment de l'historique d'Attunement.",
    ["This applies only while the checkbox is enabled."]                              =
    "Ceci ne s'applique que tant que la case est cochée.",
    ["Tiers above your selected value still require a truly new affix (or no variant attuned yet)."] =
    "Les paliers au-dessus de votre valeur sélectionnée nécessitent toujours un affixe réellement nouveau (ou aucune variante encore Attuned).",
    ["'All Items' removes the forge-tier cap."]                                       = "'All Items' retire la limite de palier de forge.",
    ["- Selected tier and up: unattuned variant only."]                               = "- À partir du palier sélectionné : variante non Attuned uniquement.",
    ["- Does not check extra affix unlocks."]                                         = "- Ne vérifie pas les déblocages d'affixes supplémentaires.",
    ["- Base and TF - Equips all if Affix is attunable."]                             = "- Base et TF : équipe tout si l'affixe est Attunable.",
    ["Hide Center Button in Normal Mode"]                                             = "Masquer le bouton central en mode normal",
    ["Hides the center action button in normal view."]                                = "Masque le bouton d'action central en vue normale.",
    ["Hold Ctrl to show Open Settings and Update AHSet."]                             =
    "Maintenez Ctrl pour afficher 'Ouvrir les réglages' et 'Mettre à jour AHSet'.",
    ["Sell Attuned Mythic Gear?"]                                                     = "Vendre l’équipement épique Attuned ?",
    ["Auto Equip Attunables Automaticly"]                                             = "Équiper automatiquement les Attunables",
    ["Do Not Sell BoE Items"]                                                         = "Ne pas vendre les objets BoE",
    ["Do Not Sell Grey And White Items"]                                              = "Ne pas vendre les objets gris et blancs",
    ["Limit Selling to 12 Items?"]                                                    = "Limiter la vente à 12 objets ?",
    ["Disable Auto-Equip Mythic BoE"]                                                 = "Désactiver l’auto-équipement des BoE épiques",
    ["Equip BoE Bountied Items"]                                                      = "Équiper les objets BoE de prime",
    ["Prioritize Low iLvl for Auto-Equip"]                                            = "Prioriser les iLvl bas pour l’auto-équipement",
    ["Enable Vendor Sell Confirmation Dialog"]                                        = "Activer la confirmation de vente au marchand",
    ["Vendor preview on Right (Default On)"]                                          = "Aperçu de vente à droite (activé par défaut)",
    ["Draggable by Right Click"]                                                      = "Déplaçable au clic droit",
    ["Lock AH in Place (Buttons Only Mouse)"]                                         = "Verrouiller AH en place (boutons à la souris uniquement)",
    ["Use Bag 1 for Disenchant"]                                                      = "Utiliser le sac 1 pour le désenchantement",
    ["This setting is recommended to be off due to the fact that disenchanting Mythic Gear results in honor and arena points."] =
    "Il est recommandé de laisser cette option désactivée, car désenchanter l’équipement épique donne de l’honneur et des points d’arène.",
    ["With this setting off, it will not vendor non-BoP white/grey items if the item can be attuned."] =
    "Avec cette option désactivée, les objets blancs/gris non BoP ne seront pas vendus s’ils peuvent être Attuned.",
    ["Quick rules:"]                                                                  = "Règles rapides :",
    ["- Below selected tier: lenient."]                                               = "- Sous le palier sélectionné : permissif.",
    ["- Existing variant: only higher tier can equip."]                               = "- Variante existante : seul un palier supérieur peut équiper.",
    ["Example (Warforged):"]                                                          = "Exemple (Warforged) :",
    ["- Warforged duplicate: blocked. (Max 1)"]                                       = "- Warforged en doublon : bloqué. (Max 1)",
    ["- Lightforged: can still equip. (Max 1)"]                                       = "- Lightforged : peut toujours s’équiper. (Max 1)",
    ["- 'All Items': strict at all tiers."]                                           = "- 'All Items' : strict à tous les paliers.",
    ["Drag an item here to assign its slot in AHSet."]                                = "Faites glisser un objet ici pour lui assigner son emplacement dans AHSet.",
    ["Empty slot — drag an item here, Set AHSet, or /ahset."]                         = "Emplacement vide : faites glisser un objet ici, utilisez Set AHSet ou /ahset.",
    ["Drag an item and left-click to add it to AHIgnore."]                            = "Faites glisser un objet puis cliquez gauche pour l’ajouter à AHIgnore.",
    ["Right-click to remove from this preset."]                                        = "Clic droit pour retirer de ce préréglage.",
    ["Item ID %s"]                                                                     = "ID d'objet %s",
    ["Enter a name for the new AHSet preset:"]                                         = "Saisissez un nom pour le nouveau préréglage AHSet :",
    ["A preset with that name already exists."]                                        = "Un préréglage avec ce nom existe déjà.",
    ["Invalid preset name."]                                                           = "Nom de préréglage invalide.",
    ["Delete AHSet preset \"%s\"?"]                                                    = "Supprimer le préréglage AHSet \"%s\" ?",
    ["List Management"]                                                                = "Gestion des listes",
    ["AHSet is stored per character (GUID). Presets swap the saved item-to-slot map. AHIgnore / Always Vendored are account-wide."] =
    "AHSet est stocké par personnage (GUID). Les préréglages remplacent la correspondance objet-emplacement sauvegardée. AHIgnore / Always Vendored sont partagés au niveau du compte.",
    ["AHSet preset"]                                                                   = "Préréglage AHSet",
    ["New"]                                                                            = "Nouveau",
    ["Delete"]                                                                         = "Supprimer",
    ["Set AHSet"]                                                                      = "Set AHSet",
    ["Set AHSet (/ahsetall)"]                                                          = "Set AHSet (/ahsetall)",
    ["After confirmation, copies your equipped items into this preset."]               = "Après confirmation, copie vos objets équipés dans ce préréglage.",
    ["Option control arrays initialized"]                                              = "Tableaux de contrôles d'options initialisés",
    ["Options panels initialized successfully"]                                        = "Panneaux d'options initialisés avec succès",
    ["'%s' added to AHSet, designated for slot %s."]                                   = "'%s' ajouté à AHSet, assigné à l'emplacement %s.",
    ["'%s' (ID: %s) added to AHSet, designated for slot %s."]                          = "'%s' (ID : %s) ajouté à AHSet, assigné à l'emplacement %s.",
}

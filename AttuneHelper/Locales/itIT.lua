-- ʕ •ᴥ•ʔ✿ Locale (Italian) ✿ ʕ •ᴥ•ʔ
local AH_LOCALES = _G.AH_LOCALES or {}
_G.AH_LOCALES = AH_LOCALES

AH_LOCALES["itIT"] = {
    ["Equip Attunables"]                                                              = "Equipaggia Attunables",
    ["Prepare Disenchant"]                                                            = "Prepara disincantamento",
    ["Vendor Attuned"]                                                                = "Vendi Attuned",
    ["Vendor Attuned Items"]                                                          = "Vendi oggetti Attuned",
    ["Add To Vendor"]                                                                 = "Aggiungi alla lista di vendita",
    ["System Default"]                                                                = "Predefinito di sistema",
    ["English (US)"]                                                                  = "English (US)",
    ["Español"]                                                                       = "Español",
    ["Deutsch"]                                                                       = "Deutsch",
    ["Select Language:"]                                                              = "Seleziona lingua:",
    ["Moves fully attuned mythic items to bag %d."]                                   = "Sposta gli oggetti mitici completamente Attuned nella borsa %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]              =
    "Svuota prima la borsa di destinazione e poi la riempie con oggetti pronti per il disincantamento.",
    ["Attunable Items: %d"]                                                           = "Oggetti Attunable: %d",
    ["Qualifying Attunables (%d):"]                                                   = "Attunables idonei (%d):",
    ["No qualifying attunables in bags."]                                             = "Nessun Attunable idoneo nelle borse.",
    ["Items to be sold (%d):"]                                                        = "Oggetti da vendere (%d):",
    ["Always-vendor entries: %d"]                                                     = "Voci Always-Vendor: %d",
    ["No items will be sold based on current settings."]                              = "Nessun oggetto verrà venduto in base alle impostazioni correnti.",
    ["Open merchant window to sell these items."]                                     = "Apri la finestra del mercante per vendere questi oggetti.",
    ["Drag an item here or pick it up and click to toggle always-vendor."]            = "Trascina un oggetto qui o raccoglilo e clicca per attivare/disattivare Always-Vendor.",
    ["Items added here are always included in AH vendor previews and selling."]       = "Gli oggetti aggiunti qui sono sempre inclusi nelle anteprime e nella vendita di AH.",
    ["Hold left 1s on this button for bulk add mode (cursor items add-only)."]        = "Tieni premuto il clic sinistro per 1 s su questo pulsante per la modalità aggiunta in blocco (gli oggetti del cursore vengono solo aggiunti).",
    ["Bulk mode: click this button again or close the vendor to exit."]               = "Modalità in blocco: clicca di nuovo questo pulsante o chiudi il mercante per uscire.",
    ["Bulk add mode is ON."]                                                          = "La modalità di aggiunta in blocco è ATTIVA.",
    ["Always-vendor skipped for Warforged/Lightforged (see options)."]                = "Always-Vendor saltato per WF/LF (vedi opzioni).",
    ["Ignore Always-Vendor for Warforged and Lightforged"]                            = "Ignora Always-Vendor per Warforged e Lightforged",
    ["When enabled, Warforged and Lightforged variants cannot be added to the always-vendor list and do not use the always-vendor bypass when selling."] =
    "Se attivata, le varianti Warforged e Lightforged non possono essere aggiunte alla lista Always-Vendor e non usano la deroga Always-Vendor durante la vendita.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."]     =
    "Gli oggetti devono essere: mitici, Attuned al 100%%, vincolati nell'anima, non in set/liste ignorate.",
    ["Prepare Disenchant Include BoE Mythic Weapons"]                                  =
    "Prepara disincantamento: armi mitiche BoE (livello oggetto 245)",
    ["Update AHSet"]                                                                  = "Aggiorna AHSet",
    ["Sets AHSet to be equal to your currently equiped items."]                       =
    "Imposta AHSet uguale agli oggetti attualmente equipaggiati.",
    ["This will delete your current AHSet."]                                          = "Questo eliminerà il tuo AHSet attuale.",
    ["Are you sure you want to update AHSet to match your currently equipped items?"] =
    "Sei sicuro di voler aggiornare AHSet in base agli oggetti attualmente equipaggiati?",
    ["AHSet 1H pre-swap for off-hand attune"] =
    "AHSet: pre-cambio 1H per Attune in mano secondaria (multiclasse Guerriero)",
    ["AHSet 1h2h swap"] = "Multiclasse Guerriero · cambio 1H / 2H",
    ["AHSet 1h2h swap tip line 1"] =
    "Nel multiclasse stile Chromie, la tua classe nell'interfaccia spesso non è Guerriero anche se giochi come tale. Con questa opzione attiva e il flag di cambio del preset impostato, Equip All può sostituire una 2H in mano principale con la tua una mano di AHSet così che un Attunable di mano secondaria possa essere equipaggiato.",
    ["AHSet 1h2h swap tip line 2"] = "Ti serve una 2H equipaggiata in mano principale che non stia attivamente Attuning, un Attunable di mano secondaria nelle borse e una 1H nelle borse mappata su Main Hand o sulla riga '1H Weapon Swaps' nella Gestione liste.",
    ["AHSet 1h2h swap tip line 3"] = "Titan's Grip si gioca con un'arma a 2H in mano principale e o un'altra 2H TG o un'ascia a una mano in mano secondaria (per esempio un build Furia in stile flurry): è la tua vera coppia di armi, non le righe '1H Weapon Swaps' / prep. Equip All di norma salta questo cambio 2H→una mano principale finché TG è rilevato, così la gestione delle borse può usare la tua mano secondaria. Eccezione: le una mano solo per mano principale non possono essere equipaggiate in mano secondaria, quindi quel cambio può comunque avvenire. Il flag di cambio si attiva quando la mano principale punta a una 2H e mappi una una mano su Main Hand o sulla riga '1H Weapon Swaps'; /ahset 1hspecial2h può ancora forzarlo prima che esistano.",
    ["AHSet 1h2h swap tip line 4"] = "Il rilevamento della mano secondaria è rigoroso quando questo preset mappa qualcosa su Off Hand o sulla casella prep mano secondaria (le una mano ambigue richiedono /ahset … oh). Altrimenti è permissivo.",
    ["AHSet 1h2h swap tip line 5"] = "/ahset 1hspecial2h remove cancella il flag di forzatura opzionale; 'Set AHSet' azzera l'intero preset.",
    ["Off-hand swap trigger"] = "Trigger di cambio mano secondaria",
    ["AHSet OH trigger strict"] = "Solo AHSet / mano secondaria nativa (rigoroso)",
    ["AHSet OH trigger loose"] = "Qualsiasi 1H utilizzabile in mano secondaria (permissivo)",
    ["AHSet OH trigger strict tip"] =
    "Rigoroso: scudi, oggetti tenuti in mano e armi di mano secondaria contano sempre. Le una mano ambigue contano solo se le hai mappate con /ahset <link> oh (mano secondaria di AHSet).",
    ["AHSet OH trigger loose tip"] =
    "Permissivo: qualsiasi una mano Attunable nelle borse conta come motivo per cambiare, anche senza una mappatura di mano secondaria di AHSet (può cambiare più spesso).",
    ["AHSet 1h2h preset button title"] = "Cambio 1H/2H multiclasse Guerriero (preset)",
    ["AHSet 1h2h preset tip line 1"] =
    "Attiva/disattiva il flag di cambio del preset (uguale a /ahset 1hspecial2h). Non è un interruttore generico: esiste perché i Guerrieri multiclasse spesso usano un profilo principale a 2H mentre gli oggetti di mano secondaria hanno ancora bisogno di Attuning.",
    ["AHSet 1h2h preset tip line 2"] = "Equip All esegue il cambio solo quando questo flag è Attivo, la casella sopra è abilitata e le altre condizioni nel tooltip sono soddisfatte.",
    ["AHSet 1h2h preset tip line 3"] = "Clicca di nuovo per Disattivare e rimuovere il flag solo da questo preset.",
    ["MC 1h2h: On"] = "MC 1h2h: Attivo",
    ["MC 1h2h: Off"] = "MC 1h2h: Disattivo",
    ["AHSet 1h2h list title"] = "MC Guerriero · 1H/2H (questo preset)",
    ["AHSet prep paper strip label"] = "1H Weapon Swaps",
    ["AHSet prep paper strip drag hint"] = "Prepara armi",
    ["AHSet prep MH slot label"] = "1H · riga mano principale",
    ["AHSet prep OH slot label"] = "Riga mano secondaria",
    ["AHSet prep slot empty slash hint"] = "'Set AHSet', /ahset prepmh, /ahset prep1h o /ahset prepoh funzionano anche.",
    ["AHSet keep item in bags for instance signature"] =
    "Tieni l'oggetto nelle borse quando lo aggiungi ad AHSet così la sua firma univoca può essere salvata. Se ne hai una sola copia, il link di un oggetto equipaggiato da solo potrebbe non bastare.",
    ["AHSet usage signature reminder"] =
    "Oggetti unici: mettili nelle borse prima di /ahset così le firme di istanza possono essere salvate quando Custom_GetItemGuid è disponibile.",
    ["AHSet 2h swap strip explanation"] =
    "Qui non c'è un interruttore separato: Equip All usa le tue mappature delle armi su questo preset. Mappa una una mano su Main Hand o sulle caselle qui sotto quando la mano principale del preset è una 2H.",
    ["AHSet auto status swap on"] = "Percorso di cambio prep 1H: attivo per questo preset.",
    ["AHSet auto status swap off"] = "Percorso di cambio prep 1H: inattivo (mappa una una mano su Main Hand o sulle caselle qui sotto, oppure usa /ahset 1hspecial2h per forzare).",
    ["AHSet auto status oh fmt"] = "Rilevamento Attunable di mano secondaria: %s.",
    ["AHSet OH trigger strict short"] = "rigoroso",
    ["AHSet OH trigger loose short"] = "permissivo",
    ["Weapon panel multiclass header"] = "Multiclasse Guerriero · cambio AHSet",
    ["Weapon panel TG detection note"] = "Titan's Grip viene rilevato dai tuoi talenti (incluse schede di talenti multiclasse stile Chromie). La logica della doppia 2H nelle borse/equipaggiamento si applica solo ad asce, mazze e spade a due mani: non a bastoni o armi inastate.",
    ["AHSet 2h swap section title"] = "1H Weapon Swaps",
    ["AHSet 1h2h preset row label"] = "Cambio 1H/2H su questo preset",
    ["AHSet swap flag on"] = "Attivo",
    ["AHSet swap flag off"] = "Disattivo",
    ["Yes"]                                                                           = "Sì",
    ["No"]                                                                            = "No",
    ["Cancel"]                                                                        = "Annulla",
    ["Toggle Auto-Equip"]                                                             = "Attiva/disattiva auto-equipaggiamento",
    ["Disable Auto-Equip"]                                                            = "Disattiva auto-equipaggiamento",
    ["Enable Auto-Equip"]                                                             = "Attiva auto-equipaggiamento",
    ["Currently enabled."]                                                            = "Attualmente attivo.",
    ["Currently disabled."]                                                           = "Attualmente disattivato.",
    ["Open Settings"]                                                                 = "Apri impostazioni",
    ["Opens the General Logic Options settings page."]                                = "Apre la pagina delle impostazioni 'General Logic Options'.",
    ["Hold Shift for additional options"]                                             = "Tieni premuto Maiusc per opzioni aggiuntive",
    ["Background Color"]                                                              = "Colore di sfondo",
    ["Equip Attunable Affixes up to:"]                                                = "Equipaggia affissi Attunable fino a:",
    ["Affix-Only Minimum Forge"]                                                      = "Forge minima Affix-Only",
    ["Works only when 'Equip New Affixes Only' is enabled."]                          =
    "Funziona solo quando 'Equip New Affixes Only' è attivo.",
    ["'All Items' disables the forge threshold behavior."]                            =
    "'All Items' disattiva il comportamento della soglia di forge.",
    ["When enabled, this setting favors affixes you have not attuned yet."]           =
    "Quando attivata, questa opzione favorisce gli affissi che non hai ancora Attuned.",
    ["Use the dropdown to choose where lenient behavior ends."]                       =
    "Usa il menu a tendina per scegliere dove finisce il comportamento permissivo.",
    ["Items below the selected forge tier can equip even if already seen."]           =
    "Gli oggetti sotto il livello di forge selezionato possono essere equipaggiati anche se già visti.",
    ["At the selected tier and above, the addon prefers truly new affixes."]          =
    "Dal livello selezionato in su, l'addon preferisce affissi veramente nuovi.",
    ["If a variant is already attuned, only higher forge tiers can still auto-equip."] =
    "Se una variante è già Attuned, solo i livelli di forge superiori possono ancora auto-equipaggiarsi.",
    ["Example: with 'Warforged', duplicate Warforged is blocked, but Lightforged can still equip."] =
    "Esempio: con 'Warforged', un WF duplicato viene bloccato, ma LF può comunque essere equipaggiato.",
    ["Below this tier: lenient equip behavior."]                                      = "Sotto questo livello: comportamento di equipaggiamento permissivo.",
    ["At this tier and above: strict new-affix behavior."]                            = "Da questo livello in su: comportamento rigoroso di nuovi affissi.",
    ["When a variant already exists, only higher forge tiers can override."]          =
    "Quando una variante esiste già, solo i livelli di forge superiori possono sovrascriverla.",
    ["'All Items' applies strict behavior to every forge tier."]                      =
    "'All Items' applica il comportamento rigoroso a ogni livello di forge.",
    ["Use the dropdown to set the highest forge tier that ignores attunement history (inclusive)."] =
    "Usa il menu a tendina per impostare il livello di forge più alto che ignora la cronologia di Attunement (incluso).",
    ["Example: 'Warforged' allows Base/Titanforged/Warforged to equip even if already seen; Lightforged still requires a new affix or no prior variant."] =
    "Esempio: 'Warforged' permette a Base/TF/WF di essere equipaggiati anche se già visti; LF richiede ancora un affisso nuovo o nessuna variante precedente.",
    ["'All Items' removes this forge-tier limit while keeping the strict new-affix preference."] =
    "'All Items' rimuove questo limite di livello di forge mantenendo la preferenza rigorosa per i nuovi affissi.",
    ["Select the highest forge tier that can equip regardless of prior attunement history."] =
    "Seleziona il livello di forge più alto che può essere equipaggiato indipendentemente dalla cronologia di Attunement.",
    ["This applies only while the checkbox is enabled."]                              =
    "Questo si applica solo finché la casella è attiva.",
    ["Tiers above your selected value still require a truly new affix (or no variant attuned yet)."] =
    "I livelli sopra il valore selezionato richiedono ancora un affisso veramente nuovo (o nessuna variante ancora Attuned).",
    ["'All Items' removes the forge-tier cap."]                                       = "'All Items' rimuove il limite di livello di forge.",
    ["- Selected tier and up: unattuned variant only."]                               = "- Dal livello selezionato in su: solo variante non Attuned.",
    ["- Does not check extra affix unlocks."]                                         = "- Non controlla sblocchi di affissi aggiuntivi.",
    ["- Base and TF - Equips all if Affix is attunable."]                             = "- Base e TF: equipaggia tutto se l'affisso è Attunable.",
    ["Hide Center Button in Normal Mode"]                                             = "Nascondi il pulsante centrale in modalità normale",
    ["Hides the center action button in normal view."]                                = "Nasconde il pulsante d'azione centrale nella vista normale.",
    ["Hold Ctrl to show Open Settings and Update AHSet."]                             =
    "Tieni premuto Ctrl per mostrare 'Apri impostazioni' e 'Aggiorna AHSet'.",
    ["Sell Attuned Mythic Gear?"]                                                     = "Vendere equipaggiamento mitico Attuned?",
    ["Auto Equip Attunables Automaticly"]                                             = "Equipaggia automaticamente gli Attunables",
    ["Do Not Sell BoE Items"]                                                         = "Non vendere oggetti BoE",
    ["Do Not Sell Grey And White Items"]                                              = "Non vendere oggetti grigi e bianchi",
    ["Limit Selling to 12 Items?"]                                                    = "Limitare la vendita a 12 oggetti?",
    ["Disable Auto-Equip Mythic BoE"]                                                 = "Disattiva auto-equipaggiamento BoE mitico",
    ["Equip BoE Bountied Items"]                                                      = "Equipaggia oggetti BoE di taglia",
    ["Prioritize Low iLvl for Auto-Equip"]                                            = "Dai priorità a iLvl basso per auto-equipaggiamento",
    ["Enable Vendor Sell Confirmation Dialog"]                                        = "Abilita conferma vendita dal mercante",
    ["Vendor preview on Right (Default On)"]                                          = "Anteprima vendita a destra (predefinito attivo)",
    ["Draggable by Right Click"]                                                      = "Trascinabile con clic destro",
    ["Lock AH in Place (Buttons Only Mouse)"]                                         = "Blocca AH in posizione (pulsanti solo mouse)",
    ["Use Bag 1 for Disenchant"]                                                      = "Usa la borsa 1 per disincantare",
    ["This setting is recommended to be off due to the fact that disenchanting Mythic Gear results in honor and arena points."] =
    "Si consiglia di tenere questa impostazione disattivata, poiché il disincantamento dell'equipaggiamento mitico assegna onore e punti arena.",
    ["With this setting off, it will not vendor non-BoP white/grey items if the item can be attuned."] =
    "Con questa impostazione disattivata, non venderà oggetti bianchi/grigi non BoP se l'oggetto può essere Attuned.",
    ["Quick rules:"]                                                                  = "Regole rapide:",
    ["- Below selected tier: lenient."]                                               = "- Sotto il livello selezionato: permissivo.",
    ["- Existing variant: only higher tier can equip."]                               = "- Variante esistente: solo un livello superiore può equipaggiare.",
    ["Example (Warforged):"]                                                          = "Esempio (Warforged):",
    ["- Warforged duplicate: blocked. (Max 1)"]                                       = "- Doppione Warforged: bloccato. (Max 1)",
    ["- Lightforged: can still equip. (Max 1)"]                                       = "- Lightforged: può ancora equipaggiare. (Max 1)",
    ["- 'All Items': strict at all tiers."]                                           = "- 'All Items': rigoroso a tutti i livelli.",
    ["Drag an item here to assign its slot in AHSet."]                                = "Trascina un oggetto qui per assegnargli lo slot in AHSet.",
    ["Empty slot — drag an item here, Set AHSet, or /ahset."]                         = "Slot vuoto: trascina qui un oggetto, usa Set AHSet o /ahset.",
    ["Drag an item and left-click to add it to AHIgnore."]                            = "Trascina un oggetto e fai clic sinistro per aggiungerlo a AHIgnore.",
    ["Right-click to remove from this preset."]                                        = "Clic destro per rimuoverlo da questo preset.",
    ["Item ID %s"]                                                                     = "ID oggetto %s",
    ["Enter a name for the new AHSet preset:"]                                         = "Inserisci un nome per il nuovo preset AHSet:",
    ["A preset with that name already exists."]                                        = "Esiste già un preset con quel nome.",
    ["Invalid preset name."]                                                           = "Nome preset non valido.",
    ["Delete AHSet preset \"%s\"?"]                                                    = "Eliminare il preset AHSet \"%s\"?",
    ["List Management"]                                                                = "Gestione liste",
    ["AHSet is stored per character (GUID). Presets swap the saved item-to-slot map. AHIgnore / Always Vendored are account-wide."] =
    "AHSet è salvato per personaggio (GUID). I preset cambiano la mappa oggetto-slot salvata. AHIgnore / Always Vendored sono condivisi a livello account.",
    ["AHSet preset"]                                                                   = "Preset AHSet",
    ["New"]                                                                            = "Nuovo",
    ["Delete"]                                                                         = "Elimina",
    ["Set AHSet"]                                                                      = "Set AHSet",
    ["Set AHSet (/ahsetall)"]                                                          = "Set AHSet (/ahsetall)",
    ["After confirmation, copies your equipped items into this preset."]               = "Dopo la conferma, copia in questo preset gli oggetti che hai equipaggiati.",
    ["Option control arrays initialized"]                                              = "Array dei controlli opzioni inizializzati",
    ["Options panels initialized successfully"]                                        = "Pannelli opzioni inizializzati con successo",
    ["'%s' added to AHSet, designated for slot %s."]                                   = "'%s' aggiunto ad AHSet, assegnato allo slot %s.",
    ["'%s' (ID: %s) added to AHSet, designated for slot %s."]                          = "'%s' (ID: %s) aggiunto ad AHSet, assegnato allo slot %s.",
}

-- ʕ •ᴥ•ʔ✿ Locale (Portuguese-BR) ✿ ʕ •ᴥ•ʔ
local AH_LOCALES = _G.AH_LOCALES or {}
_G.AH_LOCALES = AH_LOCALES

AH_LOCALES["ptBR"] = {
    ["Equip Attunables"]                                                              = "Equipar Attunables",
    ["Prepare Disenchant"]                                                            = "Preparar desencantamento",
    ["Vendor Attuned"]                                                                = "Vender Attuned",
    ["Vendor Attuned Items"]                                                          = "Vender itens Attuned",
    ["Add To Vendor"]                                                                 = "Adicionar à lista de venda",
    ["System Default"]                                                                = "Padrão do sistema",
    ["English (US)"]                                                                  = "English (US)",
    ["Español"]                                                                       = "Español",
    ["Deutsch"]                                                                       = "Deutsch",
    ["Select Language:"]                                                              = "Selecionar idioma:",
    ["Moves fully attuned mythic items to bag %d."]                                   = "Move itens míticos totalmente Attuned para a bolsa %d.",
    ["Clears target bag first, then fills with disenchant-ready items."]              =
    "Esvazia primeiro a bolsa de destino e depois a preenche com itens prontos para desencantar.",
    ["Attunable Items: %d"]                                                           = "Itens Attunable: %d",
    ["Qualifying Attunables (%d):"]                                                   = "Attunables qualificados (%d):",
    ["No qualifying attunables in bags."]                                             = "Nenhum Attunable qualificado nas bolsas.",
    ["Items to be sold (%d):"]                                                        = "Itens a serem vendidos (%d):",
    ["Always-vendor entries: %d"]                                                     = "Entradas Always-Vendor: %d",
    ["No items will be sold based on current settings."]                              = "Nenhum item será vendido conforme as configurações atuais.",
    ["Open merchant window to sell these items."]                                     = "Abra a janela do vendedor para vender estes itens.",
    ["Drag an item here or pick it up and click to toggle always-vendor."]            = "Arraste um item até aqui ou pegue-o e clique para ativar/desativar Always-Vendor.",
    ["Items added here are always included in AH vendor previews and selling."]       = "Itens adicionados aqui sempre são incluídos nas pré-visualizações e na venda de AH.",
    ["Hold left 1s on this button for bulk add mode (cursor items add-only)."]        = "Segure o clique esquerdo por 1 s neste botão para o modo de adição em massa (itens do cursor apenas são adicionados).",
    ["Bulk mode: click this button again or close the vendor to exit."]               = "Modo em massa: clique neste botão novamente ou feche o vendedor para sair.",
    ["Bulk add mode is ON."]                                                          = "O modo de adição em massa está LIGADO.",
    ["Always-vendor skipped for Warforged/Lightforged (see options)."]                = "Always-Vendor ignorado para WF/LF (veja as opções).",
    ["Ignore Always-Vendor for Warforged and Lightforged"]                            = "Ignorar Always-Vendor para Warforged e Lightforged",
    ["When enabled, Warforged and Lightforged variants cannot be added to the always-vendor list and do not use the always-vendor bypass when selling."] =
    "Quando ativado, variantes Warforged e Lightforged não podem ser adicionadas à lista Always-Vendor e não usam o desvio Always-Vendor ao vender.",
    ["Items must be: Mythic, 100% attuned, soulbound, not in sets/ignore lists."]     =
    "Os itens devem ser: míticos, 100%% Attuned, vinculados à alma e fora de conjuntos/listas ignoradas.",
    ["Prepare Disenchant Include BoE Mythic Weapons"]                                  =
    "Preparar desencantamento: armas míticas BoE (nível de item 245)",
    ["Update AHSet"]                                                                  = "Atualizar AHSet",
    ["Sets AHSet to be equal to your currently equiped items."]                       =
    "Define AHSet igual aos seus itens atualmente equipados.",
    ["This will delete your current AHSet."]                                          = "Isso apagará o seu AHSet atual.",
    ["Are you sure you want to update AHSet to match your currently equipped items?"] =
    "Tem certeza que quer atualizar AHSet para corresponder aos itens atualmente equipados?",
    ["AHSet 1H pre-swap for off-hand attune"] =
    "AHSet: pré-troca de 1H para Attune em mão secundária (multiclasse Guerreiro)",
    ["AHSet 1h2h swap"] = "Multiclasse Guerreiro · troca 1H / 2H",
    ["AHSet 1h2h swap tip line 1"] =
    "No multiclasse estilo Chromie, a sua classe de UI muitas vezes não é Guerreiro mesmo quando você joga como tal. Com esta opção ativada e o sinalizador de troca do preset definido, Equip All pode substituir uma 2H na mão principal pela sua de uma mão de AHSet para que um Attunable de mão secundária possa ser equipado.",
    ["AHSet 1h2h swap tip line 2"] = "Você precisa de uma 2H equipada na mão principal que não esteja Attuning ativamente, um Attunable de mão secundária nas bolsas e uma 1H nas bolsas mapeada para Main Hand ou para a linha '1H Weapon Swaps' no Gerenciador de listas.",
    ["AHSet 1h2h swap tip line 3"] = "Titan's Grip é jogado com uma arma a 2H na mão principal e ou outra 2H TG ou um machado de uma mão na mão secundária (por exemplo um build de Fúria estilo flurry); esse é o seu par real de armas, não as linhas '1H Weapon Swaps' / prep. Equip All normalmente ignora essa troca 2H→uma mão na principal enquanto TG é detectado para que o trabalho nas bolsas possa usar a sua mão secundária. Exceção: as de uma mão exclusivas de mão principal não podem ser equipadas em mão secundária, então essa troca pode mesmo assim acontecer. O sinalizador de troca é ativado quando a mão principal aponta para uma 2H e você mapeia uma de uma mão para Main Hand ou para a linha '1H Weapon Swaps'; /ahset 1hspecial2h ainda pode forçá-lo antes que existam.",
    ["AHSet 1h2h swap tip line 4"] = "A detecção de mão secundária é estrita quando este preset mapeia algo para Off Hand ou para o quadrado prep de mão secundária (as de uma mão ambíguas precisam de /ahset … oh). Caso contrário, é flexível.",
    ["AHSet 1h2h swap tip line 5"] = "/ahset 1hspecial2h remove limpa o sinalizador opcional de forçar; 'Set AHSet' apaga o preset inteiro.",
    ["Off-hand swap trigger"] = "Gatilho de troca de mão secundária",
    ["AHSet OH trigger strict"] = "Apenas AHSet / mão secundária nativa (estrito)",
    ["AHSet OH trigger loose"] = "Qualquer 1H utilizável em mão secundária (flexível)",
    ["AHSet OH trigger strict tip"] =
    "Estrito: escudos, itens segurados na mão e armas de mão secundária sempre contam. As de uma mão ambíguas só contam se você as mapeou com /ahset <link> oh (mão secundária de AHSet).",
    ["AHSet OH trigger loose tip"] =
    "Flexível: qualquer de uma mão Attunable nas bolsas conta como motivo para trocar, mesmo sem mapeamento de mão secundária de AHSet (pode trocar com mais frequência).",
    ["AHSet 1h2h preset button title"] = "Troca 1H/2H multiclasse Guerreiro (preset)",
    ["AHSet 1h2h preset tip line 1"] =
    "Alterna o sinalizador de troca do preset (igual a /ahset 1hspecial2h). Não é uma chave genérica: existe porque Guerreiros multiclasse muitas vezes usam um perfil principal a 2H enquanto itens de mão secundária ainda precisam de Attuning.",
    ["AHSet 1h2h preset tip line 2"] = "Equip All só realiza a troca quando este sinalizador está Ligado, a caixa acima está habilitada e as outras condições do tooltip são atendidas.",
    ["AHSet 1h2h preset tip line 3"] = "Clique de novo para Desligar e remover o sinalizador apenas deste preset.",
    ["MC 1h2h: On"] = "MC 1h2h: Ligado",
    ["MC 1h2h: Off"] = "MC 1h2h: Desligado",
    ["AHSet 1h2h list title"] = "MC Guerreiro · 1H/2H (este preset)",
    ["AHSet prep paper strip label"] = "1H Weapon Swaps",
    ["AHSet prep paper strip drag hint"] = "Preparar armas",
    ["AHSet prep MH slot label"] = "1H · linha de mão principal",
    ["AHSet prep OH slot label"] = "Linha de mão secundária",
    ["AHSet prep slot empty slash hint"] = "'Set AHSet', /ahset prepmh, /ahset prep1h ou /ahset prepoh também funcionam.",
    ["AHSet keep item in bags for instance signature"] =
    "Mantenha o item nas bolsas ao adicioná-lo ao AHSet para que sua assinatura única possa ser salva. Se você só tiver uma cópia, um link de item equipado sozinho pode não ser suficiente.",
    ["AHSet usage signature reminder"] =
    "Itens únicos: coloque-os nas bolsas antes de /ahset para que assinaturas de instância possam ser salvas quando Custom_GetItemGuid estiver disponível.",
    ["AHSet 2h swap strip explanation"] =
    "Aqui não há um interruptor separado: Equip All usa seus mapeamentos de armas neste preset. Mapeie uma de uma mão para Main Hand ou para os quadros abaixo quando a mão principal do preset for uma 2H.",
    ["AHSet auto status swap on"] = "Caminho de troca prep 1H: ativo para este preset.",
    ["AHSet auto status swap off"] = "Caminho de troca prep 1H: inativo (mapeie uma de uma mão para Main Hand ou para os quadros abaixo, ou use /ahset 1hspecial2h para forçar).",
    ["AHSet auto status oh fmt"] = "Detecção de Attunable de mão secundária: %s.",
    ["AHSet OH trigger strict short"] = "estrito",
    ["AHSet OH trigger loose short"] = "flexível",
    ["Weapon panel multiclass header"] = "Multiclasse Guerreiro · troca AHSet",
    ["Weapon panel TG detection note"] = "Titan's Grip é detectado a partir dos seus talentos (incluindo abas de talentos multiclasse estilo Chromie). A lógica de 2H dupla em bolsas/equipamento se aplica apenas a machados, maças e espadas de duas mãos, não a cajados ou armas de haste.",
    ["AHSet 2h swap section title"] = "1H Weapon Swaps",
    ["AHSet 1h2h preset row label"] = "Troca 1H/2H neste preset",
    ["AHSet swap flag on"] = "Ligado",
    ["AHSet swap flag off"] = "Desligado",
    ["Yes"]                                                                           = "Sim",
    ["No"]                                                                            = "Não",
    ["Cancel"]                                                                        = "Cancelar",
    ["Toggle Auto-Equip"]                                                             = "Alternar autoequipar",
    ["Disable Auto-Equip"]                                                            = "Desativar autoequipar",
    ["Enable Auto-Equip"]                                                             = "Ativar autoequipar",
    ["Currently enabled."]                                                            = "Atualmente ativado.",
    ["Currently disabled."]                                                           = "Atualmente desativado.",
    ["Open Settings"]                                                                 = "Abrir configurações",
    ["Opens the General Logic Options settings page."]                                = "Abre a página de configurações 'General Logic Options'.",
    ["Hold Shift for additional options"]                                             = "Segure Shift para opções adicionais",
    ["Background Color"]                                                              = "Cor de fundo",
    ["Equip Attunable Affixes up to:"]                                                = "Equipar afixos Attunable até:",
    ["Affix-Only Minimum Forge"]                                                      = "Forge mínima de Affix-Only",
    ["Works only when 'Equip New Affixes Only' is enabled."]                          =
    "Funciona apenas quando 'Equip New Affixes Only' está ativado.",
    ["'All Items' disables the forge threshold behavior."]                            =
    "'All Items' desativa o comportamento de limite de forge.",
    ["When enabled, this setting favors affixes you have not attuned yet."]           =
    "Quando ativada, esta opção favorece afixos que você ainda não fez Attune.",
    ["Use the dropdown to choose where lenient behavior ends."]                       =
    "Use o menu suspenso para escolher onde o comportamento permissivo termina.",
    ["Items below the selected forge tier can equip even if already seen."]           =
    "Itens abaixo do nível de forge selecionado podem ser equipados mesmo que já tenham sido vistos.",
    ["At the selected tier and above, the addon prefers truly new affixes."]          =
    "A partir do nível selecionado, o addon prefere afixos verdadeiramente novos.",
    ["If a variant is already attuned, only higher forge tiers can still auto-equip."] =
    "Se uma variante já está Attuned, apenas níveis de forge superiores ainda podem se auto-equipar.",
    ["Example: with 'Warforged', duplicate Warforged is blocked, but Lightforged can still equip."] =
    "Exemplo: com 'Warforged', um WF duplicado é bloqueado, mas LF ainda pode ser equipado.",
    ["Below this tier: lenient equip behavior."]                                      = "Abaixo deste nível: comportamento permissivo de equipamento.",
    ["At this tier and above: strict new-affix behavior."]                            = "Neste nível e acima: comportamento estrito de novos afixos.",
    ["When a variant already exists, only higher forge tiers can override."]          =
    "Quando uma variante já existe, apenas níveis de forge superiores podem substituí-la.",
    ["'All Items' applies strict behavior to every forge tier."]                      =
    "'All Items' aplica comportamento estrito a todos os níveis de forge.",
    ["Use the dropdown to set the highest forge tier that ignores attunement history (inclusive)."] =
    "Use o menu suspenso para definir o maior nível de forge que ignora o histórico de Attunement (inclusive).",
    ["Example: 'Warforged' allows Base/Titanforged/Warforged to equip even if already seen; Lightforged still requires a new affix or no prior variant."] =
    "Exemplo: 'Warforged' permite que Base/TF/WF sejam equipados mesmo já vistos; LF ainda exige um afixo novo ou nenhuma variante prévia.",
    ["'All Items' removes this forge-tier limit while keeping the strict new-affix preference."] =
    "'All Items' remove esse limite de nível de forge mantendo a preferência estrita por novos afixos.",
    ["Select the highest forge tier that can equip regardless of prior attunement history."] =
    "Selecione o maior nível de forge que pode ser equipado independentemente do histórico de Attunement.",
    ["This applies only while the checkbox is enabled."]                              =
    "Isso se aplica apenas enquanto a caixa estiver marcada.",
    ["Tiers above your selected value still require a truly new affix (or no variant attuned yet)."] =
    "Níveis acima do valor selecionado ainda exigem um afixo verdadeiramente novo (ou nenhuma variante ainda Attuned).",
    ["'All Items' removes the forge-tier cap."]                                       = "'All Items' remove o limite de nível de forge.",
    ["- Selected tier and up: unattuned variant only."]                               = "- A partir do nível selecionado: apenas variante não Attuned.",
    ["- Does not check extra affix unlocks."]                                         = "- Não verifica desbloqueios de afixos extras.",
    ["- Base and TF - Equips all if Affix is attunable."]                             = "- Base e TF: equipa tudo se o afixo for Attunable.",
    ["Hide Center Button in Normal Mode"]                                             = "Ocultar botão central no modo normal",
    ["Hides the center action button in normal view."]                                = "Oculta o botão de ação central na visualização normal.",
    ["Hold Ctrl to show Open Settings and Update AHSet."]                             =
    "Segure Ctrl para mostrar 'Abrir configurações' e 'Atualizar AHSet'.",
    ["Sell Attuned Mythic Gear?"]                                                     = "Vender equipamento mítico Attuned?",
    ["Auto Equip Attunables Automaticly"]                                             = "Equipar Attunables automaticamente",
    ["Do Not Sell BoE Items"]                                                         = "Não vender itens BoE",
    ["Do Not Sell Grey And White Items"]                                              = "Não vender itens cinza e brancos",
    ["Limit Selling to 12 Items?"]                                                    = "Limitar venda a 12 itens?",
    ["Disable Auto-Equip Mythic BoE"]                                                 = "Desativar autoequipar BoE mítico",
    ["Equip BoE Bountied Items"]                                                      = "Equipar itens BoE de recompensa",
    ["Prioritize Low iLvl for Auto-Equip"]                                            = "Priorizar iLvl baixo para autoequipar",
    ["Enable Vendor Sell Confirmation Dialog"]                                        = "Ativar confirmação de venda no vendedor",
    ["Vendor preview on Right (Default On)"]                                          = "Prévia de venda à direita (padrão ligado)",
    ["Draggable by Right Click"]                                                      = "Arrastável com clique direito",
    ["Lock AH in Place (Buttons Only Mouse)"]                                         = "Travar AH no lugar (botões apenas com mouse)",
    ["Use Bag 1 for Disenchant"]                                                      = "Usar bolsa 1 para desencantar",
    ["This setting is recommended to be off due to the fact that disenchanting Mythic Gear results in honor and arena points."] =
    "Recomenda-se deixar esta opção desligada, pois desencantar equipamento mítico gera honra e pontos de arena.",
    ["With this setting off, it will not vendor non-BoP white/grey items if the item can be attuned."] =
    "Com esta opção desligada, não venderá itens brancos/cinzas não BoP se o item puder ser Attuned.",
    ["Quick rules:"]                                                                  = "Regras rápidas:",
    ["- Below selected tier: lenient."]                                               = "- Abaixo do nível selecionado: permissivo.",
    ["- Existing variant: only higher tier can equip."]                               = "- Variante existente: apenas nível superior pode equipar.",
    ["Example (Warforged):"]                                                          = "Exemplo (Warforged):",
    ["- Warforged duplicate: blocked. (Max 1)"]                                       = "- Warforged duplicado: bloqueado. (Máx. 1)",
    ["- Lightforged: can still equip. (Max 1)"]                                       = "- Lightforged: ainda pode equipar. (Máx. 1)",
    ["- 'All Items': strict at all tiers."]                                           = "- 'All Items': estrito em todos os níveis.",
    ["Drag an item here to assign its slot in AHSet."]                                = "Arraste um item aqui para atribuir o slot dele no AHSet.",
    ["Empty slot — drag an item here, Set AHSet, or /ahset."]                         = "Slot vazio: arraste um item aqui, use Set AHSet ou /ahset.",
    ["Drag an item and left-click to add it to AHIgnore."]                            = "Arraste um item e clique com o botão esquerdo para adicioná-lo ao AHIgnore.",
    ["Right-click to remove from this preset."]                                        = "Clique com o botão direito para remover deste preset.",
    ["Item ID %s"]                                                                     = "ID do item %s",
    ["Enter a name for the new AHSet preset:"]                                         = "Digite um nome para o novo preset de AHSet:",
    ["A preset with that name already exists."]                                        = "Já existe um preset com esse nome.",
    ["Invalid preset name."]                                                           = "Nome de preset inválido.",
    ["Delete AHSet preset \"%s\"?"]                                                    = "Excluir o preset de AHSet \"%s\"?",
    ["List Management"]                                                                = "Gerenciamento de listas",
    ["AHSet is stored per character (GUID). Presets swap the saved item-to-slot map. AHIgnore / Always Vendored are account-wide."] =
    "AHSet é armazenado por personagem (GUID). Presets trocam o mapa salvo de item para slot. AHIgnore / Always Vendored são da conta inteira.",
    ["AHSet preset"]                                                                   = "Preset de AHSet",
    ["New"]                                                                            = "Novo",
    ["Delete"]                                                                         = "Excluir",
    ["Set AHSet"]                                                                      = "Set AHSet",
    ["Set AHSet (/ahsetall)"]                                                          = "Set AHSet (/ahsetall)",
    ["After confirmation, copies your equipped items into this preset."]               = "Após a confirmação, copia seus itens equipados para este preset.",
    ["Option control arrays initialized"]                                              = "Arrays de controle de opções inicializados",
    ["Options panels initialized successfully"]                                        = "Painéis de opções inicializados com sucesso",
    ["'%s' added to AHSet, designated for slot %s."]                                   = "'%s' adicionado ao AHSet, designado para o slot %s.",
    ["'%s' (ID: %s) added to AHSet, designated for slot %s."]                          = "'%s' (ID: %s) adicionado ao AHSet, designado para o slot %s.",
}

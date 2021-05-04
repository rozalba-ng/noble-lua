
local AIO = AIO or require("AIO")

local AddonStartTeleHandlers = AIO.AddHandlers("AIOAddonStarterTeleporter", {})

local UnitEntry = 9921053
local SecretItem = 900
local TeleporterPhrases = {
"Я бы не стал так опрометчиво забегать в телепортатор без разрешения.",
"Сначала выбери конечную точку! Иначе по кусочкам перенесет!",
"Запомни: сначала я настраиваю портал, потом ты заходишь! Дилетанты...",
"Далеко собираешься? Ты бы хоть выбрал куда отправляться.",
"Совсем без разницы куда тебя отправят? Давай помогу настроить портал.",
"Помню одного паренька который так же прыгнул без настройки в портал. Больше я его, кстати, не видел."
}

local TeleporterPhrasesCorrectPort = {
"Готово! Теперь вставай на платформу рядом со мной и она перенесет тебя туда, куда нужно! ",
}

local WrongJumpCount = {}
local TeleportKnockdown = {}
local ChosenPlayerTeleport = {}
----// [1] =   { "НАЗВАНИЕ РАЗДЕЛА", НОМЕР_РЕЖИМА,
----// НОМЕР_РЕЖИМА: 0 - обычный список
----// НОМЕР_РЕЖИМА: 1 - модульные локации с предупреждением
----// НОМЕР_РЕЖИМА: 3 - для отключения списка. Выбирается 1 из списка при клике.
----// НОМЕР_РЕЖИМА: 4 - для списка, который виден только при наличии итема.

----// {"НАЗВАНИЕ", НОМЕР_МАПЫ, X, Y, Z, ОРИЕНТАЦИЯ, ФАЗА},
local Teleport_table = {
        [1] =   { "Торговцы и учителя профессий", 0,
                {"К продавцам питомцев", 1, 8005, -2673, 512.1, 5.9, 1},
                {"К рынку ездовых питомцев", 1, 7492, -2483, 459, 3.2, 1},
                {"К аукционисту", 1, 7963, -2432, 489, 1.65, 1},
                {"К учителям профессий", 1, 7965, -2576, 493.2, 6.2, 1},
                {"Корабль контрабандистов", 1, 7751, -2633, 459, 3.6, 1},
        },
        [2] =   { "Общесерверные локации", 0,
                {"Андорал", 901, 1678.810059, -1363.930054, 69.893494, 3.635610, 1},
                {"Астранаар (Ночные эльфы)", 2105, 2729.848389, -370.810364, 107.120834, 3.987438, 1},
                {"Альтерак (столица Северных Волков)", 801, -1296.390015, 114.396004, 104.753998, 2.786900, 1},
                {"Альтерак (Бернхольм)", 801, 1144.540039, -976.880005, 125.328079, 5.823030, 1},
                {"Внутренние земли (Орда)", 901, 467.757385, -3607.046875, 118.396866, 4.601053, 1},
                {"Гавань Менетилов", 901, -3674.899902, -284.726990, 3.855650, 4.699050, 1},
                {"Гилнеас", 901, -1319.890015, 1791.500000, 10.668268, 3.883800, 1},
                {"Дал'Гронд", 901, -4142.765137, -5441.999512, 28.337221, 5.449099, 1},
                {"Даларан", 901, -191.822983, 105.548187, 54.825768, 0.194782, 1},
                {"Крепость Северной Стражи", 2105, -1918.040039, -3842.909912, 9.266480, 3.005350, 1},
                {"Луносвет", 901, 7734.020020, -4609.259766, 13.514867, 6.234380, 1},
                {"Стромгард", 901, -1428.310059, -1805.060059, 68.018829, 3.092910, 1},
                {"Южнобережье", 901, -877.286987, -541.385010, 7.654230, 0.076970, 1},
                {"Янтарная Мельница", 901, -135.701462, 1044.697632, 68.467491, 4.724164, 1},
               
        },
        [3] =   { "Дополнительные локации", 0,
                {"Крестфол", 902, -1121.089966, -2509.330078, 2.935100, 0.680599, 1},
                {"Тол Барад", 732, 143.380005, 1125.479980, 1.189980, 3.111067, 1},
                {"Долина Штормсонг", 1643, 2467.123047, -8.324386, 57.927937, 6.146457, 1},
                {"Боралус", 1643, 1020.750000, -658.453003, 7.585129, 0.787683, 1},
                {"Тирагардское Поморье", 1643, -386.657013, 1026.119995, 15.934800, 4.514400, 1},
                {"Друствар", 1643, 460.601013, 3532.340088, 187.917999, 5.901420, 1},
                {"Старый мир", 1, -8155.810059, -4588.069824, 0.303943, 3.332640, 1},
                {"Даларан (Нордскол)", 571, 5721.870117, 738.127014, 641.768982, 2.491540, 1},
                {"Шаттрат", 530, -1849.420044, 5401.459961, -12.427900, 2.008190, 1},
                {"Дренор", 1116, 1589.050049, 552.458008, 74.922958, 3.868340, 1},
                {"Сурамар", 1220, 966.226013, 3951.540039, 17.360701, 1.021540, 1},
                {"Зандалар", 1642, 3136.366455, 3150.830322, 113.442558, 3.098110, 1},
                {"Пандария", 904, 1208.589966, 1376.770020, 363.664001, 5.309690, 1},
        },
        [4] =   { "Модульные локации (требуются отдельные патчи)", 1,
                {"Кезан (Ведущий: AcoStar#7819)", 916, -8090.9, 1567, 15.3, 1, 1},
                {"Дор'Аран (Ведущий: Elnir#6156)", 913, 2506, 816, 566, 1, 1},
        },
       --[[ [5] =   { "К рынку ездовых питомцев", 3, --// 3 для отключения списка. Выбирается 1 из списка при клике.
                    {"", 1, 8005, -2673, 512.1, 5.9}, 
                },]]
        --[[[6] =   { "К рынку ездовых питомцев", 4, --// 4 для списка, который виден только при наличии итема.
                    {"", 1, 8005, -2673, 512.1, 5.9}, 
                },]]
                               
                                
};            
 


function Teleporter_Gossip(event, player, unit)
        if (#Teleport_table <= 10) then
                for i, v in ipairs(Teleport_table) do
                        if(v[2] < 4 or (v[2] == 4 and player:HasItem( SecretItem ))) then
                                player:GossipMenuAddItem(0, v[1], 0, i)
                        end
                end
                player:GossipSendMenu(924772, unit)
        else
                print("This teleporter only supports 10 different menus.")
        end
end   

local function TeleportSpeaker(player, text)
TeleportCreature = player:GetNearestCreature( 15, UnitEntry )
player:GossipComplete()
player:GossipClearMenu()
player:GossipMenuAddItem(0, "TalkingHead", 1, 1)
player:GossipSendMenu(100, TeleportCreature)
AIO.Handle(player,"AIOAddonStarterTeleporter","ElunaTeleporterTalkingHead", text, "Тотти Варпопрыг", "technical")
player:GossipComplete()
end 
 
function Teleporter_Event(event, player, unit, sender, intid, code)
        if intid ~= 0 and intid <= #Teleport_table and Teleport_table[intid][2] == 3 then
            ChosenPlayerTeleport[player:GetName()] = {Teleport_table[intid][3][2], Teleport_table[intid][3][3], Teleport_table[intid][3][4], Teleport_table[intid][3][5], Teleport_table[intid][3][6], Teleport_table[intid][3][7]}
            WrongJumpCount[player:GetName()] = 0
            player:GossipComplete()
            --[[if math.random(10) > 9 then
                unit:SendUnitSay("|cffFFFF9F" .. TeleporterPhrasesCorrectPort[math.random(#TeleporterPhrasesCorrectPort)], 0)
            else
                player:SendBroadcastMessage("|cffFFFF9FТотти Варпопрыг говорит: " .. TeleporterPhrasesCorrectPort[math.random(#TeleporterPhrasesCorrectPort)])
            end]]
            TeleportSpeaker(player, TeleporterPhrasesCorrectPort[math.random(#TeleporterPhrasesCorrectPort)])
            player:SendBroadcastMessage("Чтобы воспользоваться телепортом, встаньте на площадку транспортера.")
        return
        end
        if(intid == 0) then
                Teleporter_Gossip(event, player, unit)
        elseif(intid <= 10) then
                    for i, v in ipairs(Teleport_table[intid]) do
                            if (i > 2) then
                                    player:GossipMenuAddItem(0, v[1], 0, intid..i)
                            end
                    end
                    player:GossipMenuAddItem(0, "Назад", 0, 0)
                    player:GossipSendMenu(924772, unit)
        elseif(intid > 10) then
                for i = 1, #Teleport_table do
                        for j, v in ipairs(Teleport_table[i]) do
                                if(intid == tonumber(i..j)) then
                                        ChosenPlayerTeleport[player:GetName()] = {v[2], v[3], v[4], v[5], v[6], v[7]}
                                        WrongJumpCount[player:GetName()] = 0
                                        player:GossipComplete()
                                        --[[if math.random(10) > 9 then
                                            unit:SendUnitSay("|cffFFFF9F" .. TeleporterPhrasesCorrectPort[math.random(#TeleporterPhrasesCorrectPort)], 0)
                                        else
                                            player:SendBroadcastMessage("|cffFFFF9FТотти Варпопрыг говорит: " .. TeleporterPhrasesCorrectPort[math.random(#TeleporterPhrasesCorrectPort)])
                                        end]]
                                        TeleportSpeaker(player, TeleporterPhrasesCorrectPort[math.random(#TeleporterPhrasesCorrectPort)])
                                        player:SendBroadcastMessage("Чтобы воспользоваться телепортом, встаньте на площадку транспортера.")
                                        if Teleport_table[i][2] == 1 then
                                            TeleportSpeaker(player, "Внимательно! Эти координаты точно верны?  Хорошенько подумай, прежде чем входить в портал.|cffee2727 ~Для корректной телепортации требуется пользовательский патч.~")
                                        end
                                end
                        end
                end
        end
end
 
RegisterCreatureGossipEvent(UnitEntry, 1, Teleporter_Gossip)
RegisterCreatureGossipEvent(UnitEntry, 2, Teleporter_Event)


function TriggerStarterTeleport(event, player, spell, skipCheck)
if player:HasAura( 54643 ) then return end
    if spell:GetEntry() == 36177 then
        if not ChosenPlayerTeleport[player:GetName()] then
            if WrongJumpCount[player:GetName()] ~= nil and WrongJumpCount[player:GetName()] > 6 then
                player:NearTeleport( 7899, -2778, 487, 2.3 )
                WrongJumpCount[player:GetName()] = 0
                player:CastSpell( player, 68848, false );
                AIO.Handle(player,"AIOAddonStarterTeleporter","CloseTalkingHead")
            else
            TeleportKnockdown[player:GetName()] = true
            player:MoveJump( 7846, -2574, 489.5, 20, 3 )
            TeleportSpeaker(player, TeleporterPhrases[math.random(#TeleporterPhrases)])
                if WrongJumpCount[player:GetName()] then
                    WrongJumpCount[player:GetName()] = WrongJumpCount[player:GetName()] + 1
                else
                    WrongJumpCount[player:GetName()] = 1
                end
            end
        else
            player:CastSpell( player, 54643, false );
            player:Teleport(ChosenPlayerTeleport[player:GetName()][1], ChosenPlayerTeleport[player:GetName()][2], ChosenPlayerTeleport[player:GetName()][3], ChosenPlayerTeleport[player:GetName()][4], ChosenPlayerTeleport[player:GetName()][5])
            player:SetPhaseMask( ChosenPlayerTeleport[player:GetName()][6] )
            ChosenPlayerTeleport[player:GetName()] = nil
            AIO.Handle(player,"AIOAddonStarterTeleporter","CloseTalkingHead")
        end
    elseif spell:GetEntry() == 49375 then  ---// Триггер от ловушки на полу. Если до этого зашел в портал неправильно - собъет с ног.
        if TeleportKnockdown[player:GetName()] == true then 
            player:CastSpell( player, 68848, false );
            TeleportKnockdown[player:GetName()] = false
        end
    end
end
RegisterPlayerEvent( 5, TriggerStarterTeleport)


function TH_OnLogin(event, player)--// Костыльно фиксит TalkingHead.
            TestCreature = player:GetNearestGameObject(100)
            if TestCreature then
                player:GossipComplete()
                player:GossipSendMenu(100, TestCreature)
                player:GossipComplete()
            end
end
RegisterPlayerEvent(3, TH_OnLogin)
RegisterPlayerEvent(28, TH_OnLogin)


-- RoleStatSystem.lua
ROLE_STAT_STRENGTH = 0;
ROLE_STAT_AGLILITY = 1;
ROLE_STAT_INTELLECT = 2;
ROLE_STAT_STAMINA = 3;
ROLE_STAT_VERSA = 4;
ROLE_STAT_WILL = 5;
ROLE_STAT_SPIRIT = 6;
ROLE_STAT_CHARISMA = 7;
ROLE_STAT_AVOID = 8;
ROLE_STAT_LUCK = 9;
ROLE_STAT_STEALTH = 10;
ROLE_STAT_INIT = 11;
ROLE_STAT_PERCEPT = 12;
ROLE_STAT_HEALTH = 100;
ROLE_STAT_ARMOR = 101;

local npc_health = {};
local PLAYER_EVENT_ON_EQUIP = 29;

local gmToCrit = {}

local ROLE_STAT_DEFAULT_TRESHOLD = 15;

local auraModificators = {
    [1] = { 88067, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    [2] = { 88068, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    [3] = { 88069, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
}

-- массовый ролевой бой (альтерак)
roleCombatArray = {};
roleCombat = {};
roleCombat.playerCombat = {};
roleCombat.playerCombatMove = {};
roleCombat.playerCombatFaction = {};
roleCombat.menuID = 6010;
roleCombat.diff_number = {};

local statCorrespondedDef = {
    [ROLE_STAT_STRENGTH] = ROLE_STAT_STAMINA, -- силе стойкость
    [ROLE_STAT_AGLILITY] = ROLE_STAT_VERSA, -- ловкости сноровка
    [ROLE_STAT_INTELLECT] = ROLE_STAT_WILL, -- интеллекту воля
    [ROLE_STAT_STAMINA] = ROLE_STAT_STRENGTH, -- стойкости сила
    [ROLE_STAT_VERSA] = ROLE_STAT_AGLILITY, -- сноровке ловкость
    [ROLE_STAT_WILL] = ROLE_STAT_INTELLECT -- воле интеллект
}

statAllowedInBattle = {
    [ROLE_STAT_STRENGTH] = 1, -- силе
    [ROLE_STAT_AGLILITY] = 1, -- ловкости
    [ROLE_STAT_INTELLECT] = 1, -- интеллекту
    [ROLE_STAT_STAMINA] = 0, -- стойкости
    [ROLE_STAT_VERSA] = 0, -- сноровке
    [ROLE_STAT_WILL] = 0, -- воле
    [ROLE_STAT_SPIRIT] = 1, -- дух
    [ROLE_STAT_CHARISMA] = 0, -- харизма
    [ROLE_STAT_AVOID] = 0, -- избегание
    [ROLE_STAT_LUCK] = 0, -- удача
    [ROLE_STAT_STEALTH] = 0, -- скрытность
    [ROLE_STAT_INIT] = 0, -- инициатива
    [ROLE_STAT_PERCEPT] = 0, -- восприятие
}

local statBaseTreshold = {
    [ROLE_STAT_STRENGTH] = 0, -- силе
    [ROLE_STAT_AGLILITY] = 0, -- ловкости
    [ROLE_STAT_INTELLECT] = 0, -- интеллекту
    [ROLE_STAT_STAMINA] = 0, -- стойкости
    [ROLE_STAT_VERSA] = 0, -- сноровке
    [ROLE_STAT_WILL] = 0, -- воле
    [ROLE_STAT_SPIRIT] = 15, -- дух
    [ROLE_STAT_CHARISMA] = 15, -- харизма
    [ROLE_STAT_AVOID] = 15, -- избегание
    [ROLE_STAT_LUCK] = 15, -- удача
    [ROLE_STAT_STEALTH] = 15, -- скрытность
    [ROLE_STAT_INIT] = 15, -- инициатива
    [ROLE_STAT_PERCEPT] = 15, -- восприятие
}

statNpcDoDefRoll = {
    [ROLE_STAT_STRENGTH] = 0, -- силе
    [ROLE_STAT_AGLILITY] = 0, -- ловкости
    [ROLE_STAT_INTELLECT] = 0, -- интеллекту
    [ROLE_STAT_STAMINA] = 1, -- стойкости
    [ROLE_STAT_VERSA] = 1, -- сноровке
    [ROLE_STAT_WILL] = 1, -- воле
    [ROLE_STAT_SPIRIT] = 0, -- дух
    [ROLE_STAT_CHARISMA] = 0, -- харизма
    [ROLE_STAT_AVOID] = 0, -- избегание
    [ROLE_STAT_LUCK] = 0, -- удача
    [ROLE_STAT_STEALTH] = 0, -- скрытность
    [ROLE_STAT_INIT] = 0, -- инициатива
    [ROLE_STAT_PERCEPT] = 0, -- восприятие
}

hpBuffAuraList = {
    --{ id = 88044, bonus = 1 },
    { id = 88039, bonus = 1 }, -- зелье "каменная кожа"
    --{ id = 88045, bonus = 1 },
    --{ id = 88071, bonus = 1 },
    --{ id = 88072, bonus = 1 },
    --{ id = 88046, bonus = 2 },
    --{ id = 88047, bonus = 2 },
    --{ id = 88048, bonus = 2 },
    --{ id = 88049, bonus = 2 },
    --{ id = 88074, bonus = 2 },
    --{ id = 88078, bonus = 2 },
    --{ id = 88073, bonus = 2 },
    --{ id = 88079, bonus = 1 },
	--{ id = 91205, bonus = 1 }, -- Бонус от Мастерская. 3 часа
}

local healthByType = {
    [3] = 2, --NPC
    [4] = 3 --PLAYER
};
local statnames = {
    [ROLE_STAT_STRENGTH] = "Сила",
    [ROLE_STAT_AGLILITY] = "Ловкость",
    [ROLE_STAT_INTELLECT] = "Интеллект",
    [ROLE_STAT_STAMINA] = "Стойкость",
    [ROLE_STAT_VERSA] = "Сноровка",
    [ROLE_STAT_WILL] = "Воля",
    [ROLE_STAT_SPIRIT] = "Дух",
    [ROLE_STAT_CHARISMA] = "Харизма", -- харизма
    [ROLE_STAT_AVOID] = "Избегание", -- избегание
    [ROLE_STAT_LUCK] = "Удача", -- удача
    [ROLE_STAT_STEALTH] = "Скрытность", -- скрытность
    [ROLE_STAT_INIT] = "Инициатива", -- инициатива
    [ROLE_STAT_PERCEPT] = "Восприятие", -- восприятие
}
local greenColor = "|cFF5fdb2e"

function gettargetDefValue(stat, target)
    if (statBaseTreshold[stat] > 0) then -- получаем фиксированный порог, используется для кубов с фиксированным порогом
        return statBaseTreshold[stat];
    end

    local tarDef = target:GetRoleStat(statCorrespondedDef[stat]);
    for i = 1, #auraModificators do
        if target:HasAura(auraModificators[i][1]) then
            tarDef = tarDef + auraModificators[i][stat + 5]
        end
    end

    if not target:ToPlayer() then
        local npcStatsValues = getStatsByCreature(target)
        if npcStatsValues then
            tarDef = npcStatsValues[statCorrespondedDef[stat]]; if tarDef == nil then tarDef = ROLE_STAT_DEFAULT_TRESHOLD end
        else
            tarDef = ROLE_STAT_DEFAULT_TRESHOLD;
        end
    end

    return tarDef;
end

function getDefRandByStatTypeAndTarget(stat, target)
    if (statBaseTreshold[stat] > 0) then -- юзается для кубов с фиксированным порогом
        return 0;
    end

    if not target:ToPlayer() and statNpcDoDefRoll[stat] == 0 then -- нпс в общем случае не кидают куб назащиту
        return 0;
    end

    return math.random(20);
end

local function getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand)
    if def_rand > 0 then
        return string.format("%s действие %s %s %s |c%s%s|r. \n(%u+%u |c%s%s|r %u+%u)", attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand);
    else
        return string.format("%s действие %s %s %s |c%s%s|r. \n(%u+%u |c%s%s|r порог %u)", attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def);
    end
end

function roleCombat.ChooseFactionGossip(event, player, object)
    local playerGuid = player:GetGUIDLow();
    local combat_id = roleCombat.playerCombat[playerGuid];
    player:GossipClearMenu() -- required for player gossip
    for index, faction_info in pairs(roleCombatArray[combat_id].factions) do
        player:GossipMenuAddItem(1, faction_info.name, 1, index)
    end
    player:GossipSendMenu(1, player, roleCombat.menuID) -- MenuId required for player gossip
end

function roleCombat.OnGossipSelect(event, player, object, sender, intid, code, menuid)
    local playerGuid = player:GetGUIDLow();
    if (intid == 99) then
        player:GossipComplete();
    else
        local combat_id = roleCombat.playerCombat[playerGuid];
        if (combat_id) then
            if (intid <= #roleCombatArray[combat_id].factions) then
                table.insert(roleCombatArray[combat_id].factions[intid].members, player:GetName());
                player:SendBroadcastMessage('|c00FF0632Вы присоединились к стороне: ' .. roleCombatArray[combat_id].factions[intid].name .. "|r");
                roleCombat.playerCombatMove[playerGuid] = true;
                roleCombat.playerCombatFaction[playerGuid] = intid;
                --player:AddAura(88011);
            end
        end
        player:GossipComplete();
    end
end

RegisterPlayerGossipEvent(roleCombat.menuID, 2, roleCombat.OnGossipSelect);

function roleCombatRound(eventId, delay, repeats)
    local combat_id = nil;
    for index, combat in pairs(roleCombatArray) do
        if (combat.roundId == eventId) then
            combat_id = index;
            break;
        end
    end
    if (combat_id ~= nil) then
        local faction1 = roleCombatArray[combat_id].factions[1];
        local faction2 = roleCombatArray[combat_id].factions[2];

        local f1_rand = math.random(6);
        local f2_rand = math.random(6);

        local winner = nil;
        local looser = nil;
        local round_result = "";

        if ((faction1.army_bonus + faction1.players_bonus + f1_rand) > (faction2.army_bonus + faction2.players_bonus + f2_rand)) then
            winner = 1;
            looser = 2;
            round_result = "победа " .. faction1.name;
        elseif ((faction1.army_bonus + faction1.players_bonus + f1_rand) == (faction2.army_bonus + faction2.players_bonus + f2_rand)) then
            winner = 0;
            looser = 0;
            round_result = "ничья"
        else
            winner = 2;
            looser = 1;
            round_result = "победа " .. faction2.name;
        end

        PrintError("Ролевая битва, " .. round_result .. ", цифры: " .. faction1.army_bonus .. " " .. faction1.players_bonus .. " " .. f1_rand .. " " .. faction2.army_bonus .. " " .. faction2.players_bonus .. " " .. f2_rand);
        faction1.players_bonus = 0;
        faction2.players_bonus = 0;



        if (winner > 0) then
            roleCombatArray[combat_id].factions[looser].army_bonus = roleCombatArray[combat_id].factions[looser].army_bonus - 1;
        else
            roleCombatArray[combat_id].factions[looser] = {}
            roleCombatArray[combat_id].factions[looser].army_bonus = 2;
            roleCombatArray[combat_id].factions[looser].name = "сражены";
        end

        if (roleCombatArray[combat_id].factions[looser].army_bonus > 0) then
            local roundFunction = CreateLuaEvent(roleCombatArray[combat_id].roundFunction, 240 * 1000, 1);
            roleCombatArray[combat_id].roundId = roundFunction;
        end

        for index, faction in pairs(roleCombatArray[combat_id].factions) do
            for ind, member_name in pairs(faction.members) do
                local member = GetPlayerByName(member_name);
                if (member) then
                    if (roleCombatArray[combat_id].factions[looser].army_bonus > 0) then
                        local playerGuid = member:GetGUIDLow();
                        roleCombat.playerCombatMove[playerGuid] = true;
                        member:SendBroadcastMessage('|c00FF0632Итог раунда: ' .. round_result .. '! Конец следующего раунда через 4 минуты.|r');
                        member:SendAreaTriggerMessage('|c00FF0632Итог раунда: ' .. round_result .. '! Конец следующего раунда через 4 минуты.|r');
                    else
                        member:RemoveAura(88011);
                        member:SendBroadcastMessage('|c00FF0632Битва завершилась! Войска фракции ' .. roleCombatArray[combat_id].factions[looser].name .. ' сражены.|r');
                        member:SendAreaTriggerMessage('|c00FF0632Битва завершилась! Войска фракции ' .. roleCombatArray[combat_id].factions[looser].name .. ' сражены.|r');
                        local wound = member:GetAura(88013);
                        if (wound) then
                            local wound_stack = wound:GetStackAmount();
                            local old_wound_stack = 0;
                            local old_wound = member:GetAura(88010);
                            if (old_wound) then
                                old_wound_stack = old_wound:GetStackAmount();
                            end
                            if ((wound_stack + old_wound_stack) >= 3) then
                                --member:CreateCorpse();
                                member:AddAura(8326, member);
                            end
                            member:RemoveAura(88013);
                            member:RemoveAura(88010);
                            local perm_wound = member:AddAura(88010, member);
                            perm_wound:SetStackAmount(wound_stack + old_wound_stack);
                        end
                    end
                end
            end
            local faction_leader = GetPlayerByName(faction.leader_name);
            if (faction_leader) then
                faction_leader:SendBroadcastMessage('Сила ваших войск: ' .. faction.army_bonus);
            end
        end
    end
end

local function playerOnEquip(event, player, item, bag, slot)
    local id1 = item:GetEnchantmentId(9)
    local id2 = item:GetEnchantmentId(10)
    local inv_type = item:GetInventoryType();
    if ((id1 ~= 0 or id2 ~= 0) and inv_type ~= 2 and inv_type ~= 6 and inv_type ~= 14 and inv_type ~= 23 and player:IsInWorld()) then
        player:AddAura(88009, player)
    end
end

function attackRoll(roller, target, spellid)
    local stat = 0;
    local attack_type = "Силовое";
    local action_type = "против"
    if (spellid == 88005 or spellid == "1" or string.upper(spellid) == "С") then
        stat = 0;
        attack_type = "Силовое";
    elseif (spellid == 88006 or spellid == "2" or string.upper(spellid) == "Л") then
        stat = 1;
        attack_type = "Ловкое";
    elseif (spellid == 88007 or spellid == "3" or string.upper(spellid) == "И") then
        stat = 2;
        attack_type = "Магическое";
    elseif ((spellid == 88008 or spellid == "4" or string.upper(spellid) == "Х") and roller:ToPlayer()) then
        stat = 6;
        attack_type = "Исцеляющее";
        action_type = "на";
    elseif ((spellid == 91154 or spellid == "5" or string.upper(spellid) == "СТ") and roller:ToPlayer()) then
        stat = 3;
        attack_type = "Защитное (стойкость)";
        action_type = "от";
    elseif ((spellid == 91155 or spellid == "6" or string.upper(spellid) == "СН") and roller:ToPlayer()) then
        stat = 4;
        attack_type = "Защитное (сноровка)";
        action_type = "от";
    elseif ((spellid == 91156 or spellid == "7" or string.upper(spellid) == "ВО") and roller:ToPlayer()) then
        stat = 5;
        attack_type = "Защитное (воля)";
        action_type = "от";
    elseif ((spellid == 91157 or spellid == "8" or string.upper(spellid) == "ХА") and roller:ToPlayer()) then
        stat = 7;
        attack_type = "Специальное (харизма)";
        action_type = "на";
    elseif ((spellid == 91158 or spellid == "9" or string.upper(spellid) == "ИЗ") and roller:ToPlayer()) then
        stat = 8;
        attack_type = "Специальное (избегание)";
        action_type = "на";
    elseif ((spellid == 91159 or spellid == "10" or string.upper(spellid) == "УД") and roller:ToPlayer()) then
        stat = 9;
        attack_type = "Специальное (удача)";
        action_type = "на";
    elseif ((spellid == 91160 or spellid == "11" or string.upper(spellid) == "СК") and roller:ToPlayer()) then
        stat = 10;
        attack_type = "Специальное (скрытность)";
        action_type = "на";
    elseif ((spellid == 91161 or spellid == "12" or string.upper(spellid) == "ИН") and roller:ToPlayer()) then
        stat = 11;
        attack_type = "Специальное (инициатива)";
        action_type = "на";
    elseif ((spellid == 91162 or spellid == "13" or string.upper(spellid) == "ВО") and roller:ToPlayer()) then
        stat = 12;
        attack_type = "Специальное (восприятие)";
        action_type = "на";
    end

    if (roller:HasAura(88011) and roller:ToPlayer()) then -- аура "Бой", кастер - юзер, цель - не важно
        local playerGuid = roller:GetGUIDLow();
        if (roleCombat.playerCombatMove[playerGuid] == true) then
            local player_att = roller:GetRoleStat(stat);
            local target_def = 3;
            local att_rand = math.random(20);
            local def_rand = math.random(20);

            local roller_name = roller:GetName();
            local target_name = "вражеской армии"

            local roll_maded = false;
            local isSuccess = false;

            if (statAllowedInBattle[stat] == 0) then
                roller:SendBroadcastMessage("Данную способность нельзя использовать в массовой битве.")
                return false
            elseif (stat == ROLE_STAT_SPIRIT) then
                if (target ~= nil) then
                    if (target:ToPlayer()) then
                        target_name = target:GetName();
                        --                        target_def = roller:GetRoleStat(0)+roller:GetRoleStat(1)+roller:GetRoleStat(2)+(player_att/2);
                        --                        def_rand = 11;
                        target_def = 15;
                        def_rand = 2; -- в массовой битве порог на хил повыше, раж битвы
                        if ((player_att + att_rand) >= (target_def + def_rand)) then
                            result_color = "FF4DB54D"
                            result_text = "удачно"
                            result_symbol = ">="
                            isSuccess = true;
                        else
                            result_color = "FFC43533"
                            result_text = "неудачно"
                            result_symbol = "<"
                        end
                        roll_maded = true;
                        roller:SendBroadcastMessage(string.format("%s действие %s %s %s |c%s%s|r. \n(%u+%u |c%s%s|r %u+%u)", attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                        target:SendBroadcastMessage(string.format("%s действие %s %s %s |c%s%s|r. \n(%u+%u |c%s%s|r %u+%u)", attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                    end
                end
            else
                if (att_rand == 1) then
                    result_color = "FFFF0000"
                    result_text = "критически неудачно"
                    result_symbol = "X"
                elseif (att_rand == 20) then
                    result_color = "FF00FF00"
                    result_text = "критически удачно"
                    result_symbol = "X"
                    isSuccess = true;
                else
                    if ((player_att + att_rand) >= (target_def + def_rand)) then
                        result_color = "FF4DB54D"
                        result_text = "удачно"
                        result_symbol = ">="
                        isSuccess = true;
                    else
                        result_color = "FFC43533"
                        result_text = "неудачно"
                        result_symbol = "<"
                    end
                end
                roll_maded = true;
                roller:SendBroadcastMessage(string.format("%s действие %s %s %s |c%s%s|r. \n(%u+%u |c%s%s|r %u+%u)", attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
            end


            PrintError("Ролевая битва, имя: " .. roller_name .. " стат: " .. stat .. " " .. result_text);

            if (roll_maded) then
                roleCombat.playerCombatMove[playerGuid] = false;
                if (stat == 6) then
                    if (target:HasAura(88011) and target:HasAura(88013) and isSuccess == true) then
                        local wound = target:GetAura(88013);
                        if (wound) then
                            local wound_stack = wound:GetStackAmount();
                            wound:SetStackAmount(wound_stack - 1);
                            if (wound_stack == 1) then
                                target:RemoveAura(88013);
                            end
                        end
                    end
                else
                    local combatID = roleCombat.playerCombat[playerGuid];
                    local factionID = roleCombat.playerCombatFaction[playerGuid];
                    local faction_leader = GetPlayerByName(roleCombatArray[combatID].factions[factionID].leader_name);
                    if (isSuccess == true) then
                        roleCombatArray[combatID].factions[factionID].players_bonus = roleCombatArray[combatID].factions[factionID].players_bonus + 0.5;
                    end
                    faction_leader:SendBroadcastMessage(string.format("%s действие %s %s %s |c%s%s|r. \n(%u+%u |c%s%s|r %u+%u)", attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));


                    player_att = 2;

                    local att_stat = math.random(3) - 1;
                    local def_stat = 3 + att_stat;

                    stat = 0;
                    attack_type = "Силовое";
                    action_type = "против"
                    if (att_stat == 0) then
                        stat = 0;
                        attack_type = "Силовое";
                    elseif (att_stat == 1) then
                        stat = 1;
                        attack_type = "Ловкое";
                    elseif (att_stat == 2) then
                        stat = 2;
                        attack_type = "Магическое";
                    end

                    target_def = roller:GetRoleStat(def_stat);
                    att_rand = math.random(20);
                    def_rand = math.random(20);
                    isSuccess = false;

                    roller_name = "вражеской армии";
                    target_name = roller:GetName();

                    if (att_rand == 1) then
                        result_color = "FFFF0000"
                        result_text = "критически неудачно"
                        result_symbol = "X"
                    elseif (att_rand == 20) then
                        result_color = "FF00FF00"
                        result_text = "критически удачно"
                        result_symbol = "X"
                        isSuccess = true;
                    else
                        if ((player_att + att_rand) >= (target_def + def_rand)) then
                            result_color = "FF4DB54D"
                            result_text = "удачно"
                            result_symbol = ">="
                            isSuccess = true;
                        else
                            result_color = "FFC43533"
                            result_text = "неудачно"
                            result_symbol = "<"
                        end
                    end
                    roller:SendBroadcastMessage(string.format("%s действие %s %s %s |c%s%s|r. \n(%u+%u |c%s%s|r %u+%u)", attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                    if (isSuccess) then
                        local aura = roller:AddAura(88013, roller)
                        local stacks = aura:GetStackAmount();
                        if (stacks >= healthByType[roller:GetTypeId()]) then
                            roller:AddAura(88014, roller)
                            roller:RemoveAura(88011);
                        end
                    end
                end
            end
        else
            --roller:SendBroadcastMessage("Вы уже сделали свой ход в этом раунде.")
        end
    end

    if (target ~= nil and not target:HasAura(88011)) then -- цель - имеется но на ней НЕТ ауры "Бой" - обычный ролл на цель или ролл в ролевом нападении
        local player_att = roller:GetRoleStat(stat);
        for i = 1, #auraModificators do
            if roller:HasAura(auraModificators[i][1]) then
                player_att = player_att + auraModificators[i][stat + 2]
            end
        end
        if not roller:ToPlayer() then
            local npcStatsValues = getStatsByCreature(roller)
            if npcStatsValues then
                if npcStatsValues[stat] then
                    player_att = npcStatsValues[stat]
                end
            end
        end

        local target_def = gettargetDefValue(stat, target);

        local att_rand = math.random(20);
        local def_rand = getDefRandByStatTypeAndTarget(stat, target)

        local result_color = "";
        local result_text = "";
        local result_symbol = "";
        local isSuccess = false;
        local isCrit = false

        if (att_rand == 1) then
            result_color = "FFFF0000"
            result_text = "критически неудачно"
            result_symbol = "X"
            if roller:HasAura(88040) then
                result_color = "FF00FF00"
                result_text = "критически удачная неудача.|r Эффект " .. GetItemLink(600053)
                result_symbol = ">>"
                isSuccess = true;
            end
        elseif (att_rand == 20 or gmToCrit[roller:GetName()]) then
            result_color = "FF00FF00"
            result_text = "критически удачно"
            result_symbol = "X"
            isCrit = true
            gmToCrit[roller:GetName()] = false
            isSuccess = true;
        else
            if ((player_att + att_rand) >= (target_def + def_rand)) then
                result_color = "FF4DB54D"
                result_text = "удачно"
                result_symbol = ">="
                isSuccess = true;
            else
                result_color = "FFC43533"
                result_text = "неудачно"
                result_symbol = "<"
            end
        end


        local roller_name = ""
        local target_name = ""

        if (roller:ToPlayer()) then
            roller_name = roller:GetName();
        else
            roller_name = roller:GetNameForLocaleRu();
        end
        if (target:ToPlayer()) then
            target_name = target:GetName();
        else
            target_name = target:GetNameForLocaleRu();
        end

        local isFogPotionUsed = false
        local isAdaptPotionUsed = false
        local isLuckPotionUsed = false

        if roller:HasAura(88043) and not isSuccess then
            isFogPotionUsed = true
            roller:RemoveAura(88043)
        end
        if target:HasAura(88042) then
            isAdaptPotionUsed = true
            isSuccess = false
            target:RemoveAura(88042)
        end

       

        if (roller:ToPlayer()) then
            if isFogPotionUsed and not isLuckPotionUsed then -- Зелье тумана
                result_color = "FF7a7671"
                roller:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                local itemLink = GetItemLink(600055, 8)
                roller:SendBroadcastMessage("Эффект бонуса " .. itemLink .. " = " .. "|cFF8192deПереброс атаки!|r")
            elseif isAdaptPotionUsed then -- Зелье адаптации
                result_color = "FF7a7671"
                roller:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                local itemLink = GetItemLink(600056, 8)
                roller:SendBroadcastMessage("Эффект бонуса " .. itemLink .. " = " .. "|cFFC43533Неудачно!|r")

            else
                roller:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
            end
        end


        if (roller:ToPlayer()) then
            local nearPlayers = roller:GetPlayersInRange(140, 0, 0)
            for index, nearPlayer in pairs(nearPlayers) do
                if (roller:IsInSameRaidWith(nearPlayer) or (target:ToPlayer() and target:IsInSameRaidWith(nearPlayer))) then
                    if isFogPotionUsed then -- Зелье тумана
                        nearPlayer:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                        local itemLink = GetItemLink(600055, 8)
                        nearPlayer:SendBroadcastMessage("Эффект бонуса " .. itemLink .. " = " .. "|cFF8192deПереброс атаки!|r")
                    elseif isAdaptPotionUsed then -- Зелье адаптации
                        result_color = "FF7a7671"
                        nearPlayer:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                        local itemLink = GetItemLink(600056, 8)
                        nearPlayer:SendBroadcastMessage("Эффект бонуса " .. itemLink .. " = " .. "|cFFC43533Неудачно!|r")

                    else
                        nearPlayer:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                    end
                end
            end

            local nearPlayers = roller:GetPlayersInRange(40, 0, 0)
            for index, nearPlayer in pairs(nearPlayers) do
                if (roller:IsInSameRaidWith(nearPlayer) ~= true and target:ToPlayer() and target:IsInSameRaidWith(nearPlayer) ~= true) then
                    if isFogPotionUsed then -- Зелье тумана
                        nearPlayer:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                        local itemLink = GetItemLink(600055, 8)
                        nearPlayer:SendBroadcastMessage("Эффект бонуса " .. itemLink .. " = " .. "|cFF8192deПереброс атаки!|r")
                    elseif isAdaptPotionUsed then -- Зелье адаптации
                        result_color = "FF7a7671"
                        nearPlayer:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                        local itemLink = GetItemLink(600056, 8)
                        nearPlayer:SendBroadcastMessage("Эффект бонуса " .. itemLink .. " = " .. "|cFFC43533Неудачно!|r")

                    else
                        nearPlayer:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                    end
                end
            end
        else
            local nearPlayers = roller:GetPlayersInRange(140, 0, 0)
            for index, nearPlayer in pairs(nearPlayers) do
                if target:IsInSameRaidWith(nearPlayer) then
                    if isFogPotionUsed then -- Зелье тумана
                        nearPlayer:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                        local itemLink = GetItemLink(600055, 8)
                        nearPlayer:SendBroadcastMessage("Эффект бонуса " .. itemLink .. " = " .. "|cFF8192deПереброс атаки!|r")
                    elseif isAdaptPotionUsed then -- Зелье адаптации
                        result_color = "FF7a7671"
                        nearPlayer:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                        local itemLink = GetItemLink(600056, 8)
                        nearPlayer:SendBroadcastMessage("Эффект бонуса " .. itemLink .. " = " .. "|cFFC43533Неудачно!|r")

                    else
                        nearPlayer:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                    end
                end
            end

            local nearPlayers = roller:GetPlayersInRange(40, 0, 0)
            for index, nearPlayer in pairs(nearPlayers) do
                if (target:IsInSameRaidWith(nearPlayer) ~= true) then
                    if isFogPotionUsed then -- Зелье тумана
                        nearPlayer:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                        local itemLink = GetItemLink(600055, 8)
                        nearPlayer:SendBroadcastMessage("Эффект бонуса " .. itemLink .. " = " .. "|cFF8192deПереброс атаки!|r")
                    elseif isAdaptPotionUsed then -- Зелье адаптации
                        result_color = "FF7a7671"
                        nearPlayer:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                        local itemLink = GetItemLink(600056, 8)
                        nearPlayer:SendBroadcastMessage("Эффект бонуса " .. itemLink .. " = " .. "|cFFC43533Неудачно!|r")

                    else
                        nearPlayer:SendBroadcastMessage(getFormattedRollMessage(attack_type, roller_name, action_type, target_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                    end
                end
            end
        end



        if isFogPotionUsed then
            attackRoll(roller, target, spellid)
        end

        if (roller:GetPhaseMask() == 32) then
            if ((not roller:ToPlayer()) and target:ToPlayer()) then
                if (isSuccess) then
                    roller:DealDamage(target, (target:GetMaxHealth() / 3) + 1, false, 0)
                end
            end
            if (not target:ToPlayer()) then
                if (isSuccess) then
                    local target_guid = target:GetGUIDLow();
                    if (npc_health[target_guid] == nil) then
                        npc_health[target_guid] = 0;
                    end
                    npc_health[target_guid] = npc_health[target_guid] + 1;
                    if (npc_health[target_guid] >= 3) then
                        npc_health[target_guid] = nil;
                        roller:Kill(target);
                    end
                end
                if (target:IsAlive()) then
                    target:SendUnitEmote(target_name .. " атакует " .. roller_name .. " в ответ.");
                    attackRoll(target, roller, "2");
                end
            end
        end

        --[[if(roller:HasAura(88011) and target:HasAura(88011))then
            if(stat == 6)then
                --
            else
                if(isSuccess)then
                    local aura = target:AddAura( 88010, target )
                    local stacks = aura:GetStackAmount();
                    if (stacks >= healthByType[target:GetTypeId()]) then
                        roller:Kill( target, false )
                    end
                end
                if((not target:ToPlayer()) and target:IsAlive())then
                    target:SendUnitEmote( target_name.." атакует "..roller_name.." в ответ." );
                    local dist = target:GetDistance(roller);
                    target:GetAngle( roller )
                    target:SetFacingToObject(roller);
                    if(dist > 2)then
                        attackRoll(target, roller, "2");
                        target:SetSheath(2);
                        target:Emote( 435 )
                    else
                        attackRoll(target, roller, "1");
                        target:SetSheath(1);
                        target:Emote( 36 )
                    end
                end
            end
        end]]
    end

    if (target == nil and not roller:HasAura(88011)) then -- цели нет и на кастере нет ауры "бой"
        local player_att = roller:GetRoleStat(stat);
        local att_rand = math.random(20);

        local roller_name = ""

        if (roller:ToPlayer()) then
            roller_name = roller:GetName();
        else
            roller_name = roller:GetNameForLocaleRu();
        end
        if (roleCombat.diff_number[roller:GetGUIDLow()]) then
            local def_rand = math.random(20);
            local target_def = roleCombat.diff_number[roller:GetGUIDLow()];

            local result_color = "";
            local result_text = "";
            local result_symbol = "";
            local isSuccess = false;

            if (att_rand == 1) then
                result_color = "FFFF0000"
                result_text = "критически неудачно"
                result_symbol = "X"
            elseif (att_rand == 20) then
                result_color = "FF00FF00"
                result_text = "критически удачно"
                result_symbol = "X"
                isSuccess = true;
            else
                if ((player_att + att_rand) >= (target_def + def_rand)) then
                    result_color = "FF4DB54D"
                    result_text = "удачно"
                    result_symbol = ">="
                    isSuccess = true;
                else
                    result_color = "FFC43533"
                    result_text = "неудачно"
                    result_symbol = "<"
                end
            end

            if (roller:ToPlayer()) then
                roller:SendBroadcastMessage(string.format("%s действие %s |c%s%s|r. \n(%u+%u |c%s%s|r %u+%u)", attack_type, roller_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
            end
            local nearPlayers = roller:GetPlayersInRange(140, 0, 0)
            for index, nearPlayer in pairs(nearPlayers) do
                if roller:IsInSameRaidWith(nearPlayer) then
                    nearPlayer:SendBroadcastMessage(string.format("%s действие %s |c%s%s|r. \n(%u+%u |c%s%s|r %u+%u)", attack_type, roller_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                end
            end
            local nearPlayers = roller:GetPlayersInRange(40, 0, 0)
            for index, nearPlayer in pairs(nearPlayers) do
                if (roller:IsInSameRaidWith(nearPlayer) ~= true) then
                    nearPlayer:SendBroadcastMessage(string.format("%s действие %s |c%s%s|r. \n(%u+%u |c%s%s|r %u+%u)", attack_type, roller_name, result_color, result_text, player_att, att_rand, result_color, result_symbol, target_def, def_rand));
                end
            end
        else
            if (roller:ToPlayer()) then
                roller:SendBroadcastMessage(string.format("%s действие %s. Результат: %u (%u+%u)", attack_type, roller_name, (player_att + att_rand), player_att, att_rand));
            end
            local nearPlayers = roller:GetPlayersInRange(140, 0, 0)
            for index, nearPlayer in pairs(nearPlayers) do
                if roller:IsInSameRaidWith(nearPlayer) then
                    nearPlayer:SendBroadcastMessage(string.format("%s действие %s. Результат: %u (%u+%u)", attack_type, roller_name, (player_att + att_rand), player_att, att_rand));
                end
            end
            local nearPlayers = roller:GetPlayersInRange(40, 0, 0)
            for index, nearPlayer in pairs(nearPlayers) do
                if (roller:IsInSameRaidWith(nearPlayer) ~= true) then
                    nearPlayer:SendBroadcastMessage(string.format("%s действие %s. Результат: %u (%u+%u)", attack_type, roller_name, (player_att + att_rand), player_att, att_rand));
                end
            end
        end
    end
end

local function OnPlayerCommandWithArg(event, player, code)
    if (string.find(code, " ")) then
        local arguments = {}
        local arguments = string.split(code, " ")
        if (arguments[1] == "npcsetstat" and #arguments == 3) then
            if player:GetGMRank() > 0 or player:GetDmLevel() > 0 then
                local statid = tonumber(arguments[2]) - 1
                local value = tonumber(arguments[3])
                local GM_target = player:GetSelectedUnit()
                if not GM_target:ToPlayer() then
                    local result = setNpcStats(GM_target, statid, value)
                    if (result) then
                        player:SendBroadcastMessage("Существу " .. greenColor .. "\"" .. GM_target:GetName() .. "\"|r " .. statnames[statid] .. " установлена в значение " .. greenColor .. value)
                    end
                end
            end
        elseif (arguments[1] == "npcsetstatradius" and #arguments == 9) then
            if player:GetGMRank() > 0 then
                local strength = tonumber(arguments[2]); if strength == nil then strength = 0 end
                local agila = tonumber(arguments[3]); if agila == nil then agila = 0 end
                local inta = tonumber(arguments[4]); if inta == nil then inta = 0 end
                local stamina = tonumber(arguments[5]); if stamina == nil then stamina = 0 end
                local versa = tonumber(arguments[6]); if versa == nil then versa = 0 end
                local will = tonumber(arguments[7]); if will == nil then will = 0 end
                local hpval = tonumber(arguments[8]); if hpval == nil then hpval = 0 end
                local ammoval = tonumber(arguments[9]); if ammoval == nil then ammoval = 0 end

                local GM_target = player:GetSelectedUnit()
                if not GM_target then
                    player:SendBroadcastMessage("Выберите цель (нпс)")
                else
                    if not GM_target:ToPlayer() then
                        -- сначала на цель
                        setNpcStats(GM_target, ROLE_STAT_STRENGTH, strength)
                        setNpcStats(GM_target, ROLE_STAT_AGLILITY, agila)
                        setNpcStats(GM_target, ROLE_STAT_INTELLECT, inta)
                        setNpcStats(GM_target, ROLE_STAT_STAMINA, stamina)
                        setNpcStats(GM_target, ROLE_STAT_VERSA, versa)
                        setNpcStats(GM_target, ROLE_STAT_WILL, will)
                        setNpcStats(GM_target, ROLE_STAT_HEALTH, hpval)
                        setNpcStats(GM_target, ROLE_STAT_ARMOR, ammoval)

                        GM_target:RemoveAura(EBS_HP_AURA)
                        if hpval > 0 then
                            local hpAura = GM_target:AddAura(EBS_HP_AURA, GM_target)
                            hpAura:SetStackAmount(hpval)
                        end

                        GM_target:RemoveAura(EBS_ARMOR_AURA)
                        if ammoval > 0 then
                            local ammoAura = GM_target:AddAura(EBS_ARMOR_AURA, GM_target)
                            ammoAura:SetStackAmount(ammoval)
                        end

                        -- теперь на радиус
                        local creaturesInRange = GM_target:GetCreaturesInRange(50, GM_target:GetEntry())

                        for i = 1, #creaturesInRange do

                            setNpcStats(creaturesInRange[i], ROLE_STAT_STRENGTH, strength)
                            setNpcStats(creaturesInRange[i], ROLE_STAT_AGLILITY, agila)
                            setNpcStats(creaturesInRange[i], ROLE_STAT_INTELLECT, inta)
                            setNpcStats(creaturesInRange[i], ROLE_STAT_STAMINA, stamina)
                            setNpcStats(creaturesInRange[i], ROLE_STAT_VERSA, versa)
                            setNpcStats(creaturesInRange[i], ROLE_STAT_WILL, will)
                            setNpcStats(creaturesInRange[i], ROLE_STAT_HEALTH, hpval)
                            setNpcStats(creaturesInRange[i], ROLE_STAT_ARMOR, ammoval)

                            creaturesInRange[i]:RemoveAura(EBS_HP_AURA)
                            if hpval > 0 then
                                local hpAura = creaturesInRange[i]:AddAura(EBS_HP_AURA, creaturesInRange[i])
                                hpAura:SetStackAmount(hpval)
                            end

                            creaturesInRange[i]:RemoveAura(EBS_ARMOR_AURA)
                            if ammoval > 0 then
                                local ammoAura = creaturesInRange[i]:AddAura(EBS_ARMOR_AURA, creaturesInRange[i])
                                ammoAura:SetStackAmount(ammoval)
                            end
                        end

                        player:SendBroadcastMessage("Всем существам с именем " .. greenColor .. "\"" .. GM_target:GetName() .. "\"|r в радиусе 50 ярдов установлены характеристики: сила: " .. strength .. " ловкость: " .. agila .. "  инта: " .. inta .. "  стойкость: " .. stamina .. "  сноровка: " .. versa .. "  воля: " .. will .. "  здоровье: " .. hpval .. "  броня: " .. ammoval)
                    else
                        player:SendBroadcastMessage("Возьмите в цель нпс, сейчас выбран игрок")
                    end
                end
            elseif player:GetDmLevel() > 0 then
                player:SendBroadcastMessage("На вашем уровне доступа данная команда недоступна")
            end
        elseif (arguments[1] == "makemecrit") then
            if player:GetGMRank() > 1 then
                gmToCrit[player:GetName()] = true
                player:SendBroadcastMessage("Уа-а-а-а-зяяя, ты щас ему ТАК дашь, что у него зубы вылетят")
            end
        elseif (arguments[1] == "reloadnpcstats") then
            if player:GetGMRank() > 0 then
                loadAllCreatureTemplateRollStats();
                player:SendBroadcastMessage("Статы перезагружены")
            end
        end
    end
end

RegisterPlayerEvent(42, OnPlayerCommandWithArg)
RegisterPlayerEvent(PLAYER_EVENT_ON_EQUIP, playerOnEquip);
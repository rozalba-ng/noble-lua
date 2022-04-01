lockedDoorArray = {}; -- массив с заспавнеными в мире дверьми
doorDataArray = {}; -- массив с темплейтами дверей
houseFactions = {}; -- массив с данными по фракциям

local building_quest = 110000;
local andoral_currency = 43721;
local storm_currency = 600057;
local region_stormwind = 1;
local region_shadow_stormwind = 2;
local faction_stormwind = 1162;
local faction_shadow_stormwind = 1163;
local reputation_honored = 9000;
local reputation_friendly = 3000;

local DOOR_QUEST_END_NPC = 987863
local DOOR_QUEST = 110212

local payCurrency = {
    [0] = "серебра",
    [1] = "клав.",
    [2] = "крон"
};

local doorAccessGroups = {
    [2] = { "Группа", 10 },
    [4] = { "Рейд", 11 },
    [8] = { "Гильдия", 12 }
};

local houseFactionsNames = {
    [0] = 'rep_base',
    [1] = 'rep_stormwind',
    [2] = 'rep_shadows'
};

---------------------------------------------------------
local function escapeCode(code)
    local new_text = ""
    if (code ~= nil) then
        for S in string.gmatch(code, "[^\"\'\\]") do
            new_text = (new_text .. S)
        end
    end
    return new_text
end

--- - Сохранение данных по транзакциям -------------------
local function savePaymentHistory(player, doorGUID, amount, curr)
    CharDBExecute("INSERT INTO `doors_pay_history` (`account`, `currency`, `amount`, `door_guid`) VALUES (" .. player:GetAccountId() .. ", " .. curr .. ", " .. amount .. ", " .. doorGUID .. ");");
end

local function saveDoorOwnerData(lockedDoorItem, doorGUID)
    CharDBExecute("UPDATE `doors_owners` SET `door_level` = " .. lockedDoorItem.door_level .. ", `owner_type` = " .. lockedDoorItem.owner_type .. ", `ownerID` = " .. lockedDoorItem.ownerID .. ", `expTime` = " .. lockedDoorItem.expTime .. ", `open` = " .. lockedDoorItem.open .. ", `allowed` = " .. lockedDoorItem.allowed .. ", `owner_guild` = " .. lockedDoorItem.owner_guild .. " where door_guid = " .. doorGUID .. ";");
end

local function createDoorOwnerData(lockedDoorItem, doorGUID)
    CharDBExecute("INSERT INTO `doors_owners` (`door_guid`, `door_id`, `door_level`, `owner_type`, `ownerID`, `expTime`, `open`, `allowed`, `owner_guild`) VALUES (" .. doorGUID .. ", " .. lockedDoorItem.door_id .. ", " .. lockedDoorItem.door_level .. ", " .. lockedDoorItem.owner_type .. ", " .. lockedDoorItem.ownerID .. ", " .. lockedDoorItem.expTime .. ", " .. lockedDoorItem.open .. ", " .. lockedDoorItem.allowed .. ", " .. lockedDoorItem.owner_guild .. ");");
end

local function canBuyFactionHouses(player, gobDBID, guild)
    local guildId = player:GetGuildId();
    local guildDataQuery = CharDBQuery('SELECT * from guild_data where guild_id = ' .. guildId .. ' limit 1')
    if (guildDataQuery == nil) then -- сначала проверяем может ли вообще эта гильдия закупаться домами
        player:SendBroadcastMessage("Вашей гильдии недоступна покупка зданий в этой зоне.");
        return false
    else -- (не актуально, просто высчитываем количество зданий у гильдии) 0если может, то проверяем какая у гильдии сейчас репутация, и не достигла ли она лимита домов. Кроме того, рассчитываем коэффициент стоимости (который надо будет умножить на цену)
        local guildData = guildDataQuery:GetRow();
        local regionId = lockedDoorArray[gobDBID].region_id;
        local houseRegionCount = 0; -- количество домов в районе
        for i, v in pairs(lockedDoorArray) do
            if (v.owner_guild == guildId and v.owner_type == 1 and v.region_id == regionId) then
                houseRegionCount = houseRegionCount + 1;
            end
        end
--        local currReputation = guildData[houseFactionsNames[regionId]]; -- текущая репутация гильдии в районе
--        local reputationType = 'Normal';
--
--        if (currReputation >= houseFactions[regionId]['repExalt']) then
--            reputationType = 'Exalt';
--        elseif (currReputation >= houseFactions[regionId]['repFriend']) then
--            print(1)
--            reputationType = 'Friend';
--        elseif (currReputation >= houseFactions[regionId]['repNormal']) then
--            reputationType = 'Normal';
--        elseif (currReputation >= houseFactions[regionId]['repDislike']) then
--            reputationType = 'Dislike';
--        else
--            reputationType = 'Hate';
--        end

--        local fieldHouseCount = 'houseCount' .. reputationType
        if (houseRegionCount >= 1) then --houseRegionCount >= houseFactions[regionId][fieldHouseCount]) then
            player:SendBroadcastMessage("В этой зоне покупка дополнительных гильдейских зданий невозможна.");
            return false
        else
            return 1;
--            print(2)
--            local fieldHouseCoef = 'houseCostCoef' .. reputationType;
--            print(fieldHouseCoef)
--            print(houseFactions[regionId][fieldHouseCoef])
--            return houseFactions[regionId][fieldHouseCoef];
        end
    end
end

------------ МЕНЮ ----------------------------------------							
local function gossipDoorBuy(event, player, object, guid)
    player:GossipClearMenu() -- required for player gossip

    local text = "Меню покупки помещения"
    if (lockedDoorArray[guid].can_own_user == 1) then
        if lockedDoorArray[guid].region_id == 1 then
            text = "Для покупки нужна репутация у одной из фракций штормграда: дружелюбие"
--        elseif lockedDoorArray[guid].region_id == 2 then
--            text = "Для покупки нужна репутация Тени Штормграда: дружелюбие"
        end
        player:GossipMenuAddItem(10, "Купить дом", 1, 22, false, "Вы желаете приобрести этот личный дом? Это будет стоить " .. lockedDoorArray[guid].cost_start .. " " .. payCurrency[lockedDoorArray[guid].cost_type]);
    end
    if (lockedDoorArray[guid].can_own_faction == 1) then
        text = "Для покупки нужна репутация Королевство Штормград: уважение"
        player:GossipMenuAddItem(10, "Купить лавку", 1, 23, false, "Вы желаете приобрести эту лавку? Это будет стоить " .. lockedDoorArray[guid].cost_start .. " " .. payCurrency[lockedDoorArray[guid].cost_type]);
    end
    if (lockedDoorArray[guid].can_own_guild == 1) then
        if lockedDoorArray[guid].region_id ==1 then
            --    Обращение к дворянину
            text = "Для покупки гильдия должна быть внесена в реестр ситикрафта Штормград. По всем вопросам обращайтесь на сайт в личные сообщения по нику Розальба либо в наш дискорд, по нику rozalba#8315"
        end
        player:GossipMenuAddItem(10, "Купить гилдхолл", 1, 24, false, "Вы желаете приобрести этот гилдхолл? Это будет стоить " .. lockedDoorArray[guid].cost_start .. " " .. payCurrency[lockedDoorArray[guid].cost_type]);
    end
    player:GossipMenuAddItem(0, "Закрыть", 1, 25);
    player:GossipSetText( text, 23122243 )
    player:GossipSendMenu( 23122243, object, 5500 ) -- MenuId required for player gossip
end

local function gossipDoorOption(event, player, object, guid)
    player:GossipClearMenu() -- required for player gossip
    if (lockedDoorArray[guid].open == 1) then
        player:GossipMenuAddItem(4, "Запереть", 1, 1, false, nil, nil, false)
    else
        player:GossipMenuAddItem(4, "Отпереть", 1, 2, false, nil, nil, false)
    end
    player:GossipMenuAddItem(3, "Дать доступ", 1, 3, false, nil, nil, false)
    player:GossipMenuAddItem(3, "Изъять доступ", 1, 4, false, nil, nil, false)
	
	local nextCooldownReset_time = os.date("*t")
	--Ezil: Проверка, находится ли игрок в гильдии к которой привязана дверь и есть ли привязанный к дверке бонус, а также обновилась ли возможность взять бонус этой ауры.
	if (lockedDoorArray[guid].owner_guild == player:GetGuildId() and lockedDoorArray[guid].aura ~= 0 and (not player:GetInfo("LastDoorBonus_"..tostring(lockedDoorArray[guid].aura)) or nextCooldownReset_time.day~=tonumber(player:GetInfo("LastDoorBonus_"..tostring(lockedDoorArray[guid].aura))))) then
		player:GossipMenuAddItem(4, "Получить бонус предприятия", 1, 7)
	end
	--Ezil: Проверка, является ли дверь 1 уровня и типом Личная, а также обновился ли квест, либо этот квест в целом не был еще ни разу начат.
	if (lockedDoorArray[guid].door_level == 1 and lockedDoorArray[guid].owner_type == 0 and not player:HasQuest(DOOR_QUEST) and (not player:GetInfo("LastDoorQuest") or nextCooldownReset_time.day~=tonumber(player:GetInfo("LastDoorQuest")))) then
		player:GossipMenuAddItem(4, "Сдать припасы", 1, 6)
	end
	------
    player:GossipMenuAddItem(4, "Отказаться от владения", 1, 26, false, "ВНИМАНИЕ! После согласия, весь ваш доступ к зданию пропадет и оно вновь станет свободным. Вы согласны?")
    player:GossipMenuAddItem(4, "Передать владение", 1, 27, true, "ВНИМАНИЕ! После согласия, весь ваш доступ к зданию перейдет к указаному игроку. Вы согласны?")
    player:GossipMenuAddItem(1, "Настройка жильцов", 1, 28)
    if (lockedDoorArray[guid].expTime - os.time() < 172800) then
        player:GossipMenuAddItem(10, "Оплатить на неделю", 1, 21, false, "Оплатить аренду на неделю? Это будет стоить " .. lockedDoorArray[guid].cost_prolong .. " " .. payCurrency[lockedDoorArray[guid].cost_type])
    end
    player:GossipMenuAddItem(0, "Проверить оплаченный срок", 1, 5)
    player:GossipMenuAddItem(0, "Закрыть", 1, 25)
    player:GossipSendMenu(1, object, 5500) -- MenuId required for player gossip
end


--Ezil:Регистрация собатия, когда игрок Сдает квест, навешивать кулдаун в сутки.
local function OnDoorQuestReward(event, player, creature, quest, opt)
	if quest:GetId() == DOOR_QUEST then
		local nextCooldownReset_time = os.date("*t")
		player:SetInfo("LastDoorQuest",tostring(nextCooldownReset_time.day))
	end
end
RegisterCreatureEvent(DOOR_QUEST_END_NPC,34,OnDoorQuestReward)
-----


local function gossipDoorSubOptionGive(player, guid)
    flags = lockedDoorArray[guid].allowed;
    for i, v in pairs(doorAccessGroups) do
        if (bit_and(flags, i) == 0) then
            player:GossipMenuAddItem(1, v[1], 1, v[2], false, nil, nil, false);
        end
    end
    player:GossipMenuAddItem(0, "Назад ..", 1, 20)
    player:GossipSendMenu(1, player, 5500)
end

local function gossipDoorSubOptionTake(player, guid)
    flags = lockedDoorArray[guid].allowed;
    for i, v in pairs(doorAccessGroups) do
        if (bit_and(flags, i) == i) then
            player:GossipMenuAddItem(3, v[1], 1, v[2] + 4, false, nil, nil, false);
        end
    end
    player:GossipMenuAddItem(0, "Назад ..", 1, 20)
    player:GossipSendMenu(1, player, 5500)
end

-- обработка выбора пункта меню в gossip при взаимодействии с door (покупаемой дверью)
local function gossipSelectDoorOption(event, player, object, sender, intid, code, menuid)
    local map = player:GetMap();
    local playerGUID = player:GetGUIDLow();
    local gobGUID = PlayerBuild.targetgobject[playerGUID];
    local gob = map:GetWorldObject(gobGUID)
    local gobDBID = gob:GetDBTableGUIDLow();
    local codeEscaped = escapeCode(code);
    if (lockedDoorArray[gobDBID].ownerID == playerGUID) then
        if (intid == 1) then
            lockedDoorArray[gobDBID].open = 0;
            saveDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
            gossipDoorOption(event, player, object, gobDBID);
        elseif (intid == 2) then
            lockedDoorArray[gobDBID].open = 1;
            saveDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
            gossipDoorOption(event, player, object, gobDBID);
        elseif (intid == 3) then
            gossipDoorSubOptionGive(player, gobDBID);
        elseif (intid == 5) then
            player:SendBroadcastMessage('Оплачено до: ' .. os.date('%d.%m.%Y %H:%M:%S', lockedDoorArray[gobDBID].expTime));
            gossipDoorOption(event, player, player, gobDBID);
		--Ezil: Обработка нажатие на кнопку Сдать припасы
		elseif (intid == 6) then
			player:AddQuest(DOOR_QUEST)
			player:SendQuestTemplate(DOOR_QUEST,true)
			
		--Ezil: Нажатие на кнопку Получить бонус предприятия
		elseif (intid == 7) then	
			local nextCooldownReset_time = os.date("*t")
			player:AddAura(lockedDoorArray[gobDBID].aura,player)
			player:SetInfo("LastDoorBonus_"..tostring(lockedDoorArray[gobDBID].aura),tostring(nextCooldownReset_time.day))
			player:GossipComplete()
		------
        elseif (intid == 4) then
            gossipDoorSubOptionTake(player, gobDBID);
        elseif (intid >= 10 and intid <= 16) then
            for i, v in pairs(doorAccessGroups) do
                if v[2] == intid then
                    lockedDoorArray[gobDBID].allowed = lockedDoorArray[gobDBID].allowed + i;
                    break;
                elseif v[2] == (intid - 4) then
                    lockedDoorArray[gobDBID].allowed = lockedDoorArray[gobDBID].allowed - i;
                    break;
                end
            end
            saveDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
            player:SendBroadcastMessage("Настройки доступа к недвижимости изменены.");
            gossipDoorOption(event, player, object, gobDBID);
        elseif (intid == 20) then
            gossipDoorOption(event, player, object, gobDBID);
        elseif (intid == 21) then
            -- Достаточно ли у персонажа репутации?
            if (lockedDoorArray[gobDBID].owner_type == 0 and lockedDoorArray[gobDBID].region_id == region_stormwind and not (player:GetReputation( faction_stormwind ) > reputation_friendly or player:GetReputation( faction_shadow_stormwind ) > reputation_friendly)) then
                player:SendBroadcastMessage("У вас недостаточно репутации для продления владения этим зданием. Требуемая репутация у одной из фракций Штормграда - дружелюбие");
                return false;
            end
--            if (lockedDoorArray[gobDBID].owner_type == 0 and lockedDoorArray[gobDBID].region_id == region_shadow_stormwind and player:GetReputation( faction_shadow_stormwind ) < reputation_friendly) then
--                player:SendBroadcastMessage("У вас недостаточно репутации для продления владения этим зданием. Требуемая репутация: Тени Штормграда - дружелюбие");
--                return false;
--            end
            if (lockedDoorArray[gobDBID].owner_type == 2 and lockedDoorArray[gobDBID].region_id == region_stormwind and player:GetReputation( faction_stormwind ) < reputation_honored) then
                player:SendBroadcastMessage("У вас недостаточно репутации для продления владения этой лавкой.");
                return false;
            end
            if (lockedDoorArray[gobDBID].cost_type == 0 and (player:GetCoinage() >= (lockedDoorArray[gobDBID].cost_prolong * 100))) then
                player:ModifyMoney(-lockedDoorArray[gobDBID].cost_prolong * 100);
                lockedDoorArray[gobDBID].expTime = lockedDoorArray[gobDBID].expTime + 604800;
                saveDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                savePaymentHistory(player, gobDBID, lockedDoorArray[gobDBID].cost_prolong, 1)
                player:SendBroadcastMessage("Продление аренды прошло успешно.");
            elseif (lockedDoorArray[gobDBID].cost_type == 1 and (player:HasItem(andoral_currency, lockedDoorArray[gobDBID].cost_prolong) or lockedDoorArray[gobDBID].cost_prolong == 0)) then
                player:RemoveItem(andoral_currency, lockedDoorArray[gobDBID].cost_prolong);
                lockedDoorArray[gobDBID].expTime = lockedDoorArray[gobDBID].expTime + 604800;
                saveDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                savePaymentHistory(player, gobDBID, lockedDoorArray[gobDBID].cost_prolong, 1)
                player:SendBroadcastMessage("Продление аренды прошло успешно.");
            elseif (lockedDoorArray[gobDBID].cost_type == 2 and (player:HasItem(storm_currency, lockedDoorArray[gobDBID].cost_prolong) or lockedDoorArray[gobDBID].cost_prolong == 0)) then
                player:RemoveItem(storm_currency, lockedDoorArray[gobDBID].cost_prolong);
                lockedDoorArray[gobDBID].expTime = lockedDoorArray[gobDBID].expTime + 604800;
                saveDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                savePaymentHistory(player, gobDBID, lockedDoorArray[gobDBID].cost_prolong, 2)
                player:SendBroadcastMessage("Продление аренды прошло успешно.");
            else
                player:SendBroadcastMessage("Недостаточно валюты для продления аренды.");
            end
            player:GossipComplete();
        elseif intid == 26 then
            CharDBQuery("DELETE FROM `doors_owners` WHERE `door_guid`='" .. gobDBID .. "' LIMIT 1;")
            assignDoorsEvents();
            player:GossipComplete();
            player:SendBroadcastMessage("|cff71C671Вы успешно отказались от недвижимости.")
        elseif intid == 27 then
            -- Достаточно ли у персонажа репутации?
            if (lockedDoorArray[gobDBID].region_id == region_stormwind or lockedDoorArray[gobDBID].region_id == region_shadow_stormwind) then
                player:SendBroadcastMessage("Дома в этой зоне на данный момент нельзя передавать другим игрокам.");
                return false;
            end
            local charQuery = CharDBQuery("SELECT * FROM characters where name = '" .. codeEscaped .. "' LIMIT 1");
            if (charQuery ~= nil) then
                for i, v in pairs(lockedDoorArray) do
                    if (v.ownerID == tonumber(charQuery:GetString(0)) and v.owner_type == 0 and v.cost_start ~= 0) then
                        player:SendBroadcastMessage("У персонажа уже есть дом.");
                        player:GossipComplete();
                        return false;
                    end
                end
                lockedDoorArray[gobDBID].ownerID = tonumber(charQuery:GetString(0));
                saveDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                player:GossipComplete();
                player:SendBroadcastMessage("|cff71C671Недвижимость передана|cffffff00 " .. codeEscaped .. "|cff71C671.")
            else
                player:SendBroadcastMessage("|cffff0000Персонаж с ником|cffbbbbbb " .. codeEscaped .. " |cffff0000не найден.")
                player:GossipComplete()
            end
        elseif intid == 28 then
            player:GossipClearMenu()
            player:GossipMenuAddItem(4, "Добавить жильца", 1, 29, true)
            player:GossipMenuAddItem(4, "Убрать жильца", 1, 30, true)
            player:GossipMenuAddItem(4, "Вывести список жильцов", 1, 31)
            player:GossipMenuAddItem(0, "Назад ..", 1, 20)
            player:GossipSendMenu(1, player, 5500)
        elseif intid == 29 then
            local charQuery = CharDBQuery("SELECT * FROM characters where name = '" .. codeEscaped .. "' LIMIT 1");
            if (charQuery ~= nil) then
                local insertPlayerGuid = tonumber(charQuery:GetString(0));
                if (CharDBQuery("SELECT * FROM doors_tenants where char_guid = '" .. insertPlayerGuid .. "' LIMIT 1") == nil and codeEscaped ~= player:GetName()) then
                    CharDBQuery("INSERT INTO `doors_tenants` (`door_guid`, `char_guid`, `char_name`) VALUES ('" .. gobDBID .. "', '" .. insertPlayerGuid .. "', '" .. tostring(codeEscaped) .. "');")
                    player:SendBroadcastMessage("|cffffff00" .. codeEscaped .. "|cff71C671 добавлен(а) в список жильцов.")
                    player:GossipComplete()
                else
                    player:SendBroadcastMessage("|cffff0000Персонаж с ником|cffbbbbbb " .. codeEscaped .. " |cffff0000уже добавлен в список жильцов.")
                    player:GossipComplete()
                end
            else
                player:SendBroadcastMessage("|cffff0000Персонаж с ником|cffbbbbbb " .. codeEscaped .. " |cffff0000не найден.")
                player:GossipComplete()
            end
        elseif intid == 30 then
            local charQuery = CharDBQuery("SELECT * FROM characters where name = '" .. codeEscaped .. "' LIMIT 1");
            if (charQuery ~= nil) then
                local deletePlayerGuid = tonumber(charQuery:GetString(0));
                if CharDBQuery("SELECT * FROM doors_tenants where char_guid = '" .. deletePlayerGuid .. "' LIMIT 1") and codeEscaped ~= player:GetName() then
                    CharDBQuery("DELETE FROM `doors_tenants` WHERE `char_guid`='" .. deletePlayerGuid .. "' LIMIT 1;")
                    player:SendBroadcastMessage("|cffffff00" .. codeEscaped .. "|cff71C671 удален(а) из списка жильцов.")
                    player:GossipComplete()
                else
                    player:SendBroadcastMessage("|cffff0000Персонаж с ником|cffbbbbbb " .. codeEscaped .. " |cffff0000не является жильцом.")
                    player:GossipComplete()
                end
            else
                player:SendBroadcastMessage("|cffff0000Персонаж с ником|cffbbbbbb " .. codeEscaped .. " |cffff0000не найден.")
                player:GossipComplete()
            end

        elseif intid == 31 then
            tenants_query = CharDBQuery("SELECT * FROM doors_tenants where door_guid = '" .. gobDBID .. "'")
            if tenants_query then
                tenants_count = tenants_query:GetRowCount()
                player:SendBroadcastMessage("Список жильцов:")
                for i = 1, tenants_count do
                    player:SendBroadcastMessage("|cffbbbbbb" .. CharDBQuery("SELECT name FROM characters where guid = '" .. tonumber(tenants_query:GetString(1)) .. "' LIMIT 1"):GetString(0))
                    tenants_query:NextRow()
                end
            else
                player:SendBroadcastMessage("На данный момент список жильцов пуст.")
            end
            player:GossipComplete()
        end
    elseif (lockedDoorArray[gobDBID].ownerID == 0) then
        if (intid == 22) then
            -- Можно ли вообще купить дом в личное пользование?
            if (lockedDoorArray[gobDBID].can_own_user ~= 1) then
                player:SendBroadcastMessage("Этот дом нельзя выкупить в личное пользование.");
                return false;
            end
            -- хватает ли персонажу репутации
            if (lockedDoorArray[gobDBID].region_id == region_stormwind and not (player:GetReputation( faction_stormwind ) > reputation_friendly or player:GetReputation( faction_shadow_stormwind ) > reputation_friendly)) then
                player:SendBroadcastMessage("У вас недостаточно репутации для приобретения этого личного дома. Требуемая репутация: дружелюбие у одной из фракций Штормграда");
                return false;
            end
--            if (lockedDoorArray[gobDBID].region_id == region_shadow_stormwind and player:GetReputation( faction_shadow_stormwind ) < reputation_friendly) then
--                player:SendBroadcastMessage("У вас недостаточно репутации для приобретения этого личного дома. Требуемая репутация: Тени Штормграда - дружелюбие");
--                return false;
--            end
            -- Нет ли у персонажа уже другого личного дома? (кроме домов с нулевой стоимостью)
            if (lockedDoorArray[gobDBID].cost_start ~= 0) then
                for i, v in pairs(lockedDoorArray) do
                    if (v.ownerID == playerGUID and v.owner_type == 0 and v.cost_start ~= 0) then
                        player:SendBroadcastMessage("У Вас уже есть личный дом.");
                        player:GossipComplete();
                        return false;
                    end
                end
            end
            -- Достаточно ли у персонажа валюты?
            if (lockedDoorArray[gobDBID].cost_type == 0 and (player:GetCoinage() >= (lockedDoorArray[gobDBID].cost_start * 100))) then
                player:ModifyMoney(-lockedDoorArray[gobDBID].cost_start * 100);
                lockedDoorArray[gobDBID].ownerID = playerGUID;
                lockedDoorArray[gobDBID].owner_type = 0;
                lockedDoorArray[gobDBID].expTime = os.time() + 604800;
                createDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                savePaymentHistory(player, gobDBID, lockedDoorArray[gobDBID].cost_start, 1)
                player:SendBroadcastMessage("Покупка прошла успешно.");
            elseif ((lockedDoorArray[gobDBID].cost_type == 1 and player:HasItem(andoral_currency, lockedDoorArray[gobDBID].cost_start)) or lockedDoorArray[gobDBID].cost_start == 0) then
                player:RemoveItem(andoral_currency, lockedDoorArray[gobDBID].cost_start);
                lockedDoorArray[gobDBID].ownerID = playerGUID;
                lockedDoorArray[gobDBID].owner_type = 0;
                lockedDoorArray[gobDBID].expTime = os.time() + 604800;
                createDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                savePaymentHistory(player, gobDBID, lockedDoorArray[gobDBID].cost_start, 1)
                player:SendBroadcastMessage("Покупка прошла успешно.");
            elseif ((lockedDoorArray[gobDBID].cost_type == 2 and player:HasItem(storm_currency, lockedDoorArray[gobDBID].cost_start)) or lockedDoorArray[gobDBID].cost_start == 0) then
                player:RemoveItem(storm_currency, lockedDoorArray[gobDBID].cost_start);
                lockedDoorArray[gobDBID].ownerID = playerGUID;
                lockedDoorArray[gobDBID].owner_type = 0;
                lockedDoorArray[gobDBID].expTime = os.time() + 604800;
                createDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                savePaymentHistory(player, gobDBID, lockedDoorArray[gobDBID].cost_start, 2)
                player:SendBroadcastMessage("Покупка прошла успешно.");
            else
                player:SendBroadcastMessage("Недостаточно валюты для покупки недвижимости.");
            end
            player:GossipComplete();
        end
        if (intid == 23) then
            -- Можно ли вообще купить дом в коммерческое пользование?
            if (lockedDoorArray[gobDBID].can_own_faction ~= 1) then
                player:SendBroadcastMessage("Эту лавку нельзя выкупить.");
                return false;
            end
            -- Достаточно ли у персонажа репутации?
            if (lockedDoorArray[gobDBID].region_id == region_stormwind and player:GetReputation( faction_stormwind ) < reputation_honored) then
                player:SendBroadcastMessage("У вас недостаточно репутации для приобретения этой лавки.");
                return false;
            end
            -- Нет ли у персонажа уже другого коммерческого помещения? (кроме домов с нулевой стоимостью)
            if (lockedDoorArray[gobDBID].cost_start ~= 0) then
                for i, v in pairs(lockedDoorArray) do
                    if (v.ownerID == playerGUID and v.owner_type == 2 and v.cost_start ~= 0) then
                        player:SendBroadcastMessage("У Вас уже есть лавка.");
                        player:GossipComplete();
                        return false;
                    end
                end
            end
            -- Достаточно ли у персонажа валюты?
            if (lockedDoorArray[gobDBID].cost_type == 0 and (player:GetCoinage() >= (lockedDoorArray[gobDBID].cost_start * 100))) then
                player:ModifyMoney(-lockedDoorArray[gobDBID].cost_start * 100);
                lockedDoorArray[gobDBID].ownerID = playerGUID;
                lockedDoorArray[gobDBID].owner_type = 2;
                lockedDoorArray[gobDBID].expTime = os.time() + 604800;
                createDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                savePaymentHistory(player, gobDBID, lockedDoorArray[gobDBID].cost_start, 1)
                player:SendBroadcastMessage("Покупка прошла успешно.");
            elseif ((lockedDoorArray[gobDBID].cost_type == 1 and player:HasItem(andoral_currency, lockedDoorArray[gobDBID].cost_start)) or lockedDoorArray[gobDBID].cost_start == 0) then
                player:RemoveItem(andoral_currency, lockedDoorArray[gobDBID].cost_start);
                lockedDoorArray[gobDBID].ownerID = playerGUID;
                lockedDoorArray[gobDBID].owner_type = 2;
                lockedDoorArray[gobDBID].expTime = os.time() + 604800;
                createDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                savePaymentHistory(player, gobDBID, lockedDoorArray[gobDBID].cost_start, 1)
                player:SendBroadcastMessage("Покупка прошла успешно.");
            elseif ((lockedDoorArray[gobDBID].cost_type == 2 and player:HasItem(storm_currency, lockedDoorArray[gobDBID].cost_start)) or lockedDoorArray[gobDBID].cost_start == 0) then
                player:RemoveItem(storm_currency, lockedDoorArray[gobDBID].cost_start);
                lockedDoorArray[gobDBID].ownerID = playerGUID;
                lockedDoorArray[gobDBID].owner_type = 2;
                lockedDoorArray[gobDBID].expTime = os.time() + 604800;
                createDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                savePaymentHistory(player, gobDBID, lockedDoorArray[gobDBID].cost_start, 2)
                player:SendBroadcastMessage("Покупка прошла успешно.");
            else
                player:SendBroadcastMessage("Недостаточно валюты для покупки недвижимости.");
            end
            player:GossipComplete();
        end
        if (intid == 24) then
            -- Можно ли вообще купить дом во владение гильдии?
            if (lockedDoorArray[gobDBID].can_own_guild ~= 1) then
                player:SendBroadcastMessage("Это помещение нельзя выкупить во владение гильдии.");
                player:GossipComplete();
                return false;
            end

            -- Состоит ли игрок в гильдии?
            local guild = player:GetGuild();
            if (guild == nil) then
                player:SendBroadcastMessage("Только лидеры гильдий могут покупать здания для гильдии.");
                player:GossipComplete();
                return false;
            end

            -- является ли игрок лидером этой гильдии
            local guildMaster = guild:GetLeader();
            if (guildMaster == playerGUID) then
                player:SendBroadcastMessage("Только лидеры гильдий могут покупать здания для гильдии.");
                player:GossipComplete();
                return false;
            end

            -- Хватает ли у игрока прав и репутации для покупки фракционных домов?
            local coeff = canBuyFactionHouses(player, gobDBID, guild);
            if (coeff == false) then
                player:GossipComplete();
                return false;
            end;

            local price = math.ceil(lockedDoorArray[gobDBID].cost_start * coeff)

            if (lockedDoorArray[gobDBID].cost_type == 0 and (player:GetCoinage() >= (price * 100))) then
                player:ModifyMoney(-price * 100);
                lockedDoorArray[gobDBID].ownerID = playerGUID;
                lockedDoorArray[gobDBID].expTime = os.time() + 604800;
                lockedDoorArray[gobDBID].owner_type = 1;
                lockedDoorArray[gobDBID].owner_guild = player:GetGuildId();
                createDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                savePaymentHistory(player, gobDBID, lockedDoorArray[gobDBID].cost_start, 1)
                player:SendBroadcastMessage("Покупка прошла успешно.");
            elseif ((lockedDoorArray[gobDBID].cost_type == 2 and player:HasItem(storm_currency, price)) or price == 0) then
                player:RemoveItem(storm_currency, price);
                lockedDoorArray[gobDBID].ownerID = playerGUID;
                lockedDoorArray[gobDBID].expTime = os.time() + 604800;
                lockedDoorArray[gobDBID].owner_type = 1;
                lockedDoorArray[gobDBID].owner_guild = player:GetGuildId();
                createDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                savePaymentHistory(player, gobDBID, lockedDoorArray[gobDBID].cost_start, 2)
                player:SendBroadcastMessage("Покупка прошла успешно.");
            elseif ((lockedDoorArray[gobDBID].cost_type == 1 and player:HasItem(andoral_currency, price)) or price == 0) then
                player:RemoveItem(andoral_currency, price);
                lockedDoorArray[gobDBID].ownerID = playerGUID;
                lockedDoorArray[gobDBID].expTime = os.time() + 604800;
                lockedDoorArray[gobDBID].owner_type = 1;
                lockedDoorArray[gobDBID].owner_guild = player:GetGuildId();
                createDoorOwnerData(lockedDoorArray[gobDBID], gobDBID);
                savePaymentHistory(player, gobDBID, lockedDoorArray[gobDBID].cost_start, 1)
                player:SendBroadcastMessage("Покупка прошла успешно.");
            else
                player:SendBroadcastMessage("Недостаточно валюты для покупки недвижимости.");
            end
            player:GossipComplete();
        end
    end
    if (intid == 25) then
        player:GossipComplete();
    end
end

RegisterPlayerGossipEvent(5500, 2, gossipSelectDoorOption);

local function checkLockedDoor(object, player)
    local door_GUID = object:GetDBTableGUIDLow();
    local allow_flags = lockedDoorArray[door_GUID].allowed;

    if (lockedDoorArray[door_GUID].ownerID == 0) then
        player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Внимание: |r |cFF00CCFFПомещение, в которое вы вошли можно купить в личное пользование! Осмотритесь, но не ставьте тут свои гошки, так как дом может быть приобретен другим игроком. Чтобы приобрести помещение, выйдите наружу, включите режим строительства и нажмите на дверь - откроется меню покупки.|r");
        return true;
    end

    if (lockedDoorArray[door_GUID].open == 1) then
        return true;
    end
    if (player:GetGUIDLow() == lockedDoorArray[door_GUID].ownerID) then
        return true;
    end
    if (CharDBQuery('SELECT * FROM doors_tenants WHERE char_guid = ' .. tostring(player:GetGUIDLow()) .. ' AND door_guid = ' .. door_GUID .. ' limit 1')) then
        return true;
    end
    if (bit_and(allow_flags, 8) == 8) then
        local ownerGuildIdQuery = CharDBQuery('SELECT guildid FROM characters.guild_member WHERE guid = ' .. lockedDoorArray[door_GUID].ownerID);
        if (ownerGuildIdQuery:GetRowCount() > 0) then
            guildID = ownerGuildIdQuery:GetUInt32(0);
            if (guildID == player:GetGuildId()) then
                return true;
            end
        end
    end
    if (bit_and(allow_flags, 4) == 4) then
        local ownerRaidIdQuery = CharDBQuery('SELECT guid FROM characters.group_member WHERE memberGuid = ' .. lockedDoorArray[door_GUID].ownerID);
        if (ownerRaidIdQuery) then
            if (ownerRaidIdQuery:GetRowCount() > 0) then
                raidID = ownerRaidIdQuery:GetUInt32(0);
                group = player:GetGroup()
                if (group) then
                    --if(GetGUIDLow(group:GetGUID()) == raidID)then
                    if (group:GetMemberGroup(lockedDoorArray[door_GUID].ownerID) ~= nil and group:IsRaidGroup()) then
                        return true;
                    end
                end
            end
        end
    end
    if (bit_and(allow_flags, 2) == 2) then
        local ownerGroupIdQuery = CharDBQuery('SELECT guid, subgroup FROM characters.group_member WHERE memberGuid = ' .. lockedDoorArray[door_GUID].ownerID);

        if (ownerGroupIdQuery == nil) then
            print('Nil value error'); --leave for test
        elseif (ownerGroupIdQuery:GetRowCount() > 0) then
            groupID = ownerGroupIdQuery:GetUInt32(0);
            subGroupID = ownerGroupIdQuery:GetUInt32(1);
            group = player:GetGroup()
            if (group) then
                --if(GetGUIDLow(group:GetGUID()) == groupID and player:GetSubGroup() == subGroupID)then
                if (group:GetMemberGroup(lockedDoorArray[door_GUID].ownerID) ~= nil and player:GetSubGroup() == subGroupID) then
                    return true;
                end
            end
        end
    end
    return false;
end

local function openLockedDoor(event, player, object)
    local gobDBID = object:GetDBTableGUIDLow();
    if (player:HasQuest(building_quest)) then
        if (player:GetGUIDLow() == lockedDoorArray[gobDBID].ownerID) then
            PlayerBuild.targetgobject[player:GetGUIDLow()] = object:GetGUID();
            gossipDoorOption(event, player, player, gobDBID);
        elseif (lockedDoorArray[gobDBID].ownerID == 0) then
            PlayerBuild.targetgobject[player:GetGUIDLow()] = object:GetGUID();
            gossipDoorBuy(event, player, player, gobDBID);
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Ошибка: |r |cFF00CCFFДом вам не принадлежит|r");
        end
    else
        if (checkLockedDoor(object, player)) then
            GoMovable.onGoTeleportGossip(event, player, object)
            return false;
        else
            return true;
        end
    end
end

----------------------------------------------------------
------ Формирование массивов данных по дверям ------------
local function assignDoorsOwners(doorNum)
    local goDoorsOwnerQuery = CharDBQuery('SELECT * FROM doors_owners where door_guid = ' .. doorNum .. ' limit 1;');
    if (goDoorsOwnerQuery ~= nil) then
        local ownerData = goDoorsOwnerQuery:GetRow();
        lockedDoorArray[doorNum].door_level = ownerData['door_level'];
        lockedDoorArray[doorNum].owner_type = ownerData['owner_type'];
        lockedDoorArray[doorNum].ownerID = ownerData['ownerID'];
        lockedDoorArray[doorNum].expTime = ownerData['expTime'];
        lockedDoorArray[doorNum].open = ownerData['open'];
        lockedDoorArray[doorNum].allowed = ownerData['allowed'];
        lockedDoorArray[doorNum].owner_guild = ownerData['owner_guild'];
		lockedDoorArray[doorNum].aura = ownerData['aura'];
    end
end

local function assignDoorsData(entry)
    local goDoorsSpawnedQuery = WorldDBQuery('SELECT * FROM gameobject where id = ' .. entry);
    if (goDoorsSpawnedQuery ~= nil) then
        local rowCount = goDoorsSpawnedQuery:GetRowCount();
        local doorId;
        for var = 1, rowCount, 1 do
            local doorId = goDoorsSpawnedQuery:GetString(0);
            local doorNum = tonumber(doorId);
            lockedDoorArray[doorNum] = {}
            lockedDoorArray[doorNum].door_id = entry;
            lockedDoorArray[doorNum].door_level = 0;
            lockedDoorArray[doorNum].owner_type = 0;
            lockedDoorArray[doorNum].ownerID = 0;
            lockedDoorArray[doorNum].expTime = 0;
            lockedDoorArray[doorNum].open = 0;
            lockedDoorArray[doorNum].allowed = 0;
            lockedDoorArray[doorNum].owner_guild = 0;
			lockedDoorArray[doorNum].aura = 0;
            lockedDoorArray[doorNum].cost_prolong = doorDataArray[entry]['cost_prolong'];
            lockedDoorArray[doorNum].cost_start = doorDataArray[entry]['cost_start'];
            lockedDoorArray[doorNum].house_type = doorDataArray[entry]['house_type'];
            lockedDoorArray[doorNum].can_own_user = doorDataArray[entry]['can_own_user'];
            lockedDoorArray[doorNum].can_own_guild = doorDataArray[entry]['can_own_guild'];
            lockedDoorArray[doorNum].can_own_faction = doorDataArray[entry]['can_own_faction'];
            lockedDoorArray[doorNum].region_id = doorDataArray[entry]['region_id'];
            lockedDoorArray[doorNum].cost_type = doorDataArray[entry]['cost_type'];
            assignDoorsOwners(doorNum);

            goDoorsSpawnedQuery:NextRow();
        end
    end
end

function assignDoorsEvents()
    local goDoorsQuery = CharDBQuery('SELECT * FROM doors');
    if (goDoorsQuery ~= nil) then
        local rowCount = goDoorsQuery:GetRowCount();
        local entry;
        lockedDoorArray = {};
        doorDataArray = {};
        for var = 1, rowCount, 1 do
            entry = goDoorsQuery:GetString(0);
            ClearGameObjectGossipEvents(entry, 1)
            RegisterGameObjectGossipEvent(entry, 1, openLockedDoor);
            doorDataArray[entry] = goDoorsQuery:GetRow();
            assignDoorsData(entry);
            goDoorsQuery:NextRow();
        end
    end
end

assignDoorsEvents(); -- Регистрируем события на двери.

function assignFactionsData()
    local factionsQuery = CharDBQuery('SELECT * FROM house_factions');
    if (factionsQuery ~= nil) then
        local rowCount = factionsQuery:GetRowCount();
        local factionId;
        houseFactions = {};
        for var = 1, rowCount, 1 do
            local factionId = factionsQuery:GetString(0);
            local factionNum = tonumber(factionId);
            houseFactions[factionNum] = factionsQuery:GetRow();
            factionsQuery:NextRow();
        end
    end
end

assignFactionsData()
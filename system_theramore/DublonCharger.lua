local NpcChargerId = 987975;
local veksel = 301397;
local crown = 301396;

local MenuId = 61225;

local function OnGossipChargerDublon(event, player, object)
    player:GossipClearMenu() -- required for player gossip
    player:GossipMenuAddItem(0, "КУПИТЬ разменные дублоны (максимум 30 за раз, вводить количество в поле <код>)", 1, 2, true, nil)
    player:GossipMenuAddItem(0, "ПРОДАТЬ разменные дублоны (максимум 30 за раз, вводить количество в поле <код>))", 1, 3, true, nil)
    player:GossipMenuAddItem(0, "Закрыть", 1, 5)
    player:GossipSetText( 'ООС: Тут вы можете обменять персональные дублоны на неперсональные "разменные дублоны" и обратно. Разменными дублонами можно обмениваться с другими игроками.\n\n После обмена дублоны придут на почту. \n\nКурс покупки и продажи: 1х1 \n\nДоступно только с 5-го уровня персонажа!', MenuId )
    player:GossipSendMenu(MenuId, object, MenuId) -- MenuId required for player gossip
end

local function OnGossipChargerSelectDublon(event, player, object, sender, intid, code, menuid)
    local level = player:GetNobleLevel()
    if level < 5 then
        player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНЕТ ДОСТУПА: Нельзя обменивать дублоны, пока вы не достигли 5-го уровня! |r");
        player:GossipComplete()
        return false;
    end

    if (intid == 2) then
        local num = tonumber(code);
        if (num > 30) then
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОШИБКА! Нельзя покупать или продавать более 30 дублонов за раз |r");
            player:GossipComplete()
            return false;
        end

        local crownsNeeded;
        crownsNeeded = num*1;

        if (player:HasItem(crown, crownsNeeded)) then
            SendMail( "Обмен у казначея", "Приятной игры", player:GetGUIDLow(), 0, 61, 0, 0, 0, veksel, num )
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОбмен проведен успешно! Выслано разменных дублонов: |r" .. tostring(num));
            player:RemoveItem(crown, crownsNeeded);
            player:GossipComplete()
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНедостаточно дублонов для покупки нужного числа разменных дублонов. Требуемое число дублонов: |r" .. tostring(crownsNeeded));
            player:GossipComplete()
        end
    elseif (intid == 3) then
        local num = tonumber(code);
        if (num > 30) then
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОШИБКА! Нельзя покупать или продавать более 30 разменных дублонов за раз |r");
            player:GossipComplete();
            return false;
        end
        if (player:HasItem(veksel, num)) then
            SendMail( "Обмен у казначея", "Приятной игры", player:GetGUIDLow(), 0, 61, 0, 0, 0, crown, num )
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОбмен проведен успешно! Выслано дублонов: |r" .. tostring(num));
            player:RemoveItem(veksel, num);
            player:GossipComplete()
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНедостаточно разменных дублонов. Требуемое число разменных дублонов: |r" .. tostring(num));
            player:GossipComplete()
        end
    elseif (intid == 5) then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NpcChargerId, 1, OnGossipChargerDublon)
RegisterCreatureGossipEvent(NpcChargerId, 2, OnGossipChargerSelectDublon)
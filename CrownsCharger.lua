local NpcChargerId = 110004;
local veksel = 600157;
local crown = 600057;
local faction_stormwind = 1162;
local faction_shadow_stormwind = 1163;
local reputation_friendly = 3000;
local reputation_honored = 9000;
local reputation_revered = 21000;
local MenuId = 61218;

local function OnGossipCharger(event, player, object)
    player:GossipClearMenu() -- required for player gossip
    player:GossipMenuAddItem(0, "КУПИТЬ вексели (максимум 30 за раз, вводить количество в поле <код>)", 1, 2, true, nil)
    player:GossipMenuAddItem(0, "ПРОДАТЬ вексели (максимум 30 за раз, вводить количество в поле <код>))", 1, 3, true, nil)
    player:GossipMenuAddItem(0, "Закрыть", 1, 5)
    player:GossipSetText( 'ООС: Тут вы можете обменять короны на вексели и обратно. Векселями можно обмениваться с другими игроками.\n\n После обмены короны/вексели придут на почту. \n\nКурс покупки векселя у казначея: \n- дружелюбие - 5 корон за вексель\n- уважение - 4 короны за вексель\n- почтение - 3 короны за вексель \nКурс продажи векселя казначею: за один вексель вы получите 3 короны на любом уровне репутации', MenuId )
    player:GossipSendMenu(MenuId, object, MenuId) -- MenuId required for player gossip
end

local function OnGossipChargerSelect(event, player, object, sender, intid, code, menuid)
    if (intid == 2) then
        local num = tonumber(code);
        if (num > 30) then
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОШИБКА! Нельзя покупать или продавать более 30 векселей за раз |r");
            player:GossipComplete()
            return false;
        end

        local crownsNeeded;

        if ((player:GetReputation( faction_stormwind ) >= reputation_revered) or (player:GetReputation( faction_shadow_stormwind ) >= reputation_revered)) then
            crownsNeeded = num*3;
        elseif ((player:GetReputation( faction_stormwind ) >= reputation_honored) or (player:GetReputation( faction_shadow_stormwind ) >= reputation_honored)) then
            crownsNeeded = num*4;
        elseif ((player:GetReputation( faction_stormwind ) >= reputation_friendly) or (player:GetReputation( faction_shadow_stormwind ) >= reputation_friendly)) then
            crownsNeeded = num*5;
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFУ вас недостаточно репутации для покупки векселей. Минимальная репутация: дружелюбие в одной из фракций Штормграда|r");
            player:GossipComplete()
            return false;
        end

        if (player:HasItem(crown, crownsNeeded)) then
            SendMail( "Обмен у казначея", "Приятной игры", player:GetGUIDLow(), 0, 61, 0, 0, 0, veksel, num )
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОбмен проведен успешно! Выслано векселей: |r" .. tostring(num));
            player:RemoveItem(crown, crownsNeeded);
            player:GossipComplete()
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНедостаточно корон для покупки нужного числа векселей. Требуемое число корон: |r" .. tostring(crownsNeeded));
            player:GossipComplete()
        end
        OnGossipCharger(event, player, object)
    elseif (intid == 3) then
        local num = tonumber(code);
        if (num > 30) then
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОШИБКА! Нельзя покупать или продавать более 30 векселей за раз |r");
            player:GossipComplete();
            return false;
        end
        local crownsToAdd = num * 3;
        if (player:HasItem(veksel, num)) then
            SendMail( "Обмен у казначея", "Приятной игры", player:GetGUIDLow(), 0, 61, 0, 0, 0, crown, crownsToAdd )
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОбмен проведен успешно! Выслано штормградских корон: |r" .. tostring(crownsToAdd));
            player:RemoveItem(veksel, num);
            player:GossipComplete()
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНедостаточно векселей. Требуемое число векселей: |r" .. tostring(num));
            player:GossipComplete()
        end
        OnGossipCharger(event, player, object)
    elseif (intid == 5) then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NpcChargerId, 1, OnGossipCharger)
RegisterCreatureGossipEvent(NpcChargerId, 2, OnGossipChargerSelect)
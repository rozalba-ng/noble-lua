local NpcChargerId = 110005;
local veksel = 301115;
local crown = 600254;

local MenuId = 61319;

local function OnGossipCharger(event, player, object)
    player:GossipClearMenu() -- required for player gossip
    player:GossipMenuAddItem(0, "КУПИТЬ партии Поющего Золота (максимум 30 за раз, вводить количество в поле <код>)", 1, 2, true, nil)
    player:GossipMenuAddItem(0, "ПРОДАТЬ партии Поющего Золота (максимум 30 за раз, вводить количество в поле <код>))", 1, 3, true, nil)

    player:GossipMenuAddItem(0, "Закрыть", 1, 5)
    player:GossipSetText( 'ООС: Тут можно обменять персональные слитки на партии золота и обратно. Партиями золота можно обмениваться с другими игроками.\n\n После обмена партии/слитки придут на почту. \n\nКурс покупки партии золота у казначея: \n- дружелюбие - 5 слитков за партию\n- уважение - 4 слитка за партию\n- почтение - 3 слитка за партию \nКурс продажи партии казначею: за одну партию вы получите 3 слитка на любом уровне репутации', MenuId )
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

        if ((player:GetReputation( venture_faction ) >= reputation_revered) or (player:GetReputation( ekspedition_faction ) >= reputation_revered) or (player:GetReputation( zulhetis_faction ) >= reputation_revered) or (player:GetReputation( brothers_faction ) >= reputation_revered) or (player:GetReputation( blacksun_faction ) >= reputation_revered) or (player:GetReputation( korus_faction ) >= reputation_revered)) then
            crownsNeeded = num*3;
        elseif ((player:GetReputation( venture_faction ) >= reputation_honored) or (player:GetReputation( ekspedition_faction ) >= reputation_honored) or (player:GetReputation( zulhetis_faction ) >= reputation_honored) or (player:GetReputation( brothers_faction ) >= reputation_honored) or (player:GetReputation( blacksun_faction ) >= reputation_honored) or (player:GetReputation( korus_faction ) >= reputation_honored)) then
            crownsNeeded = num*4;
        elseif ((player:GetReputation( venture_faction ) >= reputation_friendly) or (player:GetReputation( ekspedition_faction ) >= reputation_friendly) or (player:GetReputation( zulhetis_faction ) >= reputation_friendly) or (player:GetReputation( brothers_faction ) >= reputation_friendly) or (player:GetReputation( blacksun_faction ) >= reputation_friendly) or (player:GetReputation( korus_faction ) >= reputation_friendly)) then
            crownsNeeded = num*5;
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFУ вас недостаточно репутации для покупки партий золота. Минимальная репутация: дружелюбие в одной из фракций Западной Долины|r");
            player:GossipComplete()
            return false;
        end

        if (player:HasItem(crown, crownsNeeded)) then
            SendMail( "Обмен у казначея", "Приятной игры", player:GetGUIDLow(), 0, 61, 0, 0, 0, veksel, num )
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОбмен проведен успешно! Выслано партий золота: |r" .. tostring(num));
            player:RemoveItem(crown, crownsNeeded);
            player:GossipComplete()
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНедостаточно слитков для покупки нужного числа партий золота. Требуемое число слитков: |r" .. tostring(crownsNeeded));
            player:GossipComplete()
        end
    elseif (intid == 3) then
        local num = tonumber(code);
        if (num > 30) then
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОШИБКА! Нельзя покупать или продавать более 30 партий золота за раз |r");
            player:GossipComplete();
            return false;
        end
        local crownsToAdd = num * 3;
        if (player:HasItem(veksel, num)) then
            SendMail( "Обмен у казначея", "Приятной игры", player:GetGUIDLow(), 0, 61, 0, 0, 0, crown, crownsToAdd )
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОбмен проведен успешно! Выслано слитков Поющего Золота: |r" .. tostring(crownsToAdd));
            player:RemoveItem(veksel, num);
            player:GossipComplete()
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНедостаточно партий золота. Требуемое число партий золота: |r" .. tostring(num));
            player:GossipComplete()
        end
    elseif (intid == 5) then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NpcChargerId, 1, OnGossipCharger)
RegisterCreatureGossipEvent(NpcChargerId, 2, OnGossipChargerSelect)
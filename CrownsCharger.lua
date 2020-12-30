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
    player:GossipMenuAddItem(0, "Купить вексели (в поле 'код' вводите желаемое количество)", 1, 2, true, nil)
    player:GossipMenuAddItem(0, "Продать вексели (в поле 'код' вводите желаемое количество)", 1, 3, true, nil)
    player:GossipMenuAddItem(0, "Закрыть", 1, 5)
    player:GossipSetText( '— Приветствую!\n\nООС: Тут вы можете обменять ваши персональные короны на не-персональные вексели и обратно. Векселями можно обмениваться с другими игроками. \n\nКурс покупки векселя у казначея: \n- дружелюбие - 5 корон за вексель\n- уважение - 4 короны за вексель\n- почтение - 3 короны за вексель \nКурс продажи векселя казначею: за один вексель вы получите 3 короны на любом уровне репутации', MenuId )
    player:GossipSendMenu(MenuId, object, MenuId) -- MenuId required for player gossip
end

local function OnGossipChargerSelect(event, player, object, sender, intid, code, menuid)
    if (intid == 2) then
        local num = tonumber(code);
        local crownsNeeded;

        if ((player:GetReputation( faction_stormwind ) >= reputation_revered) or (player:GetReputation( faction_shadow_stormwind ) >= reputation_revered)) then
            crownsNeeded = num*3;
        elseif ((player:GetReputation( faction_stormwind ) >= reputation_honored) or (player:GetReputation( faction_shadow_stormwind ) >= reputation_honored)) then
            crownsNeeded = num*4;
        elseif ((player:GetReputation( faction_stormwind ) >= reputation_friendly) or (player:GetReputation( faction_shadow_stormwind ) >= reputation_friendly)) then
            crownsNeeded = num*5;
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFУ вас недостаточно репутации для покупки векселей. Минимальная репутация: дружелюбие в одной из фракций Штормграда|r");
            return false;
        end

        if (player:HasItem(crown, crownsNeeded)) then
            local item = player:AddItem(veksel, num);
            if(item == nil)then
                player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНет места.|r");
                return false;
            end
            player:RemoveItem(crown, crownsNeeded);
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНедостаточно корон для покупки нужного числа векселей. Требуемое число корон: |r" .. tostring(crownsNeeded));
        end
        OnGossipCharger(event, player, object)
    elseif (intid == 3) then
        local num = tonumber(code);
        local crownsToAdd = num * 3;
        if (player:HasItem(veksel, num)) then
            local item = player:AddItem(crown, crownsToAdd);
            if(item == nil)then
                player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНет места.|r");
                return false;
            end
            player:RemoveItem(veksel, num);
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНедостаточно векселей. Требуемое число векселей: |r" .. tostring(num));
        end
        OnGossipCharger(event, player, object)
    elseif (intid == 5) then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NpcChargerId, 1, OnGossipCharger)
RegisterCreatureGossipEvent(NpcChargerId, 2, OnGossipChargerSelect)
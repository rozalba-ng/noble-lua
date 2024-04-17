local NpcChargerId = 988028;
local greenResurs = 301394;
local whiteResurs = 301393;


local MenuId = 61265;

local function OnGossipChargerRes(event, player, object)
    player:GossipClearMenu() -- required for player gossip
    player:GossipMenuAddItem(0, "ПРОДАТЬ необычные ресурсы (максимум 5 за раз, вводить количество в поле <код>))", 1, 3, true, nil)
    player:GossipMenuAddItem(0, "Закрыть", 1, 5)
    player:GossipSetText( 'ООС: Тут вы можете обменять необычные ресурсы на обычные.\n\n После обмена ресурсы придут на почту. \n\nКурс покупки и продажи: 10 обычных за 1 необычный', MenuId )
    player:GossipSendMenu(MenuId, object, MenuId) -- MenuId required for player gossip
end

local function OnGossipChargerSelectRes(event, player, object, sender, intid, code, menuid)
    local level = player:GetNobleLevel()

    if (intid == 3) then
        local num = tonumber(code);
        if (num > 5) then
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОШИБКА! Нельзя продавать более 5 необычных ресурсов за раз |r");
            player:GossipComplete();
            return false;
        end

        local whiteResursNeeded;
        whiteResursNeeded = num*10;

        if (player:HasItem(greenResurs, num)) then
            SendMail( "Обмен у кладовщика", "Приятной игры", player:GetGUIDLow(), 0, 61, 0, 0, 0, whiteResurs, whiteResursNeeded )
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОбмен проведен успешно! Выслано обычных ресурсов: |r" .. tostring(whiteResursNeeded));
            player:RemoveItem(greenResurs, num);
            player:GossipComplete()
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНедостаточно необычных ресурсов. Требуемое число необычных ресурсов: |r" .. tostring(num));
            player:GossipComplete()
        end
    elseif (intid == 5) then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NpcChargerId, 1, OnGossipChargerRes)
RegisterCreatureGossipEvent(NpcChargerId, 2, OnGossipChargerSelectRes)
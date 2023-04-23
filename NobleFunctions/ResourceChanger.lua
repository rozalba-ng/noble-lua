-- local SimpleResource = 301393
-- local UnCommonResource = 301394
-- local chDublon = 301397
-- local value = math.floor(value/3)

-- local function ResourceChanger(event, player, object, sender, intid, code, menuid)
    -- local level = player:GetNobleLevel()

    -- -- if (intid == 2) then
        -- -- local num = tonumber(code);
        -- if (value > 21) then
            -- player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОШИБКА! Нельзя покупать или продавать более 21 дублонов за раз |r");
            -- player:GossipComplete()
            -- return false;
        -- end

        -- if level < 7 then
            -- player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНЕТ ДОСТУПА: Нельзя обменивать ресурсы, пока вы не достигли 7-го уровня! |r");
            -- player:GossipComplete()
            -- return false;
        -- end

        -- local dublonNeeded;
        -- chDublonNeeded = value*1;

        -- if (player:HasItem(chDublon, chDublonNeeded)) then
            -- SendMail( "Обменник", "Приятной игры!", player:GetGUIDLow(), 0, 61, 0, 0, 0, 301393, value )
            -- player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОбмен проведен успешно! Выслано обычных ресурсов: |r" .. tostring(value));
            -- player:RemoveItem(chDublon, chDublonNeeded);
            -- player:GossipComplete()
        -- else
            -- player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНедостаточно дублонов для покупки нужного числа разменных дублонов. Требуемое число дублонов: |r" .. tostring(crownsNeeded));
            -- player:GossipComplete()
        -- end
    -- -- elseif (intid == 3) then
        -- -- local num = tonumber(code);
        -- -- if (num > 30) then
            -- -- player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОШИБКА! Нельзя покупать или продавать более 30 разменных дублонов за раз |r");
            -- -- player:GossipComplete();
            -- -- return false;
        -- -- end
        -- -- if (player:HasItem(veksel, num)) then
            -- -- SendMail( "Обмен у казначея", "Приятной игры", player:GetGUIDLow(), 0, 61, 0, 0, 0, crown, num )
            -- -- player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОбмен проведен успешно! Выслано дублонов: |r" .. tostring(num));
            -- -- player:RemoveItem(veksel, num);
            -- -- player:GossipComplete()
        -- -- else
            -- -- player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНедостаточно разменных дублонов. Требуемое число разменных дублонов: |r" .. tostring(num));
            -- -- player:GossipComplete()
        -- -- end
    -- -- elseif (intid == 5) then
        -- -- player:GossipComplete()
    -- -- end
-- -- end

local function TestFC()
	print("123")
end
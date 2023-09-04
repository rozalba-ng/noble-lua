local goblinId = 987780;
local menuId = 61255;
---- маунты реактивации Западная Долина
mount_1_id = 1200113;
mount_2_id = 1200114;
mount_3_id = 1200115;
mount_4_id = 1200116;

local function OnGossipGoblin(event, player, object)
    player:GossipClearMenu() -- required for player gossip
    local accountId = player:GetAccountId();
    local result = AuthDBQuery("SELECT * FROM account WHERE id = "..accountId .." and brw_mount=1");
    if(result ~= nil) then
        player:GossipMenuAddItem(0, "Боевой конь Орды", 1, 1, false, "Вы выбрали: Боевой конь Орды. Выбор нельзя будет отменить. Вы уверены?")
        player:GossipMenuAddItem(0, "Боевой волк Альянса", 1, 2, false, "Вы выбрали: Боевой волк Альянса. Выбор нельзя будет отменить. Вы уверены?")
        player:GossipMenuAddItem(0, "Парадный конь Альянса", 1, 3, false, "Вы выбрали: Парадный конь Альянса. Выбор нельзя будет отменить. Вы уверены?")
        player:GossipMenuAddItem(0, "Навьюченный мул", 1, 4, false, "Вы выбрали: Навьюченный мул. Выбор нельзя будет отменить. Вы уверены?")
        player:GossipMenuAddItem(0, "Приму решение позже...", 1, 5)
        player:GossipSetText( 'Хей-хей! Я вдоль и поперёк исследовал весь Азерот и уже успел оценить масштабы земель у Черной Горы. И знаешь что? Тебе ОПРЕДЕЛЁННО понадобится четвероногий приятель! Я, так и быть, готов расщедриться и выдать лично тебе одного из моих четырех любимцев. Но помни два условия — выбрать можно только одного из них и НИКАКИХ возвратов! Итак, кого ты выберешь?', menuId )
    else
        player:GossipMenuAddItem(0, "Прощай...", 1, 5)
        player:GossipSetText( 'Эй, мы же договаривались - никаких возвратов! Может как нибудь в другой раз я подготовлю что-то еще, а сейчас бывай, до встречи у Чёрной Горы!', menuId )
    end

    player:GossipSendMenu(menuId, object, menuId) -- MenuId required for player gossip
end

local function OnGossipGoblinSelect(event, player, object, sender, intid, code, menuid)
    local accountId = player:GetAccountId();
    if (intid == 1) then
        AuthDBExecute("REPLACE INTO `donations` (`accountId`, `accountName`, `amount`, `currency`, `donateType`, `gift_done`, `comment`) VALUES ("..accountId ..", '"..accountId .."', '0', NULL, 'brw_mount_1', 0, 'reactivation'); ")
        AuthDBExecute("UPDATE account SET brw_mount=0 WHERE id = "..accountId)
        player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Чтобы получить выбранного ездового спутника - перезайдите в игру!");
        player:GossipComplete()
    elseif (intid == 2) then
        AuthDBExecute("REPLACE INTO `donations` (`accountId`, `accountName`, `amount`, `currency`, `donateType`, `gift_done`, `comment`) VALUES ("..accountId ..", '"..accountId .."', '0', NULL, 'brw_mount_2', 0, 'reactivation'); ")
        AuthDBExecute("UPDATE account SET brw_mount=0 WHERE id = "..accountId)
        player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Чтобы получить выбранного ездового спутника - перезайдите в игру!");
        player:GossipComplete()
    elseif (intid == 3) then
        AuthDBExecute("REPLACE INTO `donations` (`accountId`, `accountName`, `amount`, `currency`, `donateType`, `gift_done`, `comment`) VALUES ("..accountId ..", '"..accountId .."', '0', NULL, 'brw_mount_3', 0, 'reactivation'); ")
        AuthDBExecute("UPDATE account SET brw_mount=0 WHERE id = "..accountId)
        player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Чтобы получить выбранного ездового спутника - перезайдите в игру!");
        player:GossipComplete()
    elseif (intid == 4) then
        AuthDBExecute("REPLACE INTO `donations` (`accountId`, `accountName`, `amount`, `currency`, `donateType`, `gift_done`, `comment`) VALUES ("..accountId ..", '"..accountId .."', '0', NULL, 'brw_mount_4', 0, 'reactivation'); ")
        AuthDBExecute("UPDATE account SET brw_mount=0 WHERE id = "..accountId)
        player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Чтобы получить выбранного ездового спутника - перезайдите в игру!");
        player:GossipComplete()
    elseif (intid == 5) then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(goblinId, 1, OnGossipGoblin)
RegisterCreatureGossipEvent(goblinId, 2, OnGossipGoblinSelect)

local goblinId = 987780;
local menuId = 61255;
---- маунты реактивации Западная Долина
mount_zevra_id = 1200058;
mount_gien_id = 1200059;
mount_raptor_id = 1200060;

local function OnGossipGoblin(event, player, object)
    player:GossipClearMenu() -- required for player gossip
    local accountId = player:GetAccountId();
    local result = AuthDBQuery("SELECT * FROM account WHERE id = "..accountId .." and zd_mount=1");
    if(result ~= nil) then
        player:GossipMenuAddItem(0, "Жевра Западной Долины", 1, 1, false, "Вы выбрали: Жевра Западной Долины. Выбор нельзя будет отменить. Вы уверены?")
        player:GossipMenuAddItem(0, "Гиена диких степей", 1, 2, false, "Вы выбрали: Гиена диких степей. Выбор нельзя будет отменить. Вы уверены?")
        player:GossipMenuAddItem(0, "Джунглевый раптор", 1, 3, false, "Вы выбрали: Джунглевый раптор. Выбор нельзя будет отменить. Вы уверены?")
        player:GossipMenuAddItem(0, "Приму решение позже...", 1, 4)
        player:GossipSetText( 'Хей-хей! Я вдоль и поперёк исследовал весь Азерот и уже успел оценить масштабы этой Западной Долины. И знаешь что? Тебе ОПРЕДЕЛЁННО понадобится четвероногий приятель! Я, так и быть, готов расщедриться и выдать лично тебе одного из моих трёх любимцев. Но помни два условия — выбрать можно только одного из них и НИКАКИХ возвратов! Итак, кого ты выберешь?', MenuId )
    else
        player:GossipMenuAddItem(0, "Прощай...", 1, 4)
        player:GossipSetText( 'Эй, мы же договаривались - никаких возвратов! Может как нибудь в другой раз я подготовлю что-то еще, а сейчас бывай, до встречи в Западной Долине!', MenuId )
    end

    player:GossipSendMenu(MenuId, object, MenuId) -- MenuId required for player gossip
end

local function OnGossipGoblinSelect(event, player, object, sender, intid, code, menuid)
    local accountId = player:GetAccountId();
    if (intid == 1) then
        AuthDBExecute("REPLACE INTO `donations` (`accountId`, `accountName`, `amount`, `currency`, `donateType`, `gift_done`, `comment`, `donateDate`) VALUES ("..accountId ..", '"..accountId .."', '0', NULL, 'zevra', 0, 'reactivation'); ")
        AuthDBExecute("UPDATE account WHERE accountId = "..accountId .." SET zd_mount=0")
        player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Чтобы получить выбранного ездового спутника - перезайдите в игру!");
    elseif (intid == 2) then
        AuthDBExecute("REPLACE INTO `donations` (`accountId`, `accountName`, `amount`, `currency`, `donateType`, `gift_done`, `comment`, `donateDate`) VALUES ("..accountId ..", '"..accountId .."', '0', NULL, 'gien', 0, 'reactivation'); ")
        AuthDBExecute("UPDATE account WHERE accountId = "..accountId .." SET zd_mount=0")
        player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Чтобы получить выбранного ездового спутника - перезайдите в игру!");
    elseif (intid == 3) then
        AuthDBExecute("REPLACE INTO `donations` (`accountId`, `accountName`, `amount`, `currency`, `donateType`, `gift_done`, `comment`, `donateDate`) VALUES ("..accountId ..", '"..accountId .."', '0', NULL, 'raptor', 0, 'reactivation'); ")
        AuthDBExecute("UPDATE account WHERE accountId = "..accountId .." SET zd_mount=0")
        player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Чтобы получить выбранного ездового спутника - перезайдите в игру!");
    elseif (intid == 4) then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(goblinId, 1, OnGossipGoblin)
RegisterCreatureGossipEvent(goblinId, 2, OnGossipGoblinSelect)

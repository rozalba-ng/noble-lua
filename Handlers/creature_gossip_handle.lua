if(mountDataArray == nil)then
    mountDataArray = {};
end

if(mountTemplateArray == nil)then
    mountTemplateArray = {};
end

if(mountEquipTemplateArray == nil)then
    mountEquipTemplateArray = {};
end

local mountPrice = {[992000] = {"Гнедой конь", 15},
                    [992001] = {"Вороной конь", 15},
                    [992002] = {"Гнедая кобыла", 15},
                    [992003] = {"Игреневый конь", 15},
                    [992004] = {"Пегой конь", 15},
                    [992005] = {"Серый конь", 15},
                    [992009] = {"Вороной мул", 10},
                    [992010] = {"Голубой мул", 10},
                    [992011] = {"Гнедой мул", 10},
                    [992012] = {"Серый мул", 10},
                    [992013] = {"Саврасый мул", 10},
                    [992014] = {"Светло-серый мул", 10}} -- TODO перенести в базу
					
local mountSilverPrice = {[992000] = {"Гнедой конь", 75},
                    [992001] = {"Вороной конь", 75},
                    [992002] = {"Гнедая кобыла", 75},
                    [992003] = {"Игреневый конь", 75},
                    [992004] = {"Пегой конь", 75},
                    [992005] = {"Серый конь", 75},
                    [992009] = {"Вороной мул", 50},
                    [992010] = {"Голубой мул", 50},
                    [992011] = {"Гнедой мул", 50},
                    [992012] = {"Серый мул", 50},	
                    [992013] = {"Саврасый мул", 50},
                    [992014] = {"Светло-серый мул", 50}} 
local mountPriceHorde = {[992022] = {"Снежный волк", 60},
                    [992023] = {"Темный волк", 60},
                    [992024] = {"Пепельный волк", 60},
                    [992025] = {"Бурый волк", 60}} 
local mountSilverPriceHorde = {[992022] = {"Снежный волк", 60},
                    [992023] = {"Темный волк", 60},
                    [992024] = {"Пепельный волк", 60},
                    [992025] = {"Бурый волк", 60}} 

local andoral_currency = 43721;

local available_equip_slots = {[1] = "Седло",
                               [2] = "Флаг"};


local function saveMountOwnerQuery(player, mount)
	CharDBExecute("INSERT INTO `mount_owner` (`guid`, `entry`, `owner_id`) VALUES (".. mount:GetDBTableGUIDLow() ..", ".. mount:GetEntry() ..", ".. player:GetGUIDLow() ..");");
end

local function deleteMountEquipData(mount_guid, item_entry)
	CharDBExecute("DELETE FROM `mount_equip` where mount_guid = " .. mount_guid .. " and item_entry = " .. item_entry ..";");
end

local function saveMountEquipData(mount_guid, item_entry)
	CharDBExecute("INSERT INTO `mount_equip` (`mount_guid`, `item_entry`) VALUES (".. mount_guid..", ".. item_entry ..");");
end

local function gossipMountNpc(event, player, object)
    local guid = object:GetDBTableGUIDLow();
    if(mountDataArray[guid])then
        if(mountDataArray[guid].owner_id == player:GetGUIDLow())then
            player:GossipClearMenu() -- required for player gossip
            player:GossipMenuAddItem(4, "Оседлать", 1, 1)
            if(object:GetMovementType() ~= 14)then
                player:GossipMenuAddItem(4, "Вести", 1, 3)
            else
                player:GossipMenuAddItem(4, "Остановить", 1, 4)
            end
            local entry = mountDataArray[guid].entry;
            if(mountTemplateArray[entry])then
                player:GossipMenuAddItem(1, "Экипировать", 1, 5)
            end
            player:GossipMenuAddItem(0, "Закрыть", 1, 2)
            player:GossipSendMenu(1, object) -- MenuId required for player gossip
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Ошибка: |r |cFF00CCFFТранспорт вам не принадлежит|r");
        end
    end
end

local function gossipMountEquipList(event, player, object)
    local guid = object:GetDBTableGUIDLow();
    if(mountDataArray[guid])then
        if(mountDataArray[guid].owner_id == player:GetGUIDLow())then
            for index, slot in pairs(available_equip_slots) do
                player:GossipMenuAddItem(1, slot, 1, index+100)
            end
            player:GossipMenuAddItem(0, "Закрыть", 1, 2)
            player:GossipSendMenu(1, object) -- MenuId required for player gossip
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Ошибка: |r |cFF00CCFFТранспорт вам не принадлежит|r");
        end
    end
end

local function gossipMountSlotItemList(event, player, object, slot_id)
    local guid = object:GetDBTableGUIDLow();
    if(mountDataArray[guid])then
        if(mountDataArray[guid].owner_id == player:GetGUIDLow())then
            local entry = mountDataArray[guid].entry;
            for index, item_temp in pairs(mountEquipTemplateArray) do
                if(item_temp.slot_type == slot_id and item_temp.mount_type == mountTemplateArray[entry].mount_type)then
                    if(player:HasItem(index))then
                        local item = player:GetItemByEntry( index );
                        player:GossipMenuAddItem(1, item:GetName(), 1, index)
                    end
                end
            end
            player:GossipMenuAddItem(1, "Снять", 1, 400+slot_id)
            player:GossipMenuAddItem(0, "Закрыть", 1, 2)
            player:GossipSendMenu(1, object) -- MenuId required for player gossip
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Ошибка: |r |cFF00CCFFТранспорт вам не принадлежит|r");
        end
    end
end

local function gossipSelectMountNpc(event, player, object, sender, intid, code, menuid)
    local map = player:GetMap();
    local guid = object:GetDBTableGUIDLow();
    if(mountDataArray[guid].owner_id == player:GetGUIDLow())then
        if (intid == 1) then
            local horse = PerformIngameSpawn( 1, object:GetEntry()+2000, map:GetMapId(), 0, object:GetX(), object:GetY(), object:GetZ()+0.2, object:GetO(), false, 0, 0, 1, guid);
            if(horse:IsInWorld())then
                player:CastSpell(horse, 84022);
                --object:Delete();
                object:DespawnOrUnsummon();
                object:SetRespawnDelay(5184000);
                if(mountDataArray[guid].items)then
                    for index, item in pairs(mountDataArray[guid].items) do                        
                        horse:AddAura(mountEquipTemplateArray[item].spell_id, horse);                        
                    end
                end
            else
                horse:Delete();
            end
            player:GossipComplete();
        elseif (intid == 2) then        
            player:GossipComplete();
        elseif (intid == 3) then        
            object:MoveFollow( player, 0, 1.507 )
            player:GossipComplete();
        elseif (intid == 4) then        
            object:MoveClear(true);
            object:SaveToDB(map:GetMapId(), 1, player:GetPhaseMask());
            player:GossipComplete();
        elseif (intid == 5) then
            gossipMountEquipList(event, player, object);
        elseif (intid >= 101 and intid <= 355) then
            local slot_id = intid - 100;
            gossipMountSlotItemList(event, player, object, slot_id)
        elseif (intid >= 401 and intid <= 655) then
            local slot_id = intid - 400;
            if(mountDataArray[guid].items[slot_id])then
                local item_entry = mountDataArray[guid].items[slot_id];
                mountDataArray[guid].items[slot_id] = nil;
                object:RemoveAura(mountEquipTemplateArray[item_entry].spell_id);
                deleteMountEquipData(guid, item_entry);
                local added = player:AddItem(item_entry);
                if(added == nil)then
                    SendMail( "Седло", "Мы не смогли разместить седло в вашем инвентаре.", player:GetGUIDLow(), 0, 61, 0, 0, 0, item_entry, 1 )
                    player:SendBroadcastMessage("В инвентаре нет места. Седло отправлено по почте.");
                end
            end
            player:GossipComplete();
        elseif (intid >= 805000 and intid <= 805999) then
            if(player:HasItem(intid))then
                local slot_id = mountEquipTemplateArray[intid].slot_type;
                if(mountDataArray[guid].items[slot_id])then
                    local item_entry = mountDataArray[guid].items[slot_id];
                    table.remove(mountDataArray[guid].items, slot_id);
                    object:RemoveAura(mountEquipTemplateArray[item_entry].spell_id);
                    deleteMountEquipData(guid, item_entry);
                    local added = player:AddItem(item_entry);                    
                    if(added == nil)then
                        SendMail( "Седло", "Мы не смогли разместить седло в вашем инвентаре.", player:GetGUIDLow(), 0, 61, 0, 0, 0, item_entry, 1 )
                        player:SendBroadcastMessage("В инвентаре нет места. Седло отправлено по почте.");
                    end
                end
                mountDataArray[guid].items[slot_id] = intid;
                object:AddAura(mountEquipTemplateArray[intid].spell_id, object);
                player:RemoveItem(intid, 1);
                saveMountEquipData(guid, intid);
            end
            player:GossipComplete();
        end
    end
end

local function OnVehicleLostControl(event, vehicle, charmer)
    local entry = vehicle:GetEntry();
    if(entry >= 994000 and entry <=995999)then
        local map = charmer:GetMap();
        local horse = GetCreature(vehicle:GetCreatureReplacer(), entry-2000, map:GetMapId());
        if(horse)then
            horse:NearTeleport( vehicle:GetX(), vehicle:GetY(), vehicle:GetZ()+0.2, vehicle:GetO() );
            horse:Relocate( vehicle:GetX(), vehicle:GetY(), vehicle:GetZ()+0.2, vehicle:GetO() );
            horse:Respawn();
            horse:SetRespawnDelay(300);
            local guid = horse:GetDBTableGUIDLow();
            if(mountDataArray[guid])then
                if(mountDataArray[guid].items)then
                    for index, item in pairs(mountDataArray[guid].items) do
                        horse:AddAura(mountEquipTemplateArray[item].spell_id, horse);
                    end
                end
            end
            horse:SaveToDB(map:GetMapId(), 1, 1);
        else
            local creature = RelocateFarCreature(vehicle:GetCreatureReplacer(), vehicle:GetX(), vehicle:GetY(), vehicle:GetZ()+0.2, vehicle:GetO());
            if(creature)then
                creature:NearTeleport( vehicle:GetX(), vehicle:GetY(), vehicle:GetZ()+0.2, vehicle:GetO() );
                creature:Relocate( vehicle:GetX(), vehicle:GetY(), vehicle:GetZ()+0.2, vehicle:GetO() );
                creature:Respawn();
                creature:SetRespawnDelay(300);
                local guid = creature:GetDBTableGUIDLow();
                if(mountDataArray[guid])then
                    if(mountDataArray[guid].items)then
                        for index, item in pairs(mountDataArray[guid].items) do
                            creature:AddAura(mountEquipTemplateArray[item].spell_id, creature);
                        end
                    end
                end
                creature:SaveToDB(map:GetMapId(), 1, 1);
            else
                PrintError("Ошибка перс. маунта: ".. vehicle:GetCreatureReplacer());
                charmer:SendBroadcastMessage("Произошла ошибка. Сообщите администрации.");
            end
        end
        --vehicle:Delete();
        vehicle:DespawnOrUnsummon();
    end
end

local function OnMountNpcSpawn(event, creature)
    if(mountDataArray[creature:GetDBTableGUIDLow()])then
        if(mountDataArray[creature:GetDBTableGUIDLow()].items)then
            for index, item in pairs(mountDataArray[creature:GetDBTableGUIDLow()].items) do                
                creature:AddAura(mountEquipTemplateArray[item].spell_id, creature);                
            end  
        end        
    end
end

local function assignMountNpcEvents()
	local mountNpcQuery = WorldDBQuery('SELECT entry FROM creature_template where entry >= 992000 and entry <=993999');
    if (mountNpcQuery ~= nil) then
        local rowCount = mountNpcQuery:GetRowCount();
        if(rowCount > 0)then
            for var=1,rowCount,1 do	
                local entry = mountNpcQuery:GetUInt32(0);
                RegisterCreatureGossipEvent(entry, 1, gossipMountNpc);
                RegisterCreatureGossipEvent(entry, 2, gossipSelectMountNpc);
                RegisterCreatureEvent( entry+2000, 38, OnVehicleLostControl);
                RegisterCreatureEvent( entry, 5, OnMountNpcSpawn);
                mountNpcQuery:NextRow();
            end
        end
    end
end
assignMountNpcEvents();

function assignMountOwners()
	local mountOwnerQuery = CharDBQuery('SELECT * FROM mount_owner');
	if (mountOwnerQuery ~= nil) then
		local rowCount = mountOwnerQuery:GetRowCount();	
		mountDataArray = {};
		for var=1,rowCount,1 do
			local guid = mountOwnerQuery:GetUInt32(0);
            mountDataArray[guid] = {};
			mountDataArray[guid].entry = mountOwnerQuery:GetUInt32(1);
			mountDataArray[guid].owner_id = mountOwnerQuery:GetUInt32(2);
            mountDataArray[guid].items = {};
			mountOwnerQuery:NextRow();
		end
	end	
end
assignMountOwners();

function assignMountTemplates()
	local mountTemplateQuery = CharDBQuery('SELECT * FROM mount_template');
	if (mountTemplateQuery ~= nil) then
		local rowCount = mountTemplateQuery:GetRowCount();	
		mountTemplateArray = {};
		for var=1,rowCount,1 do
			local entry = mountTemplateQuery:GetUInt32(0);
            mountTemplateArray[entry] = {};
			mountTemplateArray[entry].mount_type = mountTemplateQuery:GetUInt8(1);
			mountTemplateQuery:NextRow();
		end
	end	
end
assignMountTemplates();

function assignMountEquipTemplates()
	local mountEquipTemplateQuery = CharDBQuery('SELECT * FROM mount_equip_template');
	if (mountEquipTemplateQuery ~= nil) then
		local rowCount = mountEquipTemplateQuery:GetRowCount();	
		mountEquipTemplateArray = {};
		for var=1,rowCount,1 do
			local item_entry = mountEquipTemplateQuery:GetUInt32(0);
            mountEquipTemplateArray[item_entry] = {};
			mountEquipTemplateArray[item_entry].spell_id = mountEquipTemplateQuery:GetUInt32(1);
			mountEquipTemplateArray[item_entry].mount_type = mountEquipTemplateQuery:GetUInt8(2);
			mountEquipTemplateArray[item_entry].slot_type = mountEquipTemplateQuery:GetUInt8(3);
			mountEquipTemplateQuery:NextRow();
		end
	end	
end
assignMountEquipTemplates();

function assignMountEquips()
	local mountEquipQuery = CharDBQuery('SELECT * FROM mount_equip');
	if (mountEquipQuery ~= nil) then
		local rowCount = mountEquipQuery:GetRowCount();	
		for var=1,rowCount,1 do
			local guid = mountEquipQuery:GetUInt32(0);
            if(mountDataArray[guid])then
                local item_entry = mountEquipQuery:GetUInt32(1);
                local item_slot = mountEquipTemplateArray[item_entry].slot_type;
                mountDataArray[guid].items[item_slot] = item_entry;
            end
			mountEquipQuery:NextRow();
		end
	end	
end
assignMountEquips();

local function gossipBuyMount(event, player, object)
    player:GossipClearMenu() -- required for player gossip
    player:GossipMenuAddItem(0, "Закрыть", 1, 1)
    for i,v in pairs(mountPrice) do
        player:GossipMenuAddItem(10, v[1].." за "..v[2].." клав.", 1, i, false, "Приобрести транспорт? Это будет стоить "..v[2].." клав.");
    end    
    player:GossipSendMenu(921114, object) -- MenuId required for player gossip
end

local function gossipBuySilverMount(event, player, object)
    player:GossipClearMenu() -- required for player gossip
    player:GossipMenuAddItem(0, "Закрыть", 1, 1)
    for i,v in pairs(mountSilverPrice) do
        player:GossipMenuAddItem(10, v[1].." за "..v[2].." серебра.", 1, i, false, "Приобрести транспорт? Это будет стоить "..v[2].." серебра.");
    end    
    player:GossipSendMenu(921114, object) -- MenuId required for player gossip
end
local function gossipBuySilverMountHorde(event, player, object)
    player:GossipClearMenu() -- required for player gossip
    player:GossipMenuAddItem(0, "Закрыть", 1, 1)
    for i,v in pairs(mountSilverPriceHorde) do
        player:GossipMenuAddItem(10, v[1].." за "..v[2].." серебра.", 1, i, false, "Приобрести транспорт? Это будет стоить "..v[2].." серебра.");
    end    
    player:GossipSendMenu(921114, object) -- MenuId required for player gossip
end

local function gossipRelocateMount(event, player, object)
    player:GossipClearMenu() -- required for player gossip    
    player:GossipMenuAddItem(0, "Потерял свой транспорт", 1, 2)  
    if(player:GetGMRank() == 3)then
        player:GossipMenuAddItem(1, "Потерял чужой транспорт", 1, 3, true)
    end
    player:GossipMenuAddItem(0, "Закрыть", 1, 1)
    player:GossipSendMenu(921114, object) -- MenuId required for player gossip
end

local function gossipSelectPersonalMount(event, player, object, sender, intid, code, menuid)
    local map = player:GetMap();
    if(object:GetEntry() == 1000046)then -- Заводчик
        if (intid == 1) then        
            player:GossipComplete();
        elseif(mountPrice[intid])then
            if(player:HasItem( andoral_currency, mountPrice[intid][2]))then
                local resultx = object:GetX()+2*(math.cos(object:GetO()));	
                local resulty = object:GetY()+2*(math.sin(object:GetO()));	
                local horse = PerformIngameSpawn( 1, intid, map:GetMapId(), 0, resultx, resulty, object:GetZ()+0.2, object:GetO(), true, 0, 0, 1);
                if(horse)then
                    player:RemoveItem(andoral_currency, mountPrice[intid][2]);
                    saveMountOwnerQuery(player, horse);
                    local guid = horse:GetDBTableGUIDLow()
                    mountDataArray[guid] = {}
                    mountDataArray[guid].entry = horse:GetEntry();
                    mountDataArray[guid].owner_id = player:GetGUIDLow();
                    mountDataArray[guid].items = {};
                    player:SendBroadcastMessage("Покупка прошла успешно.");
                else
                    player:SendBroadcastMessage("Произошла ошибка. Повторите покупку позже.");
                end
            else
                player:SendBroadcastMessage("Недостаточно средств для покупки транспорта.");
            end
            player:GossipComplete();
        end
	elseif(object:GetEntry() == 1000079)then -- Заводчик Альтерака
        if (intid == 1) then        
            player:GossipComplete();
        elseif(mountPrice[intid])then
            if(player:GetCoinage() >= mountSilverPrice[intid][2]*100)then
                local resultx = object:GetX()+2*(math.cos(object:GetO()));	
                local resulty = object:GetY()+2*(math.sin(object:GetO()));	
                local horse = PerformIngameSpawn( 1, intid, map:GetMapId(), 0, resultx, resulty, object:GetZ()+0.2, object:GetO(), true, 0, 0, 1);
                if(horse)then
                    player:ModifyMoney(-mountSilverPrice[intid][2]*100);
                    saveMountOwnerQuery(player, horse);
                    local guid = horse:GetDBTableGUIDLow()
                    mountDataArray[guid] = {}
                    mountDataArray[guid].entry = horse:GetEntry();
                    mountDataArray[guid].owner_id = player:GetGUIDLow();
                    mountDataArray[guid].items = {};
                    player:SendBroadcastMessage("Покупка прошла успешно.");
                else
                    player:SendBroadcastMessage("Произошла ошибка. Повторите покупку позже.");
                end
            else
                player:SendBroadcastMessage("Недостаточно средств для покупки транспорта.");
            end
            player:GossipComplete();
        end
	elseif(object:GetEntry() == 1001176)then -- Заводчик Орды
        if (intid == 1) then        
            player:GossipComplete();
        elseif(mountPriceHorde[intid])then
            if(player:GetCoinage() >= mountSilverPriceHorde[intid][2]*100)then
                local resultx = object:GetX()+2*(math.cos(object:GetO()));	
                local resulty = object:GetY()+2*(math.sin(object:GetO()));	
                local horse = PerformIngameSpawn( 1, intid, map:GetMapId(), 0, resultx, resulty, object:GetZ()+0.2, object:GetO(), true, 0, 0, 1);
                if(horse)then
                    player:ModifyMoney(-mountSilverPriceHorde[intid][2]*100);
                    saveMountOwnerQuery(player, horse);
                    local guid = horse:GetDBTableGUIDLow()
                    mountDataArray[guid] = {}
                    mountDataArray[guid].entry = horse:GetEntry();
                    mountDataArray[guid].owner_id = player:GetGUIDLow();
                    mountDataArray[guid].items = {};
                    player:SendBroadcastMessage("Покупка прошла успешно.");
                else
                    player:SendBroadcastMessage("Произошла ошибка. Повторите покупку позже.");
                end
            else
                player:SendBroadcastMessage("Недостаточно средств для покупки транспорта.");
            end
            player:GossipComplete();
        end
    elseif(object:GetEntry() == 1000048 or object:GetEntry() == 1000073 or object:GetEntry() == 1001175)then -- Смотритель стойл
        if (intid == 1) then        
            player:GossipComplete();
        elseif (intid == 2) then
            for index, mount in pairs(mountDataArray) do
                if(mount.owner_id == player:GetGUIDLow())then
                    local horse = GetCreature(index, mount.entry, map:GetMapId());
                    if(horse)then
                        horse:DespawnOrUnsummon();
                        horse:Respawn();
                        horse:NearTeleport( player:GetX(), player:GetY(), player:GetZ()+0.2, player:GetO() );
                        horse:Relocate( player:GetX(), player:GetY(), player:GetZ()+0.2, player:GetO() );
                        horse:SaveToDB(map:GetMapId(), 1, 1);
                        player:SendBroadcastMessage("Транспорт перемещен.");
                    else
                        local creature = RelocateFarCreature(index, player:GetX(), player:GetY(), player:GetZ()+0.2, player:GetO());
                        if(creature)then
                            creature:NearTeleport( player:GetX(), player:GetY(), player:GetZ()+0.2, player:GetO() );
                            creature:Relocate( player:GetX(), player:GetY(), player:GetZ()+0.2, player:GetO() );
                            creature:Respawn();
                            creature:SetRespawnDelay(300);
                            if(mountDataArray[index])then
                                if(mountDataArray[index].items)then
                                    for ind, item in pairs(mountDataArray[index].items) do
                                        creature:AddAura(mountEquipTemplateArray[item].spell_id, creature);
                                    end
                                end
                            end
                            creature:SaveToDB(map:GetMapId(), 1, 1);
                        else
                            player:SendBroadcastMessage("Произошла ошибка. Сообщите администрации.");
                        end
                    	--player:SendBroadcastMessage("Произошла ошибка. Сообщите администрации. (Код: "..index.."-"..mount.entry);
                    end
                end
            end
            player:GossipComplete();
        elseif (intid == 3) then
            local creature = RelocateFarCreature(tonumber(code), player:GetX(), player:GetY(), player:GetZ()+0.2, player:GetO());
            if(creature)then
                creature:NearTeleport( player:GetX(), player:GetY(), player:GetZ()+0.2, player:GetO() );
                creature:Relocate( player:GetX(), player:GetY(), player:GetZ()+0.2, player:GetO() );
                creature:Respawn();
                creature:SetRespawnDelay(300);
                local guid = creature:GetDBTableGUIDLow();
                if(mountDataArray[guid])then
                    if(mountDataArray[guid].items)then
                        for index, item in pairs(mountDataArray[guid].items) do
                            creature:AddAura(mountEquipTemplateArray[item].spell_id, creature);
                        end
                    end
                end
                creature:SaveToDB(map:GetMapId(), 1, 1);
            else
                PrintError("Ошибка перс. маунта2: ".. tonumber(code));
                charmer:SendBroadcastMessage("Произошла ошибка. Сообщите администрации.");
            end
            player:GossipComplete();
        end
    end
end
local function OnWoodenFriendEnter(event, creature, player, spellid)
	if spellid == 60968 then
		local stage = creature:GetVehicleKit()
		player:SendBroadcastMessage(stage:GetEntry())
		stage:RemovePassenger(0)
	end
	
end
RegisterCreatureGossipEvent(1001176, 1, gossipBuySilverMountHorde);
RegisterCreatureGossipEvent(1001176, 2, gossipSelectPersonalMount);

RegisterCreatureGossipEvent(1001175, 1, gossipRelocateMount);
RegisterCreatureGossipEvent(1001175, 2, gossipSelectPersonalMount);


RegisterCreatureGossipEvent(1000046, 1, gossipBuyMount);
RegisterCreatureGossipEvent(1000079, 1, gossipBuySilverMount);
RegisterCreatureGossipEvent(1000048, 1, gossipRelocateMount);
RegisterCreatureGossipEvent(1000046, 2, gossipSelectPersonalMount);
RegisterCreatureGossipEvent(1000079, 2, gossipSelectPersonalMount);
RegisterCreatureGossipEvent(1000048, 2, gossipSelectPersonalMount);
RegisterCreatureGossipEvent(1000073, 1, gossipRelocateMount);
RegisterCreatureGossipEvent(1000073, 2, gossipSelectPersonalMount);
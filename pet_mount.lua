if(petMountEquipTemplateArray == nil)then
    petMountEquipTemplateArray = {};
end

if(petMountDataArray == nil)then
    petMountDataArray = {};
end


local petMountTemplateArray = {		[1200000] = 1,
									[1200001] = 1,
									[1200002] = 1,
									[1200003] = 1,
									[1200004] = 1,
									[1200005] = 1,
									[1200006] = 1,
									[1200007] = 1,};

local petBankArray = {
	[1200032] = 1,
	[1200033] = 1,
	[1200076] = 1,
};

local available_equip_slots = {[1] = "Седло",
                               [2] = "Флаг"};

local function deleteMountEquipData(mount_entry, item_entry, character_guid)
	CharDBExecute("DELETE FROM `mount_pet_equip` where mount_entry = " .. mount_entry .. " and item_entry = " .. item_entry .." and character_guid = " .. character_guid .. ";");
end

local function saveMountEquipData(mount_entry, item_entry, character_guid)
	CharDBExecute("INSERT INTO `mount_pet_equip` (`mount_entry`, `item_entry`, `character_guid`) VALUES (".. mount_entry..", ".. item_entry ..", ".. character_guid ..");");
end

local function fillPetMountDataArray(player_guid, mount_entry, item_slot, item_entry)			
	if(petMountDataArray[player_guid] == nil)then				
		petMountDataArray[player_guid] = {};
	end
	if(petMountDataArray[player_guid][mount_entry] == nil)then				
		petMountDataArray[player_guid][mount_entry] = {};
	end	
	if(petMountDataArray[player_guid][mount_entry].items == nil)then				
		petMountDataArray[player_guid][mount_entry].items = {};
	end			
	petMountDataArray[player_guid][mount_entry].items[item_slot] = item_entry;			
end

local function gossipPetMount(event, player, object)
	
	local creatorGUID = object:GetControllerGUID();
	local plGUID = player:GetGUID();
	if(creatorGUID == plGUID)then	
		player:GossipClearMenu() -- required for player gossip
		player:GossipMenuAddItem(4, "Оседлать", 1, 1)
		if(object:GetMovementType() ~= 14)then
			player:GossipMenuAddItem(4, "Вести", 1, 3)
		else
			player:GossipMenuAddItem(4, "Остановить", 1, 4)
		end		
		local mountEntry = object:GetEntry()
		if(petMountTemplateArray[mountEntry] == 1)then
			player:GossipMenuAddItem(1, "Экипировать", 1, 5)
		end
		if(petBankArray[mountEntry] == 1)then
			player:GossipMenuAddItem(1, "Открыть седельные сумки", 1, 6)
		end
		player:GossipMenuAddItem(0, "Закрыть", 1, 2)
		player:GossipSendMenu(1, object) -- MenuId required for player gossip
	else
		player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Ошибка: |r |cFF00CCFFСпутник вам не принадлежит|r");
	end

end

local function gossipMountEquipList(event, player, object)
    for index, slot in pairs(available_equip_slots) do	
		player:GossipMenuAddItem(1, slot, 1, index+100)
	end
	player:GossipMenuAddItem(0, "Закрыть", 1, 2)
	player:GossipSendMenu(1, object) -- MenuId required for player gossip
end

local function gossipMountSlotItemList(event, player, object, slot_id)
    local guid = player:GetGUIDLow();    
	local entry = object:GetEntry();
	for index, item_temp in pairs(petMountEquipTemplateArray) do
		if(item_temp.slot_type == slot_id and item_temp.mount_type == petMountTemplateArray[entry])then
			if(player:HasItem(index))then
				local item = player:GetItemByEntry( index );
				player:GossipMenuAddItem(1, item:GetName(), 1, index)
			end
		end
	end
	player:GossipMenuAddItem(1, "Снять", 1, 400+slot_id)
	player:GossipMenuAddItem(0, "Закрыть", 1, 2)
	player:GossipSendMenu(1, object) -- MenuId required for player gossip    
end

local function gossipSelectPetMount(event, player, object, sender, intid, code, menuid)
	local map = player:GetMap();
	local entry = object:GetEntry();	
	local phase = player:GetPhaseMask();
    local creatorGUID = object:GetControllerGUID();
    local plGUID = player:GetGUID();
	local pguidLow = player:GetGUIDLow(); 
    if(creatorGUID == plGUID)then
        if (intid == 1 ) then
			player:Dismount();
			if(player:IsMounted() or player:HasAura(IS_IN_BATTLE_AURA) or listPlayersInBattle[player:GetName()] or player:IsInCombat())then
				player:GossipComplete()
				player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Пока вы не можете совершить данное действие (вы в бою, на другом маунте или в фазе). |cFF00CCFF|r");
			else
				local horse = PerformIngameSpawn( 1, entry+10000, map:GetMapId(), 0, object:GetX(), object:GetY(), object:GetZ()+0.2, object:GetO(), false, 0, 0, phase);
				if(horse:IsInWorld())then
					horse:SetPhaseMask(phase)
					player:CastSpell(horse, 84022, true);
					object:DespawnOrUnsummon();
					if(petMountDataArray[pguidLow])then
						if(petMountDataArray[pguidLow][entry])then
							if(petMountDataArray[pguidLow][entry].items)then
								for index, item in pairs(petMountDataArray[pguidLow][entry].items) do    								
									horse:AddAura(petMountEquipTemplateArray[item].spell_id, horse);                        
								end
							end
						end
					end
				else
					player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500Ошибка: 222|r |cFF00CCFF22222|r");
					horse:Delete();
				end
			end
            player:GossipComplete();
            --player:GossipComplete();
        elseif (intid == 2) then
            player:GossipComplete();
        elseif (intid == 3) then
            object:MoveFollow( player, 0, 1.507 )
            player:GossipComplete();
        elseif (intid == 4) then
            object:MoveClear(true);
            player:GossipComplete();        
        elseif (intid == 5) then
            gossipMountEquipList(event, player, object);
		elseif (intid == 6) then
			player:SendShowBank( player )
        elseif (intid >= 101 and intid <= 355) then
            local slot_id = intid - 100;
            gossipMountSlotItemList(event, player, object, slot_id)
        elseif (intid >= 401 and intid <= 655) then
		
            local slot_id = intid - 400;
			local guid = player:GetGUIDLow();    
			local entry = object:GetEntry();
			if(petMountDataArray[guid])then
				if(petMountDataArray[guid][entry])then
					if(petMountDataArray[guid][entry].items[slot_id])then					
						local item_entry = petMountDataArray[guid][entry].items[slot_id];
						petMountDataArray[guid][entry].items[slot_id] = nil;
						object:RemoveAura(petMountEquipTemplateArray[item_entry].spell_id);
						deleteMountEquipData(entry, item_entry, guid);
						local added = player:AddItem(item_entry);
						if(added == nil)then
							SendMail( "Седло", "Мы не смогли разместить седло в вашем инвентаре.", player:GetGUIDLow(), 0, 61, 0, 0, 0, item_entry, 1 )
							player:SendBroadcastMessage("В инвентаре нет места. Седло отправлено по почте.");
						end
					end
				end
			end
            player:GossipComplete();			
        elseif (intid >= 805000 and intid <= 805999) then
            if(player:HasItem(intid))then
                local slot_id = petMountEquipTemplateArray[intid].slot_type;
				local guid = player:GetGUIDLow();    
				local entry = object:GetEntry();
                if(petMountDataArray[guid])then
					if(petMountDataArray[guid][entry])then
						if(petMountDataArray[guid][entry].items[slot_id])then
							local item_entry = petMountDataArray[guid][entry].items[slot_id];
							table.remove(petMountDataArray[guid][entry].items, slot_id);
							object:RemoveAura(petMountEquipTemplateArray[item_entry].spell_id);
							deleteMountEquipData(entry, item_entry, guid);
							local added = player:AddItem(item_entry);                    
							if(added == nil)then
								SendMail( "Седло", "Мы не смогли разместить седло в вашем инвентаре.", player:GetGUIDLow(), 0, 61, 0, 0, 0, item_entry, 1 )
								player:SendBroadcastMessage("В инвентаре нет места. Седло отправлено по почте.");
							end
						end
					end
                end
					
				fillPetMountDataArray(guid, entry, slot_id, intid)					
                object:AddAura(petMountEquipTemplateArray[intid].spell_id, object);
                player:RemoveItem(intid, 1);
                saveMountEquipData(entry, intid, guid);
            end
            player:GossipComplete();
        end
    end
end

function assignPetMountEquipTemplates()
	local mountEquipTemplateQuery = CharDBQuery('SELECT * FROM mount_equip_template');
	if (mountEquipTemplateQuery ~= nil) then
		local rowCount = mountEquipTemplateQuery:GetRowCount();	
		petMountEquipTemplateArray = {};
		for var=1,rowCount,1 do
			local item_entry = mountEquipTemplateQuery:GetUInt32(0);
            petMountEquipTemplateArray[item_entry] = {};
			petMountEquipTemplateArray[item_entry].spell_id = mountEquipTemplateQuery:GetUInt32(1);
			petMountEquipTemplateArray[item_entry].mount_type = mountEquipTemplateQuery:GetUInt8(2);
			petMountEquipTemplateArray[item_entry].slot_type = mountEquipTemplateQuery:GetUInt8(3);
			mountEquipTemplateQuery:NextRow();
		end
	end	
end
assignPetMountEquipTemplates();

function assignPetMountEquips()
	local mountEquipQuery = CharDBQuery('SELECT * FROM mount_pet_equip');
	if (mountEquipQuery ~= nil) then
		local rowCount = mountEquipQuery:GetRowCount();	
		for var=1,rowCount,1 do
			local player_guid = mountEquipQuery:GetUInt32(2);
			local mount_entry = mountEquipQuery:GetUInt32(0);
			local item_entry = mountEquipQuery:GetUInt32(1);
			local item_slot = petMountEquipTemplateArray[item_entry].slot_type;

			fillPetMountDataArray(player_guid, mount_entry, item_slot, item_entry)
			mountEquipQuery:NextRow();			
		end
	end
end
assignPetMountEquips();


local function OnPetMountLostControl(event, vehicle, charmer)	
    local entry = vehicle:GetEntry();
    if(entry >= 1210000 and entry <=1210999)then
        vehicle:DespawnOrUnsummon();
    end
end

local function OnPetMountSummoned(event, creature, summoner)
	local entry = creature:GetEntry();
	local pguidLow = summoner:GetGUIDLow(); 
	if(petMountDataArray[pguidLow])then
		if(petMountDataArray[pguidLow][entry])then
			if(petMountDataArray[pguidLow][entry].items)then
				for index, item in pairs(petMountDataArray[pguidLow][entry].items) do                        
					creature:AddAura(petMountEquipTemplateArray[item].spell_id, creature);                        
				end
			end
		end
	end
end

local function assignPetMountEvents()
	for var=1200000,1200999,1 do
		RegisterCreatureGossipEvent(var, 1, gossipPetMount);
		RegisterCreatureGossipEvent(var, 2, gossipSelectPetMount);
		RegisterCreatureEvent( var+10000, 38, OnPetMountLostControl);
		RegisterCreatureEvent( var, 22, OnPetMountSummoned);
	end
end
assignPetMountEvents();


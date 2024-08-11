colors= {"|cffff6060","|cff00ccff","|cff00C78C","|cff00FF7F","|cffADFF2F","|cff0000ff","|cffDA70D6","|cff00ff00","|cffff0000","|cffffcc00","|cffffffff","|cffFF4500"
}
--------------------------- Меню поднятия на плечо ---------------------------

carryPlayerMenuId = 6015;
carryPlayerArray = {}
carryPlayerArray.available = {
                                [1] = {[0]=84015, [1]=84016},
                                [3] = {[0]=84017, [1]=84018},
                                [10] = {[0]=84019, [1]=84020},
                                };

function OnGossipCarryPlayer(event, player, object)
	player:GossipClearMenu() -- required for player gossip
    player:GossipMenuAddItem(1, "Подняться на плечо "..object:GetName(), 1, 1, false, "Вас будут нести.")
    player:GossipMenuAddItem(1, "Выход", 1, 2, false, nil, nil, false)
    player:GossipSendMenu(1, player, carryPlayerMenuId) -- MenuId required for player gossip
end

local function OnGossipSelectCarryPlayer(event, player, object, sender, intid, code, menuid)
    if (intid == 1) then
        local carrierName = carryPlayerArray[player:GetGUIDLow()];
        local carrier = GetPlayerByName( carrierName )

        local race = player:GetRace();
        local gender = player:GetGender();
        if(carryPlayerArray.available[race][gender] ~= nil and player:GetDistance( carrier ) < 15)then
            for i=84015,84020 do
                carrier:RemoveAura(i);
                player:RemoveAura(i);
            end
            carrier:AddAura(carryPlayerArray.available[race][gender], carrier);
            player:CastSpell(carrier, 43671);
        end

        carryPlayerArray[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    elseif (intid == 2) then
        carryPlayerArray[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    end
end
RegisterPlayerGossipEvent(carryPlayerMenuId, 2, OnGossipSelectCarryPlayer)

local itemTypes = {4100,4101,4102,4103,4104,4105,4106,4107} -- Энчаты для плашек предметов

--------------------------- Обработчик комманд ---------------------------
local function OnPlayerCommandWithArg(event, player, code)
    if(string.find(code, " "))then
        local arguments = {}
        local arguments = string.split(code, " ")
        if (arguments[1] == "combatrobotanim" and #arguments == 3 ) then
            local animation = tonumber(arguments[2])
            local is_state = tonumber(arguments[3])
            if(animation)then
                local vehicle = player:GetVehicleKit();
                if(vehicle ~= nil)then
                    local passenger = vehicle:GetPassenger(1);
                    if(passenger ~= nil)then
                        if(passenger:ToCreature() and passenger:GetEntry() == 990003)then
                            if(is_state == 0)then
                                passenger:Emote( animation )
                            else
                                passenger:EmoteState( animation )
                            end
                        end
                    end
                end
            end
            return false;
        elseif (arguments[1] == "combatrobotequip" and #arguments == 3 ) then
            local itemEntry = tonumber(arguments[2])
            local slot = tonumber(arguments[3])
            if(slot)then
                local vehicle = player:GetVehicleKit();
                if(vehicle ~= nil)then
                    local passenger = vehicle:GetPassenger(1);
                    if(passenger ~= nil and slot >= 0 and slot <= 2)then
                        if(passenger:ToCreature() and passenger:GetEntry() == 990003)then
                            passenger:UpdateUInt32Value(56 + slot, itemEntry)
                        end
                    end
                end
            end
            return false;
		elseif (arguments[1] == "addtagitem") then -- custom text enchantment - занимаем 5 и 6 слот чантов (если считать с 0 то 4 и 5, т.е. SOCK_ENCHANTMENT_SLOT_3 и BONUS_ENCHANTMENT_SLOT)
			if #arguments < 5 then
				local entry = tonumber(arguments[2])
				if (player:GetGMRank() > 1 and entry > 2110896) then -- 2110896 - с этого ID начинаются созданные мастерами итемы
					if (entry == 2110926 or entry == 2110924 or entry == 2110923 or entry == 2110922 or entry == 2110921) then
						player:SendBroadcastMessage("Forbidden - excluded item id");
						return false;
					end
					local GM_target = player:GetSelectedUnit();
					if(GM_target)then
						local newItem = GM_target:AddItem(entry);
						for i = 0, #arguments - 2 do
							newItem:SetEnchantment(itemTypes[tonumber(arguments[i+3])],5-i)
						end
						return false;
					else
						local newItem = player:AddItem(entry);
						for i = 0, #arguments - 2 do
							newItem:SetEnchantment(itemTypes[tonumber(arguments[i+3])],5-i)
						end
						return false;
					end
				end
			else
				player:SendBroadcastMessage("Ошибка. Не более 2 плашек на предмет")
			end
		elseif (arguments[1] == "sendmessage") then
			if player:GetGMRank() >0 then
				local colorId = tonumber(arguments[2])
				local selection = player:GetSelectedUnit()
				local text = arguments[3]
				for i = 4, #arguments do
					text = text.." "..arguments[i]
				end
				selection:SendBroadcastMessage(colors[colorId]..text)
				player:SendBroadcastMessage("Игроку отправлен текст: ")
				player:SendBroadcastMessage(colors[colorId]..text)
				return false
			end

	    elseif (arguments[1] == "molemachineanim" and #arguments == 3 ) then
            local animation = tonumber(arguments[2])
            local is_state = tonumber(arguments[3])
            if(animation)then
                local minion = player:GetCharmGUID()
                if(minion)then
                    local map = player:GetMap();
                    local molemachine = GetCreature(GetGUIDLow(minion), 2002923, map:GetMapId());
                    if(molemachine)then
                        if(is_state == 0)then
                            molemachine:Emote( animation )
                        else
                            molemachine:EmoteState( animation )
                        end
                        return false;
                    end
                end
            end
        elseif (arguments[1] == "target") then
            player:Print("Now we set target "..arguments[2])
            local target_to_select = arguments[2]
            player:SetSelection(target_to_select)
        end
    end
    if(code == "carry")then
        local target = player:GetSelectedUnit();
        if(target ~= nil and target ~= player)then
            local race = target:GetRace();
            if(target:ToPlayer() ~= nil and (race == 1 or race == 3 or race == 10))then
                if(player:GetDistance( target ) < 15)then
                    carryPlayerArray[target:GetGUIDLow()] = player:GetName();
                    OnGossipCarryPlayer(event, target, player)
                else
                    player:SendBroadcastMessage("ОШИБКА: цель слишком далеко.")
                end
            else
                player:SendBroadcastMessage("ОШИБКА: персонажа данной расы нельзя поднять.")
            end
        else
            player:SendBroadcastMessage("ОШИБКА: нет цели.")
        end
        return false;
    elseif(code == "drop")then
        local vehicle = player:GetVehicleKit();
        if(vehicle ~= nil)then
            local passenger = vehicle:GetPassenger(1);
            if(passenger ~= nil)then
                passenger:ExitVehicle();
            end
        end
        return false;
    elseif(code == "combatrobot")then
        local robot = spawnDMCreature(player, 990003);
        for i=12,13 do
            local trinket = player:GetItemByPos( 255, i );
            if(trinket ~= nil)then
                if(trinket:GetEntry() == 803009)then
                    local vehicle = player:GetVehicleKit();
                    if(vehicle ~= nil)then
                        local passenger = vehicle:GetPassenger(1);
                        if(passenger ~= nil)then
                            passenger:ExitVehicle();
                            if(passenger:ToCreature() and passenger:GetEntry() == 990003)then
                                passenger:Delete();
                            end
                        else
                            robot:CastSpell( player, 43671 );
                            return false;
                        end
                    end
                    break;
                end
            end
        end
        robot:Delete();
        return false;
    elseif(code == "squirstop")then
        local minion = player:GetCharmGUID()
        if(minion)then
            local map = player:GetMap();
            local squirrel = GetCreature(GetGUIDLow(minion), 990004, map:GetMapId());
            if(squirrel)then
                squirrel:RemoveAura(38586);
                squirrel:SaveToDB();
                return false;
            end
        end
    elseif(code == "molestop")then
        local minion = player:GetCharmGUID()
        if(minion)then
            local map = player:GetMap();
            local molemachine = GetCreature(GetGUIDLow(minion), 2002923, map:GetMapId());
            if(molemachine)then
                local enter = GetGameObject(487242, 300407, map:GetMapId());
                if(map:GetMapId() == 1)then
                    enter = GetGameObject(513209, 300407, map:GetMapId());
                end
                if(enter)then
                    local dif_x = molemachine:GetX() - enter:GetX();
                    local dif_y = molemachine:GetY() - enter:GetY();
                    local dif_z = molemachine:GetZ() - enter:GetZ();
                    enter:MoveGameObject(enter:GetX() + dif_x, enter:GetY() + dif_y, enter:GetZ() + dif_z, enter:GetO());
                    player:NearTeleport(player:GetX() + dif_x, player:GetY() + dif_y, player:GetZ() + dif_z + 0.1, player:GetO());
                    local units = player:GetNearObjects( 10, 24 );
                    for index, nearUT in pairs(units) do
                        nearUT:NearTeleport(nearUT:GetX() + dif_x, nearUT:GetY() + dif_y, nearUT:GetZ() + dif_z, nearUT:GetO());
                    end
                    local gameobjects = player:GetNearObjects( 10, 32 );
                    for index, nearGO in pairs(gameobjects) do
                        nearGO:MoveGameObject(nearGO:GetX() + dif_x, nearGO:GetY() + dif_y, nearGO:GetZ() + dif_z, nearGO:GetO());
                    end
                    for index, nearUT in pairs(units) do
                        nearUT:NearTeleport(nearUT:GetX() + dif_x, nearUT:GetY() + dif_y, nearUT:GetZ() + dif_z + 0.1, nearUT:GetO());
                    end
                end
                molemachine:RemoveAura(38586);
                return false;
            end
        end
    elseif(code == "searchmount")then
	local count = 0;
        for index, mount in pairs(mountDataArray) do
            if(mount.owner_id == player:GetGUIDLow())then
                local map = player:GetMap();
                local horse = GetCreature(index, mount.entry, map:GetMapId());
                if(horse)then
		    count = count + 1;
                    player:GossipSendPOI( horse:GetX(), horse:GetY(), 36, 5, 0, "Ваш транспорт здесь" );
                    player:SendBroadcastMessage("Местоположение транспорта отмечено на карте.");
                end
            end
        end
        return false;
	elseif (code == "leavephase") then
		player:RemoveAura(CREATIVE_PHASE_AURA)
		player:SetPhaseMask(1,true)
		player:RemoveAura(FLY_AURA)
		player:SetSpeed(1,1,true)
		ClearWhiteAuras(player)
		player:DeMorph()
    end
end
if(mountDataArray == nil)then
    mountDataArray = {};
end
RegisterPlayerEvent(42, OnPlayerCommandWithArg)
local EVENT_ON_CAST = 5;
local EVENT_ON_GO_USE = 1;
local EVENT_ON_GO_SELECT = 2;
local GO_MENU_ID = 5000;
local GO_Selected = {}

local function OnGOUse(event, player, go)
	GO_Selected[player:GetName()] = { entry = go:GetEntry(), guid = go:GetGUIDLow() }
	player:SendAddonMessage("GOM_OPENFRAME",go:GetName(),7,player)	
	player:SendBroadcastMessage("Вы передвигаете ["..go:GetName().."].")
end

local function AddonMessageEvent(event, player, type, prefix, msg, target)
	if(prefix == "MOVE_GO_FORWARD" and type == 7 and player == target)then
		if GO_Selected[player:GetName()] then
			local num = tonumber(msg)
			if not num then
				return false
			end
			if num > 0 and num <= 15 then
				local map = player:GetMap()
				local object = map:GetWorldObject(GetObjectGUID(GO_Selected[player:GetName()].guid,GO_Selected[player:GetName()].entry))		
				local x, y, z, o = object:GetLocation()
				local entry = object:GetEntry()
				local phase = object:GetPhaseMask();
				local po = player:GetO();	
				local x, y, z, o = object:GetLocation()
				local resultx = x+num/10*(math.cos(po));	
				local resulty = y+num/10*(math.sin(po))
				local scale = object:GetScale()
				local movedObj = object:MoveGameObject(resultx, resulty, z, o)
				movedObj:SetScale(scale)
				movedObj:SetPhaseMask(4096)
				movedObj:SetPhaseMask(phase)
				GO_Selected[player:GetName()].guid = movedObj:GetGUIDLow()
			else
				player:SendBroadcastMessage("Incorrect values. Max value = 15. Min value = 0")
			end
		end
	elseif (prefix == "MOVE_GO_BACKWARD" and type == 7 and player == target)then
		if GO_Selected[player:GetName()] then
			local num = tonumber(msg)
			if not num then
				return false
			end
			if num > 0 and num <= 15 then
				
				local map = player:GetMap()
				local object = map:GetWorldObject(GetObjectGUID(GO_Selected[player:GetName()].guid,GO_Selected[player:GetName()].entry))
				if not object then
					return false
				end
				local x, y, z, o = object:GetLocation()
				local entry = object:GetEntry()
				local phase = object:GetPhaseMask();
				local po = player:GetO();	
				local x, y, z, o = object:GetLocation()
				local resultx = x-num/10*(math.cos(po));	
				local resulty = y-num/10*(math.sin(po))
				local scale = object:GetScale()
				local movedObj = object:MoveGameObject(resultx, resulty, z, o)
				movedObj:SetScale(scale)
				movedObj:SetPhaseMask(4096)
				movedObj:SetPhaseMask(phase)
				GO_Selected[player:GetName()].guid = movedObj:GetGUIDLow()
			else
				player:SendBroadcastMessage("Incorrect values. Max value = 15. Min value = 0")
			end
		end
			
	elseif (prefix == "MOVE_GO_LEFT" and type == 7 and player == target) then
		if GO_Selected[player:GetName()] then
			local num = tonumber(msg)
			if not num then
				return false
			end
			if num > 0 and num <= 15 then
				local map = player:GetMap()
				local object = map:GetWorldObject(GetObjectGUID(GO_Selected[player:GetName()].guid,GO_Selected[player:GetName()].entry))
				if not object then
					return false
				end
				local x, y, z, o = object:GetLocation()
				local entry = object:GetEntry()
				local phase = object:GetPhaseMask();
				local po = player:GetO();	
				local x, y, z, o = object:GetLocation()
				local resultx = x+num/10*(math.cos(po + math.pi/2));	
				local resulty = y+num/10*(math.sin(po + math.pi/2))
				local scale = object:GetScale()
				local movedObj = object:MoveGameObject(resultx, resulty, z, o)
				movedObj:SetScale(scale)
				movedObj:SetPhaseMask(4096)
				movedObj:SetPhaseMask(phase)
				GO_Selected[player:GetName()].guid = movedObj:GetGUIDLow()
			else
				player:SendBroadcastMessage("Incorrect values. Max value = 15. Min value = 0")
			end
		end
	elseif (prefix == "MOVE_GO_RIGHT" and type == 7 and player == target)then
		if GO_Selected[player:GetName()] then
			local num = tonumber(msg)
			if not num then
				return false
			end
			if num > 0 and num <= 15 then
				local map = player:GetMap()
				local object = map:GetWorldObject(GetObjectGUID(GO_Selected[player:GetName()].guid,GO_Selected[player:GetName()].entry))		
				if not object then
					return false
				end
				local x, y, z, o = object:GetLocation()
				local entry = object:GetEntry()
				local phase = object:GetPhaseMask();
				local po = player:GetO();	
				local x, y, z, o = object:GetLocation()
				local resultx = x-num/10*(math.cos(po+ math.pi/2));	
				local resulty = y-num/10*(math.sin(po+ math.pi/2))
				local scale = object:GetScale()
				local movedObj = object:MoveGameObject(resultx, resulty, z, o)
				movedObj:SetScale(scale)
				movedObj:SetPhaseMask(4096)
				movedObj:SetPhaseMask(phase)
				GO_Selected[player:GetName()].guid = movedObj:GetGUIDLow()
			else
				player:SendBroadcastMessage("Incorrect values. Max value = 15. Min value = 0")
			end
		end
	elseif(prefix == "MOVE_GO_UP" and type == 7 and player == target)then
		if GO_Selected[player:GetName()] then
			local num = tonumber(msg)
			if not num then
				return false
			end
			if num > 0 and num <= 60 then
				local map = player:GetMap()
				local object = map:GetWorldObject(GetObjectGUID(GO_Selected[player:GetName()].guid,GO_Selected[player:GetName()].entry))
				if not object then
					return false
				end
				local x, y, z, o = object:GetLocation()
				local entry = object:GetEntry()
				local phase = object:GetPhaseMask();
				local po = player:GetO();	
				local x, y, z, o = object:GetLocation()
				local result = z+num/100;	
				local scale = object:GetScale()
				local movedObj = object:MoveGameObject(x, y, result, o)
				movedObj:SetScale(scale)
				movedObj:SetPhaseMask(4096)
				movedObj:SetPhaseMask(phase)
				GO_Selected[player:GetName()].guid = movedObj:GetGUIDLow()
			else
				player:SendBroadcastMessage("Incorrect values. Max value = 60. Min value = 0")
			end
		end
	elseif(prefix == "MOVE_GO_DOWN" and type == 7 and player == target)then
		if GO_Selected[player:GetName()] then
			local num = tonumber(msg)
			if not num then
				return false
			end
			if num > 0 and num <= 60 then
				local map = player:GetMap()
				local object = map:GetWorldObject(GetObjectGUID(GO_Selected[player:GetName()].guid,GO_Selected[player:GetName()].entry))
				if not object then
					return false
				end
				local x, y, z, o = object:GetLocation()
				local entry = object:GetEntry()
				local phase = object:GetPhaseMask();
				local po = player:GetO();	
				local x, y, z, o = object:GetLocation()
				local result = z-num/100;	
				local scale = object:GetScale()
				local movedObj = object:MoveGameObject(x, y, result, o)
				movedObj:SetScale(scale)
				movedObj:SetPhaseMask(4096)
				movedObj:SetPhaseMask(phase)
				GO_Selected[player:GetName()].guid = movedObj:GetGUIDLow()
				
			else
				player:SendBroadcastMessage("Incorrect values. Max value = 60. Min value = 0")
			end
		end
	elseif(prefix == "ROTATE_GO_RIGHT" and type == 7 and player == target)then
		if GO_Selected[player:GetName()] then
			local num = tonumber(msg)
			if not num then
				return false
			end
			local map = player:GetMap()
			local object = map:GetWorldObject(GetObjectGUID(GO_Selected[player:GetName()].guid,GO_Selected[player:GetName()].entry))
			if not object then
					return false
				end
			local map = player:GetMap();		
			local x, y, z, o = object:GetLocation()
			local pass = 6.2831/360*num
			local result = o + pass
			local scale = object:GetScale()
			local movedObj = object:MoveGameObject(x, y, z, result);	
			movedObj:SetScale(scale)
			local phase = object:GetPhaseMask()
			movedObj:SetPhaseMask(4096)
			movedObj:SetPhaseMask(phase)
			GO_Selected[player:GetName()].guid = movedObj:GetGUIDLow()
		end
	elseif (prefix == "ROTATE_GO_LEFT" and type == 7 and player == target)then
		if GO_Selected[player:GetName()] then
			local num = tonumber(msg)
			if not num then
				return false
			end
			local map = player:GetMap()
			local object = map:GetWorldObject(GetObjectGUID(GO_Selected[player:GetName()].guid,GO_Selected[player:GetName()].entry))
			if not object then
					return false
				end
			local map = player:GetMap();		
			local x, y, z, o = object:GetLocation()
			local pass = 6.2831/360*num
			local result = o - pass
			local scale = object:GetScale()
			local movedObj = object:MoveGameObject(x, y, z, result);	
			movedObj:SetScale(scale)
			local phase = object:GetPhaseMask()
			movedObj:SetPhaseMask(4096)
			movedObj:SetPhaseMask(phase)
			GO_Selected[player:GetName()].guid = movedObj:GetGUIDLow()
		end
	end
end
local function OnPlayerCommandWithArg(event, player, code)
    if(string.find(code, " "))then
        local arguments = {}
        local arguments = string.split(code, " ")
        if (arguments[1] == "movego") then
			if  player:GetGMRank() > 0 then
				if arguments[2] then
					local nearestGo = player:GetNearestGameObject(40,tonumber(arguments[2]))
					if nearestGo then
						OnGOUse(nil,player,nearestGo)
					else
						player:SendBroadcastMessage("Объектов с таким энтри не было обнаружено в радиусе")
					end
				end
			elseif player:GetDmLevel() > 0 then
				if arguments[2] then
					local nearestGo = player:GetNearestGameObject(40,tonumber(arguments[2]))
					if nearestGo then
						if nearestGo:GetOwner() == player then
							OnGOUse(nil,player,nearestGo)
						else
							player:SendBroadcastMessage("Был найден ближайший к вам объект, но он вам не принадлежит. Подойдите ближе.")
						end
					else
						player:SendBroadcastMessage("Объектов с таким энтри не было обнаружено в радиусе")
					end
				end
			end
		end
	elseif(code == "movego")then  
		if  player:GetGMRank() > 0 then
			local nearestGo = player:GetNearestGameObject(40)
			if nearestGo then
				OnGOUse(nil,player,nearestGo)
			else
				player:SendBroadcastMessage("Объектов в радиусе не было обнаружено")
			end
		elseif player:GetDmLevel() > 0 then
			local nearestGo = player:GetNearestGameObject(40)
			if nearestGo then
				if nearestGo:GetOwner() == player then
					OnGOUse(nil,player,nearestGo)
				else
					player:SendBroadcastMessage("Был найден ближайший к вам объект, но он вам не принадлежит. Подойдите ближе.")
				end
			else
				player:SendBroadcastMessage("Объектов в радиусе не было обнаружено")
			end
		end
	end
end

RegisterPlayerEvent(42, OnPlayerCommandWithArg)
RegisterServerEvent(30, AddonMessageEvent);
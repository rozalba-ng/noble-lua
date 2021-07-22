local WALK_AURA = 88032
local queryManager = {}
local npcPoint = {}
function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end
function GoToNextWaypoint(eventId, delay, repeats)
	local creatureGUID = GetUnitGUID(queryManager[eventId].guid,queryManager[eventId].entry)
	if creatureGUID then
		local map = GetMapById(queryManager[eventId].map)
		local creature = map:GetWorldObject(creatureGUID)
		if creature then
			creature:SetWalk(true)
			creature:RemoveAura(WALK_AURA)
			local id = nil
			if npcPoint[queryManager[eventId].guid][queryManager[eventId].nextOrder].c_type == 1 then
				local pos = npcPoint[queryManager[eventId].guid][queryManager[eventId].nextOrder]
				local dest = distance(creature:GetX(),creature:GetY(),pos.x,pos.y)
				id = CreateLuaEvent( GoToNextWaypoint, (dest/creature:GetSpeed(0))*1000,1)
				creature:EmoteState(0)
				creature:SetSpeed(0,1)
				creature:MoveTo(1000,pos.x,pos.y,pos.z)
			elseif npcPoint[queryManager[eventId].guid][queryManager[eventId].nextOrder].c_type == 3 then
				local pos = npcPoint[queryManager[eventId].guid][queryManager[eventId].nextOrder]
				local dest = distance(creature:GetX(),creature:GetY(),pos.x,pos.y)
				id = CreateLuaEvent( GoToNextWaypoint, (dest/creature:GetSpeed(0))*1000,1)
				creature:SetSpeed(0,0.5)
				creature:EmoteState(0)
				creature:MoveTo(1000,pos.x,pos.y,pos.z)
			elseif npcPoint[queryManager[eventId].guid][queryManager[eventId].nextOrder].c_type == 2 then
				local waitTime = npcPoint[queryManager[eventId].guid][queryManager[eventId].nextOrder].waitTime
				creature:EmoteState(npcPoint[queryManager[eventId].guid][queryManager[eventId].nextOrder].emoteId)
				id = CreateLuaEvent( GoToNextWaypoint, (waitTime)*1000,1)
			end
			queryManager[id] = queryManager[eventId]
			if #npcPoint[queryManager[eventId].guid] > queryManager[id].nextOrder then
				queryManager[id].nextOrder = queryManager[id].nextOrder + 1
			else
				queryManager[id].nextOrder = 1
			end
			
		end
	end
end
local function OnPlayerCommandWArg(event, player, code) -- command with argument
	 if(player:GetDmLevel() > 0 or player:GetGMRank() > 0)then
        if(string.find(code, " "))then
            local arguments = {}
            local arguments = string.split(code, " ")
			if (arguments[1] == "wpwait" and #arguments == 2 ) then
				
				local waitTimeToSet = tonumber(arguments[2])
				if waitTimeToSet < 0.5 then
					player:SendBroadcastMessage("Ошибка. Время ожидания не может быть меньше 0.5 секунд.")
					return false
				end
				local creature = player:GetTargetCreature()
				if(creature:GetOwner() == player) or (player:GetGMRank() > 0)then
					local lowGuid = creature:GetGUIDLow()
					if npcPoint[lowGuid] == nil then
						npcPoint[lowGuid] = {}
						npcPoint[lowGuid][1] = {}
						npcPoint[lowGuid][1] = { c_type = 2, waitTime = waitTimeToSet, emoteId = 0}
						player:SendBroadcastMessage(creature:GetName().." установлена стартовая точка. Ожидание "..waitTimeToSet.." секунд")
					else
						npcPoint[lowGuid][#npcPoint[lowGuid]+1] = { c_type = 2, waitTime = waitTimeToSet, emoteId = 0}
						player:SendBroadcastMessage(creature:GetName().." установлена точка ожидания ("..#npcPoint[lowGuid].."). Ожидание "..waitTimeToSet.." секунд")
					end
				end
			elseif (arguments[1] == "wpemote" and #arguments == 3 ) then
				local waitTimeToSet = tonumber(arguments[3])
				if waitTimeToSet < 0.5 then
					player:SendBroadcastMessage("Ошибка. Время эмоции не может быть меньше 0.5 секунд.")
					return false
				end
				local emoteToSet = tonumber(arguments[2	])
				local creature = player:GetTargetCreature()
				if(creature:GetOwner() == player) or (player:GetGMRank() > 0)then
					local lowGuid = creature:GetGUIDLow()
					if npcPoint[lowGuid] == nil then
						npcPoint[lowGuid] = {}
						npcPoint[lowGuid][1] = {}
						npcPoint[lowGuid][1] = { c_type = 2, waitTime = waitTimeToSet, emoteId = emoteToSet}
						player:SendBroadcastMessage(creature:GetName().." установлена стартовая точка. Ожидание "..waitTimeToSet.." секунд c анимацией "..emoteToSet)
					else
						npcPoint[lowGuid][#npcPoint[lowGuid]+1] = { c_type = 2, waitTime = waitTimeToSet, emoteId = emoteToSet}
						player:SendBroadcastMessage(creature:GetName().." установлена точка ожидания ("..#npcPoint[lowGuid].."). Ожидание "..waitTimeToSet.." секунд секунд c анимацией "..emoteToSet)
					end
				end
			elseif (arguments[1] == "npcsetstate" and #arguments == 2 ) then
				
				local emoteToSet = tonumber(arguments[2])
				local creature = player:GetTargetCreature()
				if(creature:GetOwner() == player) or (player:GetGMRank() > 0)then
					creature:SetStandState(emoteToSet)
				end
			end
			
		elseif (code == "wpmove") then
            local creature = player:GetTargetCreature()
			if(creature:GetOwner() == player) or (player:GetGMRank() > 0)then
				local lowGuid = creature:GetGUIDLow()
				if npcPoint[lowGuid] == nil then
					npcPoint[lowGuid] = {}
					npcPoint[lowGuid][1] = {}
					npcPoint[lowGuid][1] = { c_type = 1, x = player:GetX(), y = player:GetY(), z = player:GetZ() }
					player:SendBroadcastMessage(creature:GetName().." установлена стартовая точка (Передвижение)")
				else
					if distance(npcPoint[lowGuid][#npcPoint[lowGuid]].x,npcPoint[lowGuid][#npcPoint[lowGuid]].y,player:GetX(),player:GetY()) < 3 then
						player:SendBroadcastMessage("Невозможно установить точку. Расстояние от предыдущей точки меньше 3 ярдов.")
						return false
					end
					npcPoint[lowGuid][#npcPoint[lowGuid]+1] = { c_type = 1, x = player:GetX(), y = player:GetY(), z = player:GetZ() }
					player:SendBroadcastMessage(creature:GetName().." установлена "..#npcPoint[lowGuid].." точка (Передвижение)")
				end
			end
		elseif (code == "wpwalk") then
            local creature = player:GetTargetCreature()
			if(creature:GetOwner() == player) or (player:GetGMRank() > 0)then
				local lowGuid = creature:GetGUIDLow()
				if npcPoint[lowGuid] == nil then
					npcPoint[lowGuid] = {}
					npcPoint[lowGuid][1] = {}
					npcPoint[lowGuid][1] = { c_type = 3, x = player:GetX(), y = player:GetY(), z = player:GetZ() }
					player:SendBroadcastMessage(creature:GetName().." установлена стартовая точка (Медленный шаг)")
				else
					if distance(npcPoint[lowGuid][#npcPoint[lowGuid]].x,npcPoint[lowGuid][#npcPoint[lowGuid]].y,player:GetX(),player:GetY()) < 3 then
						player:SendBroadcastMessage("Невозможно установить точку. Расстояние от предыдущей точки меньше 3 ярдов.")
						return false
					end
					npcPoint[lowGuid][#npcPoint[lowGuid]+1] = { c_type = 3, x = player:GetX(), y = player:GetY(), z = player:GetZ() }
					player:SendBroadcastMessage(creature:GetName().." установлена "..#npcPoint[lowGuid].." точка (Медленный шаг)")
				end
			end
		elseif (code == "wpclear") then
            local creature = player:GetTargetCreature()
			if(creature:GetOwner() == player) or (player:GetGMRank() > 0)then
				local lowGuid = creature:GetGUIDLow()
				if npcPoint[lowGuid] then
					npcPoint[lowGuid] = nil
					player:SendBroadcastMessage("Вся очередь контрольных точек была убрана с "..creature:GetName())
				end
			end
		elseif (code == "wpgo") then
            local creature = player:GetTargetCreature()
			if(creature:GetOwner() == player) or (player:GetGMRank() > 0)then
				creature:RemoveAura(WALK_AURA)
				creature:SetWalk(true)
				local lowGuid = creature:GetGUIDLow()
				if npcPoint[lowGuid] == nil then
					player:SendBroadcastMessage("Ошибка. НПС не имеет точек передвижения.")
				else
					if #npcPoint[lowGuid] < 2 then
						player:SendBroadcastMessage("Ошибка. Установлено менее двух вейпоинтов.")
						return false
					end
					
					local id = nil
					if npcPoint[lowGuid][1].c_type == 1 then
						local pos = npcPoint[lowGuid][1]
						local dest = distance(creature:GetX(),creature:GetY(),pos.x,pos.y)
						creature:SetSpeed(0,1)
						id = CreateLuaEvent( GoToNextWaypoint, (dest/creature:GetSpeed(0))*1000,1)
						creature:EmoteState(0)
						creature:MoveTo(1000,pos.x,pos.y,pos.z)
					elseif npcPoint[lowGuid][1].c_type == 3 then
						local pos = npcPoint[lowGuid][1]
						creature:SetWalk(true)
						creature:SetSpeed(0,0.5)
						local dest = distance(creature:GetX(),creature:GetY(),pos.x,pos.y)
						id = CreateLuaEvent( GoToNextWaypoint, (dest/creature:GetSpeed(0))*1000,1)
						creature:EmoteState(0)
						creature:MoveTo(1000,pos.x,pos.y,pos.z)
					elseif npcPoint[lowGuid][1].c_type == 2 then
						local waitTime = npcPoint[lowGuid][1].waitTime
						local emoteToPlay = npcPoint[lowGuid][1].emoteId
						creature:EmoteState(emoteToPlay)
						id = CreateLuaEvent( GoToNextWaypoint, (waitTime)*1000,1)
					end
					queryManager[id] = {}
					queryManager[id].guid = lowGuid
					queryManager[id].entry = creature:GetEntry()
					queryManager[id].map = player:GetMapId()
					queryManager[id].nextOrder = 2
					
				end
			end
		end
    end
end
RegisterPlayerEvent(42, OnPlayerCommandWArg)
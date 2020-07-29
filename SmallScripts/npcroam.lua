function PlayerHasNPCTarget(player,PlayerTarget)
	if PlayerTarget == nil or PlayerTarget:ToCreature() == nil then
		player:SendBroadcastMessage("Возьмите NPC в таргет!")
		return false;
	else
		return true;
	end
end

function NpcRoam(event, player, command)

	-- NPC бродит в радиусе
	if(string.find(command, " ")) then
		local arguments = {}
		local arguments = string.split(command, " ")
		if ( ( arguments[1] == "npcroam" or arguments[1] == "roam") and (( player:GetGMRank() > 0 ) or player:GetDmLevel() > 0 ) ) then -- СЮДА НУЖНО ВСТАВИТЬ ПРОВЕРКУ НА ДМКУ
			PlayerTarget = nil
			-- АНТИЮЗЕР СИСТЕМА
			local PlayerTarget = player:GetSelection()
			if PlayerHasNPCTarget(player,PlayerTarget) then
				arguments[2] = tonumber(arguments[2])
				if ( arguments[2] >= 0 and arguments[2] <= 10 ) then
					PlayerTarget:MoveRandom(arguments[2])
				else
					player:SendBroadcastMessage("Указанный радиус должен быть больше 0 и меньше 10.")
				end
			end
		end
	end
	
	-- NPC бродит в радиусе (Случайный радиус)
	if ( ( command == "roam" or command == "npcroam" ) and ( (player:GetGMRank() > 0 ) or player:GetDmLevel() > 0) ) then -- СЮДА НУЖНО ВСТАВИТЬ ПРОВЕРКУ НА ДМКУ
		PlayerTarget = nil
		-- АНТИЮЗЕР СИСТЕМА
		local PlayerTarget = player:GetSelection()
		if PlayerHasNPCTarget(player,PlayerTarget) then
			PlayerTarget:MoveRandom(math.random(4,10))
		end
	end
	
	-- NPC останавливается
	if ( ( command == "stoproam" or command == "unroam" ) and ( (player:GetGMRank()  > 0 ) or player:GetDmLevel() > 0) ) then  -- СЮДА НУЖНО ВСТАВИТЬ ПРОВЕРКУ НА ДМКУ
		PlayerTarget = nil
		-- АНТИЮЗЕР СИСТЕМА
		local PlayerTarget = player:GetSelection()
		if PlayerHasNPCTarget(player,PlayerTarget) then
			-- PlayerTarget:MoveClear() ?? Почему не работает
			PlayerTarget:MoveRandom(0)
		end
	end
end

RegisterPlayerEvent( 42, NpcRoam )
function NpcFollowPlayer(event, player, command)
	-- Подсказка при вводе пустой команды
	if ( command == "follow" or command == "npcfollow" ) then
		player:SendBroadcastMessage(".follow |cffFF4500Ник персонажа |r[|cffbbbbbbДистанция от -2 до 4|r] |r[|cffbbbbbbПозиция относительно игрока|r]\nВы можете указать |cffbbbbbbr|r для выбора случайной позиции.")
	end
	-- Следовать за игроком
	if(string.find(command, " ")) then
		local arguments = {}
		local arguments = string.split(command, " ")
		if ( ( arguments[1] == "npcfollow" or arguments[1] == "follow") and (player:GetGMRank() > 0 or player:GetDmLevel() > 0 ) ) then
			PlayerTarget = nil
			-- АНТИЮЗЕР СИСТЕМА
			local PlayerTarget = player:GetSelection()
			if PlayerHasNPCTarget(player,PlayerTarget) then
				local DMcreature = player:GetTargetCreature();
				if (player:GetDmLevel() > 0 and DMcreature:GetOwner() ~= player) then
					player:SendBroadcastMessage("Этот НПС вам не принадлежит")
					return false
				end
				-- Если указана дистанция следования
				if arguments[3] ~= nil then
					arguments[3] = tonumber(arguments[3])
					if ( arguments[3] <= 4 and arguments[3] >= (-2) ) then
					
						-- Случайная позиция рядом с игроком
						if arguments[4] == "r" or arguments[4] == "R" then
							PlayerTarget:MoveFollow(GetPlayerByName(arguments[2]),arguments[3],math.random(0,180))
							
						-- Указана конкретная позиция рядом с игроком
						elseif arguments[4] ~= nil then
							arguments[4] = tonumber(arguments[4])
							PlayerTarget:MoveFollow(GetPlayerByName(arguments[2]),arguments[3],arguments[4])
							
						-- Позиция рядом с игроком не указана
						else
							PlayerTarget:MoveFollow(GetPlayerByName(arguments[2]),arguments[3])
						end
					else
						player:SendBroadcastMessage("Укажите дистанцию следования от -2 до 4.")
					end
					
				-- Если не указана дистанция следования
				else
					PlayerTarget:MoveFollow(GetPlayerByName(arguments[2]),math.random(-1.5,0),math.random(0,180))
				end
			end
		end
	end
	-- Перестать следовать за игроком
	if ( command == "unfollow" or command == "npcunfollow" ) and (player:GetGMRank() > 0 or player:GetDmLevel() > 0 ) then
		PlayerTarget = nil
		local PlayerTarget = player:GetSelection()
		if PlayerHasNPCTarget(player,PlayerTarget) then
			PlayerTarget:MoveClear()
		end
	end
end

RegisterPlayerEvent( 42, NpcFollowPlayer )
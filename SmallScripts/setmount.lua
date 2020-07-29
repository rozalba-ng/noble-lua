function NpcSetMount(event, player, command)

	-- -- -- -- -- -- --
	-- ЗАЛЕЗТЬ НА МАУНТА
	if(string.find(command, " ")) then
		local arguments = {}
		local arguments = string.split(command, " ")
		-- Проверка соответствия всем условиям.
		if ( ( arguments[1] == "setmount" or arguments[1] == "npcsetmount" ) and player:GetGMRank() > 0 ) then
			PlayerTarget, TargetEntry = nil
			DisplayIDList = {}
		-- АНТИЮЗЕР СИСТЕМА
			local PlayerTarget = player:GetSelection()
			if PlayerTarget == nil then
				player:SendBroadcastMessage("Возьмите NPC в таргет!")
				return false;
			end
			if PlayerTarget:ToCreature() ~= nil then
		-- ПОЛУЧЕНИЕ ВСЕХ ДИСПЛЕЙНИКОВ
				arguments[2] = tonumber(arguments[2])
				local GobQ = WorldDBQuery('SELECT modelid1,modelid2,modelid3,modelid4 FROM creature_template WHERE entry = ' ..arguments[2])
				for i = 0, 3 do
					if GobQ:GetInt32(i) ~= 0 then
						table.insert( DisplayIDList, GobQ:GetInt32(i) )
					end
				end
				local MountDisplayID = math.random(1,#DisplayIDList)
		-- САЖАЕМ NPC НА МАУНТА
				PlayerTarget:Mount(DisplayIDList[MountDisplayID])
			end
		end
	end
	
	-- -- -- -- -- -- --
	-- СЛЕЗТЬ С МАУНТА
	if (( command == "unsetmount" or command == "unsetnpcmount" ) and player:GetGMRank() > 0 ) then
		PlayerTarget = nil
		local PlayerTarget = player:GetSelection()
		-- АНТИЮЗЕР СИСТЕМА
		if PlayerTarget == nil then
			layer:SendBroadcastMessage("Возьмите NPC в таргет!")
			return false;
		end
		if PlayerTarget:ToCreature() ~= nil then
			PlayerTarget:Dismount()
		end
	end
	
end

RegisterPlayerEvent( 42, NpcSetMount )
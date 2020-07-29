function NpcSetDisplay(event, player, command)
	if(string.find(command, " ")) then
		local arguments = {}
		local arguments = string.split(command, " ")
		-- Проверка соответствия всем условиям.
		if ( ( arguments[1] == "setdisplay" or arguments[1] == "npcsetdisplay" ) and (player:GetGMRank() > 0 or player:GetDmLevel() > 0 ) ) then
			PlayerTarget, TargetEntry = nil
			DisplayIDList = {}
		-- АНТИЮЗЕР СИСТЕМА
			local PlayerTarget = player:GetSelection()
			if PlayerTarget == nil then
				player:SendBroadcastMessage("Возьмите NPC в таргет!")
				return false;
			end
			if PlayerTarget:ToCreature() ~= nil then
				local TargetEntry = PlayerTarget:GetEntry() -- Получение ID NPC
		-- ПОЛУЧЕНИЕ ВСЕХ ДИСПЛЕЙНИКОВ
				local GobQ = WorldDBQuery('SELECT modelid1,modelid2,modelid3,modelid4 FROM creature_template WHERE entry = ' ..TargetEntry)
				for i = 0, 3 do
					if GobQ:GetInt32(i) ~= 0 then
						table.insert( DisplayIDList, GobQ:GetInt32(i) )
					end
				end
		-- УСТАНОВКА DisplayID
				if #DisplayIDList == 1 then
					player:SendBroadcastMessage("Данный NPC имеет только один DisplayID.")
				else
					arguments[2] = tonumber(arguments[2])
					if arguments[2] <= #DisplayIDList and arguments[2] > 0 then
						local DMcreature = player:GetTargetCreature();
						if player:GetDmLevel() > 0 then
							if(DMcreature:GetOwner() == player)then
								PlayerTarget:SetDisplayId(DisplayIDList[arguments[2]])
							else
								player:SendBroadcastMessage("НПС вам не принадлежит.")
							end
						else
							PlayerTarget:SetDisplayId(DisplayIDList[arguments[2]])
						
						end
					else
						player:SendBroadcastMessage("Укажите номер от 1 до "..#DisplayIDList..".")
					end
				end
			else
				player:SendBroadcastMessage("Возьмите в таргет NPC!" )
			end
			
		end
	end
end

RegisterPlayerEvent( 42, NpcSetDisplay )
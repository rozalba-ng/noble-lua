function NpcGetDisplay(event, player, command)
	if ( command == "npcmodel" or command == "npcdisplay" ) then
	
		local PlayerTarget, CurrentDisplayID, TargetEntry, DisplayIDAll = nil
		local DisplayIDList = {}
		local PlayerTarget = player:GetSelection() -- Выбранный NPC
		if PlayerTarget == nil then -- Анти юзер система
			player:SendBroadcastMessage("Возьмите NPC в таргет!")
			return false;
		end
		if PlayerTarget:ToCreature() ~= nil then
		
			local CurrentDisplayID = PlayerTarget:GetDisplayId() -- Текущий DisplayID
			local TargetEntry = PlayerTarget:GetEntry() -- Получение ID npc
			
			-- Поиск всех дисплейников
			local GobQ = WorldDBQuery('SELECT modelid1,modelid2,modelid3,modelid4 FROM creature_template WHERE entry = ' ..TargetEntry)
			-- Запись существующих дисплейников
			for i = 0, 3 do
				if GobQ:GetInt32(i) ~= 0 then
					table.insert( DisplayIDList, GobQ:GetInt32(i) )
				end
			end
			
			-- Вывод сообщения
			if #DisplayIDList > 1 then
				for i = 1, #DisplayIDList do
					if DisplayIDAll ~= nil then
						DisplayIDAll = ( DisplayIDAll.." "..DisplayIDList[i] )
					else
						DisplayIDAll = DisplayIDList[1]
					end
				end
				player:SendBroadcastMessage("[|cffFFC125"..PlayerTarget:GetName().. "|r]\nТекущий DisplayID: |cffFFC125"..CurrentDisplayID.. "|r\nВсе используемые: |cffFFC125"..DisplayIDAll)
			-- Если дисплейник только один
			else
				player:SendBroadcastMessage("[|cffFFC125"..PlayerTarget:GetName().. "|r]\nТекущий DisplayID: |cffFFC125"..CurrentDisplayID.. "|r")
			end
		else
			player:SendBroadcastMessage("Возьмите в таргет NPC!")
			return false;
		end
		
	end
end

RegisterPlayerEvent( 42, NpcGetDisplay )
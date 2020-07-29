function NPCByte2(event, player, command)
	if player:GetGMRank() > 0 or player:GetDmLevel() > 0 then -- Проверка на гмку.
		if(string.find(command, " ")) then
			local arguments = {}
			local arguments = string.split(command, " ")
			if arguments[1] == "weapon" then
				local PlayerTarget = player:GetSelection()
				if PlayerTarget then
					if PlayerTarget:ToCreature() then
						if arguments[2] and tonumber(arguments[2]) then
							PlayerTarget:SetByteValue(6+116,0,tonumber(arguments[2]))
						else player:SendBroadcastMessage("Правильное использование: |cff00FF7F.weapon [0-2]") end
					else player:SendBroadcastMessage("Возьмите в цель NPC.") end
				else player:SendBroadcastMessage("Возьмите в цель NPC.") end
			end
		end
	end
end
RegisterPlayerEvent(42,NPCByte2)
function OnCommand( event, player, command )
	if player:GetGMRank() > 0 then
		if command == "changeweapon" then
			player:SendBroadcastMessage(".changeweapon id_mainhand id_offhand id_ranged - позволяет сменить оружие для NPC.\nВместо id вписывается любой id предмета.\nЕсли вам не нужно его отображать вовсе - вписывайте значение 0.")
		elseif string.find( command, " " ) then
				local command = string.split( command, " " )
				if command[1] == "changeweapon" then
				local idmain = tonumber(command[2])
				local idoff = tonumber(command[3])
				local idrang = tonumber(command[4])
					local playerTarget = player:GetSelection()
					if playerTarget then
						if playerTarget:ToCreature() then
							playerTarget:SetEquipmentSlots( idmain, idoff, idrang )
						else
							player:SendBroadcastMessage("Заполните все id оружия.")
					end
				end
			end
		end
	end
end

RegisterPlayerEvent( 42, OnCommand )
local ROMAKA_ACCOUNT_ID = 5794 --Сменить на айди аккаунта ромаки.

local function OnPlayerCommand(event, player,command)
	if(string.match(command,'giveres')) then
		if (player:GetAccountId() == ROMAKA_ACCOUNT_ID or player:GetGMRank() == 3 ) then
			local selection = player:GetSelection()
			if selection:ToPlayer() then
				player:GossipClearMenu()
				player:GossipMenuAddItem(4, "Выдать биастры", 1, 600034,true,"Необходимо будет ввести количество выдаваемых |cff71C671биастров|cffffffff игроку |cff00ccff".. selection:GetName().."|cffffffff.\n\nУбедитесь, что у игрока достаточно места в инвентаре!")
				player:GossipMenuAddItem(4, "Выдать алмазы", 1, 600030,true,"Необходимо будет ввести количество выдамаемых |cff71C671алмазов|cffffffff игроку |cff00ccff".. selection:GetName().."|cffffffff.\n\nУбедитесь, что у игрока достаточно места в инвентаре!")
				player:GossipMenuAddItem(4, "Выдать изумруды", 1, 600032,true,"Необходимо будет ввести количество выдамаемых |cff71C671изумрудов|cffffffff игроку |cff00ccff".. selection:GetName().."|cffffffff.\n\nУбедитесь, что у игрока достаточно места в инвентаре!")
				player:GossipMenuAddItem(4, "Выдать рубины", 1, 600033,true,"Необходимо будет ввести количество выдамаемых |cff71C671рубинов|cffffffff игроку |cff00ccff".. selection:GetName().."|cffffffff.\n\nУбедитесь, что у игрока достаточно места в инвентаре!")
				player:GossipMenuAddItem(4, "Выдать сапфиры", 1, 600031,true,"Необходимо будет ввести количество выдамаемых |cff71C671сапфиров|cffffffff игроку |cff00ccff".. selection:GetName().."|cffffffff.\n\nУбедитесь, что у игрока достаточно места в инвентаре!")
				player:GossipMenuAddItem(1, "Закрыть", 1, 100)
				player:GossipSendMenu(1, player,1000)
			else
				player:SendBroadcastMessage("|cffff0000Ошибка! Не выбран игрок. Выберите игрока, которому хотите отправить ресурсы в цель.")
			end
			return false
		end
	end
	
end
local function OnSelectGossip(event, player, object, sender, intid, code, menu_id)
	if intid == 100 then
		player:GossipComplete()
	else
		local selection = player:GetSelection()
		local player_reciever = selection:ToPlayer()
		if player_reciever then
			player:GossipComplete()
			local given_item = player_reciever:AddItem(intid,code)
			if given_item then
				player:SendBroadcastMessage(given_item:GetItemLink(8).. "|cff71C671 в количестве |cff00ccff"..code.."|cff71C671 штук были выданы игроку |cff00ccff"..player_reciever:GetName())
			else
				player:SendBroadcastMessage("|cffff0000 У игрока полон инвентарь!")
			end
		else
			player:SendBroadcastMessage("|cffff0000Ошибка! Не выбран игрок. Выберите игрока, которому хотите отправить ресурсы в цель.")
			
		end
	end

end
	
RegisterPlayerGossipEvent(1000,2, OnSelectGossip)
RegisterPlayerEvent(42, OnPlayerCommand)
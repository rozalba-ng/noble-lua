local AIO = AIO or require("AIO")

local QuestBarHandlers = AIO.AddHandlers("QuestBarHandlers", {})



local function OnPlayerCommandWArg(event, player, code) -- command with argument
    if(player:GetDmLevel() > 0 or player:GetGMRank() > 0)then
        if(string.find(code, " "))then
			local arguments = {}
			local arguments = string.split(code, " ")
			if (arguments[1] == "bar") then
				local group = player:GetGroup()
				local players = nil
				if group then
					players = group:GetMembers()
				end
				local mode = 1
				local leftmsg = ""
				local rightmsg = ""
				for i = 2, #arguments do
					if arguments[i] == ":" then
						mode = 2
					else
						
						if mode == 1 then
							leftmsg = leftmsg.." "..arguments[i]
						elseif mode == 2 then
							rightmsg = rightmsg.." "..arguments[i]
						end
					end
					
				end
				if players then
					for i = 1, #players do
						print(players[i]:GetName())
						if mode == 2 then
							AIO.Handle(players[i],"QuestBarHandlers","ShowQuest","|cffffc43b"..leftmsg..":|cffffffff "..rightmsg)
							players[i]:SendBroadcastMessage("|cffffc43b"..leftmsg..":|cffffffff "..rightmsg)
						else
							AIO.Handle(players[i],"QuestBarHandlers","ShowQuest",leftmsg)
							players[i]:SendBroadcastMessage("Событие мастера: "..leftmsg)
						end
					end
				else
					local selection = player:GetSelection()
					if mode == 2 then
						AIO.Handle(player,"QuestBarHandlers","ShowQuest","|cffffc43b"..leftmsg..":|cffffffff "..rightmsg)
						player:SendBroadcastMessage("|cffffc43b"..leftmsg..":|cffffffff "..rightmsg)
						
						AIO.Handle(selection,"QuestBarHandlers","ShowQuest","|cffffc43b"..leftmsg..":|cffffffff "..rightmsg)
						selection:SendBroadcastMessage("|cffffc43b"..leftmsg..":|cffffffff "..rightmsg)
					else
						AIO.Handle(player,"QuestBarHandlers","ShowQuest",leftmsg)
						player:SendBroadcastMessage("Событие мастера:|cffffffff "..leftmsg)
						
						AIO.Handle(selection,"QuestBarHandlers","ShowQuest",leftmsg)
						selection:SendBroadcastMessage("Событие мастера:|cffffffff "..leftmsg)
					end
				
				end
			end
		end
	end
end


RegisterPlayerEvent(42, OnPlayerCommandWArg)

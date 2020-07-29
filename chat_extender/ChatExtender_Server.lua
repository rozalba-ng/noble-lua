local function AddonMessageEvent(event, player, type, prefix, msg, target)
	if(prefix == "CALL_TO_SHARE_POSTFIX" and type == 7 and player == target)then
		local nearPlayers = player:GetPlayersInRange(200)
		player:SendAddonMessage("POSTFIX_SEND",msg,7,player)
		for i = 1, #nearPlayers do
			player:SendAddonMessage("POSTFIX_SEND",msg,7,nearPlayers[i])
		end
	end


end

RegisterServerEvent(30, AddonMessageEvent);
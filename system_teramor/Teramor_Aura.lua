function loginEvent(event, player, arg2, arg3, arg4)
	local query = CharDBQuery("SELECT * FROM characters.dd_chars WHERE name = '"..player:GetName().."'")
	if query then
		player:AddAura(88119,player)
	else
		player:RemoveAura(88119)
	end
end
local function OnPlayerCommandWithArg(event, player, code)
    if(string.find(code, " "))then
		if player:GetGMRank() < 2 then
			return false
		end
        local arguments = {}
        local arguments = string.split(code, " ")
		if (arguments[1] == "addtopolygon" and #arguments == 2 ) then
			local name = arguments[2]
			local query = CharDBQuery("SELECT * FROM characters.dd_chars WHERE name = '"..name.."'")
			if query then
				player:SendBroadcastMessage("Игрок "..name.." УЖЕ добавлен в список участников Западного Края.")
			else
				player:SendBroadcastMessage("Игрок "..name.." успешно ДОБАВЛЕН в список участников Западного Края!")
				CharDBExecute("INSERT INTO `characters`.`dd_chars` (`name`) VALUES ('"..name.."');")
			end
		elseif (arguments[1] == "removefrompolygon" and #arguments == 2 ) then
			local name = arguments[2]
			local query = WorldDBQuery("SELECT * FROM characters.dd_chars WHERE name = '"..name.."'")
			if query then
				player:SendBroadcastMessage("Игрок "..name.." успешно ИСКЛЮЧЕН из списка участников Западного Края!")
				CharDBExecute("DELETE FROM `characters`.`dd_chars` WHERE  `name`='"..name.."' LIMIT 1;")
			else
				player:SendBroadcastMessage("Игрок "..name.." НЕ НАХОДИТСЯ в списке участников Западного Края.")
			end
		end
	end
end
RegisterPlayerEvent(42, OnPlayerCommandWithArg)
RegisterPlayerEvent(3, loginEvent);
local types = { 
	{ 300, "Раннее утро" },
	{ 550, "Утро" },
	{ 800, "Полдень" },
	{ 1160, "Вечер" },
	{ 1310, "Поздний вечер" },
	{ 0, "Ночь" },
}




local function OnCommand( event, player, command )
	if player:GetGMRank() > 0 or player:GetDmLevel() > 0 then
		if command == "setgrouptime" then
			player:SendBroadcastMessage(".setgrouptime id - выставляет время для всех участников вашей группы\nДоступные id:")
			for i=1, #types do
				player:SendBroadcastMessage(i .. " " .. types[i][2])
			end
			return
		elseif string.find( command, " " ) then
			local command = string.split ( command, " " )
			if command[1] == "setgrouptime" then
				local id = tonumber(command[2])
				local packet = CreatePacket( 66, 12 )
				packet:WriteULong( types[id][1] ) -- Время от 1го ноября 2002 в минутах. Определяет время суток
				packet:WriteFloat( 0 ) -- FLOAT скорость времени. По дефолту 0.017
				packet:WriteLong( 0 )
				player:SendPacket( packet )
				local group = player:GetGroup()
				if group then
					local members = group:GetMembers()
					for i=1, #members do
						members[i]:SendPacket( packet )
					end
				end
				return
			end
		end
	end
	if command == "settime" then
		player:SendBroadcastMessage(".settime id - устанавливает время персонально для вас\nДоступные id:")
		for i=1, #types do
			player:SendBroadcastMessage(i .. " " .. types[i][2])
		end
	elseif string.find( command, " " ) then
		local command = string.split ( command, " " )
		if command[1] == "settime" then
			local id = tonumber(command[2])
			local packet = CreatePacket( 66, 12 )
			packet:WriteULong( types[id][1] ) -- Время от 1го ноября 2002 в минутах. Определяет время суток
			packet:WriteFloat( 0 ) -- FLOAT скорость времени. По дефолту 0.017
			packet:WriteLong( 0 )
			player:SendPacket( packet )
		end
	end
end

RegisterPlayerEvent( 42, OnCommand )
-- Аналог /roll отображающий результат броска игрокам поблизости.

--[[	РАДИУС ОТОБРАЖЕНИЯ БРОСКА	]]--
local rollDistance = 20

--[[	КОМАНДА БРОСКА	]]--
local function OutGroupRoll(event, player, command)
	if command == "roll" then -- d100
		local nearPlayers = player:GetPlayersInRange(rollDistance)
		local playerName = player:GetName()
		local randomValue = math.random(100)
		if nearPlayers then
			for i = 1, #nearPlayers do
				nearPlayers[i]:SendBroadcastMessage(playerName.." выбрасывает "..randomValue.." (1-100)")
			end
		end
		player:SendBroadcastMessage(playerName.." выбрасывает "..randomValue.." (1-100)")
		return false
	elseif string.find(command, " ") then -- Свой бросок
		local arguments = {}
		arguments = string.split(command, " ")
		if arguments[1] == "roll" then
			local nearPlayers = player:GetPlayersInRange(rollDistance)
			local message = player:GetName().." выбрасывает "
			local randomValue
			if string.find(command, "-") then
				arguments[2] = string.split(arguments[2], "-")
				if ( arguments[2][1] and arguments[2][2] ) and ( tonumber(arguments[2][1]) and tonumber(arguments[2][2]) ) then
					arguments[2][1], arguments[2][2] = math.floor(tonumber(arguments[2][1])), math.floor(tonumber(arguments[2][2]))
					if not ( arguments[2][1] < arguments[2][2] ) then return end
					randomValue = math.random(arguments[2][1],arguments[2][2])
					message = message..randomValue.." ("..arguments[2][1].."-"..arguments[2][2]..")"
				end
			elseif arguments[2] and tonumber(arguments[2]) then
				arguments[2] = math.floor(tonumber(arguments[2]))
				if arguments[3] and tonumber(arguments[3]) then
					arguments[3] = math.floor(tonumber(arguments[3]))
					if not ( arguments[3] > 0 ) then return end
					randomValue = math.random(arguments[2],arguments[3])
					message = message..randomValue.." ("..arguments[2].."-"..arguments[3]..")"
				else
					if not ( arguments[2] > 0 ) then return end
					randomValue = math.random(arguments[2])
					message = message..randomValue.." (1-"..arguments[2]..")"
				end
			else
				randomValue = math.random(100)
				message = message..randomValue.." (1-100)"
			end
			if randomValue then
				if nearPlayers then
					for i = 1,#nearPlayers do
						nearPlayers[i]:SendBroadcastMessage(message)
					end
				end
				player:SendBroadcastMessage(message)
			end
		end
		return false
	end
end
RegisterPlayerEvent( 42, OutGroupRoll )
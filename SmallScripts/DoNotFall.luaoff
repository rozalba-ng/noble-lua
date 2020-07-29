
local timeTable = {}
local timeTableToUnfreeze = {}
-- Разморозка игрока через 6 секунд
local function DoNotFreeze(timerId, delay, repeats)
	local playerName = timeTableToUnfreeze[timerId]
	player = GetPlayerByName(playerName)
	player:RemoveAura(59123)
end

-- Игрок падает?
local function PlayerIsFalls(timerId, delay, repeats)
	player = GetPlayerByName(timeTable[timerId].playerName)
	if player:IsFalling() then
		if not player:IsInWater() then
			player:AddAura(59123,player)
			player:NearTeleport( timeTable[timerId].x, timeTable[timerId].y, timeTable[timerId].z, timeTable[timerId].o )
			local timerIdToUnfreeze = CreateLuaEvent( DoNotFreeze, 5000,1)
			timeTableToUnfreeze[timerIdToUnfreeze] = player:GetName()
		end
	end
end

-- Сохранение координат при входе в игру
local function DoNotFall(event,player)
	if player:GetGMRank() > 0 then
		local timerId = CreateLuaEvent( PlayerIsFalls, 1000,1)	
		timeTable[timerId] = {}
		timeTable[timerId].x, timeTable[timerId].y, timeTable[timerId].z, timeTable[timerId].o = player:GetLocation()
		timeTable[timerId].playerName = player:GetName()
	end
end

RegisterPlayerEvent(3,DoNotFall)
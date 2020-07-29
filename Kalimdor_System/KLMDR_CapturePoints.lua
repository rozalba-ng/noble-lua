
KAL_POINT_RADIUS = 20
local CAPTURING_TIME = 100

local RESOURSES_TIME = 600

local lastTimeCheck = {}

local captureTimerList = {}

KAL_CP_Entry = 	987679




function GetPointData(creature_point)
	local pointGuid = creature_point:GetDBTableGUIDLow()
	local pointDataQ = WorldDBQuery("SELECT * FROM kalimdor_capture_points WHERE point_guid = "..pointGuid)
	if pointDataQ then
		local pointData = {	id =  pointDataQ:GetInt32(0),
							name = pointDataQ:GetString(1),
							point_guid = pointGuid,
							res_gain = pointDataQ:GetInt32(3),
							owner_id = pointDataQ:GetInt32(4),
							power = pointDataQ:GetInt32(5)
							}
		return pointData
	else
		return nil
	end
end

local function SayToPlayerList(list,text)
	for i, player in pairs(list) do
		player:SendBroadcastMessage(text)
	end
end

local function GetPlayerAroundPoint(creature_point)
	local playersAround = creature_point:GetPlayersInRange(KAL_POINT_RADIUS)
	if playersAround[1] then

		local pointData = GetPointData(creature_point)
		local enemyList = {}
		local ownerList = {}
		if pointData then
			for num, player in pairs(playersAround) do
				if KAL_playerInfo[player:GetName()] then
					local playerFID = KAL_playerInfo[player:GetName()].fid
					if playerFID and playerFID ~= pointData.owner_id then
						table.insert(enemyList,{ name = player:GetName(), fid = playerFID })
					elseif playerFID and playerFID == pointData.owner_id then
						table.insert(ownerList,{ name = player:GetName(), fid = playerFID })
					end
				end
			end
			local playersOnPoint = { owners = ownerList, enemies = enemyList }
			
			return playersOnPoint
		else
			return false
		end
	else
		return false
	end
end

function AddCapturePower(pointGuid,powerCount,fid)
	local pointDataQ = WorldDBQuery("SELECT power FROM kalimdor_capture_points WHERE point_guid = "..pointGuid)
	local pointPower = pointDataQ:GetInt32(0)
	local newPointPower = pointPower + powerCount
	if newPointPower > 100 then
		newPointPower = 100
	end
	WorldDBExecute("UPDATE kalimdor_capture_points SET `power`='"..newPointPower.."' WHERE  `point_guid`="..pointGuid)
	WorldDBExecute("UPDATE kalimdor_capture_points SET `owner_id`='"..fid.."' WHERE  `point_guid`="..pointGuid)
	
end
local function TakeCapturePower(pointGuid,powerCount)
	local pointDataQ = WorldDBQuery("SELECT power FROM kalimdor_capture_points WHERE point_guid = "..pointGuid)
	local pointPower = pointDataQ:GetInt32(0)
	local newPointPower = pointPower - powerCount
	if newPointPower < 0 then
		newPointPower = 0
		WorldDBExecute("UPDATE kalimdor_capture_points SET `owner_id`='0' WHERE  `point_guid`="..pointGuid)
	end
	WorldDBExecute("UPDATE kalimdor_capture_points SET `power`='"..newPointPower.."' WHERE  `point_guid`="..pointGuid)
end



local lastCaptureChangeList = {}

local function CaptureUpdate(event, creature_point, diff)
	local pointGuid = creature_point:GetDBTableGUIDLow()
	if not lastTimeCheck[pointGuid] or (os.time()- lastTimeCheck[pointGuid]) > 5 then
		lastTimeCheck[pointGuid] = os.time()
		local playersAround = GetPlayerAroundPoint(creature_point)
		local playerToSay = creature_point:GetPlayersInRange(KAL_POINT_RADIUS)
		local pointData = GetPointData(creature_point)
		if playersAround and pointData.owner_id ~= 0 then
			
			
			if #playersAround.owners < 1 and #playersAround.enemies > 0 then
				if not lastCaptureChangeList[pointGuid] or os.time() - lastCaptureChangeList[pointGuid] > CAPTURING_TIME then
					lastCaptureChangeList[pointGuid] = os.time()
					TakeCapturePower(pointGuid,2)
					local pointDataQ = WorldDBQuery("SELECT power FROM kalimdor_capture_points WHERE point_guid = "..pointGuid)
					local pointPower = pointDataQ:GetInt32(0)
					SayToPlayerList(playerToSay,"Точку "..pointData.name.." отхватывают.\nНынешнее состояние точки - "..pointPower.."% укрепления.")
				end
			elseif #playersAround.enemies < 1 and #playersAround.owners > 0 and pointData.power < 100 then
				if not lastCaptureChangeList[pointGuid] or os.time() - lastCaptureChangeList[pointGuid] > CAPTURING_TIME then
					lastCaptureChangeList[pointGuid] = os.time()
					AddCapturePower(pointGuid,1,pointData.owner_id)
					local pointDataQ = WorldDBQuery("SELECT power FROM kalimdor_capture_points WHERE point_guid = "..pointGuid)
					local pointPower = pointDataQ:GetInt32(0)
					SayToPlayerList(playerToSay,"Точку "..pointData.name.." укрепляют.\nНынешнее состояние точки - "..pointPower.."% укрепления.")
				end
			end
			
		
		elseif playersAround and pointData.owner_id == 0 then
			local fid = 0
			local onlyOne = true
			for num, playerInfo in pairs(playersAround.enemies) do
				if fid == 0 then
					fid = playerInfo.fid
				elseif fid ~= playerInfo.fid then
					onlyOne = false
				end
				
			end
			if onlyOne then
				SayToFraction(1,"Точку "..pointData.name.." захватили!.\nВладелец - "..KAL_fractionList[tonumber(fid)].name)
				SayToFraction(2,"Точку "..pointData.name.." захватили!.\nВладелец - "..KAL_fractionList[tonumber(fid)].name)
				SayToFraction(3,"Точку "..pointData.name.." захватили!.\nВладелец - "..KAL_fractionList[tonumber(fid)].name)
				AddCapturePower(pointGuid,1,fid)
			end
		end
	end
	
end

function AddResources(frac_id,count,power)
	local currentResQ = WorldDBQuery("SELECT name, res_count FROM kalimdor_fractions WHERE id = "..frac_id)
	local currentRes = currentResQ:GetInt32(1)
	local fracName = currentResQ:GetString(0)
	local resToAdd = currentRes + ((count/100)*power)
	WorldDBExecute("UPDATE `kalimdor_fractions` SET `res_count`='"..resToAdd.."' WHERE  `id`="..frac_id..";")
	
end
function GetResources(frac_id)
	local currentResQ = WorldDBQuery("SELECT res_count FROM kalimdor_fractions WHERE id = "..frac_id)
	local currentRes = currentResQ:GetInt32(0)
	return currentRes
end

local function calculateResourses()
	local allPointsQ = WorldDBQuery("SELECT * FROM kalimdor_capture_points")
	if allPointsQ then
		for i = 1, allPointsQ:GetRowCount() do
			local resCount = 	allPointsQ:GetInt32(3)
			local owner_id = 	allPointsQ:GetInt32(4)
			local power = 		allPointsQ:GetInt32(5)
			if owner_id ~= 0 then
				AddResources(owner_id,resCount,power)
			end
			allPointsQ:NextRow()
		end
	end
end

local lastTimeCheck = {}

local lastPlayerList = {}

local playersInLastCheck = {}
local function DoThis(pvpTrigger)
	local playerList = pvpTrigger:GetPlayersInRange(KAL_POINT_RADIUS)
	local triggerGuid = pvpTrigger:GetDBTableGUIDLow()
	if not lastTimeCheck[triggerGuid] or (os.time()- lastTimeCheck[triggerGuid]) > 1 then
		lastTimeCheck[triggerGuid] = os.time()
		local newPlayersList = {}
		local newPlayersOnLastCheck = {}
		if lastPlayerList[triggerGuid] then
			for i, player in pairs(playerList) do
				if lastPlayerList[triggerGuid][player:GetName()] == 1 then

				else
					player:SendBroadcastMessage("Вы вошли в зону захвата точки. Включен режим Каждый сам за себя. Не забывайте кто ваш противник.")
					player:SetFFA(true)
				end
				
				newPlayersList[player:GetName()] = 1

				table.insert(newPlayersOnLastCheck,player:GetName())	
			end
		end

		if playersInLastCheck[triggerGuid] then
			for i, playerName in pairs(playersInLastCheck[triggerGuid]) do
				local checker = newPlayersList[playerName]
				if checker == 1 then
					
				else
					local player = GetPlayerByName(playerName)
					if player then
						player:SendBroadcastMessage("Вы покинули зону захвата точки")
						player:SetFFA(false)
					end
				
				end

			end
		end
		lastPlayerList[triggerGuid] = newPlayersList
		playersInLastCheck[triggerGuid] = newPlayersOnLastCheck
	end


end



local function OnEnterOnPvPZone(event, pvpTrigger, diff) --pvpTrigger существо
	DoThis(pvpTrigger)
end
RegisterCreatureEvent(KAL_CP_Entry,7,OnEnterOnPvPZone)
CreateLuaEvent(calculateResourses, RESOURSES_TIME*1000, 0);
RegisterCreatureEvent(KAL_CP_Entry,7,CaptureUpdate)
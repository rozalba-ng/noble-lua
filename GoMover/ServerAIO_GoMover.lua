
local AIO = AIO or require("AIO")

local GoMover = AIO.AddHandlers("GOM_Handlers", {})

playersCooldowns = {}

function copysign(value,valuetocopy)
	return value * (valuetocopy / math.abs(valuetocopy))
end


function FromQuatToEuler(x,y,z,w)

	local sinr_cosp = 2 * (w * x + y * z);
    local cosr_cosp = 1 - 2 * (x * x + y * y);
    local roll = math.atan2(sinr_cosp, cosr_cosp);
    local sinp = 2 * (w * y - z * x);
	local pitch = 0
    if (math.abs(sinp) >= 1) then
        pitch = copysign(math.pi() / 2, sinp)
    else
        pitch = math.asin(sinp);
	end
    local siny_cosp = 2 * (w * z + x * y);
    local cosy_cosp = 1 - 2 * (y * y + z * z);
    local yaw = math.atan2(siny_cosp, cosy_cosp);
	return yaw , pitch ,roll
end

function GoMover.StartRotate(player,guid,value,rotateType)
	if ( not playersCooldowns[player:GetName()] or (  os.time() - playersCooldowns[player:GetName()]  ) > 0.3 )  then
		playersCooldowns[player:GetName()] = os.time()
		q = WorldDBQuery('SELECT rotation0, rotation1,rotation2,rotation3 FROM gameobject WHERE guid ='..guid)	
		local x,y,z = FromQuatToEuler(q:GetFloat(0),q:GetFloat(1),q:GetFloat(2),q:GetFloat(3))
		AIO.Handle(player,"GOM_Handlers","RotateGo",rotateType,x,y,z,value)
	end
end
function GoMover.StartMove(player,guid,value,moveType)
	if ( not playersCooldowns[player:GetName()] or (  os.time() - playersCooldowns[player:GetName()]  ) > 0.3 )  then
		playersCooldowns[player:GetName()] = os.time()
		q = WorldDBQuery('SELECT position_x, position_y,position_z,orientation FROM gameobject WHERE guid ='..guid)
		local x,y,z,o = q:GetFloat(0),q:GetFloat(1),q:GetFloat(2),q:GetFloat(3)
		local po = player:GetO()
		AIO.Handle(player,"GOM_Handlers","MoveGo",moveType,x,y,z,po,value)
	end
end
function GoMover.StartScale(player,guid,value,scaleType)
	if ( not playersCooldowns[player:GetName()] or (  os.time() - playersCooldowns[player:GetName()]  ) > 0.3 )  then
		playersCooldowns[player:GetName()] = os.time()
		AIO.Handle(player,"GOM_Handlers","ScaleGo",scaleType,value)
	end
end
function GoMover.ReturnToInventory(player,guid)
	if(player:GetGMRank() == 2 or player:GetGMRank() == 1)then
		player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFДоступ запрещен для вашего типа аккаунта.|r");
		return false;
	end
	for index, go in pairs(player:GetGameObjectsInRange(40)) do 
		if tonumber(go:GetDBTableGUIDLow()) == tonumber(guid) then
			if go:GetPhaseMask() == 1024 then --Нельзя забирать гошки в 1024 фазе (Творческая фаза)
				player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFВы не можете забирать объекты в творческой фазе.|r");
				return false
			end
			local entry = go:GetEntry();
			local item = player:AddItem(entry);
			if(item == nil)then
				player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНет места.|r");
				return false;
			end
			
			go:RemoveFromWorld(true)

		end
	end
end
function GOM_OpenEditAddon(player,gob)
	AIO.Handle(player,"GOM_Handlers","SetName",gob:GetName())
	AIO.Handle(player,"GOM_Handlers","GetGUID",gob:GetDBTableGUIDLow())

end

local function OnPlayerCommandWithArg(event, player, code)
    if(string.find(code, " "))then -- кста, Вадик, а что это за странный кусок кода, который ничего не делает?
        local arguments = {}
        local arguments = string.split(code, " ")
	elseif(code == "movego")then
		local nearestGo = player:GetNearestGameObject(5)
		if nearestGo then
			if (nearestGo:GetOwner() == player) or player:GetGMRank() > 0 then
				AIO.Handle(player,"GOM_Handlers","SetName",nearestGo:GetName())
				AIO.Handle(player,"GOM_Handlers","GetGUID",nearestGo:GetDBTableGUIDLow())
			else
				player:SendBroadcastMessage("Рядом стоящий объект вам не принадлежит")
			end
		else
			player:SendBroadcastMessage("Объектов в радиусе не было обнаружено")
		end
	end
end

RegisterPlayerEvent(42, OnPlayerCommandWithArg)
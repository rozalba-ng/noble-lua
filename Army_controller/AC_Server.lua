function string:split(sep)
    local sep, fields = sep or ",", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

local RUN_NPC_COMMAND = 1001170
local WALK_NPC_COMMAND = 1001171
local ROTATE_NPC_COMMAND = 1001172
local SELECT_RANGE_2_NPC = 1001173
local SELECT_RANGE_5_NPC = 1001174

local AIO = AIO or require("AIO")

local ArmyHandlers = AIO.AddHandlers("ArmyHandlers", {})
local npcToCommand = {}



local function OnNPCSelectSpawn(event, creature, summoner)
	local SelectedNPCInRange = {}
	local SelectedNPCToPlayer = {}
	if creature:GetEntry() == SELECT_RANGE_2_NPC then
		SelectedNPCInRange = creature:GetCreaturesInRange(-1,0,0,1)
	elseif creature:GetEntry() == SELECT_RANGE_5_NPC then
		SelectedNPCInRange = creature:GetCreaturesInRange(2.5,0,0,1)
	end
	creature:DespawnOrUnsummon()
	for i = 1, #SelectedNPCInRange do
		local creatureGuid = SelectedNPCInRange[i]:GetGUIDLow()
		SelectedNPCToPlayer[i] = { guid = creatureGuid, entry = SelectedNPCInRange[i]:GetEntry() }
	end
	AIO.Handle(summoner,"ArmyHandlers","SelectNewNPCs",SelectedNPCToPlayer)
end
local function OnNPCCommandSpawn(event, creature, summoner)
	local creatureEntry = creature:GetEntry()
	local xPos,yPos,zPos = creature:GetHomePosition()
	creature:DespawnOrUnsummon()

	if creatureEntry == RUN_NPC_COMMAND then
		AIO.Handle(summoner,"ArmyHandlers","CallTableToCommand",1,xPos,yPos,zPos)
	elseif creatureEntry == WALK_NPC_COMMAND then
		AIO.Handle(summoner,"ArmyHandlers","CallTableToCommand",2,xPos,yPos,zPos)
	elseif creatureEntry == ROTATE_NPC_COMMAND then
		AIO.Handle(summoner,"ArmyHandlers","CallTableToCommand",3,xPos,yPos,zPos)
	end
	
end
function ArmyHandlers.DeleteAllNpcInGroup(player,arr)
	for i = 1, #arr do
		local creatureGUID = GetUnitGUID(arr[i].guid, arr[i].entry)
		if creatureGUID then
			local map = player:GetMap()
			local creatureToDel = map:GetWorldObject(creatureGUID)
			creatureToDel:DespawnOrUnsummon()
		end
	end
end
function ArmyHandlers.SetEmoteToNPC(player,npcToCommand,emoteID)
	local map = player:GetMap()
	for i = 1, #npcToCommand do
		local creatureGUID = GetUnitGUID(npcToCommand[i].guid, npcToCommand[i].entry)
		local creature = map:GetWorldObject(creatureGUID)
		creature:EmoteState(tonumber(emoteID))
	end
end

function ArmyHandlers.CommandToNPC(player,npcToCommand,commandType,xPos,yPos,zPos)
	local total = { x = 0, y = 0, z = 0 }
	local endVector = { x =0, y = 0, z = 0}
	local armyAngle = 0
	local center = { x =0, y = 0, z = 0}
	local position ={}

	for i = 1, #npcToCommand do
		local creatureGUID = GetUnitGUID(npcToCommand[i].guid, npcToCommand[i].entry)
		local map = player:GetMap()
		local creature = map:GetWorldObject(creatureGUID)
		local x,y,z,o = creature:GetHomePosition()
		total.x = total.x + x
		total.y = total.y + y
		total.z = total.z + z
	end
	center.x = total.x/#npcToCommand
	center.y = total.y/#npcToCommand
	center.z = total.z/#npcToCommand
	
	endVector.x = xPos - center.x 
	endVector.y = yPos - center.y
	endVector.z = zPos - center.z
	if #npcToCommand > 0 then
		for i = 1, #npcToCommand do
			local startVector = { x =0, y = 0, z = 0}
			local creatureGUID = GetUnitGUID(npcToCommand[i].guid, npcToCommand[i].entry)
			local map = player:GetMap()
			local creatureToMove = map:GetWorldObject(creatureGUID)
			crPosX, crPosY, crPosZ, crPosO = creatureToMove:GetHomePosition()
			startVector.x = crPosX - center.x 
			startVector.y = crPosY - center.y
			startVector.z = crPosZ - center.z

			local startVectorAngle	= math.atan2(startVector.y,startVector.x)
			local endVectorAngle = math.atan2(endVector.y,endVector.x)
			local AngleToRotate = endVectorAngle - crPosO
			local ca = math.cos(AngleToRotate)
			local sa = math.sin(AngleToRotate)
			local rotatedVector = { x = ca*startVector.x - sa*startVector.y, y = sa*startVector.x + ca*startVector.y }
			local rotatedVectorAngle = math.atan2(rotatedVector.y,rotatedVector.x)
			if commandType == 1 then
				creatureToMove:SetWalk(false)
				creatureToMove:SetHomePosition(xPos + rotatedVector.x,yPos + rotatedVector.y,zPos + startVector.z, endVectorAngle)
				creatureToMove:MoveHome()
			elseif commandType == 2 then
				creatureToMove:SetWalk(true)
				creatureToMove:MoveTo(i,xPos + rotatedVector.x,yPos + rotatedVector.y,zPos + startVector.z)
				creatureToMove:SetHomePosition(xPos + rotatedVector.x,yPos + rotatedVector.y,zPos + startVector.z, endVectorAngle)

			elseif commandType == 3 then
				
				creatureToMove:SetHomePosition(center.x  +rotatedVector.x,center.y  +rotatedVector.y, center.z  +startVector.z, endVectorAngle)
				creatureToMove:MoveHome()
			end
		end
	elseif player:GetTargetCreature() then
		local creatureToMove = player:GetTargetCreature()
		endVector.x = xPos - creatureToMove:GetX()
		endVector.y = yPos - creatureToMove:GetY()
		endVector.z = zPos - creatureToMove:GetZ()
		local endVectorAngle = math.atan2(endVector.y,endVector.x)
		if commandType == 1 then
			creatureToMove:SetWalk(false)
			creatureToMove:SetHomePosition(xPos,yPos,zPos, endVectorAngle)
			creatureToMove:MoveHome()
		elseif commandType == 2 then
			creatureToMove:SetWalk(true)
			creatureToMove:MoveTo(1,xPos,yPos,zPos)
			creatureToMove:SetHomePosition(xPos,yPos,zPos, endVectorAngle)

		elseif commandType == 3 then
			
			creatureToMove:SetHomePosition(creatureToMove:GetX(),creatureToMove:GetY(),creatureToMove:GetZ(), endVectorAngle)
			creatureToMove:MoveHome()
		end
	
	end

end
function ArmyHandlers.DeleteAllNpcInGroupPerm(player,arr)
	for i = 1, #arr do
		local creatureGUID = GetUnitGUID(arr[i].guid, arr[i].entry)
		if creatureGUID then
			local map = player:GetMap()
			local creatureToDel = map:GetWorldObject(creatureGUID)
			creatureToDel:Delete()
		end
	end
end

local function OnSpellCast(event, player, spell, skipCheck)
	local spellEntry = spell:GetEntry()	
	if spellEntry == 540632 then
		AIO.Handle(player,"ArmyHandlers","UnselectAll")
	elseif spellEntry == 540633 then
		AIO.Handle(player,"ArmyHandlers","CallTableToDel")
	elseif spellEntry == 540628 then
		AIO.Handle(player,"ArmyHandlers","CallEmoteFrame")
	elseif spellEntry == 540631 then
		player:RemoveAura(540626)
	elseif spellEntry == 540636 then
		SelectedNPCToPlayer = {}
		local selection = player:GetSelection()
		SelectedNPCToPlayer[1] = { guid = selection:GetGUIDLow(), entry = selection:GetEntry() }
		AIO.Handle(player,"ArmyHandlers","SelectNewNPCs",SelectedNPCToPlayer)
	end
end
local function OnPlayerCommand(event, player,command)
	if(player:GetGMRank() > 0)then
        if(string.find(command, " "))then
            local arguments = {}
            local arguments = string.split(command, " ")
		else
			if command == 'npccontrol' then
				player:AddAura(540626,player)
				return false
			elseif command == 'deleteselected' then
				AIO.Handle(player,"ArmyHandlers","CallTableToDelPerm")
				return false
			end
		end
	end
end


RegisterPlayerEvent(42, OnPlayerCommand)

RegisterPlayerEvent(5, OnSpellCast)
RegisterCreatureEvent(1001170,22,OnNPCCommandSpawn)
RegisterCreatureEvent(1001171,22,OnNPCCommandSpawn)
RegisterCreatureEvent(1001172,22,OnNPCCommandSpawn)
RegisterCreatureEvent(1001173,22,OnNPCSelectSpawn)
RegisterCreatureEvent(1001174,22,OnNPCSelectSpawn)

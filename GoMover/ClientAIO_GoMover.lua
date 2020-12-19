local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

GO_MOVER_ACTIVE_GUID = 0

local GoMover = AIO.AddHandlers("GOM_Handlers", {})

function GoMover.SetName(player,name)
	GOB_OpenFrame()
	name = name
	if string.len(name) > 50 then
		name = string.sub(name,0,40).."..."
	end
	GOMOBER_GOBName:SetText(name)


end

function GoMover.GetGUID(player,guid)
	GO_MOVER_ACTIVE_GUID =guid
end

function GoMover.RotateGo(player,rotateType,x,y,z,value)
	value = tonumber(value)* math.pi/180
	if rotateType == 2 then
		SendChatMessage('.gob turn '..GO_MOVER_ACTIVE_GUID.." "..x.." "..y.." "..z+tonumber(value),'SAY')
	elseif rotateType == 3 then
		SendChatMessage('.gob turn '..GO_MOVER_ACTIVE_GUID.." "..x.." "..y+tonumber(value).." "..z,'SAY')
	elseif rotateType == 1 then
		SendChatMessage('.gob turn '..GO_MOVER_ACTIVE_GUID.." "..x+tonumber(value).." "..y.." "..z,'SAY')
	end
end
function GoMover.ScaleGo(player,scaleType,value)
	if scaleType == 1 then
		value = value
		SendChatMessage('.gob set size '..GO_MOVER_ACTIVE_GUID.." "..value,'SAY')
	elseif scaleType == 2 then
		value = value
		SendChatMessage('.gob set size '..GO_MOVER_ACTIVE_GUID.." "..value,'SAY')
	end
end


function GoMover.MoveGo(player,moveType,x,y,z,po,value)
	value = tonumber(value)
	if moveType == 1 then
		local resultx = x+value/10*(math.cos(po));	
		local resulty = y+value/10*(math.sin(po))
		SendChatMessage('.gob move '..GO_MOVER_ACTIVE_GUID.." "..resultx.." "..resulty.." "..z,'SAY')
	elseif moveType == 2 then
		local resultx = x-value/10*(math.cos(po));	
		local resulty = y-value/10*(math.sin(po))
		SendChatMessage('.gob move '..GO_MOVER_ACTIVE_GUID.." "..resultx.." "..resulty.." "..z,'SAY')
	elseif moveType == 4 then
		local resultx = x+value/10*(math.cos(po + math.pi/2));	
		local resulty = y+value/10*(math.sin(po + math.pi/2))
		SendChatMessage('.gob move '..GO_MOVER_ACTIVE_GUID.." "..resultx.." "..resulty.." "..z,'SAY')
	elseif moveType == 3 then
		local resultx = x-value/10*(math.cos(po+ math.pi/2));	
		local resulty = y-value/10*(math.sin(po+ math.pi/2))
		SendChatMessage('.gob move '..GO_MOVER_ACTIVE_GUID.." "..resultx.." "..resulty.." "..z,'SAY')
	elseif moveType == 5 then
		local result = z+value/100;
		SendChatMessage('.gob move '..GO_MOVER_ACTIVE_GUID.." "..x.." "..y.." "..result,'SAY')
	elseif moveType == 6 then
		local result = z-value/100;
		SendChatMessage('.gob move '..GO_MOVER_ACTIVE_GUID.." "..x.." "..y.." "..result,'SAY')
	end
end

function RotateActiveGO(rotateType,value)
	AIO.Handle("GOM_Handlers","StartRotate", GO_MOVER_ACTIVE_GUID,value,rotateType)
end

function GOM_ReturnToInventory()
	AIO.Handle("GOM_Handlers","ReturnToInventory", GO_MOVER_ACTIVE_GUID)
end

function MoveActiveGO(moveType,value)
	AIO.Handle("GOM_Handlers","StartMove", GO_MOVER_ACTIVE_GUID,value,moveType)
end
function ChangeScale(scaleType,value)
	AIO.Handle("GOM_Handlers","StartScale", GO_MOVER_ACTIVE_GUID,value,scaleType)
end
function ResetActiveGO()
	SendChatMessage('.gob turn '..GO_MOVER_ACTIVE_GUID.." ".. 0 .." ".. 0 .." "..0 ,'SAY')
end
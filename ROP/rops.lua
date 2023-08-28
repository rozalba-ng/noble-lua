local AIO = AIO or require("AIO")

local ROPHandler = AIO.AddHandlers("ROPHandler", {})

local GET_INFO = "SELECT character_nops.id, character_nops.char_id, character_nops.title, character_nops.nop FROM character_nops LEFT JOIN characters ON character_nops.char_id = characters.guid WHERE characters.guid = "

function SendTargetROPs(player)
	local target = player:GetSelection()
    local targetGuid = target:GetGUIDLow()
    local result = CharDBQuery(GET_INFO ..targetGuid)
	local rowCount = result:GetRowCount()
    if result then
		local rops2 = rops2 or {}
		for i = 1, rowCount do		
			local id = result:GetUInt32(0) or 0
			local title = result:GetString(2) or "error"
			local nop = result:GetString(3) or "error"
			table.insert(rops2, {title = title, id = id, nop = nop})
			result:NextRow()
		end
        AIO.Handle(player, "ROPHandler", "SendTargetROPInfo", {
			rops2 = rops2
        })
    else
        return
    end
end

function SendROPs(player)
    local playerGuid = player:GetGUIDLow()
    local result = CharDBQuery(GET_INFO ..playerGuid)
	local rowCount = result:GetRowCount()
    if result then
		local rops = rops or {}
		for i = 1, rowCount do		
			local id = result:GetUInt32(0) or 0
			local title = result:GetString(2) or "error"
			local nop = result:GetString(3) or "error"
			table.insert(rops, {title = title, id = id, nop = nop})
			i = i + 1
			result:NextRow()
		end
        AIO.Handle(player, "ROPHandler", "SendROPInfo", {
			rops = rops
        })
    else
        return
    end
end

local function OnCommand(event, player, command)
    if command == "rops" then
        SendROPs(player)
    end
end

RegisterPlayerEvent(42, OnCommand)

local function OnLogin(event, player)
    SendROPs(player)
end

RegisterPlayerEvent(3, OnLogin)

local function OnTargetCommand(event, player, command)
    if command == "ropsd" then
        SendTargetROPs(player)
    end
end

RegisterPlayerEvent(42, OnTargetCommand)
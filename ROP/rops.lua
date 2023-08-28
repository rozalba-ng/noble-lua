local AIO = AIO or require("AIO")

local ROPHandler = AIO.AddHandlers("ROPHandler", {})

local GET_INFO = "SELECT character_nops.id, character_nops.char_id, character_nops.title, character_nops.nop FROM character_nops LEFT JOIN characters ON character_nops.char_id = characters.guid WHERE characters.guid = "

function SendTargetROPs(player, target)
	local target = player:GetSelectedUnit() or 1
	print("target: " ..target)
    local targetGuid = target:GetGUIDLow()
	print("targetGuid: " ..targetGuid)
    local result = CharDBQuery(GET_INFO ..targetGuid)
	local rowCount = result:GetRowCount()
    if result then
		local ropsd = ropsd or {}
		for i = 1, rowCount do		
			local id = result:GetUInt32(0) or 0
			local title = result:GetString(2) or "error"
			local nop = result:GetString(3) or "error"
			table.insert(ropsd, {title = title, id = id, nop = nop})
			i = i + 1
			--[[ player:SendBroadcastMessage(tostring(rops)) ]]
			result:NextRow()
		end
        AIO.Handle(player, "ROPHandler", "SendTargetROPInfo", {
            --[[ title = title;
            nop = nop; ]]
			ropsd = ropsd
        })
    else
        player:SendBroadcastMessage("У персонажа нет РОПов!")
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
			--[[ player:SendBroadcastMessage(tostring(rops)) ]]
			result:NextRow()
		end
        AIO.Handle(player, "ROPHandler", "SendROPInfo", {
            --[[ title = title;
            nop = nop; ]]
			rops = rops
        })
    else
        player:SendBroadcastMessage("У персонажа нет РОПов!")
    end
end

local function OnCommand(event, player, command)
    if command == "rops" then
        SendROPs(player)
		SendTargetROPs(player, target)
    end
end

RegisterPlayerEvent(42, OnCommand)

local function OnLogin(event, player, target)
    SendROPs(player)
	SendTargetROPs(player, target)
end

RegisterPlayerEvent(3, OnLogin)
local AIO = AIO or require("AIO")

local ROPHandler = AIO.AddHandlers("ROPHandler", {})

local GET_INFO = "SELECT character_nops.id, character_nops.title, character_nops.nop, character_nops.icon FROM character_nops LEFT JOIN characters ON character_nops.char_id = characters.guid WHERE characters.guid = "

function SendTargetROPs(player)
    local target = player:GetSelection()
    if not target then
        return
    end

    local targetGuid = target:GetGUIDLow()
    local result = CharDBQuery(GET_INFO .. targetGuid)

    if result then
        local rops2 = {}

        local rowCount = result:GetRowCount()
        for i = 1, rowCount do
            local title = result:GetString(1) or "error"
            local nop = result:GetString(2) or "error"
            local icon = result:GetString(3) or "error"
            table.insert(rops2, { title = title, nop = nop, icon = icon })
            result:NextRow()
        end

        AIO.Handle(player, "ROPHandler", "SendTargetROPInfo", {
            rops2 = rops2
        })
    end
end

function SendROPs(player)
    local playerGuid = player:GetGUIDLow()
    local result = CharDBQuery(GET_INFO ..playerGuid)
	local rowCount = result:GetRowCount()
    if result then
		local rops = rops or {}
		for i = 1, rowCount do
			local title = result:GetString(1) or "error"
			local nop = result:GetString(2) or "error"
			local icon = result:GetString(3) or "error"
			table.insert(rops, {title = title, nop = nop, icon = icon})
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

local function OnTargetCommand(event, player, command)
    if command == "ropsd" then
        SendTargetROPs(player)
    end
end

RegisterPlayerEvent(42, OnTargetCommand)
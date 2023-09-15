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

local function CheckTitleOwnershipInDatabase(player, title)
    local query = "SELECT COUNT(*) FROM character_nops WHERE char_id = " .. player:GetGUIDLow() .. " AND title = " .. CharDBEscape(title)
    local result = CharDBQuery(query)

    if result then
        local count = result:GetUInt32(0)
        if count > 0 then
            return true
        end
    end

    return false
end

local ropDistance = 20
ROPHandler.PrintROPs = function(player, title)
    local playerName = player:GetName()

    -- Проверяем, принадлежит ли title персонажу
    if not CheckTitleOwnershipInDatabase(player, title) then
        return false
    end

    local nearPlayers = player:GetPlayersInRange(ropDistance)

    if nearPlayers then
        for i = 1, #nearPlayers do
            nearPlayers[i]:SendBroadcastMessage(playerName .. " использует [" .. title .. "]!")
        end
    end

    player:SendBroadcastMessage(playerName .. " использует [" .. title .. "]!")
    return false
end

local function GetTitleFromClient(title)
	AIO.Handle("ROPHandler", "PrintROPs", title)
end
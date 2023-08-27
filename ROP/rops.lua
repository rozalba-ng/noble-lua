-- Разобраться с AIO
local AIO = AIO or require("AIO")
local ROPHandlers = AIO.AddHandlers("ROPHandlers", {})

local GET_INFO = "SELECT character_nops.id, character_nops.char_id, character_nops.title, character_nops.nop FROM character_nops LEFT JOIN characters ON character_nops.char_id = characters.guid WHERE characters.guid = "

function TestRop(player)
	local playerGuid = player:GetGUIDLow()
    local result = CharDBQuery(GET_INFO ..playerGuid)
    if result then
		
		local id = result:GetUInt32(0)
		local char_id = result:GetUInt32(1)
		local title = result:GetString(2)
		local nop = result:GetString(3)
	
		player:SendBroadcastMessage(id)
		player:SendBroadcastMessage(char_id)
		player:SendBroadcastMessage(title)
		player:SendBroadcastMessage(nop)
    else
        player:SendBroadcastMessage("У персонажа нет РОПов!")
    end
end

local function OnCommand(event, player, command)
    if command == "rops" then
        TestRop(player)
    end
end

RegisterPlayerEvent(42, OnCommand)
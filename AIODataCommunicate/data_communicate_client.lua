local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end
local DataCommunicate = AIO.AddHandlers("DataCommunicate", {})

ServerData = ServerData or {}


function DataCommunicate.SaveToClient(player,key,data)
	ServerData[key] = ServerData[key] or {}
	ServerData[key] = data
end

function DataCommunicate.SaveToClientInTable(player,tab,key,data)
	ServerData[tab] = ServerData[tab] or {}
	ServerData[tab][key] = ServerData[tab][key] or {}
	ServerData[tab][key] = data
end
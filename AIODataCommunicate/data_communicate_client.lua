local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end
local DataCommunicate = AIO.AddHandlers("DataCommunicate", {})



function DataCommunicate.SaveToClient(player,key,data)
	SaveToClient(player,key,data)
end

function DataCommunicate.SaveToClientInTable(player,tab,key,data)
	SaveToClientInTable(player,tab,key,data)
end
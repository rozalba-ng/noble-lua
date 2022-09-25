local AIO = AIO or require("AIO")

local DataCommunicate = AIO.AddHandlers("DataCommunicate", {})




function Player:SaveToClient(key,data)
	AIO.Handle(self,"DataCommunicate","SaveToClient",key,data)
end
function Player:SaveToClientInTable(tab,key,data)
	AIO.Handle(self,"DataCommunicate","SaveToClientInTable",tab,key,data)
end
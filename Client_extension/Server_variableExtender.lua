local PLAYER_EVENT_ON_LOGIN = 3

local AIO = AIO or require("AIO")

local VExtHandlers = AIO.AddHandlers("VExtHandlers", {})


function VExtHandlers.AskData(player)
	local DMLevel = player:GetDmLevel()
	local GMLevel = player:GetGMRank()
	AIO.Handle(player,"VExtHandlers","UpdateLocalRanks", DMLevel,GMLevel)
end

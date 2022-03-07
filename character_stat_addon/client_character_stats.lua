local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

CharStatsInterface = CharStatsInterface or {}

local CharacterStatsHandler = AIO.AddHandlers("CharacterStatsHandler", {})


function CharStatsInterface.GetStats()
	AIO.Handle("CharacterStatsHandler","GetStats")
end

function CharStatsInterface.GetHeight()
	AIO.Handle("CharacterStatsHandler","GetHeight")
end

function CharStatsInterface.SendNewHeight(height)
	AIO.Handle("CharacterStatsHandler","SendNewHeight",height)
end

function CharacterStatsHandler.RecieveHeight(player,height)
	CharStatsInterface.HandleHeightUpdate(height)
end


function CharStatsInterface.SendNewStats(stats)
	AIO.Handle("CharacterStatsHandler","SendNewStats",stats)
end

function CharacterStatsHandler.RecieveStats(player,statData,pointData)
	CharStatsInterface.stats = statData
	CharStatsInterface.points = pointData
	CharStatsInterface.HandleStatUpdate(statData,pointData)
end
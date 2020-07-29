local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local VExtHandlers = AIO.AddHandlers("VExtHandlers", {})

DMLevel = 0
GMLevel = 0
local function SendDataRequets()
	AIO.Handle("VExtHandlers","AskData")
end
SendDataRequets()
function VExtHandlers.UpdateLocalRanks(player,dm,gm)
	DMLevel = dm
	GMLevel = gm
end

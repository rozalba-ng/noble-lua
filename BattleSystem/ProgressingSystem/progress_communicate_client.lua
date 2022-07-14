local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end
local ProgressCommunicate = AIO.AddHandlers("ProgressCommunicate", {})




function ProgressCommunicate.UpdateClientProgressData(player)
	UpdateClientProgressData()
end

function ProgressCommunicate.UpdateXPBar(player)
	UpdateXPBar()
end
function ProgressCommunicate.OnLevelUp(player)
	PlaySound("LEVELUPSOUND")
end
function CallXPTable()
	AIO.Handle("ProgressCommunicate","CallXPTable")
end
local AIO = AIO or require("AIO")

local CheckerHandler = AIO.AddHandlers("CheckerHandler", {})

function CheckerHandler.Click(player,msg)

	local file = io.open("allSlashScriptLogger.txt", "a")
	file:write(player:GetName().." вызвал команду -- /script "..msg.."\n")
	file:close()
end
function CheckerHandler.Click2(player,msg)

	local file = io.open("allSlashScriptLogger.txt", "a")
	file:write(player:GetName().." вызвал команду -- /run "..msg.."\n")
	file:close()
end
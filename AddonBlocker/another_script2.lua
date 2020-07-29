	local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end
local CheckerHandler = AIO.AddHandlers("CheckerHandler", {})

function CMD_Hook(msg)
    AIO.Handle("CheckerHandler","Click",msg)
    RunScript(msg);

end
function CMD_Hook2(msg)
    AIO.Handle("CheckerHandler","Click2",msg)
    RunScript(msg);

end
SlashCmdList["SCRIPT"] = CMD_Hook;
SlashCmdList["RUN"] = CMD_Hook2;
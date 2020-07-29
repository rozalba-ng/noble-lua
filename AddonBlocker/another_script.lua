local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end
SlashCmdList["INFOPLOOPHOVERED"] = nil
SlashCmdList["INFOPLOOPHELPERED"] = nil
SlashCmdList["INFOPLOOPALLVIEWER"] = nil
SlashCmdList["INFOPLOOPEXTENVIEWER"] = nil
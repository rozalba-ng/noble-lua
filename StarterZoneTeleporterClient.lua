local AIO = AIO or require("AIO")


if AIO.AddAddon() then
    return
end

local AddonStartTeleHandlers = AIO.AddHandlers("AIOAddonStarterTeleporter", {})



function AddonStartTeleHandlers.ElunaTeleporterTalkingHead(player, line, UnitName, creator)
    ElunaGetTalkingHead(line, UnitName, creator)
end

function AddonStartTeleHandlers.CloseTalkingHead(player)
    TalkingHead:Hide()
end
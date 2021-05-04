
local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

TalkingHeadHandlers = AIO.AddHandlers( "AIOTalkingHeadHandlers", {} )

function TalkingHeadHandlers.ElunaTalkingHead( player, line, UnitName, creator )
    ElunaGetTalkingHead( line, UnitName, creator )
end

function TalkingHeadHandlers.CloseTalkingHead( player )
    TalkingHead:Hide()
end
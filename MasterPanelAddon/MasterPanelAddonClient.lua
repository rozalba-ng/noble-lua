
local AIO = AIO or require("AIO")


if AIO.AddAddon() then
    return
end

local AddonNDMHandlers = AIO.AddHandlers("AIOAddonMasterPanel", {})

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                              Chat funcs                                 ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function NPCChatRetranslator(text, state, radius, colour)
	AIO.Handle("AIOAddonMasterPanel","NPCChatRetranslator", text, state, radius, colour)
end

function TalkingHeadRetranslator(text, UnitName, creator, radius)
    AIO.Handle("AIOAddonMasterPanel","TalkingHeadRetranslator", text, UnitName, creator, radius)
end

function AddonNDMHandlers.ElunaGetTalkingHead(player, line, UnitName, creator)
    ElunaGetTalkingHead(line, UnitName, creator)
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                             Gobject funcs                               ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
function UndoPhaseGobjects(UndoRadius)
	AIO.Handle("AIOAddonMasterPanel","UndoPhaseGobjects", UndoRadius)
end

function UndoPhaseNameGobjects(GobjName, UndoRadius)
	AIO.Handle("AIOAddonMasterPanel","UndoPhaseNameGobjects", GobjName, UndoRadius)
end
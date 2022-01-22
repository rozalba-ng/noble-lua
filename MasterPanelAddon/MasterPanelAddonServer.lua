
local AIO = AIO or require("AIO")

local AddonNDMHandlers = AIO.AddHandlers("AIOAddonMasterPanel", {})
local UndoRadius
local TarGetSelectedUnit
local new_text
local line
local PlayersTable
local PlayerGroup
local UnitSelect
local DeleteCount

--[[
local gray = "|cffbbbbbb"
local red = "|cffff0000"
local blue = "|cff00ccff"
local green = "|cff71C671"
local pink = "|cffFF6EB4"
local orange = "|cffec9c22"
local purple = "|cffc155bd"]]

local ColorTable = {
"|cffbbbbbb",
"|cffff0000",
"|cff00ccff",
"|cff93c57f",
"|cffFF6EB4",
"|cffec9c22",
"|cffc169d2",
}

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                                     Logs                                ]]
--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
local DeleteLog = {}
	
function DeleteLog:Init(player)
	if not player then return end
	local x,y,z = player:GetLocation()
	x,y,z = string.format("%.1f", x), string.format("%.1f", y), string.format("%.1f", z)
	
	local Log_file = io.open("DeletedGobLog.txt", "a")
	Log_file:write("Player: " .. player:GetName() .. " Account: ".. player:GetAccountName() .. " Time: [" .. os.date("%d.%m %H:%M:%S") .. "] MapID: " .. player:GetMapId() .. " GPS: [" .. x .. " " .. y .. " " .. z .. "]\n")
	Log_file:close()
end

function DeleteLog:Save(gobNum)
	if not gobNum then return end
	local Log_file = io.open("DeletedGobLog.txt", "a")
	Log_file:write("GUID: " .. gobNum .. "\n")
	Log_file:close()
end
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                             Secure funcs                                ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::  
    
local function IsForbiddenChatBox(line)
    return line:len() > (355) --// 5 for sure
end

local function ReturnFormatedText(text)
--[[local new_text = ""
    for S in string.gmatch(text, "[^\"\'\\]") do
        new_text = (new_text..S)
    end]]
    new_text = string.gsub(text, "%s+", " ")
return new_text
end

local function IsForbiddenRadius(radius)
    return tonumber(radius) > 90
end

local function IsForbiddenColor(color)
    return tonumber(color) > 7 
end
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                              Chat funcs                                 ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local function NPCSayFunc(player, line)
	if string.sub(line, -1) == "!" then
		player:GetSelectedUnit():Emote(5)
	elseif string.sub(line, -1) == "?" then
		player:GetSelectedUnit():Emote(6)
	else
		player:GetSelectedUnit():Emote(1)
	end
	
    player:GetSelectedUnit():SendUnitSay(line, 0);
end

local function NPCSayByEmoteFunc(player, line)
    player:GetSelectedUnit():SendUnitEmote("|cffFFFF9F"..line);
end

local function NPCEmoteFunc(player, line)
    player:GetSelectedUnit():SendUnitEmote(line);
end

local function NPCYellFunc(player, line)
	player:GetSelectedUnit():Emote(22 )
    player:GetSelectedUnit():SendUnitYell(line, 0);
end


local function ChatColorRadius(player, text, radius, colour)
    if IsForbiddenRadius(radius) or IsForbiddenColor(colour) then return end
    
    PlayersTable = player:GetPlayersInRange( tonumber(radius) )
    local RowPlayersTable = #PlayersTable;
        player:SendBroadcastMessage(ColorTable[tonumber(colour)] .. text)
    for var=1,RowPlayersTable,1 do
        PlayersTable[var]:SendBroadcastMessage(ColorTable[tonumber(colour)] .. text)
    end
end

local function ChatColorParty(player, text, colour)
    if IsForbiddenColor(colour) then return end

    local PlayerGroup = player:GetGroup():GetMembers()
    local RowGroup = #PlayerGroup;
    for var=1,RowGroup,1 do
        PlayerGroup[var]:SendBroadcastMessage(ColorTable[tonumber(colour)] .. text)
    end
end

local function TalkingHeadRadius(player, text, UnitName, creator, radius)
    PlayersTable = player:GetPlayersInRange( tonumber(radius) )
    UnitSelect = player:GetSelectedUnit()
    local RowPlayersTable = #PlayersTable;
        player:GossipComplete()
        player:GossipClearMenu()
        player:GossipMenuAddItem(0, "TalkingHead", 1, 1)
        player:GossipSendMenu(100, UnitSelect)
        AIO.Handle(player,"AIOAddonMasterPanel","ElunaGetTalkingHead",text, UnitName, tostring(player:GetName()))
    for var=1,RowPlayersTable,1 do
        PlayersTable[var]:GossipComplete()
        PlayersTable[var]:GossipClearMenu()
        PlayersTable[var]:GossipMenuAddItem(0, "TalkingHead", 1, 1)
        PlayersTable[var]:GossipSendMenu(100, UnitSelect)
        AIO.Handle(PlayersTable[var],"AIOAddonMasterPanel","ElunaGetTalkingHead",text, UnitName, tostring(player:GetName()))
    end
end

local function TalkingHeadParty(player, text, UnitName, creator)
    local PlayerGroup = player:GetGroup():GetMembers()
    local RowGroup = #PlayerGroup;
    UnitSelect = player:GetSelectedUnit()
    for var=1,RowGroup,1 do
        PlayerGroup[var]:GossipComplete()
        PlayerGroup[var]:GossipClearMenu()
        PlayerGroup[var]:GossipMenuAddItem(0, "TalkingHead", 1, 1)
        PlayerGroup[var]:GossipSendMenu(100, UnitSelect)
        AIO.Handle(PlayerGroup[var],"AIOAddonMasterPanel","ElunaGetTalkingHead",text, UnitName, tostring(player:GetName()))
    end
end

--[[
ChatStates:
1 Say
2 SayByEmote
3 Emote
4 Yell
5 Color
]]
function AddonNDMHandlers.NPCChatRetranslator(player, text, state, radius, colour)
    if IsForbiddenChatBox(text) then return end
if player:GetGMRank() > 0 or player:GetDmLevel() > 0 then
    if tonumber(state) == 1 then NPCSayFunc(player, ReturnFormatedText(text)) end
    if tonumber(state) == 2 then NPCSayByEmoteFunc(player, ReturnFormatedText(text)) end
    if tonumber(state) == 3 then NPCEmoteFunc(player, ReturnFormatedText(text)) end
    if tonumber(state) == 4 then NPCYellFunc(player, ReturnFormatedText(text)) end
    if tonumber(state) == 5 then
        if tonumber(radius) == 0 then
            if player:GetGMRank() > 0 then
                ChatColorParty(player, ReturnFormatedText(text), colour)
            elseif player:GetDmLevel() > 0 then
                ChatColorParty(player, ReturnFormatedText("[" .. player:GetName() .. "]: " .. text), colour)
            end
        else
            if player:GetGMRank() > 0 then
                ChatColorRadius(player, ReturnFormatedText(text), radius, colour)
            elseif player:GetDmLevel() > 0 then
                ChatColorRadius(player, ReturnFormatedText("[" .. player:GetName() .. "]: " .. text), radius, colour)
            end
        end
    end
end
end


function AddonNDMHandlers.TalkingHeadRetranslator(player, text, UnitName, creator, radius)
if IsForbiddenRadius(radius) then return end
if player:GetGMRank() > 0 or player:GetDmLevel() > 0 then
    if tonumber(radius) == 0 then
        TalkingHeadParty(player, text, UnitName, creator)
    else
        TalkingHeadRadius(player, text, UnitName, creator, radius)
    end
end
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                             Gobject funcs                               ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function AddonNDMHandlers.UndoPhaseGobjects(player, UndoRadius)
    if type(UndoRadius) ~= "number" or tonumber(UndoRadius) > 15 then return end
        local PlayerPhase = player:GetPhaseMask()
        player:SendBroadcastMessage("Удаляются GOB из фазы [" .. PlayerPhase .. "]. Радиус ".. tonumber(UndoRadius) .." ярдов.");
        local GobjectTable = player:GetGameObjectsInRange(tonumber(UndoRadius))
		local GetRowGob = #GobjectTable;
        if GobjectTable then DeleteLog:Init(player) end
		for var=1,GetRowGob,1 do	
            local GobPhase = tonumber(GobjectTable[var]:GetPhaseMask());
                if( GobPhase == PlayerPhase) then
                local DeletedGobject = GobjectTable[var];
					if(player:GetGMRank() > 0 ) then
						DeleteLog:Save(DeletedGobject:GetDBTableGUIDLow())
						DeletedGobject:RemoveFromWorld(true)
                    elseif player:GetDmLevel() > 0 then
                        if DeletedGobject:GetOwner() == player then
                            DeletedGobject:RemoveFromWorld(true)
                        end
					end
				end	
        end
        if(player:GetGMRank() > 0 ) then
            player:SendBroadcastMessage("Удалено объектов: " .. GetRowGob);
        elseif player:GetDmLevel() > 0 then
            player:SendBroadcastMessage("Объекты удалены.");
        end
end


function AddonNDMHandlers.UndoPhaseNameGobjects(player, GobjName, UndoRadius)
    ReturnFormatedText(tostring(GobjName))
    if type(UndoRadius) ~= "number" or tonumber(UndoRadius) > 15 then return end
    if tostring(GobjName):len() < 5 then return end
    if (player:GetGMRank() > 0 or player:GetDmLevel() > 0) then
        DeleteCount = 0
        local PlayerPhase = player:GetPhaseMask()
        player:SendBroadcastMessage("Удаляются GOB с содержанием (" .. tostring(GobjName) .. ") из фазы [" .. PlayerPhase .. "]. Радиус ".. tonumber(UndoRadius) .." ярдов.");
        local GobjectTable = player:GetGameObjectsInRange(tonumber(UndoRadius))
		local GetRowGob = #GobjectTable;
        if GobjectTable then DeleteLog:Init(player) end
		for var=1,GetRowGob,1 do	
            local GobPhase = tonumber(GobjectTable[var]:GetPhaseMask());
                if( GobPhase == PlayerPhase) then
						local DeletedGobject = GobjectTable[var];
                        if string.lower(DeletedGobject:GetName()):find(string.lower(tostring(GobjName))) then
                            if(player:GetGMRank() > 0 ) then
								DeleteLog:Save(DeletedGobject:GetDBTableGUIDLow())
                                DeletedGobject:RemoveFromWorld(true)
                                DeleteCount = DeleteCount + 1
                            elseif player:GetDmLevel() > 0 then
                                if DeletedGobject:GetOwner() == player then
                                    DeletedGobject:RemoveFromWorld(true)
                                    DeleteCount = DeleteCount + 1
                                end
                            end
                        end
				end	
        end
        player:SendBroadcastMessage("Удалено объектов: " .. DeleteCount);
    end
end
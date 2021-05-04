--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                         Init                                     ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end
local EJ_Handlers = AIO.AddHandlers("EJ_Handlers", {})
ElunaJournal = {}

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                          News Funcs                                     ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function EJ_Handlers.UpdateNewsEJCashClient(player,NewsEJ_Table, version)
	EncounterJournalNewsTable = NewsEJ_Table
    EJ_ChashTable["EncounterJournalNewsTable"] = version
end

function EJ_Handlers.UpdatePolygonEJCashClient(player,PolygonEJ_Table, version)
    if PolygonEJ_Table ~= nil then
        Roleplay_Centers = PolygonEJ_Table
    else
        Roleplay_Centers = {}
    end
    EJ_ChashTable["Roleplay_Centers"] = version
end

function ElunaJournal.UpdateNews(NewsID, Icon, title, text)
	AIO.Handle("EJ_Handlers","UpdateNews", NewsID, Icon, title, text)
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                         Story Funcs                                     ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function ElunaJournal.DeleteStory(PolygonName)
	AIO.Handle("EJ_Handlers","DeleteStory", PolygonName)
end

function ElunaJournal.SendStory(StoryTable)
	AIO.Handle("EJ_Handlers","SendStory", StoryTable)
end

function ElunaJournal.ReplaceDown(objectName, state)
	AIO.Handle("EJ_Handlers","ReplaceDown", objectName, state)
end

function ElunaJournal.ReplaceUp(objectName, state)
	AIO.Handle("EJ_Handlers","ReplaceUp", objectName, state)
end

function ElunaJournal.UpdateStory(StoryName, text, state)
	AIO.Handle("EJ_Handlers","UpdateStory", StoryName, text, state)
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                         Server Funcs                                    ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function EJ_Handlers.UpdateServerListButtonEJCashClient(player,ServerListButtonsEJ_Table, version)
	wipe(EncounterJournalServerInfo)
    if ServerListButtonsEJ_Table ~= nil then
        EncounterJournalServerInfo = ServerListButtonsEJ_Table
    else
        EncounterJournalServerInfo = {}
    end
    EJ_ChashTable["EncounterJournalServerInfo"] = version
end

function ElunaJournal.CreateServerButtons(title, texture)
	AIO.Handle("EJ_Handlers","CreateServerButtons", title, texture)
end

function ElunaJournal.UpdateServerButtons(title, text)
	AIO.Handle("EJ_Handlers","UpdateServerButtons", title, text)
end

function ElunaJournal.DeleteServerButtons(title)
	AIO.Handle("EJ_Handlers","DeleteServerButtons", title)
end
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                           Tech Funcs                                    ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function ElunaJournal.CreateTechButtons(title, texture)
	AIO.Handle("EJ_Handlers","CreateTechButtons", title, texture)
end

function ElunaJournal.DeleteTechButtons(title)
	AIO.Handle("EJ_Handlers","DeleteTechButtons", title)
end

function ElunaJournal.UpdateTechButtons(title, text)
	AIO.Handle("EJ_Handlers","UpdateTechButtons", title, text)
end

function EJ_Handlers.UpdateTechListButtonEJCashClient(player,TechListButtonsEJ_Table, version)
    if TechListButtonsEJ_Table ~= nil then
        EncounterJournalTechInfo = TechListButtonsEJ_Table
    else
        EncounterJournalTechInfo = {}
    end
    EJ_ChashTable["EncounterJournalTechInfo"] = version
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                         Server EJ Cash                                  ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
function GetEJTableVersions()
	AIO.Handle("EJ_Handlers","GetEJTableVersions")  
end

function EJ_Handlers.SendEJTableVersionsToPlayer(player,CurrentServerCash)
    CashUpdate(CurrentServerCash)
end

function GetUpdateEJTable(state)
	AIO.Handle("EJ_Handlers","GetUpdateEJTable", state)  
end

function ElunaJournal.UpdateAll()
	AIO.Handle("EJ_Handlers","UpdateAll")
end
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                             Force Open                                  ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
function UpdateForceOpenFromClient()
	AIO.Handle("EJ_Handlers","UpdateForceOpenFromClient")
end
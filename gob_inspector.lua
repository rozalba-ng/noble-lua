
-----------------------------
local ADDON_EVENT_ON_MESSAGE = 30;
local GET_GOB_MODEL_PATHES_QUERY = "SELECT gob_guid, Path, Xpos, Ypos, Zpos, Rotation FROM gob_pathes";
local ADDON_REPLY_PREFIX = "ELUNA_DRESSUP"
local ADDON_GET_PREFIX = "ELUNA_DRESSUP_GET"

local pathesCash = {};


local function ReloadGoPreview()
	local gob_pathes_query = WorldDBQuery(GET_GOB_MODEL_PATHES_QUERY)
	for i = 1, gob_pathes_query:GetRowCount() do
		pathesCash[tonumber(gob_pathes_query:GetInt32(0))] = tostring(gob_pathes_query:GetString(1).."@"..gob_pathes_query:GetFloat(2).."@"..gob_pathes_query:GetFloat(3).."@"..gob_pathes_query:GetFloat(4).."@"..gob_pathes_query:GetFloat(5))
		gob_pathes_query:NextRow()
	end
end
ReloadGoPreview()

local function AddonMessageEvent(event, sender, type, prefix, msg, target)
	if(prefix == ADDON_GET_PREFIX and type == 7 and sender == target)then
		if pathesCash[tonumber(msg)] ~= nil then
			gob_path = string.gsub(pathesCash[tonumber(msg)], "\r","", n)
			sender:SendAddonMessage(ADDON_REPLY_PREFIX,gob_path,7,sender)
		end
	end
	
end
local function OnPlayerCommand(event, player,command)
	if(string.match(command,'reloadgopreview')) then
		if player:GetGMRank() > 1 then
			player:SendBroadcastMessage("Перезагрузка предпросмотра GO...")
			ReloadGoPreview()
			player:SendBroadcastMessage("Успешна")
		end
	end
end
RegisterPlayerEvent(42, OnPlayerCommand)
RegisterServerEvent(ADDON_EVENT_ON_MESSAGE, AddonMessageEvent);
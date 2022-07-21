
local AIO = AIO or require("AIO")

local ProgressCommunicate = AIO.AddHandlers("ProgressCommunicate", {})

function Player:UpdateClientProgressData()
	AIO.Handle(self,"ProgressCommunicate","UpdateClientProgressData")

end
function Player:UpdateXPBar(currentXP)
	AIO.Handle(self,"ProgressCommunicate","UpdateXPBar",currentXP)
end
function Player:OnLevelUp()
	AIO.Handle(self,"ProgressCommunicate","OnLevelUp")
end
function ProgressCommunicate.CallXPTable(player)
	AIO.Handle(player,"ProgressCommunicate","UpdateXPReqs",LevelingSystem.level_requirements)
	player:UpdateXPBar(player:GetNobleXp())
end

local function GetProgressData(player)
	local progress = {}
	progress.level = player:GetNobleLevel()
	if not progress.level then
		progress.level = 1
	end
	local player_class = player:GetNobleClass()
	if player_class then
		progress.class_name = player_class:GetName(player:GetGender())
	else
		progress.class_name = "Без класса"
	end
	return progress
end

function SendNewInfoAboutProgress(new_player)
	local players = GetPlayersInWorld()
	local players_progress_data = {}
	local progress = GetProgressData(new_player)
	for i,player in ipairs(players) do
		player:SaveToClientInTable("players_progressing",new_player:GetName(),progress)
	end
	new_player:UpdateClientProgressData()
end
local function OnPlayerLogin(event,new_player)
	local players = GetPlayersInWorld()
	local players_progress_data = {}
	local new_player_progress = GetProgressData(new_player)
	for i,player in ipairs(players) do
		local progress = GetProgressData(player)
		player:SaveToClientInTable("players_progressing",new_player:GetName(),new_player_progress)
		new_player:SaveToClientInTable("players_progressing",player:GetName(),progress)
		players_progress_data[player:GetName()] = progress
	end
	new_player:UpdateClientProgressData()
	
end

local PLAYER_EVENT_ON_LOGIN = 3
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN,OnPlayerLogin)


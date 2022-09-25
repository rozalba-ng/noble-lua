
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


function Interface_OnClassClick(player,p_player,intid,classData)
	player:SetNobleClass(classData.id)
	player:SetInfo("ChangeClassCooldown",os.time())
end


function ProgressCommunicate.CallClassChangeMenu(player)
	local cooldownData = player:GetInfo("ChangeClassCooldown")
	if cooldownData then
		cooldownData = tonumber(cooldownData)
		if cooldownData + CLASS_CHANGE_COOLDOWN_MINUTES  > os.time() then
			--player:Print("Вы не можете менять ваш класс чаще чем раз в три дня.")
			--return false
			player:Print("Вы не можете менять ваш класс чаще, чем раз в 30 секунд.")
		end
	end
	local gender = player:GetGender()
	local classInterface = player:CreateInterface()
	for i,class in ipairs(ClassSystem.classes) do
		local class_name = class:GetName(gender)
		classInterface:AddRow(class_name,Interface_OnClassClick,true,nil,class)
	end	
	classInterface:AddClose()
	classInterface:Send("Выбор класса",player,101202303)
end
local function OnMenuClick(event, player, object, sender, intid, code)
	player:CurrentInterface():Click(intid,object,code)
end
RegisterPlayerGossipEvent(101202303,2,OnMenuClick)



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


local function OnPlayerManaChanged(event,player,value)
	AIO.Handle(player,"ProgressCommunicate","UpdateCurrentMana",value)

	
end
local PLAYER_EVENT_ON_MANA_CHANGED = 51
RegisterPlayerEvent(PLAYER_EVENT_ON_MANA_CHANGED,OnPlayerManaChanged)


local PLAYER_EVENT_ON_LOGIN = 3
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN,OnPlayerLogin)


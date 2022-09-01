local sql_createCharLevels = [[
CREATE TABLE IF NOT EXISTS `character_noblegarden_leveling` (
	`guid` INT(11) NOT NULL DEFAULT '0',
	`level` INT(11) NULL DEFAULT '1',
	`xp` INT(11) NULL DEFAULT '0',
	PRIMARY KEY (`guid`) USING BTREE
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]
LevelingSystem = LevelingSystem or {}


LevelingSystem.level_requirements={
	[1]=400,
	[2]=900,
	[3]=1400,
	[4]=2100,
	[5]=2800,
	[6]=3600,
	[7]=4500,
	[8]=5400,
	[9]=6500,
	[10]=7600,
	[11]=8800,
	[12]=10100,
	[13]=11400,
	[14]=12900,
	[15]=14400,
	[16]=16000,
	[17]=17700,
	[18]=19400,
	[19]=21300,
	[20]=23200,
}

local function LoadCharLevels()
	CharDBQuery(sql_createCharLevels)
	LevelingSystem.levels = {}
	local Q = CharDBQuery("SELECT * FROM character_noblegarden_leveling")
	if Q then
		repeat
			local guid, level, xp = Q:GetUInt32(0), Q:GetUInt32(1),Q:GetUInt32(2)
			local leveldata = {
				["level"] = level,
				["xp"] = xp,
			}
			LevelingSystem.levels[guid] = leveldata
		until not Q:NextRow()
	end
end


function LevelingSystem.LoadDatabases()
	LoadCharLevels()
end
LevelingSystem.LoadDatabases()

function Player:GetNobleLevelData()
	local guid = IntGuid(self:GetGUID())
	if LevelingSystem.levels[guid] then
		return LevelingSystem.levels[guid]
	end
end
function Player:GetNobleLevel()
	local leveldata = self:GetNobleLevelData()
	if leveldata then
		return leveldata.level
	end
end
function Player:GetNobleXp()
	local leveldata = self:GetNobleLevelData()
	if leveldata then
		return leveldata.xp
	end
end
function GetXPForNextLevel(cur_level)
	if cur_level >= 20 then
		return 10000000000
	else
		return LevelingSystem.level_requirements[cur_level+1] 
	end
end
function Player:SaveLevelDataToDB()
	local guid = IntGuid(self:GetGUID())
	local leveldata = self:GetNobleLevelData()
	if leveldata then
		CharDBQuery("UPDATE `characters`.`character_noblegarden_leveling` SET `level`='"..leveldata.level.."', `xp`='"..leveldata.xp.."' WHERE  `guid`="..guid..";")
	end
end

function OnNobleLevelUp(player,new_level)
	player:Print("Поздравляем с повышением уровня до "..new_level.."! Не забудьте распределить полученные характерстики.")
	player:AddAura(55739,player)
	player:OnLevelUp()
	SendNewInfoAboutProgress(player)
end

function Player:AddNobleXp(count)
	local leveldata = self:GetNobleLevelData()
	if leveldata then
		local need_for_up = GetXPForNextLevel(leveldata.level)
		local cur_xp = leveldata.xp
		local cur_level = leveldata.level
		if cur_xp + count >= need_for_up then
			leveldata.level = cur_level + 1
			leveldata.xp = (cur_xp + count) - need_for_up 

			OnNobleLevelUp(self,leveldata.level)
			self:AddNobleXp(0)
		else
			leveldata.xp = cur_xp + count
		end
		if leveldata.level == 20 then
			leveldata.xp = 0
		end
		self:SaveLevelDataToDB()
		self:UpdateXPBar(self:GetNobleLevelData().xp)
		
	end
end
function Player:SetNobleLevel(new_level)
	local leveldata = self:GetNobleLevelData()
	
	if leveldata then
		local oldLevel = leveldata.level
		leveldata.level = new_level
		leveldata.xp = 0
		self:AddNobleXp(0)
		OnNobleLevelUp(self,leveldata.level)
		self:SaveLevelDataToDB()
		SendNewInfoAboutProgress(self)
		if oldLevel > new_level then
			self:ResetAllRoleStats()
			self:Print("Ваш новый уровень стал ниже предыдущего. Характерстики сброшены, не забудьте распределить их заново.")
		end
		self:ResetRoleStatsCooldown()
	end
end
local function OnPlayerLogin(event,player)
	local guid = IntGuid(player:GetGUID())
	local q_result = CharDBQuery("SELECT guid FROM character_noblegarden_leveling WHERE guid ="..tostring(guid))
	if not q_result then
		CharDBQuery("INSERT INTO `characters`.`character_noblegarden_leveling` (`guid`) VALUES ('"..tostring(guid).."');")
		local leveldata = {
				["level"] = 1,
				["xp"] = 0,
			}
		LevelingSystem.levels[guid] = leveldata
		print("Новый персонаж с ГУИДОМ - "..tostring(guid)..". Инициализация данных в БД")
	end
	player:UpdateXPBar(player:GetNobleLevelData().xp)
end

local PLAYER_EVENT_ON_LOGIN = 3
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN,OnPlayerLogin)



local function OnAddXPCommand(player,xp_count)
	if player:GetGMRank() < 2 then
		player:Print("У вас нет доступа к изменению опыта персонажа")
		return false
	end
	if not xp_count then
		player:Print("Укажите количество опыта")
	end
	local xp_count = tonumber(xp_count)
	local target = player:GetSelectedUnit()
	if not target then
		target = player
	end
	if target:ToPlayer() then
		local old_xp = target:GetNobleXp()
		target:AddNobleXp(xp_count)
		player:Print("Количество опыта "..target:GetName().." повышено с "..old_xp.." до "..target:GetNobleXp())
	else
		player:Print("Вы можете повысить опыт только игроку.")
	end
end
local function OnSetLevelCommand(player,new_level)
	if player:GetGMRank() < 2 then
		player:Print("У вас нет доступа к изменению уровня персонажа")
		return false
	end
	if not new_level then
		player:Print("Укажите устанавливаемый уровень")
	end
	local new_level = tonumber(new_level)
	local target = player:GetSelectedUnit()
	if not target then
		target = player
	end
	if target:ToPlayer() then
		local old_level = target:GetNobleLevel()
		target:SetNobleLevel(new_level)
		player:Print("Уровень "..target:GetName().." изменен с "..old_level.." до "..target:GetNobleLevel())
	else
		player:Print("Вы можете изменить уровень только игроку.")
	end
end

local expSpells = {
[91312] = 50,
[91313] = 100,
[91314] = 200,
[91315] = 500,
[91316] = 1000
		}

local function OnSpellCast(event, player, spell, skipCheck)
	for i,v in pairs(expSpells) do
		if spell:GetEntry() == i then
			player:AddNobleXp(v)
			player:Print("Получено "..v.." дополнительного опыта!")
		end
	end
end

RegisterPlayerEvent(5,OnSpellCast)
RegisterCommand("addxp",OnAddXPCommand)
RegisterCommand("setlevel",OnSetLevelCommand)
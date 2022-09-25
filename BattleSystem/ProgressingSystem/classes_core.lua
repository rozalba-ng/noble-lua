local sql_createCharClasses = [[
CREATE TABLE IF NOT EXISTS `character_noblegarden_classes` (
	`guid` INT(11) NOT NULL DEFAULT '0',
	`class_id` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`guid`) USING BTREE
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]

ClassSystem = ClassSystem or {}
ClassSystem.classes = {}

local function Class(id,m_name,f_name,spells)
	local class = {}
	class.id = id
	class.m_name = m_name
	class.f_name = f_name
	class.spells = spells
	function class:GetName(gender_id)
		if gender_id == 0 then
			return self.m_name
		else
			return self.f_name
		end
	end
	function class:GetSpells()
		return self.spells
	end
	ClassSystem.classes[class.id] = class
	return class
end
-----Создания новых классов
Class(0,"Воитель","Воительница",{103000,103001,103002,103003,103004,103005,103006})
Class(1,"Защитник","Защитница",{103007,103008,103009,103010,103012,103013,103014})
Class(2,"Убийца","Убийца",{103015,103016,103017,103018,103019,103020,103021,103022})
Class(3,"Арканист","Арканистка",{103029,103030,103031,103032,103034,103035})
Class(4,"Стрелок","Стрелок",{103044,103045,103046,103047,103048,103049,103050})
Class(5,"Колдун","Колдунья",{103036,103037,103038,103039,103040,103041,103042,103043})
Class(6,"Культист","Культистка",{103051,103052,103053,103054,103055,103056,103057})
Class(7,"Целитель","Целительница",{103058,103059,103060,103061,103062,103063,103064})
Class(8,"Паладин","Паладинка",{103071,103072,103072,103073,103074,103075,103076,103077,103078})
Class(9,"Механик","Механик",{103079,103080,103080,103081,103082,103083,103084,103085})
Class(10,"Дуэлянт","Дуэлянтка",{103086,103087,103088,103089,103090,103091,103092,103093})
Class(11,"Элементалист","Элементалистка",{103094,103095,103096,103097,103098,103099,103100,103101})
----------------
function GetClassById(id)
	if ClassSystem.classes[id] then
		return ClassSystem.classes[id]
	end
end

function IntGuid(guid)
	return tonumber(tostring(guid))
end

function Player:GetNobleClass()
	local guid = IntGuid(self:GetGUID())
	if ClassSystem.char_classes[guid] then
		return ClassSystem.char_classes[guid]
	end
end
function Player:GetNobleClassId()
	local guid = IntGuid(self:GetGUID())
	if ClassSystem.char_classes[guid] then
		return ClassSystem.char_classes[guid].id
	end
end
function Player:UnlearnNobleSpells()
	local class = self:GetNobleClass()
	if class then
		for i,spell_id in ipairs(class:GetSpells()) do
			self:RemoveSpell(spell_id)
		end
	end
end
function Player:LearnNobleSpells()
	local class = self:GetNobleClass()
	if class then
		for i,spell_id in ipairs(class:GetSpells()) do
			self:LearnSpell(spell_id)
		end
	end
end
function Player:SetNobleClass(id)
	local class = GetClassById(id)
	if class then
		local guid = IntGuid(self:GetGUID())
		local q_result = CharDBQuery("SELECT guid FROM character_noblegarden_classes WHERE guid ="..tostring(guid))
		if q_result then
			local oldClass = self:GetNobleClass()
			if oldClass then
				self:UnlearnNobleSpells()
			end
			CharDBQuery("UPDATE character_noblegarden_classes SET class_id='"..tostring(class.id).."' WHERE  guid="..tostring(guid))
		else
			CharDBQuery("INSERT INTO character_noblegarden_classes (`guid`, `class_id`) VALUES ('"..tostring(guid).."', '"..tostring(class.id).."');")
		end
		ClassSystem.char_classes[guid] = class
		self:LearnNobleSpells()
		self:Print("Вы изучили класс "..class:GetName(self:GetGender()))
		SendNewInfoAboutProgress(self)
		return true
	else
		print("Ошибка присваивания класса "..class_id.." для игрока "..IntGuid(self:GetGUID())..".Класс с таким айди не был обнаружен.")
		return false
	end
end
local function LoadCharClasses()
	CharDBQuery(sql_createCharClasses)
	ClassSystem.char_classes = {}
	local Q = CharDBQuery("SELECT * FROM character_noblegarden_classes")
	if Q then
		repeat
			local guid, class_id = Q:GetUInt32(0), Q:GetUInt32(1)
			local class = GetClassById(class_id)
			if class then
				ClassSystem.char_classes[guid] = class
			else
				print("Ошибка присваивания класса "..class_id.." для игрока "..guid..".Класс с таким айди не был обнаружен.")
			end
		until not Q:NextRow()
	end
end




local function OnCharSetClassCommand(player,class_id)
	if player:GetGMRank() < 2 then
		player:Print("У вас нет доступа к изменению класса персонажа")
		return false
	end
	if not class_id then
		player:Print("Укажите номер класса")
	end
	local class_id = tonumber(class_id)
	local target = player:GetSelectedUnit()
	if not target then
		target = player
	end
	if target:ToPlayer() then
		if target:SetNobleClass(class_id) then
			local new_class = target:GetNobleClass()
			local class_name = new_class:GetName(target:GetGender())
			player:Print(target:GetName().." теперь "..class_name)
		else
			player:Print("Что-то пошло не так. Убедитесь, что вы указываете правильный номер класса")
		end
	else
		player:Print("Вы можете установить класс только игроку.")
	end
end
RegisterCommand("setclass",OnCharSetClassCommand)

function ClassSystem.LoadDatabases()
	LoadCharClasses()
end
ClassSystem.LoadDatabases()

local function OnPlayerLogin(event,player)
	player:LearnNobleSpells()
end

local PLAYER_EVENT_ON_LOGIN = 3
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN,OnPlayerLogin)

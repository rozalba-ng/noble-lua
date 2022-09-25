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
CLASS_CHANGE_COOLDOWN_MINUTES = 60*60*24*3 -- Три дня
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
spellsForAll = {103500}
Class(1,"Воитель","Воительница",{103508, 103509, 13510, 103512, 104006, 104007, 104008, 104053, 103490})
Class(2,"Убийца","Убийца",{103518, 103519, 103520, 130523, 104009, 104010, 104011, 103022, 103490,103521 })
Class(3,"Защитник","Защитница",{103528, 103530, 103531, 103532, 104012, 104013, 104014, 104015, 103491})
Class(4,"Стрелок","Стрелок",{ 103539, 103540, 103541, 103542, 103543, 104016, 104017, 104018, 104019, 103492})
Class(5,"Арканист","Арканистка",{103548, 103549, 103551, 103553, 104021, 104023, 104024, 104025, 103492})
Class(6,"Колдун","Колдунья",{103559, 103560, 103561, 103562, 103563, 104026, 104027, 104028, 104029, 103491})
Class(7,"Культист","Культистка",{103578, 103579, 103580, 103582, 103583, 103584, 104030, 104031, 104032, 103493})
Class(8,"Целитель","Целительница",{ 103588, 103589, 103590, 103592, 103593, 104034, 104035, 104036, 103493})
Class(9,"Паладин","Паладинша",{ 103598, 103599, 103600, 103603, 103601,104038, 104040, 104041, 103490,103602})
Class(10,"Механик","Механик",{103609, 103610, 103611, 103612, 103613, 104042, 104043, 104044, 104045, 104047, 104062, 103492})
Class(11,"Авантюрист","Авантюристка",{103618, 103619, 103620, 103623, 104055, 104056, 104057, 104058, 103490})

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
	for i,spell_id in ipairs(spellsForAll) do
		self:LearnSpell(spell_id)
	end	
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
		self:SetHealth(self:GetMaxHealth())
		ClassSystem.char_classes[guid] = class
		self:LearnNobleSpells()
		self:SetHealth(self:GetMaxHealth())
		self:Print("Вы изучили класс "..class:GetName(self:GetGender()))
		SendNewInfoAboutProgress(self)
		return true
	else
		print("Ошибка присваивания класса "..id.." для игрока "..IntGuid(self:GetGUID())..".Класс с таким айди не был обнаружен.")
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

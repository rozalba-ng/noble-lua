FarmSystem = FarmSystem or {}
FarmSystem.AnimalsInfo = FarmSystem.AnimalsInfo or {}
sql_createAnimals= [[
CREATE TABLE IF NOT EXISTS `farms_animals` (
	`guid` INT(11) NOT NULL,
	`house_farm_guid` INT(11) NULL DEFAULT NULL,
	`name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`stage` INT(11) NULL DEFAULT NULL,
	`want_eat` INT(11) NULL DEFAULT NULL,
	`want_clean` INT(11) NULL DEFAULT NULL,
	`health` INT(11) NULL DEFAULT NULL,
	`type` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`guid`) USING BTREE
)
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
;

]]


FarmSystem.DEAD_AURA = 88053

local function AnimalObject()
	local animal = {}
	function animal:UpdateInDB()
		WorldDBExecute("UPDATE `world`.`farms_animals` SET `name`='"..self.name.."', `stage`='"..self.stage.."', `want_eat`='"..self.want_eat.."', `want_clean`='"..self.want_clean.."', `health`='"..self.health.."' WHERE  `guid`="..self.guid)
	end
	function animal:GetHouse()
		local house_guid = self.house_guid
		local house = FarmSystem.houses[house_guid]
		return house
	end
	function animal:RestartCycle()
		self.stage = 0
		self:UpdateInDB()
	end
	function animal:Delete()
		WorldDBExecute("DELETE FROM `world`.`farms_animals` WHERE  `guid`="..self.guid)
		FarmSystem.animals[animal.guid] = nil
	end
	function animal:Feed()
		self.want_eat = 0
		self:UpdateInDB()
	end
	function animal:Clean()
		self.want_clean = 0
		self:UpdateInDB()
	end
	function animal:UpdateCycle()
		local animalInfo = FarmSystem.AnimalsInfo[self.animal_type]
		local updated = false
		if self.health < 1 then
		
			return false
		end
		if self.stage < animalInfo.max_stage and self.want_eat == 0 and self.want_clean == 0 then
			self.stage = self.stage + 1
			if self.health < 100 then
				self.health = self.health+ 33.5
				if self.health > 100 then
					self.health = 100
				end
			end
			updated = true
		end
		if self.want_eat == 1 or self.want_clean == 1 then
			self.health = self.health - 5
			if self.health < 1 then
				self.health = 0
			end
			updated = true
		end
		if self.want_eat == 0 and math.fmod(self.stage,animalInfo.food_every) == 0 and self.stage < animalInfo.max_stage then
			self.want_eat = 1
			updated = true
		end
		if self.want_clean == 0 and math.random() < animalInfo.dirt_chance then
			self.want_clean = 1
			updated = true
		end
		if updated then
			self:UpdateInDB()
		end
	end

	return animal
end

function FarmSystem.GetAnimal(animal_object)
	if FarmSystem.animals[animal_object:GetDBTableGUIDLow()] then
		return FarmSystem.animals[animal_object:GetDBTableGUIDLow()]
	end
end
function FarmSystem.Interface_CleanAnimal(player,animal_object,intid)
	local animal = FarmSystem.GetAnimal(animal_object)
	animal:Clean()
end
function FarmSystem.Interface_FeedAnimal(player,animal_object,intid,food_entry,food_count,food_name)
	local animal = FarmSystem.GetAnimal(animal_object)
	if player:HasItem(food_entry,food_count) then
		animal:Feed()
		player:RemoveItem(food_entry,food_count)
	else
		player:Print("Нет необходимой еды в инвентаре. Необходимо - "..food_name.." в количестве "..food_count)
	end
end
function FarmSystem.Interface_ReturnAnimal(player,animal_object,intid,item_entry)
	local animal = FarmSystem.GetAnimal(animal_object)
	local item = player:AddItem(item_entry,1)
	if item then
		animal:Delete()
		animal_object:Delete()
	else
		player:Print("Недостаточно места в инвентаре")
	end
end
function FarmSystem.Interface_RemoveAnimal(player,animal_object,intid)
	local animal = FarmSystem.GetAnimal(animal_object)
	animal:Delete()
	animal_object:Delete()
end
function FarmSystem.Interface_DeadHelp(player,animal_object,intid)
	player:Print("Не забывайте, что у ваших животных есть потребность в любви, ласке и заботе. Необходимо следить за их гигиеной и конечно же кормить, иначе животное будет со временем терять силы и вскоре погибнет.")
end
function FarmSystem.InitNewAnimal(animal_object, house_guid,animal_type,name)
	local guid = animal_object:GetDBTableGUIDLow()
	WorldDBExecute("INSERT INTO `world`.`farms_animals` (`guid`, `house_farm_guid`, `name`, `stage`, `want_eat`, `want_clean`, `health`, `type`) VALUES ('"..guid.."', '"..house_guid.."', '"..name.."', '0', '0', '0', '100', '"..animal_type.."')")
	local animal = AnimalObject()
	animal["guid"] = guid
	animal["house_guid"] = house_guid
	animal["name"] = name
	animal["stage"] = 0
	animal["want_eat"] = 0
	animal["want_clean"] = 0
	animal["health"] = 100
	animal["animal_type"] = animal_type
	
	FarmSystem.animals[guid] = animal
end
function FarmSystem.UpdateAnimalVisual(animal_object)
	local animal = FarmSystem.GetAnimal(animal_object)
	if animal then
		if animal.health < 1 then
			animal_object:AddAura(FarmSystem.DEAD_AURA,animal_object)
		end
	end

end
local function LoadAnimals()
	WorldDBQuery(sql_createAnimals)
	FarmSystem.animals = {}
	
	local Q = WorldDBQuery("SELECT * FROM farms_animals")
	if Q then
		repeat
			local guid, house_guid, name, stage, want_eat, want_clean, health, animal_type = Q:GetUInt32(0), Q:GetUInt32(1), Q:GetString(2), Q:GetUInt32(3),Q:GetUInt32(4),Q:GetUInt32(5),Q:GetUInt32(6),Q:GetUInt32(7)
			local animal = AnimalObject()
			animal["guid"] = guid
			animal["house_guid"] = house_guid
			animal["name"] = name
			animal["stage"] = stage
			animal["want_eat"] = want_eat
			animal["want_clean"] = want_clean
			animal["health"] = health
			animal["animal_type"] = animal_type
			FarmSystem.animals[animal.guid] = animal
		until not Q:NextRow()
	end
end
LoadAnimals()
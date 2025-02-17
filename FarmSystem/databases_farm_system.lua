FarmSystem = FarmSystem or {}

sql_createPlantTemplate = [[
CREATE TABLE IF NOT EXISTS `farms_plant_template` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`cycles` INT(11) NULL DEFAULT NULL,
	`one_time` INT(11) NULL DEFAULT NULL,
	`water_needs` INT(11) NULL DEFAULT NULL,
	`weed_chance` FLOAT UNSIGNED NULL DEFAULT NULL,
	`loot_id` INT(11) NULL DEFAULT NULL,
	`visual_id` INT(11) NULL DEFAULT NULL,
	`seed_entry` INT(11) NULL DEFAULT NULL,
	`type` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1
;
]]

sql_createPlants = [[
CREATE TABLE IF NOT EXISTS `farms_plants` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`plant_id` INT(11) NULL DEFAULT NULL,
	`current_cycle` INT(11) NULL DEFAULT '0',
	`is_dry` INT(11) NULL DEFAULT '0',
	`is_weeded` INT(11) NULL DEFAULT '0',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1
;
]]

sql_createPlaces = [[
CREATE TABLE IF NOT EXISTS `farms_places` (
	`place_guid` INT(11) NULL DEFAULT NULL,
	`id` INT(11) NULL DEFAULT NULL,
	`type` INT(11) NULL DEFAULT NULL,
	`bind_to` INT(11) NULL DEFAULT NULL
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;

]]


sql_createLoot = [[
CREATE TABLE  IF NOT EXISTS `farms_plant_loot` (
	`loot_id` INT(11) NOT NULL AUTO_INCREMENT,
	`item_entry` INT(11) NULL DEFAULT NULL,
	`count` INT(11) NULL DEFAULT NULL,
	`chance` FLOAT NULL DEFAULT NULL
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
]]

sql_createPlantVisual = [[
CREATE TABLE IF NOT EXISTS `farms_plant_visual` (
	`visual_id` INT(11) NOT NULL AUTO_INCREMENT,
	`visual_entry` INT(11) NULL DEFAULT NULL,
	`start_size` FLOAT NULL DEFAULT NULL,
	`end_size` FLOAT NULL DEFAULT NULL,
	PRIMARY KEY (`visual_id`) USING BTREE
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1
;

]]

sql_createHouses = [[
CREATE TABLE IF NOT EXISTS `farms_houses` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`gob_guid` INT(11) NOT NULL DEFAULT '0',
	`door_guid` INT(11) NOT NULL DEFAULT '0',
	`level` INT(11) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
;
]]

local function LoadDoorsEntries()
	FarmSystem.doors_entry = {}
	
	local Q = CharDBQuery("SELECT door_id FROM doors")
	if Q then
		repeat
			local door_entry = Q:GetUInt32(0)
			table.insert(FarmSystem.doors_entry, door_entry)

		until not Q:NextRow()
	end

end
local function LoadDoorOwners()
	FarmSystem.door_owners = {}
	
	local Q = CharDBQuery("SELECT door_id FROM doors")
	if Q then
		repeat
			local door_entry = Q:GetUInt32(0)
			table.insert(FarmSystem.doors_entry, door_entry)

		until not Q:NextRow()
	end

end
local function LoadPlantVisual()
	WorldDBQuery(sql_createPlantVisual)
	FarmSystem.plant_visual = {}
	
	local Q = WorldDBQuery("SELECT * FROM farms_plant_visual")
	if Q then
		repeat
			local visual_id, visual_entry, start_size, end_size = Q:GetUInt32(0), Q:GetUInt32(1), Q:GetFloat(2), Q:GetFloat(3)
			local visual = {
				["id"] = visual_id,
				["visual_entry"] = visual_entry,
				["start_size"] = start_size,
				["end_size"] = end_size,
				
				}
			FarmSystem.plant_visual[visual.id] = visual

		until not Q:NextRow()
	end
end
local function LoadLoot()
	--WorldDBQuery(sql_createLoot)
	FarmSystem.loot = {}
	
	local Q = WorldDBQuery("SELECT * FROM farms_plant_loot")
	if Q then
		repeat
			local loot_id, item_entry, count, chance = Q:GetUInt32(0), Q:GetUInt32(1), Q:GetUInt32(2), Q:GetFloat(3)
			local loot = {
				["loot_id"] = loot_id,
				["item_entry"] = item_entry,
				["count"] = count,
				["chance"] = chance,
				
				}
			if FarmSystem.loot[loot.loot_id] == nil then
				FarmSystem.loot[loot.loot_id] = {loot}
			else
				table.insert(FarmSystem.loot[loot.loot_id],loot)
			end

		until not Q:NextRow()
	end
end
local function LoadPlantTemplate()
	WorldDBQuery(sql_createPlantTemplate)
	FarmSystem.plantTemplate = {}
	
	local Q = WorldDBQuery("SELECT * FROM farms_plant_template")
	if Q then
		repeat
			local id, name, cycles, one_time, water_needs, weed_chance, loot_id, visual_id, seed_entry, plant_type = Q:GetUInt32(0), Q:GetString(1), Q:GetUInt32(2), Q:GetUInt32(3), Q:GetUInt32(4), Q:GetFloat(5),Q:GetUInt32(6),Q:GetUInt32(7),Q:GetUInt32(8),Q:GetUInt32(9)
			local template = {
				["id"] = id,
				["name"] = name,
				["cycles"] = cycles,
				["one_time"] = one_time,
				["water_needs"] = water_needs,
				["weed_chance"] = weed_chance,
				["loot_id"] = loot_id,
				["visual_id"] = visual_id,
				["seed_entry"] = seed_entry,
				["type"] = plant_type,
				}
			FarmSystem.plantTemplate[template.id] = template
		until not Q:NextRow()
	end
end
local function PlantObject()
	local plant = {}
	function plant:GetName()
		return FarmSystem.plantTemplate[self.plant_id].name
	end
	function plant:UpdateInDB()
		FarmSystem.UpdatePlant(self)
	end
	function plant:AddWater()
		self.is_dry = 0
		self:UpdateInDB(self)
	end
	
	function plant:RemoveWeeds()
		self.is_weeded = 0
		self:UpdateInDB(self)
	end
	function plant:Grow(cycles)
		self.current_cycle = self.current_cycle + cycles
		if self.current_cycle > FarmSystem.plantTemplate[self.plant_id].cycles then
			self.current_cycle = FarmSystem.plantTemplate[self.plant_id].cycles
		end
	end
	return plant
end
local function HouseObject()
	local house = {}
	function house:HasAccess(player)
		local door_GUID = self.door_guid;
		local allow_flags = lockedDoorArray[door_GUID].allowed;
		
		if (lockedDoorArray[door_GUID].open == 1) then
			return true;
		end
		if (player:GetGUIDLow() == lockedDoorArray[door_GUID].ownerID) then
			return true;
		end
		if (CharDBQuery('SELECT * FROM doors_tenants WHERE char_guid = ' .. tostring(player:GetGUIDLow()) .. ' AND door_guid = ' .. door_GUID .. ' limit 1')) then
			return true;
		end
		if (bit_and(allow_flags, 8) == 8) then
			local ownerGuildIdQuery = CharDBQuery('SELECT guildid FROM characters.guild_member WHERE guid = ' .. lockedDoorArray[door_GUID].ownerID);
			if (ownerGuildIdQuery:GetRowCount() > 0) then
				guildID = ownerGuildIdQuery:GetUInt32(0);
				if (guildID == player:GetGuildId()) then
					return true;
				end
			end
		end
		if (bit_and(allow_flags, 4) == 4) then
			local ownerRaidIdQuery = CharDBQuery('SELECT guid FROM characters.group_member WHERE memberGuid = ' .. lockedDoorArray[door_GUID].ownerID);
			if (ownerRaidIdQuery) then
				if (ownerRaidIdQuery:GetRowCount() > 0) then
					raidID = ownerRaidIdQuery:GetUInt32(0);
					group = player:GetGroup()
					if (group) then
						--if(GetGUIDLow(group:GetGUID()) == raidID)then
						if (group:GetMemberGroup(lockedDoorArray[door_GUID].ownerID) ~= nil and group:IsRaidGroup()) then
							return true;
						end
					end
				end
			end
		end
		if (bit_and(allow_flags, 2) == 2) then
			local ownerGroupIdQuery = CharDBQuery('SELECT guid, subgroup FROM characters.group_member WHERE memberGuid = ' .. lockedDoorArray[door_GUID].ownerID);

			if (ownerGroupIdQuery == nil) then
				print('Nil value error'); --leave for test
			elseif (ownerGroupIdQuery:GetRowCount() > 0) then
				groupID = ownerGroupIdQuery:GetUInt32(0);
				subGroupID = ownerGroupIdQuery:GetUInt32(1);
				group = player:GetGroup()
				if (group) then
					--if(GetGUIDLow(group:GetGUID()) == groupID and player:GetSubGroup() == subGroupID)then
					if (group:GetMemberGroup(lockedDoorArray[door_GUID].ownerID) ~= nil and player:GetSubGroup() == subGroupID) then
						return true;
					end
				end
			end
		end
		return false;
	end
	function house:GetPlaces()
		local places = {}
		for i,place in pairs(FarmSystem.places) do
			print(place.type)
			print(place.bind)
			print(house.gob_guid)
			if place.type == 2 and place.bind == self.gob_guid then
				print("OKAAKAKAKAK")
				table.insert(places, place)
			end
		end
		return places
	end
	function house:GetAnimals()
		local animals = {}
		for i,animal in pairs(FarmSystem.animals) do
			if animal.house_guid == self.gob_guid then
				table.insert(animals, animal)
			end
		end
		return animals
	end
	function house:SetLevel(level)
		house.level = level
		WorldDBExecute("UPDATE `world`.`farms_houses` SET `level`='"..level.."' WHERE  `id`="..house.id)
	end
	return house
end
local function LoadHouses()
	WorldDBQuery(sql_createHouses)
	FarmSystem.houses = {}
	
	local Q = WorldDBQuery("SELECT * FROM farms_houses")
	if Q then
		repeat
			local id, gob_guid, door_guid, level = Q:GetUInt32(0), Q:GetUInt32(1), Q:GetUInt32(2), Q:GetUInt32(3)
			local house = HouseObject()
			house["id"] = id
			house["gob_guid"] = gob_guid
			house["door_guid"] = door_guid
			house["level"] = level
			FarmSystem.houses[house.gob_guid] = house

		until not Q:NextRow()
	end
end
local function PlaceObject()
	local place = {}
	
	
	function place:GetPlant()
		return FarmSystem.plants[self.plant_id]
	end
	function place:SeedNewPlant(plant_id)
		if self.plant_id ~= 0 then --Если растение уже посажено
			print("Attempt to seed new plant on place that already have one: Place-"..self.guid..", PlantId-"..self.plant_id)
			return false
		end
		local newId = FarmSystem.AddNewPlantToDB(plant_id)
		local plant = PlantObject()
		
		plant["id"] = newId
		plant["plant_id"] = plant_id
		plant["current_cycle"] = 0
		plant["is_dry"] = 0
		plant["is_weeded"] = 0
		
		
		FarmSystem.plants[plant.id] = plant
		
		place.plant_id = plant.id
		WorldDBExecute("UPDATE `world`.`farms_places` SET `id`='"..plant.id.."' WHERE  `place_guid`="..self.guid)
	end
	function place:DeletePlant()
		if self.plant_id == 0 then
			print("Attempt to delete plant empty place: Place-"..self.guid)
			return false
		end
		WorldDBExecute("DELETE FROM `world`.`farms_plants` WHERE  `id`="..self.plant_id..";")
		FarmSystem.plants[self.plant_id] = nil
		WorldDBExecute("UPDATE `world`.`farms_places` SET `id`='0' WHERE  `place_guid`="..self.guid)
		self.plant_id = 0
	end
	function place:GetHouse()
		if self.type == 2 then
			return FarmSystem.houses[self.bind]
		else
			return nil
		end
	end
	
	return place
end

local function LoadPlants()
	WorldDBQuery(sql_createPlants)
	FarmSystem.plants = {}
	
	local Q = WorldDBQuery("SELECT * FROM farms_plants")
	if Q then
		repeat
			local id, plant_id, current_cycle, is_dry, is_weeded = Q:GetUInt32(0),Q:GetUInt32(1),Q:GetUInt32(2),Q:GetUInt32(3),Q:GetUInt32(4)
			local plant = PlantObject()
			
			plant["id"] = id
			plant["plant_id"] = plant_id
			plant["current_cycle"] = current_cycle
			plant["is_dry"] = is_dry
			plant["is_weeded"] = is_weeded
	
			FarmSystem.plants[plant.id] = plant
		until not Q:NextRow()
	end
end



function FarmSystem.AddNewPlantToDB(plant_id)
	WorldDBQuery("INSERT INTO `world`.`farms_plants` (`plant_id`, `current_cycle`, `is_dry`, `is_weeded`) VALUES ('"..plant_id.."', '0', '0', '0');")
	local Q = WorldDBQuery("SELECT id FROM farms_plants ORDER BY `id` DESC LIMIT 1;")
	return Q:GetUInt32(0)
end

function FarmSystem.AttachHouseToDoor(player, house_object, door_guid)

	local Q = WorldDBQuery("SELECT id FROM gameobject WHERE guid  =  "..door_guid.."")
	if Q then
		local door_entry = Q:GetUInt32(0)
		for i, v in pairs(FarmSystem.doors_entry) do
			if door_entry == v then
				WorldDBQuery("INSERT INTO `world`.`farms_houses` (`gob_guid`, `door_guid`, `level`) VALUES ('"..house_object:GetDBTableGUIDLow().."', '"..door_guid.."', '1');")
				player:Print("Ферма успешно привязана к двери "..door_guid)
				LoadHouses()
				return false
			end
		end
		player:Print("Данный объект не является дверью.")
		return false
	else
		player:Print("Двери с данным гуидом не обнаружено.")
	end
end




function FarmSystem.UpdatePlant(plant)
	WorldDBExecute("UPDATE `world`.`farms_plants` SET `current_cycle`='"..plant.current_cycle.."', `is_dry`='"..plant.is_dry.."', `is_weeded`='"..plant.is_weeded.."' WHERE  `id`="..plant.id..";")
end


local function LoadPlaces()
	WorldDBQuery(sql_createPlaces)
	FarmSystem.places = {}
	
	local Q = WorldDBQuery("SELECT * FROM farms_places")
	if Q then
		repeat
			local guid, id,place_type,bind_to = Q:GetUInt32(0),Q:GetUInt32(1),Q:GetUInt32(2),Q:GetUInt32(3)
			local place = PlaceObject()
			
			place["guid"] = guid
			place["plant_id"] = id
			place["type"] = place_type
			place["bind"] = bind_to

			FarmSystem.places[place.guid] = place
		until not Q:NextRow()
	end
end

function FarmSystem.InitNewFarmPlace(place_object, place_type,bind_to)
	local place_guid = place_object:GetDBTableGUIDLow()
	
	WorldDBQuery("INSERT INTO `world`.`farms_places` (`place_guid`, `id`,`type`, `bind_to`) VALUES ('"..place_guid.."', '0','"..place_type.."','"..bind_to.."');")
	local place = PlaceObject()
	place["guid"] = place_guid
	place["plant_id"] = 0
	place["type"] = place_type
	place["bind"] = bind_to
	
	
	FarmSystem.places[place_guid] = place
end

function FarmSystem.LoadDatabases()
	LoadPlantTemplate()
	LoadPlants()
	LoadPlaces()
	LoadLoot()
	LoadPlantVisual()
	LoadHouses()
	LoadDoorsEntries()
end
FarmSystem.LoadDatabases()

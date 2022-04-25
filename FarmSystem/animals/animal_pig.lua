FarmSystem = FarmSystem or {}
FarmSystem.AnimalsInfo = FarmSystem.AnimalsInfo or {}
local ENTRY = 987821
local ITEM_ENTRY = 301347
local FOOD_ENTRY = 5059142
local LOOT_ENTRY = 769
local FOOD_COUNT = 3

local TYPE = 3
local info = {max_stage = 14, dirt_chance=0.1, food_every = 3, entry = ENTRY}
FarmSystem.AnimalsInfo[TYPE] = info


local function Interface_Collect(player,animal_object,intid)
	local animal = FarmSystem.GetAnimal(animal_object)
	local item = player:AddItem(LOOT_ENTRY,40)
	if item then
		animal:Delete()
		animal_object:Delete()
	else
		player:Print("Недостаточно места в инвентаре")
	end
end

local function OnAnimalTalk(event, player, animal_object)
	local animal = FarmSystem.GetAnimal(animal_object)
	if not animal then
		player:Print("Данное животное не находится в системе Ферм. Обратитесь к администрации.")
		return false
	end
	if not animal:GetHouse():HasAccess(player) then
		player:Print("Данное животное не находится в вашем владении.")
		return false
	end
	
	local interface = player:CreateInterface()
	animal.init_object = {}
	animal.init_object.map = animal_object:GetMapId()
	animal.init_object.guid_low = animal_object:GetGUIDLow()
	animal.init_object.entry = ENTRY
	function animal.init_object:GetCreature()
		local mapObject= GetMapById(self.map)
		local guid = GetUnitGUID(self.guid_low,self.entry)
		local object = mapObject:GetWorldObject(guid)
		return object
	end
	if animal.health > 0 then
		if animal.want_eat == 1 then
			interface:AddRow("Накормить морковью", FarmSystem.Interface_FeedAnimal, true,nil,FOOD_ENTRY, FOOD_COUNT,"Морковь"):SetIcon(5)
		end
		if animal.want_clean == 1 then
			interface:AddRow("Почистить", FarmSystem.Interface_CleanAnimal, true):SetIcon(5)
		end
		if animal.want_clean == 0 and animal.want_eat == 0 and animal.stage == info.max_stage then
			interface:AddRow("Заколоть на мясо",Interface_Collect, true):SetIcon(5)
			
		end
	end
	local title = ""
	title = title..animal.name
	if animal.health > 0 then
		local collectText = animal.stage < info.max_stage and ""..animal.stage.."/"..info.max_stage or "Можно заколоть"
		title = title.."\nПрогресс мяса: "..collectText
		title = title.."\nЗдоровье: "..animal.health.."/100"
		local cleanText = animal.want_clean == 1 and "Грязный" or "Чистый"
		title = title.."\nГигиена: "..cleanText
		local eatText = animal.want_eat == 1 and "Голодает" or "Сытый"
		title = title.."\nПитание: "..eatText
		
		interface:AddPopupRow("Вернуть в инвентарь",FarmSystem.Interface_ReturnAnimal, "Весь прогресс животного будет потерян!",true,nil,ITEM_ENTRY):SetIcon(5)
		interface:AddRow("О животноводстве",FarmSystem.Interface_DeadHelp, true)
	else
		title = title.."\n\n\nМертвый..."
		interface:AddRow("Что я сделал не так?",FarmSystem.Interface_DeadHelp, true)
		interface:AddRow("Убрать",FarmSystem.Interface_RemoveAnimal, true):SetIcon(5)
	end
	
	
	interface:AddClose()
	interface:Send(title,animal_object)
	
end

local function OnAnimalMenuClick(event, player, animal_object, sender, intid, code, menu_id)
	player:CurrentInterface():Click(intid,animal_object,code)
end


local function OnItemUse(event, player, item, target)
	local nearestFarm = nil;
	for i, v in pairs(FarmSystem.houseGobjects) do
		local near = player:GetNearestGameObject(FARM_RANGE,v)
		if near and (nearestFarm == nil or player:GetDistance(near) > player:GetDistance(nearestFarm)) then
			nearestFarm = near
		end
	end
	if nearestFarm then
		local house = FarmSystem.GetHouseFarm(nearestFarm)
		
		if house then
			if house:HasAccess(player) then
				if #house:GetAnimals() >= FarmSystem.levelSettings[house.level].maxAnimals then
					player:Print("Вы не можете разместить больше животных на данном уровне фермы. Максимум - "..FarmSystem.levelSettings[house.level].maxAnimals)
					return false
				end
				local x,y,z,o = player:GetLocation()
				local mapId = player:GetMapId()
				local pid = player:GetGUIDLow();
				local animal_object = PerformIngameSpawn( 1, ENTRY, mapId, 0, x, y, z, o, true, pid, 0, 1);
				FarmSystem.InitNewAnimal(animal_object,house.gob_guid,TYPE,"Кабан")
				player:RemoveItem(ITEM_ENTRY,1)
			else
				player:SendNotification("Вы находитесь на территории чужой фермы")
			end
		end
	else
		player:SendNotification("Вы должны находиться на территории своей фермы.")
	end
end

local function OnAnimalLoaded(event, animal_object)
	local animal = FarmSystem.GetAnimal(animal_object)
	if animal then
		animal.init_object = {}
		animal.init_object.map = animal_object:GetMapId()
		animal.init_object.guid_low = animal_object:GetGUIDLow()
		animal.init_object.entry = ENTRY
		function animal.init_object:GetCreature()
			local mapObject= GetMapById(self.map)
			local guid = GetUnitGUID(self.guid_low,self.entry)
			local object = mapObject:GetWorldObject(guid)
			return object
		end
		FarmSystem.UpdateAnimalVisual(animal_object)
	end
end


RegisterItemEvent(ITEM_ENTRY,2,OnItemUse)
RegisterCreatureEvent(ENTRY,36,OnAnimalLoaded)
RegisterCreatureGossipEvent(ENTRY,1,OnAnimalTalk)
RegisterCreatureGossipEvent(ENTRY,2,OnAnimalMenuClick)
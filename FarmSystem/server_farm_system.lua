FarmSystem = FarmSystem or {}

local DRY_EFFECT_ENTRY = 530074
local WEEED_EFFECT_ENTRY = 530075
local ON_COLLECT_REDUCTION = 0.5

local SHOVEL_ENTRY = 301343
FARM_RANGE = 10
local HOUSE_FARM_PLACE_ENTRY = 508906

local CYCLE_TIME = 1*60*60*1000
--local CYCLE_TIME = 6*1000 --DEBUG
local PHASE_FOR_SCALE_CHANGE = 65536

local placeAdditionalInfo = {
		[508903] = {
		place_type = 1,
		dry_offset = {x = 0, y = 0, z = 0.84},
		dry_size = 0.035,
		weed_offset = {x = 0, y = 0, z = 0.78},
		weed_size = 0.55,
		plant_offset = {x = 0, y = 0, z = 0.9},
		plant_size = 1
		},
		
		[508904] = {
		place_type = 1,
		dry_offset = {x = 0, y = 0, z = 0.74},
		dry_size = 0.05,
		weed_offset = {x = 0, y = 0, z = 0.6},
		weed_size = 0.7,
		plant_offset = {x = 0, y = 0, z = 0.7},
		plant_size = 1
		},
		[HOUSE_FARM_PLACE_ENTRY] = {
		place_type = 2,
		dry_offset = {x = 0, y = 0, z = 0.25},
		dry_size = 0.05,
		weed_offset = {x = 0, y = 0, z = 0.20},
		weed_size = 0.7,
		plant_offset = {x = 0, y = 0, z = 0.3},
		plant_size = 1
		}
}
FarmSystem.houseGobjects = {530746,530747,530748,530749}

FarmSystem.levelSettings = {
		[1] = {
		maxPlaces = 4,
		maxAnimals = 3,
		cost = 0,
		},
		[2] = {
		maxPlaces = 6,
		maxAnimals = 4,
		cost = 100*100*1
		},
		[3] = {
		maxPlaces = 8,
		maxAnimals = 5,
		cost = 100*100*1.5
		},
		[4] = {
		maxPlaces = 10,
		maxAnimals = 6,
		cost = 100*100*2
		},
		[5] = {
		maxPlaces = 12,
		maxAnimals = 7,
		cost = 100*100*3
		}
	}

function FarmSystem.GetFarmPlace(place_object)
	local place = FarmSystem.places[place_object:GetDBTableGUIDLow()]
	return place
end
function FarmSystem.DeleteFarmPlace(place_object)
	local place = FarmSystem.GetFarmPlace(place_object)
	place:DeletePlant()
	FarmSystem.LoadVisuals(place_object)
	WorldDBExecute("DELETE FROM `world`.`farms_places` WHERE  `place_guid`="..place.guid)
	FarmSystem.places[place_object:GetDBTableGUIDLow()] = nil
	place_object:RemoveFromWorld(true)
end
function FarmSystem.GetHouseFarm(object)
	local house = FarmSystem.houses[object:GetDBTableGUIDLow()]
	return house
end
local function Cycle()
	CreateLuaEvent(Cycle,CYCLE_TIME,1)
	for i, place in pairs(FarmSystem.places) do
		
		local plant = place:GetPlant()
		if plant then
			local template = FarmSystem.plantTemplate[plant.plant_id]
		
			if plant.current_cycle < template.cycles then
				local isUpdated = false
				if plant.is_dry == 0 and plant.is_weeded  == 0 then
					plant:Grow(1)
					isUpdated = true
				end
				if plant.is_dry == 0 and math.fmod(plant.current_cycle,template.water_needs) == 0 and plant.current_cycle < template.cycles then
					plant.is_dry = 1
					isUpdated = true
				end
				if plant.is_weeded == 0 and math.random() < template.weed_chance and plant.current_cycle < template.cycles then
					plant.is_weeded = 1
					isUpdated = true
				end
				if isUpdated then
					plant:UpdateInDB()
				end
			end
			if place.init_object then
				local place_object = place.init_object:GetGameobject()
				if place_object then
					FarmSystem.LoadVisuals(place_object)
				end
			end	
		end
		
	end
	for i, animal in pairs(FarmSystem.animals) do
		animal:UpdateCycle()
		if animal.init_object then
			local animal_object = animal.init_object:GetCreature()
			FarmSystem.UpdateAnimalVisual(animal_object)
		end
		
	end
	

end
Cycle()
local function Interface_InitFarmPlace(player, place_object, intid)
	FarmSystem.InitNewFarmPlace(place_object)
	player:Print("Ферма [GUID:"..place_object:GetDBTableGUIDLow().."] успешно инициализирована")
end

local function Interface_ChooseSeedToPlant(player,place_object,intid,template)
	local place = FarmSystem.GetFarmPlace(place_object)
	
	player:RemoveItem(template.seed_entry,1)
	place:SeedNewPlant(template.id)
	FarmSystem.LoadVisuals(place_object)
	
end
local function Interface_SeedHelp(player,place_object,intid)
	player:Print("Семена падают с небольшим шансом из собираемой травы. Запаситесь терпением и дерзайте в поиски, либо обзаведетесь знакомством с хорошим травником.")
end
local function Interface_Seed(player,place_object,intid)
	local seedToPlantInterface = player:CreateInterface()
	local hasAny = false
	local place = FarmSystem.GetFarmPlace(place_object)
	for i, template in pairs(FarmSystem.plantTemplate) do
		if player:HasItem(template.seed_entry) then
			if (place.type == 1 and template.type == 1) or place.type == 2 then
				seedToPlantInterface:AddRow(template.name,Interface_ChooseSeedToPlant, true,nil,template)
				hasAny = true
			end
		end
	end
	if hasAny == false then
		seedToPlantInterface:AddRow("Где достать семена?",Interface_SeedHelp, true)
		seedToPlantInterface:AddClose()
		seedToPlantInterface:Send("У вас нет нет семян растений",place_object)
	else
		seedToPlantInterface:AddClose()
		seedToPlantInterface:Send("Какое растение посадить?",place_object)
	end
end

local function Interface_DeletePlant(player,place_object,intid)
	local place = FarmSystem.GetFarmPlace(place_object)
	place:DeletePlant()
	FarmSystem.LoadVisuals(place_object)

end
local function Interface_ReturnGo(player,place_object,intid)
	local item = player:AddItem(place_object:GetEntry(),1)
	if item then
		FarmSystem.DeleteFarmPlace(place_object)
	else
		player:Print("В вашем инвентаре недостаточно места")
	end
end
local function Interface_DeleteGo(player,place_object,intid)
	FarmSystem.DeleteFarmPlace(place_object)
end
local function Interface_AddWater(player,place_object,intid)
	local place = FarmSystem.GetFarmPlace(place_object)
	local plant = place:GetPlant()
	plant:AddWater()
	FarmSystem.LoadVisuals(place_object)
end

local function Interface_RemoveWeeds(player,place_object,intid)
	local place = FarmSystem.GetFarmPlace(place_object)
	local plant = place:GetPlant()
	plant:RemoveWeeds()
	FarmSystem.LoadVisuals(place_object)
end

function Player:AddFarmLoot(loot_id)
	local lootList = FarmSystem.loot[loot_id]
	local isFull = false
	local itemToMail = {}
	for i, loot in pairs(lootList) do
		if math.random() < loot.chance then
			for i=1, loot.count do
				local item = self:AddItem(loot.item_entry)
				if item == nil then
					table.insert(itemToMail,loot.item_entry)
					isFull = true
				end
			end
		end
	end
	if isFull then
		for i, entry in pairs(itemToMail) do
			SendMail("Потерянный урожай","Данный урожай не поместился в ваш инвентарь", self:GetGUIDLow(),36,61,20,0,0,entry,1)
		end
		self:Print("Некоторый урожай не поместился в ваш инвентарь и был отправлен вам на почту.")
	end
end

local function Interface_Collect(player,place_object,intid)
	local place = FarmSystem.GetFarmPlace(place_object)
	local plant = place:GetPlant()
	local template = FarmSystem.plantTemplate[plant.plant_id]
	if template.one_time == 1 then
		place:DeletePlant()
		FarmSystem.LoadVisuals(place_object)
	else
		plant.current_cycle = math.floor(plant.current_cycle * ON_COLLECT_REDUCTION)
		plant:UpdateInDB()
	end
	player:AddFarmLoot(template.loot_id)
end


local function OnPlaceUsed(event, player, place_object)
	local place = FarmSystem.GetFarmPlace(place_object)
	
	
	if place then
		
		place.init_object = {}
		place.init_object.map = place_object:GetMapId()
		place.init_object.guid_low = place_object:GetGUIDLow()
		place.init_object.entry = place_object:GetEntry()		
		function place.init_object:GetGameobject()
			local mapObject= GetMapById(self.map)
			local guid = GetObjectGUID(self.guid_low,self.entry)
			local object = mapObject:GetWorldObject(guid)
			return object
		end
		FarmSystem.LoadVisuals(place_object)
		local house = place:GetHouse()
		if house then
			if not house:HasAccess(player) then
				return false
			end
		
		elseif player ~= place_object:GetOwner() then
			return false
		end
		local interface = player:CreateInterface()
		local title = ""
		if place.plant_id == 0 then
			if place.type == 1 then
				title = "Перед вами пустой горшок, пока что в нем ничего не посажено"
			elseif place.type == 2 then
				title = "Перед вами пустая грядка, пока что на ней ничего не посажено"
			end
			interface:AddRow("Посадить растение",Interface_Seed,false)
		else
			
			local plant = place:GetPlant()
			local template = FarmSystem.plantTemplate[plant.plant_id]
			title = ("Здесь растет "..plant:GetName())
			title = title .. "\n\nУровень роста: "
			
			if plant.current_cycle == template.cycles then
				title = title.."Созрело"
			else
				title = title..plant.current_cycle.." из "..template.cycles
			end
			
			local waterText = plant.is_dry == 1 and "Требует полива" or "Полито"
			local statusText = plant.is_weeded == 1 and "Задыхается в сорняках" or "Здоровое"
			title = title.."\nВлажность: "..waterText
			title = title.."\nСостояние: "..statusText
			
			if plant.current_cycle == template.cycles then
				interface:AddRow("Собрать урожай", Interface_Collect, true):SetIcon(5)
			end
			if player:GetGMRank()>1 then
				interface:AddRow("[GM] Собрать урожай", Interface_Collect, true):SetIcon(5)
			end
			if plant.is_dry == 1 then
				interface:AddRow("Полить", Interface_AddWater, true):SetIcon(5)
			end
			if plant.is_weeded == 1 then
				interface:AddRow("Выкопать сорняки", Interface_RemoveWeeds, true):SetIcon(5)
			end
			interface:AddPopupRow("Выкопать растение",Interface_DeletePlant,"Вы действительно хотите удалить растение с этой грядки? Затраченные семена не будут возвращены.",true):SetIcon(5)
			
		end
		if place.type == 1 then
			interface:AddPopupRow("Забрать горшок",Interface_ReturnGo,"Посаженные растения будут удалены!",true):SetIcon(5)
		elseif place.type == 2 then
			interface:AddPopupRow("Удалить грядку",Interface_DeleteGo,"Посаженные растения будут удалены!",true):SetIcon(5)
		end
		interface:AddClose()
		interface:Send(title,place_object)
	end
	
end

local function OnPlaceClickMenu(event, player, object, sender, intid, code)
	player:CurrentInterface():Click(intid,object,code)
end


local visualList = {}
function math.clamp(num, min, max)
	if num < min then
		num = min
	elseif num > max then
		num = max    
	end
	
	return num
end

local clamp = math.clamp

function math.lerp(from, to, t)
	return from + (to - from) * clamp(t, 0, 1)
end
function FarmSystem.LoadVisuals(place_object)
	local place = FarmSystem.GetFarmPlace(place_object)
	if place == nil then
		return false
	end
	visualList[place.guid] = visualList[place.guid] or {}
	local visual = visualList[place.guid]
	local info = placeAdditionalInfo[place_object:GetEntry()]
	
	local plant = place:GetPlant()
	local map = place_object:GetMap()
	if plant == nil then
		if visual.dry then
			local dry_guid = GetObjectGUID(visual.dry.low_guid,DRY_EFFECT_ENTRY)
			local dry_object = map:GetWorldObject(dry_guid)
			if dry_object then
				dry_object:RemoveFromWorld(true)
			end
		end
		if visual.weed then
			local weed_guid = GetObjectGUID(visual.weed.low_guid,WEEED_EFFECT_ENTRY)
			local weed_object = map:GetWorldObject(weed_guid)
			if weed_object then
				weed_object:RemoveFromWorld(true)
			end
		end
		if visual.plant then
			local plant_entry = visual.plant.entry
			
			local plant_guid = GetObjectGUID(visual.plant.low_guid,plant_entry)
			
			local plant_object = map:GetWorldObject(plant_guid)
			if plant_object then
				plant_object:RemoveFromWorld(true)
			end
		end
		
		return false
	end
	
	
	if plant.is_dry == 1 then
		if visual.dry then
			local dry_guid = GetObjectGUID(visual.dry.low_guid,DRY_EFFECT_ENTRY)
			
			local dry_object = map:GetWorldObject(dry_guid)
			if dry_object == nil then
				local x,y,z,o = place_object:GetLocation()
				dry_object = PerformIngameSpawn(2,DRY_EFFECT_ENTRY,map:GetMapId(),0,x+info.dry_offset.x, y+info.dry_offset.y,z+info.dry_offset.z,0,false,0,0,place_object:GetPhaseMask())
				dry_object:SetScale(info.dry_size)
				dry_object:SetPhaseMask(PHASE_FOR_SCALE_CHANGE)
				dry_object:SetPhaseMask(place_object:GetPhaseMask())
				visual.dry.low_guid = dry_object:GetGUIDLow()
			end
		else
			visual.dry = {}
			local x,y,z,o = place_object:GetLocation()
			dry_object = PerformIngameSpawn(2,DRY_EFFECT_ENTRY,map:GetMapId(),0,x+info.dry_offset.x, y+info.dry_offset.y,z+info.dry_offset.z,0,false,0,0,place_object:GetPhaseMask())
			dry_object:SetScale(info.dry_size)
			dry_object:SetPhaseMask(PHASE_FOR_SCALE_CHANGE)
			dry_object:SetPhaseMask(place_object:GetPhaseMask())
			visual.dry.low_guid = dry_object:GetGUIDLow()
		end
	else
		if visual.dry then
			local dry_guid = GetObjectGUID(visual.dry.low_guid,DRY_EFFECT_ENTRY)
			
			local dry_object = map:GetWorldObject(dry_guid)
			if dry_object then
				dry_object:RemoveFromWorld(true)
			else
				visual.dry = nil
			end
		end
	end
	if plant.is_weeded == 1 then
		if visual.weed then
			local weed_guid = GetObjectGUID(visual.weed.low_guid,WEEED_EFFECT_ENTRY)
			
			local weed_object = map:GetWorldObject(weed_guid)
			if weed_object == nil then
				local x,y,z,o = place_object:GetLocation()
				weed_object = PerformIngameSpawn(2,WEEED_EFFECT_ENTRY,map:GetMapId(),0,x+info.weed_offset.x, y+info.weed_offset.y,z+info.weed_offset.z,0,false,0,0,place_object:GetPhaseMask())
				weed_object:SetScale(info.weed_size)
				weed_object:SetPhaseMask(PHASE_FOR_SCALE_CHANGE)
				weed_object:SetPhaseMask(place_object:GetPhaseMask())
				visual.weed.low_guid = weed_object:GetGUIDLow()
			end
		else
			visual.weed = {}
			local x,y,z,o = place_object:GetLocation()
			weed_object = PerformIngameSpawn(2,WEEED_EFFECT_ENTRY,map:GetMapId(),0,x+info.weed_offset.x, y+info.weed_offset.y,z+info.weed_offset.z,0,false,0,0,place_object:GetPhaseMask())
			weed_object:SetScale(info.weed_size)
			weed_object:SetPhaseMask(PHASE_FOR_SCALE_CHANGE)
			weed_object:SetPhaseMask(place_object:GetPhaseMask())
			visual.weed.low_guid = weed_object:GetGUIDLow()
		end
	else
		if visual.weed then
			local weed_guid = GetObjectGUID(visual.weed.low_guid,WEEED_EFFECT_ENTRY)
			
			local weed_object = map:GetWorldObject(weed_guid)
			if weed_object then
				weed_object:RemoveFromWorld(true)
			else
				visual.weed = nil
			end
		end
	end
	
	if visual.plant then
		local template = FarmSystem.plantTemplate[plant.plant_id]
		local visual_id = template.visual_id
		
		local visual_plant = FarmSystem.plant_visual[visual_id]
		local plant_entry = visual_plant.visual_entry
		
		local plant_guid = GetObjectGUID(visual.plant.low_guid,plant_entry)
		
		local plant_object = map:GetWorldObject(plant_guid)
		if plant_object == nil then
			local x,y,z,o = place_object:GetLocation()
			plant_object = PerformIngameSpawn(2,plant_entry,map:GetMapId(),0,x+info.plant_offset.x, y+info.plant_offset.y,z+info.plant_offset.z,0,false,0,0,place_object:GetPhaseMask())
			visual.plant.low_guid = plant_object:GetGUIDLow()
		end
		plant_object:SetScale((math.lerp(visual_plant.start_size,visual_plant.end_size,plant.current_cycle/template.cycles))*info.plant_size)
		plant_object:SetPhaseMask(PHASE_FOR_SCALE_CHANGE)
		plant_object:SetPhaseMask(place_object:GetPhaseMask())
		visual.plant.entry = plant_entry
	else
		visual.plant = {}
		local template = FarmSystem.plantTemplate[plant.plant_id]
		local visual_id = template.visual_id
		local visual_plant = FarmSystem.plant_visual[visual_id]
		local plant_entry = visual_plant.visual_entry
		local x,y,z,o = place_object:GetLocation()
		local plant_object = PerformIngameSpawn(2,plant_entry,map:GetMapId(),0,x+info.plant_offset.x, y+info.plant_offset.y,z+info.plant_offset.z,0,false,0,0,place_object:GetPhaseMask())
		visual.plant.low_guid = plant_object:GetGUIDLow()
		plant_object:SetScale((math.lerp(visual_plant.start_size,visual_plant.end_size,plant.current_cycle/template.cycles))*info.plant_size)
		plant_object:SetPhaseMask(PHASE_FOR_SCALE_CHANGE)
		plant_object:SetPhaseMask(place_object:GetPhaseMask())
		visual.plant.entry = plant_entry
	end

end
local function OnPlaceLoaded(event, place_object)
	print("loaded new place")
	if place_object:GetOwner() == nil then
		return false
	end
	local place = FarmSystem.GetFarmPlace(place_object)
	local entry = place_object:GetEntry()
	local info = placeAdditionalInfo[place_object:GetEntry()]
	if place then
		place.init_object = {}
		place.init_object.map = place_object:GetMapId()
		place.init_object.guid_low = place_object:GetGUIDLow()
		place.init_object.entry = entry
		function place.init_object:GetGameobject()
			local mapObject= GetMapById(self.map)
			local guid = GetObjectGUID(self.guid_low,self.entry)
			local object = mapObject:GetWorldObject(guid)
			return object
		end
		
		FarmSystem.LoadVisuals(place_object)
	else
		if info.place_type == 1 then
			
			FarmSystem.InitNewFarmPlace(place_object,info.place_type,place_object:GetOwner():GetGUIDLow())
		end
	end
end



local function Interface_AttachHouseToDoor(player,house_object,intid,door_guid_str)
	local door_guid = tonumber(door_guid_str)
	FarmSystem.AttachHouseToDoor(player, house_object, door_guid)
end
local function Interface_LevelUp(player,house_object,intid)
	local house = FarmSystem.GetHouseFarm(house_object)
	local newLevel = house.level+1
	local currentCopper = player:GetCoinage()
	local cost = FarmSystem.levelSettings[newLevel].cost
	if currentCopper >= FarmSystem.levelSettings[newLevel].cost then
		house:SetLevel(newLevel)
		player:SetCoinage(currentCopper-cost)
	else
		player:Print("Недостаточно монет. Необходимо "..(cost/100/100).." золотых монет.")
	end
end
local function Interface_UpgradeHouseMenu(player,house_object,intid)
	local upgradeOptionsInterface = player:CreateInterface()
	local house = FarmSystem.GetHouseFarm(house_object)
	local newLevel = house.level+1
	local popupText = "Цена улучшения - "..(FarmSystem.levelSettings[newLevel].cost/100/100).." золотых монет."
	popupText = popupText.."\nСтанет доступно:"
	popupText = popupText.."\nМакс. количество грядок - "..FarmSystem.levelSettings[newLevel].maxPlaces
	popupText = popupText.."\nМакс. количество животных - "..FarmSystem.levelSettings[newLevel].maxAnimals
	upgradeOptionsInterface:AddPopupRow("Улучшить ферму до "..(house.level+1).." уровня", Interface_LevelUp, popupText, true):SetIcon(5)
	upgradeOptionsInterface:AddClose()
	upgradeOptionsInterface:Send("Меню улучшений",house_object)
end
local function OnHouseUsed(event, player, house_object)
	local house = FarmSystem.houses[house_object:GetDBTableGUIDLow()]
	local interface = player:CreateInterface()
	if not house then
		if player:GetGMRank() > 1 then
			interface:AddAskRow("[GM] Привязать к двери",Interface_AttachHouseToDoor,true):SetIcon(5)
		end
		interface:AddClose()
		interface:Send("Данная ферма не привязана к дому. Обратитесь к администрации.",house_object)
		return false
	end
	
	if house.level < #FarmSystem.levelSettings and house:HasAccess(player) then
		interface:AddRow("Улучшить ферму",Interface_UpgradeHouseMenu,false):SetIcon(5)
	
	end
	
	interface:AddClose()
	local farmInfo = "Ферма "..house.level.." уровня\n"
	farmInfo = farmInfo.."\nГрядок "..#house:GetPlaces().." из "..FarmSystem.levelSettings[house.level].maxPlaces
	farmInfo = farmInfo.."\nЖивотных "..#house:GetAnimals().." из "..FarmSystem.levelSettings[house.level].maxAnimals
	interface:Send(farmInfo,house_object)
end

local function OnHouseClickMenu(event, player, object, sender, intid, code)
	player:CurrentInterface():Click(intid,object,code)
end


local function OnShovelUse(event, player, item, target)
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
				if #house:GetPlaces() >= FarmSystem.levelSettings[house.level].maxPlaces then
					player:Print("Вы не можете вскопать больше грядок на данном уровне фермы. Максимум - "..FarmSystem.levelSettings[house.level].maxPlaces)
					return false
				end
				local x,y,z,o = player:GetLocation()
				local mapId = player:GetMapId()
				local pid = player:GetGUIDLow();
				local place_object = PerformIngameSpawn( 2, HOUSE_FARM_PLACE_ENTRY, mapId, 0, x, y, z, o+0.9, true, pid, 0, 1);
				FarmSystem.InitNewFarmPlace(place_object,2,house.gob_guid)
				player:RemoveItem(SHOVEL_ENTRY,1)
			else
				player:SendNotification("Данная ферма вам не принадлежит")
			end
		end
	else
		player:SendNotification("Вы должны находиться на территории своей фермы.")
	end
end



RegisterItemEvent(SHOVEL_ENTRY,2,OnShovelUse)

for i,v in pairs(FarmSystem.houseGobjects) do
	RegisterGameObjectGossipEvent(v,1,OnHouseUsed)
	RegisterGameObjectGossipEvent(v,2,OnHouseClickMenu)
end



for entry,v in pairs(placeAdditionalInfo) do
	RegisterGameObjectEvent(entry,12,OnPlaceLoaded)
	RegisterGameObjectGossipEvent(entry,1,OnPlaceUsed)
	RegisterGameObjectGossipEvent(entry,2,OnPlaceClickMenu)
end

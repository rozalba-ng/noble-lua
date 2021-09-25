FarmSystem = FarmSystem or {}

local FARM_PLACE_ENTRY = 100000
local DRY_EFFECT_ENTRY = 100002
local WEEED_EFFECT_ENTRY = 100001
local ON_COLLECT_REDUCTION = 0.5

local CYCLE_TIME = 5000

local DRY_EFFECT_OFFSET = {x = 0, y = 0, z = 0}
local WEED_EFFECT_OFFSET = {x = 0, y = 0, z = 0}
local PLANT_EFFECT_OFFSET = {x = 0, y = 1, z = 0}

local function GetFarmPlace(object)
	local place = FarmSystem.places[object:GetDBTableGUIDLow()]
	return place
end


local function PlantCycle()
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
	SendWorldMessage("UPDATED")
	CreateLuaEvent(PlantCycle,CYCLE_TIME)

end
PlantCycle()
local function Interface_InitFarmPlace(player, place_object, intid)
	FarmSystem.InitNewFarmPlace(place_object)
	player:Print("Ферма [GUID:"..place_object:GetDBTableGUIDLow().."] успешно инициализирована")
end

local function Interface_ChooseSeedToPlant(player,place_object,intid,plant_id)
	local place = GetFarmPlace(place_object)
	place:SeedNewPlant(plant_id)
end

local function Interface_Seed(player,place_object,intid)
	seedToPlantInterface = player:CreateInterface()
	seedToPlantInterface:AddRow(FarmSystem.plantTemplate[1].name,Interface_ChooseSeedToPlant, true,FarmSystem.plantTemplate[1].id)
	seedToPlantInterface:AddClose()
	seedToPlantInterface:Send("Какое растение посадить?",place_object)
end

local function Interface_DeletePlant(player,place_object,intid)
	local place = GetFarmPlace(place_object)
	place:DeletePlant()
	FarmSystem.LoadVisuals(place_object)

end


local function Interface_AddWater(player,place_object,intid)
	local place = GetFarmPlace(place_object)
	local plant = place:GetPlant()
	plant:AddWater()
	FarmSystem.LoadVisuals(place_object)
end

local function Interface_RemoveWeeds(player,place_object,intid)
	local place = GetFarmPlace(place_object)
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
	local place = GetFarmPlace(place_object)
	local plant = place:GetPlant()
	local template = FarmSystem.plantTemplate[plant.plant_id]
	if template.one_time == 1 then
		place:DeletePlant()
	else
		plant.current_cycle = math.floor(plant.current_cycle * ON_COLLECT_REDUCTION)
		plant:UpdateInDB()
	end
	player:AddFarmLoot(template.loot_id)
end


local function Interface_DEBUGUpdate(player,place_object,intid)
	FarmSystem.LoadVisuals(place_object)
end
local function OnPlaceUsed(event, player, place_object)
	local place = GetFarmPlace(place_object)
	if not place then
		if player:GetGMRank() > 1 then
			local interface = player:CreateInterface()
			interface:AddRow("[GM] Инициализировать ферму",Interface_InitFarmPlace,true)
			interface:AddClose()
			interface:Send("Данная ферма не находится в системе и не может быть использована. Требуется инициализация", place_object,true)
		else
			player:Print("Данная ферма [GUID:"..place_object:GetDBTableGUIDLow().."] недоступна. Обратитесь к администрации.")
			return true
		end
	else
		local interface = player:CreateInterface()
		local title = ""
		if place.plant_id == 0 then
			title = "Перед вами пустая грядка, пока что на ней ничего не посажено"
			interface:AddRow("Посадить растение",Interface_Seed,false)
		else
			local plant = place:GetPlant()
			local template = FarmSystem.plantTemplate[plant.plant_id]
			title = ("На грядке растет "..plant:GetName().."["..plant.id.."]")
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
			if plant.is_dry == 1 then
				interface:AddRow("Полить", Interface_AddWater, true):SetIcon(5)
			end
			if plant.is_weeded == 1 then
				interface:AddRow("Выкопать сорняки", Interface_RemoveWeeds, true):SetIcon(5)
			end
			interface:AddRow("DEBUG_UPDATE", Interface_DEBUGUpdate,true)
			interface:AddPopupRow("Выкопать",Interface_DeletePlant,"Вы действительно хотите удалить растение с этой грядки? Затраченные семена не будут возвращены.",true):SetIcon(5)
		end
		
		interface:AddClose()
		interface:Send(title,place_object)
	end
	
end

local function OnPlaceClickMenu(event, player, object, sender, intid, code)
	player:CurrentInterface():Click(intid,object)
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
	local place = GetFarmPlace(place_object)
	visualList[place.guid] = visualList[place.guid] or {}
	local visual = visualList[place.guid]
	if place == nil then
		return false
	end
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
				dry_object = PerformIngameSpawn(2,DRY_EFFECT_ENTRY,map:GetMapId(),0,x+DRY_EFFECT_OFFSET.x, y+DRY_EFFECT_OFFSET.y,z+DRY_EFFECT_OFFSET.z,0,false,0,place_object:GetPhaseMask())
				visual.dry.low_guid = dry_object:GetGUIDLow()
			end
		else
			visual.dry = {}
			local x,y,z,o = place_object:GetLocation()
			dry_object = PerformIngameSpawn(2,DRY_EFFECT_ENTRY,map:GetMapId(),0,x+DRY_EFFECT_OFFSET.x, y+DRY_EFFECT_OFFSET.y,z+DRY_EFFECT_OFFSET.z,0,false,0,place_object:GetPhaseMask())
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
				weed_object = PerformIngameSpawn(2,WEEED_EFFECT_ENTRY,map:GetMapId(),0,x+WEED_EFFECT_OFFSET.x, y+WEED_EFFECT_OFFSET.y,z+WEED_EFFECT_OFFSET.z,0,false,0,place_object:GetPhaseMask())
				visual.weed.low_guid = weed_object:GetGUIDLow()
			end
		else
			visual.weed = {}
			local x,y,z,o = place_object:GetLocation()
			weed_object = PerformIngameSpawn(2,WEEED_EFFECT_ENTRY,map:GetMapId(),0,x+WEED_EFFECT_OFFSET.x, y+WEED_EFFECT_OFFSET.y,z+WEED_EFFECT_OFFSET.z,0,false,0,place_object:GetPhaseMask())
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
			plant_object = PerformIngameSpawn(2,plant_entry,map:GetMapId(),0,x+PLANT_EFFECT_OFFSET.x, y+PLANT_EFFECT_OFFSET.y,z+PLANT_EFFECT_OFFSET.z,0,false,0,place_object:GetPhaseMask())
			visual.plant.low_guid = plant_object:GetGUIDLow()
		end
		plant_object:SetScale(math.lerp(visual_plant.start_size,visual_plant.end_size,template.cycles/plant.current_cycle))
		visual.plant.entry = plant_entry
	else
		visual.plant = {}
		local template = FarmSystem.plantTemplate[plant.plant_id]
		local visual_id = template.visual_id
		local visual_plant = FarmSystem.plant_visual[visual_id]
		local plant_entry = visual_plant.visual_entry
		local x,y,z,o = place_object:GetLocation()
		local plant_object = PerformIngameSpawn(2,plant_entry,map:GetMapId(),0,x+PLANT_EFFECT_OFFSET.x, y+PLANT_EFFECT_OFFSET.y,z+PLANT_EFFECT_OFFSET.z,0,false,0,place_object:GetPhaseMask())
		visual.plant.low_guid = plant_object:GetGUIDLow()
		plant_object:SetScale(math.lerp(visual_plant.start_size,visual_plant.end_size,template.cycles/plant.current_cycle))
		visual.plant.entry = plant_entry
	end

end
local function OnPlaceLoaded(event, place_object)
	local place = GetFarmPlace(place_object)
	if place then
		place.init_object = {}
		place.init_object.map = place_object:GetMapId()
		place.init_object.guid_low = place_object:GetGUIDLow()
		function place.init_object:GetGameobject()
			local mapObject= GetMapById(self.map)
			local guid = GetObjectGUID(self.guid_low,FARM_PLACE_ENTRY)
			local object = mapObject:GetWorldObject(guid)
			return object
		end
		
		FarmSystem.LoadVisuals(place_object)
	end
end
RegisterGameObjectEvent(FARM_PLACE_ENTRY,12,OnPlaceLoaded)
RegisterGameObjectGossipEvent(FARM_PLACE_ENTRY,1,OnPlaceUsed)
RegisterGameObjectGossipEvent(FARM_PLACE_ENTRY,2,OnPlaceClickMenu)
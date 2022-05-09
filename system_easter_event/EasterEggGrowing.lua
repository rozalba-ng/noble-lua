local EGG_ITEM_ID = 301381
local FARM_NPC  = 987881
local FARM_RANGE = 15
local EGG_GO = 530798
local GROW_TIME = 2*24*60*60 
local HUG_TIME = 4*60*60 
local function OnEggUse(event, player, item, target)
	local nearestFarm= player:GetNearestCreature(FARM_RANGE,FARM_NPC)
	if nearestFarm then
		player:RemoveItem(EGG_ITEM_ID,1)
		local x, y, z, o = player:GetLocation();
		local pid = player:GetGUIDLow();
		local map = player:GetMapId();
		local phase = player:GetPhaseMask();
		local egg = PerformIngameSpawn( 2, EGG_GO, map, 0, x, y, z, o, true, pid, 0, phase);
		player:SetInfo("EasterEggPlanted_2022",tostring(os.time()+GROW_TIME))
		player:SetInfo("EasterEggHug_2022",tostring(os.time()-(HUG_TIME*2)))
		player:CompleteQuest(110220)
		player:AddQuest(110226)
		
	else
		player:Print("Подойдите поближе к ферме для кроликов")
	end
end


local function Interface_Knock(player,obj,intid)
	local lastHug = os.time()
	local growTime = tonumber(player:GetInfo("EasterEggPlanted_2022"))-6*60*60
	player:SetInfo("EasterEggPlanted_2022",tostring(growTime))
	player:SetInfo("EasterEggHug_2022",tostring(lastHug))
end


local function Interface_GetRabbit(player,obj,intid)
	obj:RemoveFromWorld(true)
	player:CompleteQuest(110226)
end
local function OnEggClick(event, player, egg)
	if egg:GetOwner() == player then
		local interace = player:CreateInterface()
		
		local lastHug = tonumber(player:GetInfo("EasterEggHug_2022"))
		local growTime = tonumber(player:GetInfo("EasterEggPlanted_2022"))
		local title = ""
		if (os.time() - growTime > 0) then
			interace:AddRow("Вынуть крольчонка",Interface_GetRabbit,true)
			title = title.."Крольчонок вот-вот вылупится! Хватайте его!"
		else
			
			local seconds = (growTime-os.time())
			local minutes = math.floor(seconds/60)
			local hours = math.floor(minutes/60)
			local minutesLeft = minutes % 60
			if (os.time() - lastHug) > HUG_TIME then
				interace:AddRow("Постучать по яйцу",Interface_Knock,true)
			
			end
			title = title.."Яйцо вылупиться через: "..hours.." ч. "..minutesLeft.." м.\n\nНе забывайте переодически проверять крольчонка. \nВаше внимание позволит ускорить процесс его вылупления!"
		end
		interace:AddClose():SetIcon(0)
		interace:Send(title,egg)
	end
end

local function OnEggSelect(event, player, object, sender, intid, code, menu_id)
	player:CurrentInterface():Click(intid,object,code)
end

RegisterGameObjectGossipEvent(EGG_GO,1,OnEggClick)
RegisterGameObjectGossipEvent(EGG_GO,2,OnEggSelect)

RegisterItemEvent( EGG_ITEM_ID, 2, OnEggUse )
local CARROT_ENTRY = 301353 
local ITEMS = {
301354,301355,301356,301357,301358,301359,301360,301361,301362,301363,301364,301365,301366,301367,301368,301369,301370
}
local Egg_ENTRY = 5052396
local Egg_ENTRY2 = 5052397
local Egg_ENTRY3 = 5052398
local Egg_ENTRY4 = 5052399

local function OnEggClick(event, player, object)
	if player:HasItem(CARROT_ENTRY) then
		local entry = ITEMS[math.random(1,#ITEMS)]
		local item = player:AddItem(entry)
		if item then
			player:Print("|cffff7588Взмахивая заточенной морковкой словно копьем в насквозь пробиваете крепкую скорлупу пасхального яйца, доставая |r "..item:GetItemLink())
			player:RemoveItem(CARROT_ENTRY,1)
			object:RemoveFromWorld(false)
		else
			player:Print("Повторите со свободным местом в инвентаре.")
		end
	else
		player:SendAreaTriggerMessage("Постукивая по пасхальному яйцу вы слышите глухой звук. В нем явно есть что-то заманчивое, но у вас пока нет ничего, чем бы вы могли пробить скорлупу.")
	end
end

RegisterGameObjectGossipEvent(Egg_ENTRY,1,OnEggClick)
RegisterGameObjectGossipEvent(Egg_ENTRY2,1,OnEggClick)
RegisterGameObjectGossipEvent(Egg_ENTRY3,1,OnEggClick)
RegisterGameObjectGossipEvent(Egg_ENTRY4,1,OnEggClick)



local function OnMapChange(event,player)
	if player:GetMapId() == 11458 then
		if not player:HasSpell(91286) then
			player:LearnSpell(91286)
		end
	end
end

RegisterPlayerEvent( 28, OnMapChange )
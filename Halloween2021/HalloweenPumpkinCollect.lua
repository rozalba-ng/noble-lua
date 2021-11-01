local LANTER_ENTRY = 5059250 
local DEAD_LANTER_ENTRY = 5059254 
local NPC_ENTRY = 987830
local ITEMS = {
5059193, 5059194, 5059194,5059195,5059196,5059197,5059198,5059199,5059200,5059201,5059202,5059203,5059236, 5059204,5059205,5059206,5059207,5059208,5059209
}
local PUMPKIN_ENTRY = 508905
local function Interface_AskFire(player,npc,intid)
	if player:GetTotalPlayedTime() > 60*60*24*2 then
		local lantern = player:AddItem(LANTER_ENTRY)
		if lantern then
			player:SetInfo("HalloweenHasLantern","1")
			player:SetInfo("HalloweenLanternCount","10")
		else
			player:Print("Повторите со свободным местом в инвентаре.")
		end
	else
		player:Print("Ты пока еще не достоин. Подходи когда наберешься мудрости.")
	end
end

local function OnNPCClick(event, player, npc)
	local interace = player:CreateInterface()
	local data = player:GetInfo("HalloweenHasLantern")
	local title = ""
	if data then
		title = "А что будет если посадить здесь арбузы..."
	else
		title = "Тебя интересуют дары Тыквовинской жатвы? Лишь огонь из этой деревни поможет тебе их добыть."
		interace:AddRow("Попросить огонь Страхвилла",Interface_AskFire,true)
	end
	interace:AddClose():SetIcon(0)
	interace:Send(title,npc)
end
local function OnNPCSelect(event, player, object, sender, intid, code, menu_id)
	player:CurrentInterface():Click(intid,object,code)
end
local function OnPumpkinClick(event, player, object)
	if player:HasItem(LANTER_ENTRY) then
		local entry = ITEMS[math.random(1,#ITEMS)]
		local count = tonumber(player:GetInfo("HalloweenLanternCount")) or 10
		if count < 1 then
			return false
		end
		local item = player:AddItem(entry)
		
		if item and count > 0then
			count = count - 1
			player:SetInfo("HalloweenLanternCount",tostring(count))
			player:Print("|cffff7588Вы подносите фонарь к тыкве и та всыхивает зеленым пламенем. Из пепла вы достаете|r "..item:GetItemLink())
			if count == 0 then
				player:RemoveItem(LANTER_ENTRY,1)
				player:Print("|cffff7588В вашем фонаре тухнет последний язычек пламени.")
				player:AddItem(DEAD_LANTER_ENTRY)
			end
			object:RemoveFromWorld(false)
		else
			player:Print("Повторите со свободным местом в инвентаре.")
		end
	elseif player:HasItem(DEAD_LANTER_ENTRY) then
		player:Print("|cffff7588Огонь вашего фонаря потух. Жатва собрана.")
	else
		player:SendAreaTriggerMessage("Эта тыква явно заколдована, но у вас пока нет ничего, чем бы вы могли добыть ее содержимое.")
	end
end

RegisterGameObjectGossipEvent(PUMPKIN_ENTRY,1,OnPumpkinClick)

RegisterCreatureGossipEvent(NPC_ENTRY,2,OnNPCSelect)
RegisterCreatureGossipEvent(NPC_ENTRY,1,OnNPCClick)

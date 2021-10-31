Halloween = Halloween or {}
local NPC_ENTRY = 987825


local function Interface_SendName(player,npc,intid,code)
	math.randomseed(os.time())
	local reversedName = string.utf8lower(string.utf8reverse(player:GetName()))
	code = string.utf8lower(code)
	local rand = math.random()
	if code == reversedName then
		local item = player:AddItem(5059255)
		if item then
			npc:SendUnitEmote("Дух Страхвилля засовывает руку в грудь "..player:GetName().." и достает "..item:GetItemLink(8))
			player:SetInfo("HalloweenSecretNPC","1")
		else
			player:Print("Повторите действие со свободным местом в инвентаре")
		end
	elseif code == string.utf8lower(player:GetName()) then
		player:Print("|cffFFFFFFДух Страхвилля говорит: - Имя это оставь ты для живых. - Город мертвых не приемлет таковых.")
	else
		player:Print("|cffFFFFFFДух Страхвилля говорит: - Не неси страхвилла духу ты туфты. - От смерти до рождения молви имя ты.")
	end
end

local function OnNPCClick(event, player, npc)
	local interace = player:CreateInterface()
	local data = player:GetInfo("HalloweenSecretNPC")
	local title = ""
	if data and data == "1" then
		title = "Для Страхвилла твой лик уже знаком\nДля местных ты не будешь более врагом"
	else
		title = "Не знает имени твоего Страхвилл\nПрочь ступай, покуда жизни не лишил"
		interace:AddAskRow("Сказать свое имя",Interface_SendName,true)
	end
	interace:AddClose():SetIcon(0)
	interace:Send(title,npc)
end
local function OnNPCSelect(event, player, object, sender, intid, code, menu_id)
	player:CurrentInterface():Click(intid,object,code)
end



RegisterCreatureGossipEvent(NPC_ENTRY,2,OnNPCSelect)
RegisterCreatureGossipEvent(NPC_ENTRY,1,OnNPCClick)














local entry = {
	quest = {
		thief = 110052,
		law = 110053,
	},
	questgiver = {
		thief = 9929479,
		law = 9929478,
	}
}

--[[	ОГРАНИЧЕНИЕ ВЫБОРА ФРАКЦИИ	]]--
--	Игрок может выбрать фракцию Тени Штормграда только имея социальную роль Вольного Жителя.
--	Игрок также не может выбрать фракцию до выбора социальной роли.

-- Агитатор Теней
local function Creature_Gossip( event, player, creature )
	local text
	local Q = CharDBQuery( "SELECT id FROM character_citycraft_config WHERE character_guid = "..player:GetGUIDLow() )
	if Q then
	--	Игрок уже выбрал социальную роль
		if player:HasAura(91058) then
		--	Игрок вольный житель
			text = "Заплутал? Могу подсказать дорогу."
			player:GossipAddQuests( creature )
		else
		--	Игрок имеет другую социальную роль
			text = "Я с такими как ты не вожусь, понятно?\n\n|cff360009Обратите внимание, для вступления в Тени Штормграда вы должны быть Вольным Жителем."
		end
	else
	--	Игрок ещё не выбрал социальную роль
		text = "Я тебя не знаю. Когда покажешь себя - приходи.\n\n|cff360009Вы ещё не выбрали социальную роль. Для её выбора поищите Джибби - он должен быть где-то неподалёку.\n\nОбратите внимание, для вступления в Тени Штормграда вы должны быть Вольным Жителем."
	end
	player:GossipSetText( text, 16122001 )
	player:GossipSendMenu( 16122001, creature )
end
RegisterCreatureGossipEvent( entry.questgiver.thief, 1, Creature_Gossip ) -- GOSSIP_EVENT_ON_HELLO

--	Агитатор Штормграда
local function Creature2_Gossip( event, player, creature )
	local text
	local Q = CharDBQuery( "SELECT id FROM character_citycraft_config WHERE character_guid = "..player:GetGUIDLow() )
	if Q then
	--	Игрок уже выбрал социальную роль
		text = "Рад видеть тебя."
		player:GossipAddQuests( creature )
	else
	--	Игрок ещё не выбрал социальную роль
		text = "Ты в городе недавно, да?\n\n|cff360009Вы ещё не выбрали социальную роль. Для её выбора поищите Джибби - он должен быть где-то неподалёку."
	end
	player:GossipSetText( text, 16122003 )
	player:GossipSendMenu( 16122003, creature )
end
RegisterCreatureGossipEvent( entry.questgiver.law, 1, Creature2_Gossip ) -- GOSSIP_EVENT_ON_HELLO

--[[	ПРЕДУПРЕЖДЕНИЕ О НЕДОПУСТИМОЙ КОМБИНАЦИИ РОЛИ И ФРАКЦИИ	]]--

local function Player_OnLogin( _, player )
	local Q = CharDBQuery( "SELECT city_class FROM character_citycraft_config WHERE character_guid = "..player:GetGUIDLow() )
	if Q then
		local role = Q:GetUInt32(0)
		if ( role ~= 91058 ) and player:GetQuestStatus( 110052 ) == 6 then
		--	Игрок вступил в Тени Штормграда имея не ту роль
			player:SendBroadcastMessage("|cffFF4500[!!]|r Только игроки имеющие социальную роль \"Вольный Житель\" могут улучшать репутацию с Тенями Штормграда. Тени не желают иметь дела с официальными представителями королевских структур. При желании развития репутации с Тенями Штормграда, пожалуйста, выберите социальную роль повторно.")
		end
	end
end
RegisterPlayerEvent( 3, Player_OnLogin ) -- PLAYER_EVENT_ON_LOGIN
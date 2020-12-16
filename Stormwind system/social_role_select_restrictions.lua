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

local function Creature_Gossip( event, player, creature, sender, intid )
	local text
	if player:HasAura(91058) then
	--	Игрок вольный житель
		text = "Заплутал? Могу подсказать дорогу."
		player:GossipAddQuests( creature )
	else
	--	Игрок имеет другую социальную роль
		text = "У меня для тебя дел нет, проваливай."
	end
	player:GossipSetText( text, 16122001 )
	player:GossipSendMenu( 16122001, creature )
end
RegisterCreatureGossipEvent( entry.questgiver.thief, 1, Creature_Gossip ) -- GOSSIP_EVENT_ON_HELLO
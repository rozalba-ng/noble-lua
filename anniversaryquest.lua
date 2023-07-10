
local quests = {
	
	[1] = { -- "Где же он?"
		id = 110293,
		questgiver = 12120404,
		creature = 9930643,
		players = {},
	},
}


--[[	1 квест		]]--
--	"Где же он?"

quests[1].OnStart = function( event, player, creature, quest )
	if ( quest:GetId() == quests[1].id ) then
		quests[1].players[player:GetName()] = 0
	end
end
RegisterCreatureEvent( quests[1].questgiver, 31, quests[1].OnStart ) -- CREATURE_EVENT_ON_QUEST_ACCEPT

quests[1].OnGossip = function( event, player, creature )
	if ( event == 1 ) then
		local text = Roulette( "А?", "Чего надо?", "Что-то нужно?", "О, привет!" )
		player:GossipSetText( text, 14042101 )
		
		if ( player:HasQuest( quests[1].id ) and quests[1].players[player:GetName()] < 9 ) then
			player:GossipMenuAddItem( 0, "Чудесный дракончик, милый и с высунутым языком. Вспоминай!", 1, 1 )
			player:GossipMenuAddItem( 0, "Вы не видели тут Ноблика?", 1, 2 )
			player:GossipMenuAddItem( 0, "Не заставляй меня применять довод Кольтиры... Где НОБЛИК?!", 1, 3 )
			player:GossipMenuAddItem( 0, "Не подскажете, где находится Ноблик?", 1, 4 )
		end
		
		player:GossipSendMenu( 14042101, creature )
	else
		creature:SendChatMessageToPlayer( 12, 0, Roulette( "Кажется, он пошел туда.", "Такого не видели сегодня.", "Я его видел сегодня рядом с Райдом!" ), player )
		player:GossipComplete()
		creature:DespawnOrUnsummon(0)
		
		quests[1].players[player:GetName()] = quests[1].players[player:GetName()] + 1
		if ( quests[1].players[player:GetName()] >= 6 ) then
			player:CompleteQuest(quests[1].id)
			player:SendAreaTriggerMessage("Все зеваки опрошены!")
		else
			player:SendAreaTriggerMessage("Опрошено "..quests[1].players[player:GetName()].." зевак из 6.")
		end
	end
end
RegisterCreatureGossipEvent( quests[1].creature, 1, quests[1].OnGossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( quests[1].creature, 2, quests[1].OnGossip ) -- GOSSIP_EVENT_ON_SELECT
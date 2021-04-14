
local quests = {
	[1] = { --	"Квартал тусклых фонарей"
		id = 110084,
		questgiver = 9930671,
		gameobject = 5049683,
		item = 5057588,
		players = {},
	},
	
	[2] = { --	"Не бандит, но крысолов!"
		id = 110085,
		creature = { 9930639, 9930640, 9930641, 9930642 },
		item = { 5057592, 5057589, 5057591, 5057590 },
	},
	
	[3] = { --	"Свободная пресса"
		id = 110086,
		questgiver = 9930673,
		gameobject = 5049684,
		item = 5057593,
		players = {},
	},
	
	[4] = { -- "Нагреть шпану"
		id = 110087,
		questgiver = 9930672,
		creature = 9930643,
	},
}

--[[	1 квест 	]]--
--	"Квартал тусклых фонарей"

quests[1].OnStart = function( event, player, creature, quest )
	if ( quest == quests[1].id ) then
		quests[1].players[player:GetName()] = 0
	end
end
RegisterCreatureEvent( quests[1].questgiver, 31, quests[1].OnStart ) -- CREATURE_EVENT_ON_QUEST_ACCEPT

quests[1].OnGossip = function( event, arg1, arg2 )
	if event == 14 then
	
		local player = arg2
		local object = arg1
		
		local text
		if ( object:GetData("QUEST") and os.time() - object:GetData("QUEST") > 300 ) then
			text = "<Этот фонарь пока не нуждается в заправке.>"
		else
			text = Roulette( "<Фонарь почти потух.>", "<Фонарь слабо мерцает.>" )
		end
		player:GossipSetText( text, 01042001 )
		
		if player:HasQuest( quests[1].id and player:HasItem( quests[1].item ) then
			if quests[1].players[player:GetName()] and quests[1].players[player:GetName()] < 9 then
				if ( not object:GetData("QUEST") ) or ( os.time() - object:GetData("QUEST") ) > 300 then
					player:GossipMenuAddItem( 0, "<Подлить масла в фонарь.>", 1, 1 )
				else
					print( object:GetData("QUEST") )
					print( os.time() - object:GetData("QUEST") )
				end
			else
				print("жопа")
			end
		else
			print("хуй")
		end
		
		player:GossipSendMenu( 01042001, object )
		
	else
	
		local player = arg1
		local object = arg2
		
		if ( player:HasQuest( quests[1].id ) and player:HasItem( quests[1].item ) and quests[1].players[player:GetName()] < 9 ) then
			player:GossipComplete()
			quests[1].players[player:GetName()] = quests[1].players[player:GetName()] + 1
			object:SetData("QUEST", os.time())
		end
		
		if ( quests[1].players[player:GetName()] == 9 ) then
			player:SendAreaTriggerMessage("Все фонари зажжены.")
			player:CompleteQuest(quests[1].id)
			player:UpdatePhaseMask()
		else
			player:SendAreaTriggerMessage( quests[1].players[player:GetName()].." фонарей из 9 зажжено." )
		end
		
	end
end
RegisterGameObjectEvent( quests[1].gameobject, 14, quests[1].OnGossip ) -- GAMEOBJECT_EVENT_ON_USE
RegisterGameObjectGossipEvent( quests[1].gameobject, 2, quests[1].OnGossip ) -- GOSSIP_EVENT_ON_SELECT

--[[	2 квест 	]]--
--	"Не бандит, но крысолов!"

quests[2].OnGossip = function( _, player, creature )
	if ( player:HasQuest(quests[2].id) ) then
		local entry = creature:GetEntry()
		local item = quests[2].item[table.find( quests[2].creature, entry )]
		if not ( player:HasItem( item, 5 ) ) then
		
			player:AddItem( item, 1 )
			player:Emote(69)
			player:Kill(creature)
			
			if ( player:HasItem(quests[1].item[1], 5) and player:HasItem(quests[1].item[2], 5) and player:HasItem(quests[1].item[3], 5) and player:HasItem(quests[1].item[4], 5) ) then
				player:SendAreaTriggerMessage("Все крысы пойманы.")
				player:CompleteQuest(quests[2].id)
				player:UpdatePhaseMask()
			end
			
		else
			player:SendAreaTriggerMessage("Вы собрали достаточное количество крыс этого вида.")
		end
	else
		player:SendAreaTriggerMessage("<Крыса выглядит мерзко.>")
	end
end
RegisterCreatureGossipEvent( quests[2].creature[1], 1, quests[2].OnGossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( quests[2].creature[2], 1, quests[2].OnGossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( quests[2].creature[3], 1, quests[2].OnGossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( quests[2].creature[4], 1, quests[2].OnGossip ) -- GOSSIP_EVENT_ON_HELLO

--[[	3 квест 	]]--
--	"Свободная пресса"

quests[3].OnStart = function( event, player, creature, quest )
	if ( quest == quests[3].id ) then
		quests[3].players[player:GetName()] = {}
	end
end
RegisterCreatureEvent( quests[3].questgiver, 31, quests[3].OnStart ) -- CREATURE_EVENT_ON_QUEST_ACCEPT

quests[3].OnGossip = function( event, arg1, arg2 )
	if event == 14 then
	
		local player = arg2
		local object = arg1
		
		local guid = object:GetDBTableGUIDLow()
		
		local text = "<...>"
		if not table.find( quests[3].players[player:GetName()], guid ) and player:HasQuest( quests[3].id ) then
			if player:HasItem( quests[3].item, 1) then
				player:GossipMenuAddItem( 0, "<Вложить газету в ящик.>", 1, 1 )
			end
		elseif player:HasQuest( quests[3].id ) then
			text = "<Вы уже доставили газету в этот ящик.>"
		end
		player:GossipSetText( text, 06042101 )
		player:GossipSendMenu( 06042101, object )
		
	else
	
		local player = arg1
		local object = arg2
		
		local guid = object:GetDBTableGUIDLow()
		table.insert( quests[3].players[player:GetName()], guid )
		player:RemoveItem( quests[3].item, 1 )
		
		if ( #quests[3].players[player:GetName()] == 5 ) then
			player:SendAreaTriggerMessage("Все газеты доставлены.")
			player:CompleteQuest(quests[3].id)
			player:UpdatePhaseMask()
		else
			player:SendAreaTriggerMessage( #quests[3].players[player:GetName()].." газет из 5 доставлено." )
		end
		
	end
end
RegisterGameObjectEvent( quests[3].gameobject, 14, quests[3].OnGossip ) -- GAMEOBJECT_EVENT_ON_USE
RegisterGameObjectGossipEvent( quests[3].gameobject, 2, quests[3].OnGossip ) -- GOSSIP_EVENT_ON_SELECT

--[[	4 квест		]]--
--	"Нагреть шпану"

quests[4].OnStart = function( event, player, creature, quest )
	if ( quest == quests[4].id ) then
		quests[4].players[player:GetName()] = 0
	end
end
RegisterCreatureEvent( quests[4].questgiver, 31, quests[4].OnStart ) -- CREATURE_EVENT_ON_QUEST_ACCEPT

quests[4].OnGossip = function( event, player, creature )
	if ( event == 1 ) then
		local text = Roulette( "А?", "Чего надо?", "Монетки есть?", "<Ребёнок важно глядит на вас.>" )
		player:GossipSetText( text, 14042101 )
		
		if ( player:HasQuest( quests[4].id ) and quests[4].players[player:GetName()] < 9 ) then
			player:GossipMenuAddItem( 0, "<Дать подзатыльник и напомнить про Бориса.>", 1, 1 )
			player:GossipMenuAddItem( 0, "Эй, мелочь. У тебя должок перед сам-знаешь-кем.", 1, 2 )
			player:GossipMenuAddItem( 0, "И на это ты хочешь потратить свою молодость? Одумайся, пока не поздно!", 1, 3 )
			player:GossipMenuAddItem( 0, "Борис просил зайти к нему. Сделаешь?", 1, 4 )
		end
		
		player:GossipSendMenu( 14042101, creature )
	else
		creature:SendChatMessageToPlayer( 12, 0, Roulette( "Я вас не знаю, до свидания!", "А? Ой, мне пора!", "Ладно, урок усвоил!" ), player )
		player:GossipComplete()
		quests[4].players[player:GetName()] = quests[4].players[player:GetName()] + 1
		if ( quests[4].players[player:GetName()] >= 8 ) then
			player:CompleteQuest(quests[4].id)
			player:UpdatePhaseMask()
			player:SendAreaTriggerMessage("Все беспризорники проучены!")
		else
			player:SendAreaTriggerMessage("Проучено "..quests[4].players[player:GetName()].." беспризорников из 8.")
		end
	end
end
RegisterCreatureGossipEvent( quests[4].creature, 1, quests[4].OnGossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( quests[4].creature, 2, quests[4].OnGossip ) -- GOSSIP_EVENT_ON_SELECT
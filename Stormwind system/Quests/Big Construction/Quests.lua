
local quests = {
	[1] = { --	"Перевыполнить план"
		entry = 110080,
		gameobject = 5049936,
	},
	[2] = { -- "Все на стройку!"
		entry = 110083,
		creature = 11001656,
		players = {},
	},
}

--[[	ВСЕ - 1 квест	]]--
--	"Перевыполнить план"

quests[1].OnGossip = function( event, arg1, arg2 )
	if event == 14 then
	
		local player = arg2
		local object = arg1
		
		local text = Roulette( "<Урна приветливо звенит.>", "<Урна выглядит крепкой.>", "<Вы чувствуете умиротворение.>" )
		player:GossipSetText( text, 04032101 )
		
		if player:HasQuest( quests[1].entry ) then
			player:GossipMenuAddItem( 0, "<Совершить пожертвование.>", 1, 1, false, "Вы хотите совершить пожертвование?", 500 )
		end
		
		player:GossipSendMenu( 04032101, object )
		
	else
	
		local player = arg1
		local object = arg2
		
		if player:HasQuest( quests[1].entry ) then
			if player:GetCoinage() >= 500 then
				player:ModifyMoney(-500)
				player:CompleteQuest( quests[1].entry )
				player:GossipComplete()
				object:PlayDirectSound( 864, player )
			end
		end
		
	end
end
RegisterGameObjectEvent( quests[1].gameobject, 14, quests[1].OnGossip ) -- GAMEOBJECT_EVENT_ON_USE
RegisterGameObjectGossipEvent( quests[1].gameobject, 2, quests[1].OnGossip ) -- GOSSIP_EVENT_ON_SELECT

--[[	ВСЕ - 2 квест	]]--
--	"Все на стройку!"

quests[2].OnGossip = function( event, player, creature )
	if event == 1 then
	
		if not creature:GetData("Timer") or ( os.time() - creature:GetData("Timer") ) > 300 then
			local text = Roulette( "Работёнку бы какую!", "Чего?", "А?", "Ты пришёл дать мне денег?" )
			player:GossipSetText( text, 04032102 )
			
			if player:HasQuest( quests[2].entry ) then
				player:GossipMenuAddItem( 0, Roulette("У меня есть для тебя работа.","<Рассказать про стройку.>","За работу!","<Позвать на стройку.>","Я могу предложить тебе одно дельце...","Хочешь сто золотых?"), 1,1 )
				local name = player:GetName()
				if not quests[2].players[name] then
					quests[2].players[name] = 0
				end
			end
			
			player:GossipSendMenu( 04032102, creature )
		else
		
			local text = Roulette( "Я занят.", "Хочешь чтобы я из-за тебя на работу опоздал?", "Слышал про стройку? Я там работаю." )
			player:GossipSetText( text, 04032103 )
			player:GossipSendMenu( text, 04032103 )
			
		end
		
	else
	
		local name = player:GetName()
		if quests[2].players[name] >= 5 then
			quests[2].players[name] = nil
			player:CompleteQuest( quests[2].entry )
			player:SendAreaTriggerMessage("Задание выполнено!")
		else
			quests[2].players[name] = quests[2].players[name] + 1
			player:SendAreaTriggerMessage("Завербовано "..quests[2].players[name].." нищих из 6.")
		end
		creature:SetData("Timer",os.time())
		player:GossipComplete()
	
	end
end
RegisterCreatureGossipEvent( quests[2].creature, 1, quests[2].OnGossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( quests[2].creature, 2, quests[2].OnGossip ) -- GOSSIP_EVENT_ON_SELECT
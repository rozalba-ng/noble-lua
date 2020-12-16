
local quests = {
	[1] = { --	"Помощь бедным"
		entry = 110062,
		npc = 9929515,
		players = {},
	},
}

--[[	ДВОРЯНЕ	- 1 квест	]]--
--	"Помощь бедным"

local function Gossip_HungryBeggar( event, player, creature, sender, intid )
	local guid = player:GetName()
	if event == 1 then
		local text
		if not quests[1].players[guid] then
			quests[1].players[guid] = 0
		--	
		--	ПРОБЛЕМА
		--	Тут кладём в таблицу число
			print(quests[1].players[guid]) -- Тут ноль
		end
		if creature:GetData("Fed") and ( ( os.time() - creature:GetData("Fed") ) > 300 ) then
		--	Нищий недавно накормлен
			text = Roulette( "А?", "Ась?", "Не мешай.", "<Нищий сыто икает.>" )
		elseif player:HasQuest( quests[1].entry ) and not ( quests[1].players[guid] >= 5 ) then
		--	Игрок имеет задание
			text = Roulette( "Есть поесть?", "Подайте монетку!", "Живот сводит...", "Знали бы вы, как я голоден.", "Что там у вас?" )
			player:GossipMenuAddItem( 0, "<Накормить голодающего.>", 1, 1 )
		elseif player:HasAura(91055) then
		--	Игрок из дворян
			text = "Господин, подайте на пропитание!"
		elseif player:HasAura(91057) then
		--	Игрок из магократии
			text = "Не наколдует ли господин маг мне поесть?"
		else
			text = "Как же хочется есть... Я сейчас даже крысу помойную не прочь сожрать!"
		end
		player:GossipSetText( text, 17122001 )
		player:GossipSendMenu( 17122001, creature )
	else
		creature:SetData( "Fed", os.time() )
		player:TalkingHead( creature, Roulette( "Вот это по нашему!", "Спасибо, добрейший человек.", "Сейчас перекусим.", "Благодарю! Всех вам благ!", "Ух... Горяченькое!", "Солички не найдётся?", "Сытым дольго не пробудешь..." ) )
		--
		--	ПРОБЛЕМА
		--	Тут его уже нет. Вопрос: Где?
		print(quests[1].players[guid]) -- Тут уже nil
		quests[1].players[guid] = quests[1].players[guid] + 1
		if quests[1].players[guid] >= 5 then
			player:CompleteQuest( quests[1].entry )
			player:SendAreaTriggerMessage("Горячие блюда розданы.")
		else
			player:SendAreaTriggerMessage("Накормлено "..quests[1].players[guid].." нищих из 5.")
		end
	end
end
RegisterCreatureGossipEvent( quests[1].npc, 1, Gossip_HungryBeggar ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( quests[1].npc, 2, Gossip_HungryBeggar ) -- GOSSIP_EVENT_ON_SELECT
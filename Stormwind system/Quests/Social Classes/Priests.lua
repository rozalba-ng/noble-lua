
local quests = {
	[1] = { --	"Помощь нуждающимся"
		entry = 110058,
		npc = 9929513,
		questgiver = 9929514,
		players = {},
	},
}

--[[	ДУХОВЕНСТВО - 1 квест	]]--
--	"Помощь нуждающимся"

local function Gossip_SickBeggar( event, player, creature, sender, intid )
	local name = player:GetName()
	if event == 1 then
		local text
		if not quests[1].players[name] then
			quests[1].players[name] = 0
		end
		if creature:GetData("Healed") and ( ( os.time() - creature:GetData("Healed") ) <= 300 ) then
		--	Нищий недавно вылечен
			text = Roulette( "Жизнь чудесна пока зубы не болят.", "Вам чего?", "Ну и погодка - ноги отморозишь.", "<Нищий зевает.>" )
		elseif player:HasQuest( quests[1].entry ) and not ( quests[1].players[name] >= 5 ) then
		--	Игрок имеет задание
			text = Roulette( "А если зуб шатается - сможете помочь?", "Ногу я, значит, вчера отморозил, а руку три года назад потерял. Без ноги то я проживу...", "Живот сводит...", "Синяк под глазом видали?", "Что там у вас?" )
			player:GossipMenuAddItem( 0, "<Оказать нищему помощь.>", 1, 1 )
		elseif player:HasAura(91056) then
		--	Игрок из духовенства
			text = "Пусть Свет освещает ваши пути, господин!"
		elseif player:HasAura(91058) then
		--	Игрок из вольных жителей
			text = "Чего тебе, бедолага?"
		else
			text = "Помру я на этом холоде, ой помру."
		end
		player:GossipSetText( text, 17122001 )
		player:GossipSendMenu( 17122001, creature )
	else
		quests[1].players[name] = quests[1].players[name] + 1
		if quests[1].players[name] >= 5 then
			player:CompleteQuest( quests[1].entry )
			player:SendAreaTriggerMessage("Вы помогли нуждающимся.")
		--	Обновление фазы для корректного отображения иконок квестов
			player:SetPhaseMask(524288)
			player:SetPhaseMask(1)
		else
			player:SendAreaTriggerMessage("Вылечено "..quests[1].players[name].." нищих из 5.")
		end
		creature:SetData( "Healed", os.time() )
		creature:AddAura( 35207, creature )
		creature:SendUnitSay( Roulette( "Надо же, я теперь как новенький!", "Спасибо, добрейший человек.", "Ну и ну... Чудеса да и только.", "Благодарю! Всех вам благ!", "Спасибо Свету! Ну и вам, конечно.", "Уже казалось, что помру тут в холоде.", "Век не забуду!", "Если бы не вы - я бы тогда может и помер.", "Спасибо.", "Я этого не забуду." ), 0 )
		player:GossipComplete()
	end
end
RegisterCreatureGossipEvent( quests[1].npc, 1, Gossip_SickBeggar ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( quests[1].npc, 2, Gossip_SickBeggar ) -- GOSSIP_EVENT_ON_SELECT

local function WhenQuestAccepted_QuestGiver( event, player, creature, quest )
	if quest:GetId() == quests[1].entry then
		local name = player:GetName()
		quests[1].players[name] = nil
	end
end
RegisterCreatureEvent( quests[1].questgiver, 31, WhenQuestAccepted_QuestGiver ) -- CREATURE_EVENT_ON_QUEST_ACCEPT
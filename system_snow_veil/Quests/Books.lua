local quests = {
	[1] = {
		entry = 110279,
		npc = 988014,
		questgiver = 988015,
		players = {},
	},
}

local function BooksForKidsGossip( event, player, creature, sender, intid )
	local name = player:GetName()
	if event == 1 then
		local text
		if not quests[1].players[name] then
			quests[1].players[name] = 0
		end
		if creature:GetData("Educated") and ( ( os.time() - creature:GetData("Educated") ) <= 300 ) then
		--	В случае если уже отдали книгу
			text = Roulette( "А?", "Ещё что-то?", "Спасибо ещё раз!", "<Ребёнок увлечённо листает страницы книжки>", "М?", "Ой, а у меня такая уже есть дома.." )
		elseif player:HasQuest( quests[1].entry ) and not ( quests[1].players[name] >= 5 ) then
		--	Игрок имеет задание
			text = Roulette( "Ой, а что это у вас?", "<Ребёнок выжидаючи смотрит на вас.>", "Я вчера об одной очень интересной сказке слышал... Ой, это мне?", "Мы завтра с мамой и папой идём в книжную лавку! Представляете?", "А что там у вас в руках? Покажите?" )
			player:GossipMenuAddItem( 0, "<Вручить книгу.>", 1, 1 )
		else
		--  Просто текст в нпсе
			text = "Привет! Мне мама не разрешает разговаривать с незнакомыми..."
		end
		player:GossipSetText( text, 17122001 )
		player:GossipSendMenu( 17122001, creature )
	else
		quests[1].players[name] = quests[1].players[name] + 1
		if quests[1].players[name] >= 5 then
			player:CompleteQuest( quests[1].entry )
			player:SendAreaTriggerMessage("Все книжки были розданы.")
		--	Обновление фазы для корректного отображения иконок квестов
			player:SetPhaseMask(524288)
			player:SetPhaseMask(1)
		else
			player:SendAreaTriggerMessage("Роздано "..quests[1].players[name].." книг из 5.")
		end
		creature:SetData( "Educated", os.time() )
		creature:CastSpell( creature, 1459, true )
		creature:SendUnitSay( Roulette( "О, мне хотелось получить именно эту книгу!", "Спасибо! Спасибо! Спасибо!", "И что мне с ней делать? Под кресло подложить?..", "Мне уже хочется поскорее её прочесть!", "О, а там есть сказка про волка, колдуна и картонную коробку?", "А у меня для вас ничего нет...", "Нужно поскорее показать маме!", "Н-но я ещё не умею читать... Там есть картинки?" ), 0 )
		player:GossipComplete()
	end
end
RegisterCreatureGossipEvent( quests[1].npc, 1, BooksForKidsGossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( quests[1].npc, 2, BooksForKidsGossip ) -- GOSSIP_EVENT_ON_SELECT

local function WhenQuestAccepted_QuestGiver( event, player, creature, quest )
	if quest:GetId() == quests[1].entry then
		local name = player:GetName()
		quests[1].players[name] = nil
	end
end
RegisterCreatureEvent( quests[1].questgiver, 31, WhenQuestAccepted_QuestGiver ) -- CREATURE_EVENT_ON_QUEST_ACCEPT
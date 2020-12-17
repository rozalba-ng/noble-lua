
local quests = {
	[1] = { --	"Растопить лёд"
		entry = 110060,
		npc = 9929524,
		questgiver = 9929517,
		gameobject = 5049426,
		spell = 38042,
		players = {},
	},
}

--[[	ДВОРЯНЕ - 1 квест	]]--
--	"Растопить лёд"

local function WhenQuestAccepted_QuestGiver( event, player, creature, quest )
	if quest:GetId() == quests[1].entry then
		local name = player:GetName()
		if not quests[1].players[name] then
			quests[1].players[name] = {}
			quests[1].players[name].score = 0
			quests[1].players[name].creature = os.time()
			local x,y,z,o = player:GetLocation()
			local npc = player:SpawnCreature( quests[1].npc, x, y, z, o, 3, 600000 )
			npc:SetOwnerGUID( player:GetGUID() )
			npc:SetCreatorGUID( player:GetGUID() )
			npc:MoveFollow( player )
			player:TalkingHead( creature, "Не трогайте элементаля руками и не пытайтесь поджечь его спичками. Помните - призванное существо погаснет через десять минут. Взаимодействуйте с ним, чтобы избавиться от наледи." )
		else
			quests[1].players[name].score = 0
			if ( os.time() - quests[1].players[name].creature ) > 600 then
				quests[1].players[name].creature = os.time()
				local x,y,z,o = player:GetLocation()
				local npc = player:SpawnCreature( quests[1].npc, x, y, z, o, 3, 600000 )
				npc:SetOwnerGUID( player:GetGUID() )
				npc:SetCreatorGUID( player:GetGUID() )
				npc:MoveFollow( player )
				player:TalkingHead( creature, "Вы получите нового элементаля, но учтите - я помню как давал вам предыдущего." )
			else
				player:TalkingHead( creature, "Не слишком ли часто юный маг просит у меня элементаля? Нет? Тогда пускай он зайдёт попозже." )
			end
		end
	end
end
RegisterCreatureEvent( quests[1].questgiver, 31, WhenQuestAccepted_QuestGiver ) -- CREATURE_EVENT_ON_QUEST_ACCEPT

local function Gossip_Elemental( _, player, creature )
	creature:MoveFollow( player )
	if ( not creature:GetData("Reload") or ( os.time() - creature:GetData("Reload") ) > 3 ) then
		local go = creature:GetNearestGameObject( 5, quests[1].gameobject )
		if go then
			creature:AddAura( quests[1].spell, creature )
			creature:SetData( "Reload", os.time() )
			go:Despawn()
			local name = player:GetName()
			quests[1].players[name].score = quests[1].players[name].score + 1
			if quests[1].players[name].score >= 5 then
				player:CompleteQuest( quests[1].entry )
				player:SendAreaTriggerMessage("Лужи растоплены.")
			--	Обновление фазы для корректного отображения иконок квестов
				player:SetPhaseMask(524288)
				player:SetPhaseMask(1)
				creature:SendUnitEmote( "Элементаль гаснет." )
				creature:DespawnOrUnsummon(2000)
			else
				player:SendAreaTriggerMessage("Растоплено "..quests[1].players[name].." луж из 5.")
			end
		else
			player:TalkingHead( creature, Roulette( "<Недоумённо оглядывается.>", "<С сочувствием смотрит на вас.>", "<Упорно не замечает замерзшие лужи.>" ) )
		end
	else
		player:TalkingHead( creature, Roulette( "<Фыркает.>", "Грм-м..", "<Элементаль злобно урчит.>", "<Элементаль устало вздыхает.>", "<Элементаль как будто бы чихает.>" ) )
	end
end
RegisterCreatureGossipEvent( quests[1].npc, 1, Gossip_Elemental )
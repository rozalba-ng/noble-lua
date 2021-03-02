
local quests = {
	[1] = { --	"Коты-воришки"
		entry = 110064,
		--npc = 1211003, технический невидимый
		creature = 11001584,
		questgiver = 9929516,
		players = {},
		actions = { -- Рандомные действия при клике на кота.
			function(creature, player)
				creature:SendUnitEmote( Roulette("Кот - воришка недовольно фырчит.", "Кот-воришка не обращает на окружающих внимания.", "Кот-воришка зевает.") )
			end,
			function(creature, player)
				creature:SetFacingToObject(player)
			end,
			function(creature)
				creature:PlayDirectSound( 15705 )
			end,
		},
	},
}

--[[	ВОЛЬНЫЕ ЖИТЕЛИ - 1 квест	]]--
--	"Коты-воришки"

local function Gossip_Cat( _, player, creature )
	if player:HasQuest( quests[1].entry ) then
		if not creature:GetData("Clicked") or ( os.time() - creature:GetData("Clicked") ) > 10 then
			local name = player:GetName()
			if not quests[1].players[name] then
				quests[1].players[name] = 0
			end
			quests[1].players[name] = quests[1].players[name] + 1
			if quests[1].players[name] >= 8 then
				player:CompleteQuest( quests[1].entry )
				player:SendAreaTriggerMessage("Коты разогнаны.")
			--	Обновление фазы для корректного отображения иконок квестов
				player:SetPhaseMask(524288)
				player:SetPhaseMask(1)
			else
				player:SendAreaTriggerMessage("Прогнано котов: "..quests[1].players[name].." из 8.")
			end
			creature:PlayDirectSound( 15141 )
			creature:SetData("Clicked", os.time())
			creature:Emote(477)
			creature:DespawnOrUnsummon( 2000 )
		end
	elseif not creature:GetData("Click_Cooldown") or ( os.time() - creature:GetData("Click_Cooldown") ) > 10 then
		creature:SetData("Click_Cooldown", os.time())
		quests[1].actions[math.random(1,3)](creature,player)
	end
end
RegisterCreatureGossipEvent( quests[1].creature, 1, Gossip_Cat )

local function WhenQuestAccepted_QuestGiver( event, player, creature, quest )
	if quest:GetId() == quests[1].entry then
		local name = player:GetName()
		quests[1].players[name] = nil
		player:TalkingHead( creature, "Будь осторожен, говорят, эти коты уже кого-то покусали и он умер! Или это не про него... В общем, осторожнее!" )
	end
end
RegisterCreatureEvent( quests[1].questgiver, 31, WhenQuestAccepted_QuestGiver ) -- CREATURE_EVENT_ON_QUEST_ACCEPT
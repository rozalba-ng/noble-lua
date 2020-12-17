
local quests = {
	[1] = { --	"Растопить лёд"
		entry = 110060,
		npc = 9929524,
		questgiver = 9929517,
		gameobject = 5049426,
		players = {},
	},
}

--[[	ДВОРЯНЕ - 1 квест	]]--
--	"Растопить лёд"

local function WhenQuestAccepted_QuestGiver( event, player, creature, quest )
	if quest:GetId() == quests[1].entry then
		local name = player:GetName()
		if not quests[1].players[name] then
			quests[1].players[name].score = 0
			quests[1].players[name].creature = os.time()
			local x,y,z,o = player:GetLocation()
			local npc = player:SpawnCreature( quests[1].npc, x, y, z, o, 3, 10000 )
			npc:SetOwnerGUID( player:GetGUID() )
			npc:SetCreatorGUID( player:GetGUID() )
		end
	end
end
RegisterCreatureEvent( quests[1].questgiver, 31, WhenQuestAccepted_QuestGiver ) -- CREATURE_EVENT_ON_QUEST_ACCEPT
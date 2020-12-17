
local quests = {
	[1] = { --	"Сбить сосульки"
		entry = 110064,
		npc = 1211003,
		gameobject = 5049432,
		spell = 21343,
		players = {},
	},
}

--[[	ВОЛЬНЫЕ ЖИТЕЛИ - 1 квест	]]--
--	"Сбить сосульки"

local function OnClick_Icicle( event, go, player )
	local name = player:GetName()
	if not quests[1].players[name] then
		quests[1].players[name] = 0
	end
	quests[1].players[name] = quests[1].players[name] + 1
	if quests[1].players[name] >= 10 then
		player:CompleteQuest( quests[1].entry )
		player:SendAreaTriggerMessage("Сосульки сбиты.")
	--	Обновление фазы для корректного отображения иконок квестов
		player:SetPhaseMask(524288)
		player:SetPhaseMask(1)
	else
		player:SendAreaTriggerMessage("Сбито сосулек: "..quests[1].players[name].." из 10.")
	end
	local x,y,z = go:GetLocation()
	local creature = go:SpawnCreature( quests[1].npc, x, y, z, 0, 3, 2000 )
	player:CastSpell( creature, quests[1].spell, true )
	go:Despawn()
end
RegisterGameObjectEvent( quests[1].gameobject, 14, OnClick_Icicle ) -- GAMEOBJECT_EVENT_ON_USE

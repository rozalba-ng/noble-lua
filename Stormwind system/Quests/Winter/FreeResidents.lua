
local quests = {
	[1] = { --	"Сбить сосульки"
		entry = 110064,
		npc = 1211001,
		gameobject = 5049432,
		spell = 21343,
		players = {},
	},
}

--[[	ВОЛЬНЫЕ ЖИТЕЛИ - 1 квест	]]--
--	"Сбить сосульки"

local function OnClick_Icicle( event )
	print(event)
end
RegisterGameObjectEvent( quests[1].gameobject, 8, OnClick_Icicle ) -- GAMEOBJECT_EVENT_ON_DAMAGED
RegisterGameObjectEvent( quests[1].gameobject, 9, OnClick_Icicle ) -- GAMEOBJECT_EVENT_ON_LOOT_STATE_CHANGE
RegisterGameObjectEvent( quests[1].gameobject, 10, OnClick_Icicle ) -- GAMEOBJECT_EVENT_ON_GO_STATE_CHANGED
RegisterGameObjectEvent( quests[1].gameobject, 14, OnClick_Icicle ) -- GAMEOBJECT_EVENT_ON_USE

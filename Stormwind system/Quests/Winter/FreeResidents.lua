
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

local function OnClick_Icicle( event, go, player )
	go:Despawn()
end
RegisterGameObjectEvent( quests[1].gameobject, 14, OnClick_Icicle ) -- GAMEOBJECT_EVENT_ON_USE

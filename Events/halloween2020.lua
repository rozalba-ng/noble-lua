
--		Разбегающиеся тараканы
local entry_cockroach = 110002

--[[	ХРУСТЯЩИЕ ТАРАКАНЫ	]]--

--	Поимка таракана
local function Gossip_ScaredCockroach( event, player, creature )
	player:Kill( creature )
	player:Emote( 60 )
	creature:DespawnOrUnsummon( 1500 )
end
RegisterCreatureGossipEvent( entry_cockroach, 1, Gossip_ScaredCockroach )
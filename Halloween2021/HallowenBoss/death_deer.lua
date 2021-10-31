Halloween = Halloween or {}

--	Entry лося
local DEER_ENTRY = 987822

--	Ауры
local AURA_RED = 52670
local AURA_BLUE = 52619 -- После активации

Halloween.DeerList = {}
Halloween.DeerWorldMessages = {
	"Жители города находят трупы лосей. Трупы светятся красным.",
	"Что-то нехорошее скоро начнётся.",
	"ПО ЗЛОВЕЩЕМУ ГОРОДКУ ПРОНОСИТСЯ ЗЛОВЕЩИЙ ВЕТЕР... ВОТ-ВОТ ПРОБУДИТСЯ ОЧЕНЬ-ОЧЕНЬ САМОЕ ДРЕВНЕЕ И СТРАШНОЕ ЗЛО НЕКОГДА ДВАЖДЫ УНИЧТОЖИВШЕЕ ЭТОТ МИР (не вампир)",
}

local function OnSpawn(_,creature)
	local guid = saveCreature(creature)
	Halloween.DeerList[guid] = false
	creature:AddAura(AURA_RED, creature)
end
RegisterCreatureEvent( DEER_ENTRY, 36, OnSpawn ) -- CREATURE_EVENT_ON_ADD

local function OnReloadEluna()
	for guid,_ in pairs(Halloween.DeerList) do
		local creature = loadCreature(guid)
		if creature then
			creature:SetRespawnDelay(15) --10							ЗАМЕНИТЬ
			creature:Kill(creature)
		end
	end
end
RegisterServerEvent( 16, OnReloadEluna ) -- ELUNA_EVENT_ON_LUA_STATE_CLOSE

local function OnClick(_,player, creature)
	if creature:HasAura(AURA_RED) then
		creature:RemoveAura(AURA_RED)
		creature:AddAura(AURA_BLUE, creature)
		Halloween.DeerList[creature:GetDBTableGUIDLow()] = true
		
		local counter = 0
		for _,activated in pairs(Halloween.DeerList) do
			counter = activated and counter + 1 or counter
		end
		
		local map = creature:GetMap()
		local players = map:GetPlayers()
		for i = 1, #players do
			players[i]:SendBroadcastMessage("|cffff7588"..Halloween.DeerWorldMessages[counter])
		end
		
		if counter == #Halloween.DeerWorldMessages then
			Halloween.BossAppear(creature)
			Halloween.DeerRespawn()
		end
	end
end
RegisterCreatureGossipEvent( DEER_ENTRY, 1, OnClick ) -- GOSSIP_EVENT_ON_HELLO

function Halloween.DeerRespawn()
	for guid,_ in pairs(Halloween.DeerList) do
		Halloween.DeerList[guid] = false
		local creature = loadCreature(guid)
		if creature then
			creature:RegisterEvent(function(_,_,_, creature)
				creature:AddAura(AURA_RED, creature)
				creature:RemoveAura(AURA_BLUE)
			end, 1*60*60*1000)	--			ЗАМЕНИТЬ НА 1 час
		end
	end
end
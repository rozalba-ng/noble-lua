local BookID = 988008
local VillMurloc = 988009
local VillWolf = 988011 
local VillKoschey =  988010 
local VillRacoon = 988012 
local VillPhoenix = 988013 

local MiniBosses = {
	VillMurloc,
	VillWolf,
	VillKoschey,
	VillRacoon,
	VillPhoenix,
}

local CombatPhrases = {
	'Никто не хочет читать старые добрые сказки!',
	'Когда-то, давным-давно... Но вы уже это не узнаете! Потому что не доживете до конца сказки!',
	'Я отомщу за каждую помятую страничку, за каждую попавшую в меня крошку!',
	'И вдруг все сказки станут былью!',
	'А это вам за то, что какой-то ребёнок вчера на предпоследней страничке пририсовал усы на картинке!',
}

local takenBookDamage = 0
local lastPhraseTime = 0
local takenMurlocDamage = 0
local timeFromStarBattle = 0

local function OnEnterCombat (event, creature, target)
	totalTakenDamage = 0
	lastPhraseTime = os.time()
	creature:SendUnitSay( 'Недо-герои, я уничтожу вас, а после, примусь за героев из сказок!', 0 )
end

RegisterCreatureEvent( BookID, 1, OnEnterCombat )

local function OnLeaveCombat (event, creature)
	for i = 1, #MiniBosses do
        local creatures = creature:GetCreaturesInRange(30, MiniBosses[i])
        for x = 1, #creatures do
            creatures[x]:DespawnOrUnsummon(0)
        end
    end
end

RegisterCreatureEvent( BookID, 2, OnLeaveCombat )

local function OnTakenDamageBook (event, creature, attacker, damage)
	if os.time()-lastPhraseTime > 30 then
		lastPhraseTime = os.time()
		creature:SendUnitSay( CombatPhrases[math.random(1,#CombatPhrases)], 0 )
	end
	takenBookDamage = takenBookDamage + damage
	if takenBookDamage > 300 then
		takenBookDamage = 0
		local x, y, z, o = creature:GetLocation()
		creature:SendUnitSay( 'Эй, подручный, на помощь!', 0 )
		creature:SpawnCreature( MiniBosses[math.random(1,#MiniBosses)], x, y, z+2, o, 5 )
	end
end

RegisterCreatureEvent( BookID, 9, OnTakenDamageBook )

-- [[   MURLOC   ]] --
local function OnMurlocSpawn (event, creature)
	creature:CastCustomSpell(creature, 24085)
	creature:SendUnitSay( 'У меня такие большие глаза, чтобы лучше тебя видеть!', 0 )
end

RegisterCreatureEvent( VillMurloc, 5, OnMurlocSpawn )

local function OnTakenDamageMurloc (event, creature, attacker, damage)
	takenMurlocDamage = takenMurlocDamage + damage
	if takenMurlocDamage > 200 then
		takenMurlocDamage = 0
		creature:CastCustomSpell( target, 33917, 60 )
	end
end

RegisterCreatureEvent( VillMurloc, 9, OnTakenDamageMurloc )

-- [[   WOLF   ]] --
local function OnWolfSpawn (event, creature)
	creature:CastCustomSpell(creature, 24085)
	creature:SendUnitSay( 'Вам как обычно? Тройное яблочко, пор-р-росятки?', 0 )
end

RegisterCreatureEvent( VillWolf, 5, OnWolfSpawn )

local takenWolfDamage = 0

local function OnTakenDamageWolf (event, creature, attacker, damage)
	takenWolfDamage = takenWolfDamage + damage
	if takenWolfDamage > 200 then
		takenWolfDamage = 0
		creature:CastCustomSpell( attacker, 25189, true ) 
	end
end

RegisterCreatureEvent( VillWolf, 9, OnTakenDamageWolf )

-- [[   KOSCHEY   ]] --
local function OnKoscheySpawn (event, creature)
	creature:CastCustomSpell(creature, 24085)
	creature:SendUnitSay( 'Вихр-р-рь костей!... Ой, подождите, это другая подработка!', 0 )
end

RegisterCreatureEvent( VillKoschey, 5, OnKoscheySpawn )

local takenKoscheyDamage = 0

local function OnTakenDamageKoschey (event, creature, attacker, damage)
	takenKoscheyDamage = takenKoscheyDamage + damage
	if takenKoscheyDamage > 350 then
		takenKoscheyDamage = 0
		creature:SendUnitSay( 'Я не умру, я буду жить ве-е-ечно!', 0 )
		creature:CastCustomSpell( creature, 55336, true ) 
	end
end

RegisterCreatureEvent( VillKoschey, 9, OnTakenDamageKoschey )

-- [[   RACOON   ]] --
local function OnRacoonSpawn (event, creature)
	creature:CastCustomSpell(creature, 24085)
	creature:SendUnitSay( 'Ой.. а этого злодея, кажется, мы забыли придумать. Погодите, не бейте!', 0 )
end

RegisterCreatureEvent( VillRacoon, 5, OnRacoonSpawn )

local takenRacoonDamage = 0

local function OnTakenDamageRacoon (event, creature, attacker, damage)
	takenRacoonDamage = takenRacoonDamage + damage
	if takenRacoonDamage > 70 then
		takenRacoonDamage = 0
		creature:SendUnitSay( 'Идите вы к.. Анрилчу, ребята, я домой.', 0 )
		creature:DespawnOrUnsummon( 180 )
	end
end

RegisterCreatureEvent( VillRacoon, 9, OnTakenDamageRacoon )

-- [[   PHOENIX   ]] --
local function OnPhoenixSpawn (event, creature)
	creature:CastCustomSpell(creature, 24085)
	creature:SendUnitSay( 'Это будет пламенное представление!', 0 )
end

RegisterCreatureEvent( VillPhoenix, 5, OnPhoenixSpawn )

local takenPhoenixDamage = 0

local function OnTakenDamagePhoenix (event, creature, attacker, damage)
	takenPhoenixDamage = takenPhoenixDamage + damage
	if takenPhoenixDamage > 150 then
		takenPhoenixDamage = 0
		creature:CastCustomSpell( attacker, 15091, true ) 
	end
end

RegisterCreatureEvent( VillPhoenix, 9, OnTakenDamagePhoenix )
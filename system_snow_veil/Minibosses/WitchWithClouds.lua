local WitchID = 988006
local CloudID = 988007
local Blizzard = 15783
local FrostBolt = 42803


local totalTakenDamage = 0
local cloudDamageTrigger = 0

local function OnDamageTaken (event, creature, attacker, damage)
	totalTakenDamage = totalTakenDamage + damage
	cloudDamageTrigger = cloudDamageTrigger + damage
	if totalTakenDamage > 300 then
		totalTakenDamage = 0
		creature:CastCustomSpell( attacker, Blizzard, true, 1 )
	end
	if cloudDamageTrigger > 100 then
		cloudDamageTrigger = 0
		local Clouds = creature:GetCreaturesInRange( 30, CloudID )
		for i =1,#Clouds do
			Clouds[i]:CastCustomSpell( attacker, FrostBolt, true )
		end
	end
end

RegisterCreatureEvent( WitchID, 9, OnDamageTaken )

local function OnCloudDamageTaken (event, creature, attacker, damage)
	cloudDamageTrigger = cloudDamageTrigger + damage
	if cloudDamageTrigger > 100 then
		cloudDamageTrigger = 0
		creature:CastCustomSpell( attacker, FrostBolt, true )
	end
end
 
RegisterCreatureEvent( CloudID, 9, OnCloudDamageTaken )

local function OnEnterCombat (event, creature, target)
	totalTakenDamage = 0
	cloudDamageTrigger = 0
	local x, y, z, o = creature:GetLocation()
	creature:SpawnCreature( CloudID, x+math.random(-2,2), y+math.random(-2,2), z+1, o, 5 )
	creature:SpawnCreature( CloudID, x+math.random(-2,2), y+math.random(-2,2), z+1, o, 5 )
end

RegisterCreatureEvent( WitchID, 1, OnEnterCombat )

local function OnLeaveCombat (event, creature)
	local Clouds = creature:GetCreaturesInRange( 30, CloudID )
	for i =1,#Clouds do
		Clouds[i]:DespawnOrUnsummon( 0 )
	end
end

RegisterCreatureEvent( WitchID, 2, OnLeaveCombat )
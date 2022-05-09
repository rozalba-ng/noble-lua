local CAVE_BUNNY = 987872 
local ANGRY_BUNNY = 987873 
local STEALTH_AURA = 91287
local bunniesAITimer = {}

local function OnAI(event, creature, diff)
	if creature:GetVictim() then
		return true
	end
	if bunniesAITimer[creature:GetDBTableGUIDLow()] == nil or os.time() - bunniesAITimer[creature:GetDBTableGUIDLow()] > 1 then
		bunniesAITimer[creature:GetDBTableGUIDLow()] = os.time()
		local player = creature:GetNearestPlayer(10)
		if not player then
			return false
		end
		local dist = creature:GetExactDistance(player)
		local range = 10
		if player:HasAura(STEALTH_AURA) then
			range = 0.7
			
		end
		if dist < range then
			local x,y,z,o = creature:GetLocation()
			local angry = creature:SpawnCreature(ANGRY_BUNNY,x,y,z,o,2,60*1000)
			creature:DespawnOrUnsummon()
			angry:AttackStart(player)
		end
	end
end


RegisterCreatureEvent(CAVE_BUNNY,7,OnAI)






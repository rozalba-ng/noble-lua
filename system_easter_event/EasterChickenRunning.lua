local CHICKEN_ID = 987874 



local chickenStarted = {}


local function RunToPos(_,_,_,chicken)
	local x,y,z,o = chicken:GetHomePosition()
	chicken:MoveTo(0,x+math.random(-9,9),y+math.random(-9,9),z)

end
local function OnAI(event, creature, diff)

	if chickenStarted[creature:GetDBTableGUIDLow()] == nil or os.time() - chickenStarted[creature:GetDBTableGUIDLow()] > 0.5 then
		chickenStarted[creature:GetDBTableGUIDLow()] = os.time()
		creature:RegisterEvent(RunToPos,100,1)
	end
end

local function OnHello(event, player, object)
	if (player:HasQuest(110221) or player:HasQuest(110225)) and player:GetItemCount(301384) ~= 5 then
		object:DespawnOrUnsummon()
		player:AddItem(301384)
	end
end


RegisterCreatureEvent(CHICKEN_ID,7,OnAI)

RegisterCreatureGossipEvent(CHICKEN_ID,1,OnHello)




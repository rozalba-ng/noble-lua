CREATURE_EVENT_ON_DIED = 4;

local function orcWelcome(eventId, delay, repeats)
    local map = GetMapById( 801 )
    local creature = map:GetCreatureBySpawnId(218655);
    creature:SendUnitSay( "Иди на северо-запад, вдоль камней. Там ты выйдешь на тропу.", 1 )
end

local function OnGossipHelloTeleporter(event, player, creature)
    local faction = player:IsAlliance()
	if(creature:GetDBTableGUIDLow() == 218655 and faction == false)then
        player:Teleport( 901, 471.4, -3590.9, 117.49, 4.17 )
    elseif(creature:GetDBTableGUIDLow() == 218654 and faction == false)then
        --CreateLuaEvent( orcWelcome, 9000, 1 )
        player:SendBroadcastMessage("|cFFFFFFFF[Проводник]: |r |cFFFFFFFFИди на северо-запад, вдоль камней. Там ты выйдешь на тропу.|r");
        player:Teleport( 801, -1017.43, -69.78, 173.64, 0.24 )
    elseif(creature:GetDBTableGUIDLow() == 218885 and faction)then
        player:Teleport( 901, 702.54, -949.36, 164.91, 3.81 )
    elseif((creature:GetDBTableGUIDLow() == 218839 or creature:GetDBTableGUIDLow() == 222725) and faction)then
        player:Teleport( 801, 1156.33, -964.8, 125.62, 4.48 )
    elseif(creature:GetEntry() == 28604 and faction == false)then
        -- Дворф-шахид не может говорить с орками.
    end
end

RegisterCreatureGossipEvent(13181, 1, OnGossipHelloTeleporter)
RegisterCreatureGossipEvent(28604, 1, OnGossipHelloTeleporter)

local function denieBlockedCreatureSpawn(event, creature, killer)
    local owner = creature:GetOwner();
    if(owner)then
        if(owner:GetGMRank() < 2)then
            --creature:Delete();
        end
    else
        --creature:Delete();
    end
end

local function registerAllBlockedCreatures()
	for entry=991000,991014 do
        --RegisterCreatureEvent(entry, CREATURE_EVENT_ON_DIED, denieBlockedCreatureSpawn)
    end
end

registerAllBlockedCreatures();

local function fireElementalShot()
    local guid = math.random(12)+293946;
    local elemental = GetCreature(guid, 987668, 1);
    if(elemental)then
        local golem = GetCreature(292850, 2002933, 1);
        elemental:CastSpell(golem, 52338);
    end
end

--CreateLuaEvent(fireElementalShot, 2500, 0)

--500000672
local function earthElementalWp(event, creature)
    --creature:Delete();
    creature:DespawnOrUnsummon();
end

local function earthElementalSpawn()
    local dx = math.random(30)-15;
    local dy= math.random(30)-15;
    --local elemental = PerformIngameSpawn( 1, 2002941, 1, 0, -1246.62, 2387.38, 91.7462, 0, false, 0, 0);
    local elemental = PerformIngameSpawn( 1, 2002941, 1, 0, -1171+dx, 2235+dy, 92, 0, false, 0, 0);
    if(elemental)then
        --elemental:MoveTo(89001, -1246.62, 2387.38, 91.7462, false);
        elemental:MoveWaypoint();
        --elemental:NearTeleport(-1171+dx, 2235+dy, 92, 0);
        --elemental:MoveHome();
    end
end
--CreateLuaEvent(earthElementalSpawn, 1600, 0)
--earthElementalSpawn();
RegisterCreatureEvent(2002941, 4, earthElementalWp)
RegisterCreatureEvent(2002941, 9, earthElementalWp)
RegisterCreatureEvent(2002941, 6, earthElementalWp)

local function stageCoachSpawn()
    local board = GetGameObject(516093, 5041926, 901);
    if(board)then
        local stagecoach = board:GetNearestCreature( 25, 987674);
        if(stagecoach == nil)then
            local new_stagecoach = PerformIngameSpawn( 1, 987674, 901, 0, 1612.06, -1398.68, 66.2319, 0.516974, false, 0, 0);
            if(new_stagecoach)then
                new_stagecoach:MoveWaypoint();
            end
        end
    end
end
CreateLuaEvent(stageCoachSpawn, 540000, 0)
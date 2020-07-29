Platformer = {}
Platformer.array = {}
local platMenuId = 6007
Platformer.players = {}

local savePointNames = { [243576] = "Точка у призрачного кубка", [243587] = "Точка у двух башень", [243585] = "Точка на оранжевых крышах", [243586] = "Точка на таверне", [243584] = "Точка на ратуше"};

function Platformer.assignPlatrformToArray()
	local platformerQuery = WorldDBQuery('SELECT guid FROM gameobject WHERE id = 300256');
	local rowCount = platformerQuery:GetRowCount();
	local guid;
	for var=1,rowCount,1 do	
		guid = platformerQuery:GetString(0);
		table.insert(Platformer.array, guid);
		platformerQuery:NextRow();
	end
end

--Platformer.assignPlatrformToArray(); -- 
Platformer.fadeDelay = 3; --seconds

function Platformer.fadeEvent()
    --local eventNext = CreateLuaEvent( Platformer.fadeEvent, Platformer.fadeDelay*1000, 1 );
    
    local map = GetMapById( 0 );
    local platformerAndorhalControl = GetCreature(243545, 990001, 0);
    platformerAndorhalControl:SetPhaseMask(256);
    local platformsInRange256 = platformerAndorhalControl:GetGameObjectsInRange( 533, 300256 );
    local platformsInRange256_2 = platformerAndorhalControl:GetGameObjectsInRange( 533, 300512 );
    platformerAndorhalControl:SetPhaseMask(512);
    local platformsInRange512 = platformerAndorhalControl:GetGameObjectsInRange( 533, 300256 );
    local platformsInRange512_2 = platformerAndorhalControl:GetGameObjectsInRange( 533, 300512 );
    for index, target in pairs(platformsInRange256) do
        target:SetPhaseMask(512);
    end;
    for index, target in pairs(platformsInRange512) do
        target:SetPhaseMask(256);
    end

    for index, target in pairs(platformsInRange256_2) do
        target:SetPhaseMask(512);
    end;
    for index, target in pairs(platformsInRange512_2) do
        target:SetPhaseMask(256);
    end 
end

--local eventPlatformerNext = CreateLuaEvent( Platformer.fadeEvent, Platformer.fadeDelay*1000, 1 )

function Platformer.SavePointTeleportGossip(event, player, object)
	local playerGuid = player:GetGUIDLow();
    if(Platformer.players[playerGuid] == nil)then
        Platformer.players[playerGuid] = {}
    end
    player:GossipClearMenu() -- required for player gossip
    for index, point in pairs(Platformer.players[playerGuid]) do
        player:GossipMenuAddItem(1, savePointNames[point], 1, index)
    end 
    player:GossipMenuAddItem(1, "Выйти", 1, 99, false, "Выйти из меню?")
    player:GossipSendMenu(1, player, platMenuId) -- MenuId required for player gossip
end

function Platformer.SavePointGossip(event, player, object)
    local playerGuid = player:GetGUIDLow();
    if(Platformer.players[playerGuid] == nil)then
        Platformer.players[playerGuid] = {}
    end
    local savePointGuid = object:GetDBTableGUIDLow();
    for index, point in pairs(Platformer.players[playerGuid]) do
        if (point == savePointGuid)then
            return false;
        end
    end 
    table.insert(Platformer.players[playerGuid], object:GetDBTableGUIDLow());
    return false;
end

function Platformer.OnGossipSelect(event, player, object, sender, intid, code, menuid)
    local playerGuid = player:GetGUIDLow();
    if(intid == 99)then
        player:GossipComplete();
    else
        local savePointGuid = Platformer.players[playerGuid][intid];
        if(savePointGuid)then
            local savePoint = GetCreature(savePointGuid, 991008, 0);
            player:Teleport(0, savePoint:GetX(), savePoint:GetY(),savePoint:GetZ()+1,savePoint:GetO())
        end
    end
end

RegisterCreatureGossipEvent( 991009, 1, Platformer.SavePointTeleportGossip )
RegisterPlayerGossipEvent(platMenuId, 2, Platformer.OnGossipSelect);
RegisterCreatureGossipEvent( 991008, 1, Platformer.SavePointGossip )
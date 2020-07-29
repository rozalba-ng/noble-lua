-- here all ivents, depending on user cast 

-- flag "GOB" means that case are part of tradable gameobject functionality
-- gameobject_template entries in range between 500000 and 502000 - are reserved for tradable gameobjects
-- every gameobject with the entry in this range have corresponding spell (spell.dbc) and item_template with the same entry(id)

PlayerBuild = {}
PlayerBuild.targetgobject = {}
footBall = {}
footBall.lastHit = {};

local EVENT_ON_CAST = 5;

local function castEvent(event, player, spell, skipCheck)
	local spellId = spell:GetEntry();
if (player:GetGMRank() == 3) then
		--player:SendBroadcastMessage(spellId)
	end
	if (spellId == 90005) then -- GOB, case spell "start/stop a building mode"
		local questId = 110000;
		if (player:HasQuest(questId)) then
			player:RemoveQuest(questId);
			player:SendBroadcastMessage("Stopped building state");
			PlayerBuild.targetgobject[player:GetGUIDLow()] = nil
		else
			player:AddQuest(questId);
			player:SendBroadcastMessage("Entered building state");
		end		
	elseif (spellId == 90010) then -- GOB, case spell "user try to bring a gameobject"
		local gob = spell:GetTarget();
		local owner = gob:GetOwner();
		if (owner == player) then
			local guid = gob:GetGUID();
			PlayerBuild.targetgobject[player:GetGUIDLow()] = guid
			GoMovable.OnGossipMovable(event, player, player)			
		else
			player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFПредмет вам не принадлежит|r");
		end		
    --[[elseif (spellId == 85001) then -- GOB, управление транспортом
		Wheel.OnGossipWheel(event, player, player)]]		
	elseif (spellId >499000 and spellId < 509999) then -- GOB, case spell "user puts a gameobject in the world"
        if(player:GetPhaseMask() == 512)then
         local val = spell:GetMiscValue(0);
         player:AddItem(val);
         return false;
        end
		local x, y, z = spell:GetTargetDest();     
		local x1, y2, z2, o = player:GetLocation();
		local pid = player:GetGUIDLow();
		local val = spell:GetMiscValue(0);
		local map = player:GetMapId();
		local phase = player:GetPhaseMask();
		local myworldObject = PerformIngameSpawn( 2, val, map, 0, x, y, z, o, true, pid, 0, phase);
        --local target = spell:GetTarget();
       -- if(target)then
            --placeGameobjectAtVehicle(target, player, myworldObject)
           -- print(target:GetDisplayId());
       -- else
         --   print("Vehicle not found");
        --end
    elseif (spellId == 501404) then
        local target = spell:GetTarget();
        PlayerBuild.test = target;
        print(target:GetDisplayId());
    elseif (spellId == 60968) then
        --
    elseif (spellId == 88003) then
        local target = spell:GetTarget();
        if(target)then
            print(target:GetDBTableGUIDLow())
            table.insert(vehicle_GameObject_List[target:GetDBTableGUIDLow()].passengers, player:GetGUIDLow());
        end
    elseif (spellId >= 88005 and spellId <= 88008) then
        local target = player:GetSelectedUnit();
        attackRoll(player, target, spellId);
    elseif (spellId == 84043 or spellId == 84044) then
        local target = player:GetSelectedUnit();
        --local target= player:GetNearestCreature( 5, 995000 )
        if(target:ToCreature())then
            if(target:GetEntry() == 995000 and target:GetDistance2d( player ) <= 4.6)then --
                --local vehicle = target:GetVehicleKit();
                --local angle = math.atan2(player:GetY() - target:GetY(), player:GetX() - target:GetX()) + 3.1415926535898;
                local angle = player:GetO(); 
                target:SetRooted( false );
                target:SetWalk( false );                 
                target:RemoveAura( 84045 );
                target:SetSpeed( 0, 2, true );
                target:SetSpeed( 1, 2, true );
                target:SetFacing(angle);
                target:AddAura( 84045, target );
                --target:PlayDistanceSound( 3580 );
                footBall.lastHit[target:GetGUIDLow()] = player:GetName();                          
            end
        end
    elseif (spellId == 84047) then
        local target = spell:GetTarget();
        local vehicle = target:GetVehicleKit();
        if(vehicle)then
            local owner = vehicle:GetPassenger( 0 )
            if(owner ~= player and owner ~= nil)then
                player:RemoveAura(84047);
            end
        end
	elseif (spellId == 88041) then
		local itemLink = GetItemLink(600054,8)
			player:SendBroadcastMessage(player:GetName().." использует "..itemLink.." и |cFF79ed21 восполняет одно потерянное очко здоровья!|r")
        local nearPlayers = player:GetPlayersInRange( 40, 0, 0 )
		for index, nearPlayer in pairs(nearPlayers) do
			nearPlayer:SendBroadcastMessage(player:GetName().." использует "..itemLink.." и |cFF79ed21 восполняет одно потерянное очко здоровья!|r")
		end
		player:RemoveAura(88041)
	end
end
RegisterPlayerEvent(EVENT_ON_CAST, castEvent);


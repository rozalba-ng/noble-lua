333+

vehicle_GameObject_List = {}; -- Список для ГО-корпусов, по которому игроки долбят абилкой, заносящей их в подмассив.
vehicle_GameObject_Queue = {};

function vehicleEnter(player)
	local map = player:GetMap();
    local gobGUID = PlayerBuild.targetgobject[player:GetGUIDLow()];
    local gob = map:GetWorldObject(gobGUID);
    --print(gob)
    local vehicle_SpawnID = gob:GetCreatureAttach()
    
    local vehicle_creature = map:GetCreatureBySpawnId(vehicle_SpawnID);    
    local vehicle = vehicle_creature:GetVehicleKit();
    local vehicle_gameobject_body = vehicle:GetBodyGameObjectGUID();
    
    if(vehicle_gameobject_body)then
        vehicle_GameObject_List[vehicle_gameobject_body] = {};
        vehicle_GameObject_List[vehicle_gameobject_body].controller = player:GetGUIDLow();
        vehicle_GameObject_List[vehicle_gameobject_body].passengers = {};
        local worldObjectList = gob:GetNearObjects( 30, 16 );     
        for index, target in pairs(worldObjectList) do
            if(target ~= player)then
                target:CastSpell(vehicle_creature, 88003, true);
            end
        end
        
        --local entry = gob:GetEntry();
        if(vehicle_GameObject_Queue[os.time()+1] == nil)then
            vehicle_GameObject_Queue[os.time()+1] = {map:GetMapId(), vehicle_SpawnID, vehicle_gameobject_body}
            local VehicleGameObjectMountEvent = CreateLuaEvent( VehicleGameObjectMountDelay, 1000, 1 );
        end
    else	
        vehicle:RemoveAllGameObjects();
    end;  --]]  
end;

function VehicleGameObjectMountDelay()
    local timestamp = os.time();
    
    local mapId = vehicle_GameObject_Queue[timestamp][1];
    local vehicle_SpawnID = vehicle_GameObject_Queue[timestamp][2];
    local vehicle_gameobject_body = vehicle_GameObject_Queue[timestamp][3];
    
    local map = GetMapById( mapId );    
    local vehicle_creature = map:GetCreatureBySpawnId(vehicle_SpawnID);
    
    local vehicle = vehicle_creature:GetVehicleKit();
    vehicle_creature:SetPhaseMask(1, true); --TODO    
    vehicle_creature = vehicle_creature:UpdatePosition(vehicle_creature:GetX(), vehicle_creature:GetY(), vehicle_creature:GetZ()+1,vehicle_creature:GetO());
    
    local controller = GetPlayerByGUID(vehicle_GameObject_List[vehicle_gameobject_body].controller);
    attachPassengerAtVehicle(controller, vehicle_creature);
    controller:SetWaterWalk(true); --TODO
    controller:AddAura(546, controller);
    controller:CastSpell(vehicle_creature, 60968);
   -- print(controller:GetAccountName())
    
    local VehicleGameObjectMountEventTWO = CreateLuaEvent( testTWO, 1000, 1 );
    
    for index, passenger_guid in pairs(vehicle_GameObject_List[vehicle_gameobject_body].passengers) do
        local passenger = GetPlayerByGUID(passenger_guid);
        attachPassengerAtVehicle(passenger, vehicle_creature);
    end
    vehicle:RemoveAllVehiclesGameObjects();--]]
end

function testTWO() -- Это полный пиздец
    local timestamp = os.time()-1;
    
    local mapId = vehicle_GameObject_Queue[timestamp][1];
    local vehicle_SpawnID = vehicle_GameObject_Queue[timestamp][2];
    local vehicle_gameobject_body = vehicle_GameObject_Queue[timestamp][3];
    
    local map = GetMapById( mapId );    
    local vehicle_creature = map:GetCreatureBySpawnId(vehicle_SpawnID);
    
    local vehicle = vehicle_creature:GetVehicleKit();
    local veh_slot_seat = {}
    for i=1,8 do
        veh_slot_seat[i] = {}
    end
    for index, passenger_guid in pairs(vehicle_GameObject_List[vehicle_gameobject_body].passengers) do
        local passenger = GetPlayerByGUID(passenger_guid);
        local shipSlot = vehicle:GetPassenger( 1 );
        local seatIndex = 1;
        local passenger_attached = false;
        while (seatIndex <= 7 and passenger_attached == false) do 
            shipSlot = vehicle:GetPassenger( seatIndex );
            if(shipSlot)then
                local shipSlotVehicle = shipSlot:GetVehicleKit();
                for j=1,8 do                    
                    if(veh_slot_seat[seatIndex+1][j] == nil)then
                        veh_slot_seat[seatIndex+1][j] = 1;
                        passenger:CastSpell(shipSlot, 88004);
                        passenger_attached = true;
                        break;
                    end
                end
            end
            seatIndex = seatIndex + 1;
        end
    end
end

function attachPassengerAtVehicle(player, vehicle_creature)
    local veh_x = vehicle_creature:GetX(); local veh_y = vehicle_creature:GetY(); local veh_z = vehicle_creature:GetZ();  --Координаты транспорта
    local veh_o = vehicle_creature:GetO(); --Ориентация транспорта
    local player_x = player:GetX(); local player_y = player:GetY(); local player_z = player:GetZ(); --Ищем глобальные координаты игрока
    local player_o = player:GetO(); -- Ориентация игрока
    -- Находим 2 координаты для того, чтобы построить вектор для координат транспорта
    local obj_x = math.cos(veh_o);
	local obj_y = math.sin(veh_o);
    local lenght = math.sqrt((player_x - veh_x)^2 + (player_y - veh_y)^2); -- Расстояние от центра транспорта до игрока (радиус)
    -- Сохраняем в память радиус, угол, ориентацию и расположение по оси Z игрока относительно транспорта.
    --print("DEBUG ON")
    --print(lenght)
    --print(angleBetweenPoints((player_x-veh_x), (player_y-veh_y), obj_x, obj_y))
    --print(player_o)
    --print("DEBUG OFF")
    local vehicle = vehicle_creature:GetVehicleKit();
    vehicle:AttachPassenger(player, lenght, angleBetweenPoints((player_x-veh_x), (player_y-veh_y), obj_x, obj_y), (player_z-veh_z), (player_o-veh_o))
end

function placeGameobjectAtVehicle(target, player, go)
    local map = player:GetMap();
    --local owner = target:GetOwner();
    local vehicle_spawnid = target:GetCreatureAttach();
    if(vehicle_spawnid)then
        local vehicle_creature = map:GetCreatureBySpawnId(vehicle_spawnid);
        local veh_x = vehicle_creature:GetX(); local veh_y = vehicle_creature:GetY(); local veh_z = vehicle_creature:GetZ();  --Координаты транспорта
        local veh_o = vehicle_creature:GetO(); --Ориентация транспорта
        local go_x = go:GetX(); local go_y = go:GetY(); local go_z = go:GetZ(); --Ищем глобальные координаты ГОшки
        local go_o = go:GetO(); --Ориентация ГОшки
        -- Находим 2 координаты для того, чтобы построить вектор для координат транспорта
        local obj_x = math.cos(veh_o); 
        local obj_y = math.sin(veh_o);
        local lenght = math.sqrt((go_x - veh_x)^2 + (go_y - veh_y)^2); -- Расстояние от центра транспорта до ГОшки, которую мы ставим (радиус)
        -- Сохраняем в память и в базу радиус, угол, ориентацию и расположение по оси Z ГОшки относительно транспорта.
        vehicle_creature:AttachGameobject(go, lenght, angleBetweenPoints((go_x-veh_x), (go_y-veh_y), obj_x, obj_y), (go_z-veh_z), (go_o-veh_o));
    end;
end;

function removeGameobjectFromVehicle(player, go)
    local map = player:GetMap();
    --local owner = go:GetOwner();
    local vehicle_spawnid = go:GetCreatureAttach();
    local vehicle_creature = map:GetCreatureBySpawnId(vehicle_spawnid);
    if(vehicle_creature)then
        vehicle_creature:RemoveAttachedGameobject(go);
    end;
end;

function angleBetweenPoints(x1,y1,x2,y2)
    local len1 = math.sqrt(x1^2 + y1^2);
    local len2 = math.sqrt(x2^2 + y2^2);
    local dot = x1 * x2 + y1 * y2;
    local a = dot / (len1 * len2);
    local dot2 = x1 * y2 - y1 * x2;
    if(a >= 1.0)then
        return(0)
    elseif(a <= -1.0)then
        return(math.pi)
    else
        if(dot2>0)then
            return(-(math.acos(a)));
        else
            return(math.acos(a));
        end;
    end;
end;

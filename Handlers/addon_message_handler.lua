local ADDON_EVENT_ON_MESSAGE = 30;

local function AddonMessageEvent(event, sender, type, prefix, msg, target)
    if(prefix == "PLAYER_CONTAINER_MOVE" and type == 7 and sender == target)then
        local arg = string.split(msg, "/b");        
        local gobGUID = PlayerContainerSession[sender:GetGUIDLow()];
        if(gobGUID)then
            local map = sender:GetMap();           
            local gob = map:GetWorldObject(gobGUID)
            gob:MoveContainerItem(arg[1]-1, arg[2]-1);
            sender:SendAddonMessage("PLAYER_CONTAINER_UPDATE", gob:GetContainerItemList(), 7, sender);
        end
    elseif(prefix == "PLAYER_CONTAINER_STORE_FROM_INV" and type == 7 and sender == target)then
        local arg = string.split(msg, "/b");        
        local gobGUID = PlayerContainerSession[sender:GetGUIDLow()];
        if(gobGUID)then
            local map = sender:GetMap();        
            local gob = map:GetWorldObject(gobGUID)
            if(arg[1]=="0")then
                gob:StoreContainerItem(sender, 255, arg[2]+22, arg[3]-1);
            else
                gob:StoreContainerItem(sender, arg[1]+18, arg[2]-1, arg[3]-1);
            end
            
            sender:SendAddonMessage("PLAYER_CONTAINER_UPDATE", gob:GetContainerItemList(), 7, sender);
        end
    elseif(prefix == "PLAYER_CONTAINER_TAKE" and type == 7 and sender == target)then
        local arg = string.split(msg, "/b");        
        local gobGUID = PlayerContainerSession[sender:GetGUIDLow()];
        if(gobGUID)then
            local map = sender:GetMap();        
            local gob = map:GetWorldObject(gobGUID)
            if(arg[1]=="0")then
                gob:TakeContainerItem(sender, 255, arg[2]+22, arg[3]-1);
            else
                gob:TakeContainerItem(sender, arg[1]+18, arg[2]-1, arg[3]-1);
            end
            
            sender:SendAddonMessage("PLAYER_CONTAINER_UPDATE", gob:GetContainerItemList(), 7, sender);
        end
    end
    --[[elseif(prefix == "PLAYER_CUSTOM_VEHICLE_MOVE" and type == 7 and sender == target)then -- Я сам в ахуе от того, что ниже. Нужно переписать вообще всё. (Замечание: после ExitVehicle() идёт задержка перед возможной пересадкой. Нужно найти альтернативу, а в остальном - работает, как ни странно)
        ]]
        --[[local temp = string.split(msg, "}");                
        sublevel = tonumber(temp[1]);
        seatID = tonumber(temp[2]) - 1;
        --print("seatID:"..seatID);
        --print("sublevel:"..sublevel);
        if(not seatID or not sublevel) then
            return;
        end
        local vehicle = sender:GetVehicle(); -- Получаем транспорт.
        if (vehicle) then            
            local vehicleParent = vehicle:GetOwner():GetVehicle(); -- Если это транспорт в транспорте (подушка, пушка и т.д.), получаем родителя (дилижанс, корабль).
            if (vehicleParent) then
                if (seatID < 7) then -- Пересаживаемся в родителя. Выбор места будет ниже, в простом пересаживании.
                    sender:ExitVehicle();
                    sender:CastSpell(vehicleParent, 60968);
                else
                    sender:ChangeSeat(seatID-7*sublevel); -- Находясь в том же подтранспорте, пересаживаемся на соседний слот. (Неточность: нужно учитывать пересаживание в другие подтранспорты, но я ебал сейчас это, вообще весь этот код нужно реворкать).
                    return;
                end
            end          
            local passenger = vehicle:GetPassenger( seatID ); -- Проверяем, не сидит ли кто-то в месте, куда мы ходим посадить игрока.
            if(passenger)then
                if (passenger:GetEntry() == 987657) then -- Хардкод на подушку, если она в слоте, куда игрок хотел сесть.
                    sender:ExitVehicle();
                    sender:CastSpell(passenger, 43671);
                    return;
                end
            else
                if (seatID < 7) then -- Простое пересаживание по основным местам транспорта.
                    sender:ChangeSeat(seatID);
                    return;
                else
                    passenger = vehicle:GetPassenger( 7*sublevel ); -- Попытка сесть в слот, принадлежащий подтранспорту. Находим слот транспорта и пересаживаем в него игрока.
                    sender:ExitVehicle();
                    sender:CastSpell(passenger, 43671);
                    sender:ChangeSeat(seatID-7*sublevel);
                    return;
                end
            end
        end]]
    --end
    if(prefix == "PLAYER_CHAT_TYPING" and type == 7 and sender == target)then
        if(msg == "SAY")then
            if(not sender:HasAura(84011))then
                sender:AddAura( 84011, sender )
            end
            local vehicle = sender:GetVehicle();
            if(vehicle ~= nil)then
                local vehicleBase = vehicle:GetOwner();
                if(not vehicleBase:ToPlayer())then
                    sender:Emote( 1 )
                end
            else
                sender:Emote( 1 )
            end
        elseif(msg == "YELL")then
            if(not sender:HasAura(84012))then
                sender:AddAura( 84012, sender )
            end
            local vehicle = sender:GetVehicle();
            if(vehicle ~= nil)then
                local vehicleBase = vehicle:GetOwner();
                if(not vehicleBase:ToPlayer())then
                    sender:Emote( 22 )
                end
            else
                sender:Emote( 22 )
            end
        elseif(msg == "EMOTE")then
            if(not sender:HasAura(84013))then
                sender:AddAura( 84013, sender )
            end
        elseif(msg == "STOP")then
            if(sender:HasAura(84011))then
                sender:RemoveAura(84011)
            end
            if(sender:HasAura(84012))then
                sender:RemoveAura(84012)
            end
            if(sender:HasAura(84013))then
                sender:RemoveAura(84013)
            end
        end
    end
    if(prefix == "PLAYER_TABARD_CHANGE" and type == 7 and sender == target)then
        if(string.find(msg, "|"))then
            local arguments = {}
            local arguments = string.split(msg, "|")
            if (#arguments == 6) then
                if(tonumber(arguments[1]) > 0)then
                    local nearestCreature = sender:GetNearestCreature( 20, tonumber(arguments[1]) )
                    local money = sender:GetCoinage();
                    if(nearestCreature and money >= 10)then
                        if(nearestCreature:IsTabardDesigner())then
                            local guild = sender:GetGuild();
                            if(guild and sender:GetGuildRank() == 0 and (tonumber(arguments[2]) >= 0 and tonumber(arguments[2]) <= 169) and (tonumber(arguments[3]) >= 0 and tonumber(arguments[3]) <= 16) and (tonumber(arguments[4]) >= 0 and tonumber(arguments[4]) <= 5) and (tonumber(arguments[5]) >= 0 and tonumber(arguments[5]) <= 16) and (tonumber(arguments[6]) >= 0 and tonumber(arguments[6]) <= 50))then               
                                guild:SetEmblemInfo(tonumber(arguments[2]), tonumber(arguments[3]), tonumber(arguments[4]), tonumber(arguments[5]), tonumber(arguments[6]));
                                sender:ModifyMoney( -10 );
                                sender:SendBroadcastMessage("Табард сохранён. Перезайдите за персонажа, чтобы изменения вступили в силу.");
                                local tabardPacket = CreatePacket( 497, 4 );
                                tabardPacket:WriteULong( 0 );
                                sender:SendPacket( packet );
                            end
                        end
                    end
                end
            end
        end
    end
    if(prefix == "INSPECT_DESC_GET" and type == 7 and sender == target)then
        local playerName = string.match(msg, "([а-Ор-Я]+)");
        local player = GetPlayerByName(playerName);
        local sendPrefix;
        local sendMessage;
        
        if (player == sender) then
            sendPrefix = "CHAR_DESC_RESP";
        else
            sendPrefix = "INSPECT_DESC_RESP";
        end
        
        if (player) then
            local distance = sender:GetExactDistance(player);
            if (distance <= 28) then
                local playerGUID = player:GetGUIDLow();
                local appearance, features, state, notice = getCharacterDescription(playerGUID);    
                
                if (not (appearance or features or state or notice)) then
                    sendMessage = "Незнакомец| О данной личности ничего неизвестно.";
                else
                    sendMessage = playerName .. "| | " .. appearance .. "| " .. features .. "| " .. state .. "| " .. notice;
                end
            else
                sendMessage = "Незнакомец| Персонаж слишком далеко.";
            end
        else
            sendMessage = "Незнакомец| О данной личности ничего неизвестно.";            
        end
        
        sender:SendAddonMessage(sendPrefix, " " .. sendMessage, 7, sender);
    end
    
    return true;
end

local characterDescriptionMemcache = {};

function getCharacterDescription(playerGUID)
    local appearance;
    local features;
    local state;
    local notice;
    
    local memcachedInfo = characterDescriptionMemcache[playerGUID];
    if (memcachedInfo) then
        local cacheTime = memcachedInfo["timestamp"];
        if ((os.time() - cacheTime) <= 10) then
            local descriptionTexts = memcachedInfo["description"];
            return descriptionTexts["appearance"], descriptionTexts["features"], descriptionTexts["state"], descriptionTexts["notice"];
        end
    end
    
    local result = CharDBQuery("SELECT appearance, features, state, notice FROM character_customs WHERE char_id = "..playerGUID);    
            
    if result then
        repeat
            appearance = result:GetString(0);
            features = result:GetString(1);
            state = result:GetString(2);
            notice = result:GetString(3);
        until not result:NextRow();
    end
    
    characterDescriptionMemcache[playerGUID] = {
        timestamp = os.time(),
        description = {
            appearance = appearance,
            features = features,
            state = state,
            notice = notice
        }
    };
    
    return appearance, features, state, notice; 
end

RegisterServerEvent(ADDON_EVENT_ON_MESSAGE, AddonMessageEvent);
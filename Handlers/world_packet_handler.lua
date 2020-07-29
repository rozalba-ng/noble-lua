local function EventHandlerTest(event, packet, player)
    if(player:GetAccountId() == 1)then
      player:SendBroadcastMessage("asd "..packet:GetOpcode());
    end
    --[[if(packet:GetOpcode() == 351)then -- CMSG_LOOT_RELEASE Закрытие лута.
        --if(PlayerContainerSession[player:GetGUIDLow()] == packet:ReadGUID())then
        --    PlayerContainerSession[player:GetGUIDLow()] = nil;
        --    print("close")
        --end
    elseif(packet:GetOpcode() == 1133 and cannonControlerInfo.player == player:GetGUIDLow())then -- CMSG_DISMISS_CONTROLLED_VEHICLE
        player:Teleport( 0, -134.966690, 787.873291, 67.482530, 3.217391 );
        local map = player:GetMap();
        local cannon = map:GetWorldObject(cannonControlerInfo.cannon);
        local console = map:GetWorldObject(cannonControlerInfo.console);
        cannon:DespawnOrUnsummon(0);
        console:SetGoState(1);
        cannonControlerInfo.player = nil;
    elseif(packet:GetOpcode() == 909 or packet:GetOpcode() == 1179)then -- SMSG_PLAYER_VEHICLE_DATA
        local vehicle = player:GetVehicle();
        local vehicle_entry = vehicle:GetOwner():GetEntry();
        if(vehicle_entry == 987656 or vehicle_entry == 987657)then
            local playerListStr = ""; --|1,7,Lola
            local playerListContainer = {}
            for i=0,7 do
                local passenger = vehicle:GetPassenger( i );
                if(passenger)then
                    playerListStr = playerListStr .. "|0," .. i .. "," .. passenger:GetName();
                    if(passenger:ToPlayer())then
                        table.insert(playerListContainer, passenger);
                    end
                end
            end        
            player:SendAddonMessage("CUSTOM_VEHICLE_ENTER", "1;2;8;" .. playerListStr, 7, player);        
                    
            for i, passenger in pairs(playerListContainer) do
                passenger:SendAddonMessage("CUSTOM_VEHICLE_UPDATE", playerListStr, 7, player);
            end
        end
    end]]--
    if(packet:GetOpcode() == 497)then
	player:SendBroadcastMessage("asd");
    end
end

--RegisterServerEvent( 5, EventHandlerTest );
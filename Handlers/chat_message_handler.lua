local PLAYER_EVENT_ON_CHAT = 18;

local function ChatMessageEvent(event, player, msg, Type, lang, group)
	if(player:GetAccountId() == 270)then
        if(msg == "Команда: включить свет!")then
            local lightOn = GetGameObject(242079, 5026223, 0);
            local lightOff = GetGameObject(242080, 5008308, 0);
            lightOn:SetPhaseMask( 1, true );
            lightOff:SetPhaseMask( 4, true );
        elseif(msg == "Команда: выключить свет!")then
            local lightOn = GetGameObject(242079, 5026223, 0);
            local lightOff = GetGameObject(242080, 5008308, 0);
            lightOff:SetPhaseMask(1);
            lightOn:SetPhaseMask(4);
        end
    end
    if(player:GetAccountId() == 1)then
        if(msg == "getphases")then
            local worldPlayers = GetPlayersInWorld();
            for index, target in pairs(worldPlayers) do
                if(target:GetPhaseMask() > 1)then
                    player:SendBroadcastMessage(target:GetName().. "в "..target:GetPhaseMask());
                end
            end
        end
    end
    if(player:GetAccountId() == 1)then
        --[[if(msg == "123")then
            local vehicle = GetCreature(213796, 987656, 0);
            if(vehicle)then
                vehicle = vehicle:GetVehicleKit();
            end
            print(vehicle:GetEntry());
            print(vehicle:GetOwner():GetEntry())
            print(vehicle:IsOnBoard(player))
            --vehicle:RemovePassenger( player )
            local cabin = vehicle:GetPassenger(7);
            print(cabin:GetEntry())
            if(cabin:GetEntry() == 987657)then
                player:ExitVehicle();
                player:CastSpell(cabin, 43671);
            else
                player:ChangeSeat(2)
            end
        else
            player:ChangeSeat(1)
        end]]
	--player:PlayDistanceSound(msg,player);
    end
end

RegisterPlayerEvent(PLAYER_EVENT_ON_CHAT, ChatMessageEvent);
local function OnPlayerCommand(event, player,command)
    if(command == "reskin") then
        if ( player:GetGMRank() > 0 ) then
            player:SetAtLoginFlag( 128 )
            player:SendBroadcastMessage("Смена внешности будет предложена при следующем заходе в игру.");
        end
    end
    return false
end

RegisterPlayerEvent(42, OnPlayerCommand)
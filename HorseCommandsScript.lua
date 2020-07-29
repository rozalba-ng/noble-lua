
local function HorseInfoCommand(event, player,command)
if(player:GetGMRank() > 0)then    
    if (command == "horseinfo") then
        if player:GetTargetCreature() then
            local HorseOwnerCharID = CharDBQuery("SELECT owner_id FROM mount_owner WHERE guid =".. player:GetTargetCreature():GetGUIDLow());
            if HorseOwnerCharID then
                local HorseOwnerCharName = CharDBQuery("SELECT name FROM characters WHERE guid =".. HorseOwnerCharID:GetInt32(0));
                if HorseOwnerCharName then
                    player:SendBroadcastMessage("Владелец лошади: [" .. HorseOwnerCharName:GetString(0) .."]. Аккаунт: [" .. GetPlayerByName(HorseOwnerCharName:GetString(0)):GetAccountName() .. "]")
                end
            end
        end
    
    elseif (command == "horsedel") or (command == "horsedelete") then
        if player:GetTargetCreature() then
            if player:GetMapId() == 901 then
                player:GetTargetCreature():NearTeleport( -6368, -1059, 387, 0 )
                player:SendBroadcastMessage("Транспорт удален.")
                --.go xyz -6368 -1059 387 901
            elseif player:GetMapId() == 801 then
                player:GetTargetCreature():NearTeleport( -2644, 2342, 242, 0 )
                player:SendBroadcastMessage("Транспорт удален.")
                --.go xyz -2644 2342 242 801
            end
        end
    end
    
end	
    return false
end
RegisterPlayerEvent(42, HorseInfoCommand)
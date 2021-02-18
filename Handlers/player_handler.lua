local PLAYER_EVENT_ON_LOGIN = 3;
local PLAYER_EVENT_ON_LOGOUT = 4;
local PLAYER_EVENT_ON_ROLE_STAT_UPDATE = 45;

local function RoleStatUpdateEvent(event, player, stat)
	--player:SendAddonMessage("PLAYER_ROLESTAT_UPDATE", string.format("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", player:GetRoleStat(0), player:GetRoleStat(1), player:GetRoleStat(2), player:GetRoleStat(3), player:GetRoleStat(4), player:GetRoleStat(5), player:GetRoleStat(6), player:GetRoleStat(7), player:GetRoleStat(8), player:GetRoleStat(9), player:GetRoleStat(10)), 11, player);
    player:SendAddonMessage("PLAYER_ROLESTAT_UPDATE", string.format("%d,%d,%d,%d,%d,%d,%d", player:GetRoleStat(0), player:GetRoleStat(1), player:GetRoleStat(2), player:GetRoleStat(3), player:GetRoleStat(4), player:GetRoleStat(5), player:GetRoleStat(6)), 7, player);
end

local function OnPlayerLogout(event, player)
    for i=12,13 do
        local trinket = player:GetItemByPos( 255, i );
        if(trinket ~= nil)then
            if(trinket:GetEntry() == 803009)then
                local vehicle = player:GetVehicleKit();
                if(vehicle ~= nil)then
                    local passenger = vehicle:GetPassenger(1);
                    if(passenger ~= nil)then
                        passenger:ExitVehicle();
                        if(passenger:ToCreature() and passenger:GetEntry() == 990003)then
                            passenger:Delete();
                        end
                    end
                end
                break;
            end
        end
    end
    
    if(roleCombat.diff_number[player:GetGUIDLow()])then
	roleCombat.diff_number[player:GetGUIDLow()] = nil;
    end
end

RegisterPlayerEvent(PLAYER_EVENT_ON_ROLE_STAT_UPDATE, RoleStatUpdateEvent);
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, RoleStatUpdateEvent);

RegisterPlayerEvent(PLAYER_EVENT_ON_LOGOUT, OnPlayerLogout);


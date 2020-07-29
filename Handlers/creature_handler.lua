local CREATURE_EVENT_ON_MOVEMENT_FLAGS_SET = 39;

function boatMovementFlagsChange(event, unit, flag, add)
    if(bit_and(flag,1) == 1)then
        local vehicle = unit:GetVehicleKit();
        if(vehicle)then
            local owner = vehicle:GetPassenger( 0 )
            if(owner)then
                if(not owner:HasAura(84048))then
                    owner:AddAura(84048, owner);
                end
            end
        end  
    else
        local vehicle = unit:GetVehicleKit();
        if(vehicle)then
            local owner = vehicle:GetPassenger( 0 )
            if(owner)then
                if(owner:HasAura(84048))then
                    owner:RemoveAura(84048);
                end
            end
        end     
    end
    return false;
end

local function OnBoatLostControl(event, vehicle, charmer)
    if(charmer:HasAura(84048))then
	charmer:RemoveAura(84048);
    end
end

RegisterCreatureEvent(987664, CREATURE_EVENT_ON_MOVEMENT_FLAGS_SET, boatMovementFlagsChange);
RegisterCreatureEvent( 987664, 38, OnBoatLostControl);
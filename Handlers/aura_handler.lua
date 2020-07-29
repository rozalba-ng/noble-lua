local EVENT_ON_AURA_APPLY = 43;
local EVENT_ON_AURA_REMOVE = 44;
local playerWeaponVisual = {};

local function auraApplyEvent(event, unit, aura)
	local spellId = aura:GetAuraId();
	if (spellId == 540623) then
		player = unit:ToPlayer();
		player:AddAura(84050, player);	
	end

	if (spellId == 86014) then
        player = unit:ToPlayer();
        playerWeaponVisual[player:GetGUIDLow()] = player:GetUInt32Value(313)
        player:UpdateUInt32Value(313, 29153) 
elseif(spellId == 84045) then
    if(unit:ToCreature())then
        if(unit:GetEntry() == 995000)then
            local amount = aura:GetStackAmount();
            if(amount == 5)then
            --unit:SetWalk( true );
            --elseif(math.fmod(amount, 2) == 0)then
            elseif(amount == 10 and unit:IsRooted() == false)then
                --unit:SetSpeed( 0, 2 - (amount * 0.2), true );
                --unit:SetSpeed( 1, 2 - (amount * 0.2), true );		    
                local vehicle = unit:GetVehicleKit();
                if(vehicle)then
                    local player = vehicle:GetPassenger( 0 )
                    if(player)then              
                        unit:DespawnOrUnsummon();
                        player:Teleport( 907, player:GetX(), player:GetY(), player:GetZ(), player:GetO());
                        local ball = PerformIngameSpawn( 1, 995000, 907, 0, player:GetX(), player:GetY(), player:GetZ(), player:GetO(), false, 0, 0, 1);
                        player:CastSpell(ball, 84022);
                        aura = ball:AddAura( 84045, ball); 
                        aura:SetStackAmount( 10 );
                        ball:SetRooted( true ); 		    
                        --vehicle_unit:NearTeleport(4016.6, 5733.31, 1.41, 4.33);
                    end
                end
            end
        end
    end 
end
end

local function auraRemoveEvent(event, unit, aura)
	local spellId = aura:GetAuraId();
	if (spellId == 86014) then
        player = unit:ToPlayer();
        if (player) then
            player:UpdateUInt32Value(313, playerWeaponVisual[player:GetGUIDLow()])
            table.remove(playerWeaponVisual, player:GetGUIDLow())
        end        
	elseif (spellId == 88011) then
        player = unit:ToPlayer();
        if (player) then
            if(player:HasAura(88013))then
                local wound = player:GetAura( 88013 );
                if(wound)then
                    local wound_stack = wound:GetStackAmount();
                    player:RemoveAura(88013);
                    local perm_wound = player:AddAura(88010, player);
                    perm_wound:SetStackAmount(wound_stack);
                end
            end
        end
	end
end

RegisterPlayerEvent(EVENT_ON_AURA_APPLY, auraApplyEvent);
RegisterPlayerEvent(EVENT_ON_AURA_REMOVE, auraRemoveEvent);
-- here all ivents, depending on user cast 

-- flag "GOB" means that case are part of tradable gameobject functionality
-- gameobject_template entries in range between 500000 and 502000 - are reserved for tradable gameobjects
-- every gameobject with the entry in this range have corresponding spell (spell.dbc) and item_template with the same entry(id)

PlayerBuild = {}
PlayerBuild.targetgobject = {}
footBall = {}
footBall.lastHit = {};
local playersRubberyTime = {}


local EVENT_ON_CAST = 5;
local ENERGY_SYSTEM_AURA = 91180;

local function castEvent(event, player, spell, skipCheck)
	local spellId = spell:GetEntry();
    if (player:GetGMRank() == 3) then
		player:SendBroadcastMessage(spellId)
    end

    -- обработка спеллов или вызов хендлеров
    if (spellId == 1804) then -- взлом замка

    elseif (spellId == 88086 or spellId == 88087) then -- перековка
        ItemForge.OnForge(event, player, spell)
        return false;
    elseif (spellId == 91095) then -- обшаривание карманов
        local zone = player:GetZoneId();

        if (not(zone == 1519 or player:HasAura(mainPlaygroundZones.aura ))) then
            player:SendNotification( "В этой зоне запрещены карманные кражи!" )
            player:ResetSpellCooldown( spellId )
            return false;
        end

        if (player:GetReputation( thiefs_faction ) < amount_reputation_friendly) then
            player:SendNotification( "Недостаточно репутации для совершения данного действия!" )
            player:ResetSpellCooldown( spellId )
            return false;
        end
        if (player:HasAura( 91060 )) then
            player:SendNotification( "Данное действие невозможно совершить под наблюдением стражи!" )
            player:ResetSpellCooldown( spellId )
            return false;
        end
        if not SocialTime() then
            player:SendNotification( "Данное действие можно совершать только во время социальной активности (18:00 - 2:00 по МСК)!" )
            player:ResetSpellCooldown( spellId )
            return false;
        end

        local selection = player:GetSelection()

        if not selection then
            player:SendNotification( "Ошибка! Не выбрана цель!" )
            player:ResetSpellCooldown( spellId )
            return false;
        end

        if not selection:ToPlayer() then
            player:SendNotification( "Ошибка! В цель не выбран игрок!" )
            player:ResetSpellCooldown( spellId )
            return false;
        end

        if player == selection then
            player:SendNotification( "Ошибка! Целью не можете быть вы сами!" )
            player:ResetSpellCooldown( spellId )
            return false;
        end

        if ( playersRubberyTime[selection:GetName()] and (  os.time() - playersRubberyTime[selection:GetName()]   ) < 1800 )  then
            player:SendNotification( "Данное действие невозможно: персонаж недавно был ограблен!" )
            player:ResetSpellCooldown( spellId )
            return false;
        end

        if (selection:HasAura( 91060 )) then
            player:SendNotification( "Данное действие невозможно: персонаж под защитой стражи!" )
            player:ResetSpellCooldown( spellId )
            return false;
        end

        local targetMoney = selection:GetCoinage()

        if (targetMoney < 500) then
            player:SendNotification( "Ничего не удалось украсть: персонаж слишком беден или не имеет с собой денег" )
            player:ResetSpellCooldown( spellId )
            return false;
        end

        if (targetMoney > 50000) then
            local amount = math.random(50, 500);
            selection:ModifyMoney(-amount);
            player:ModifyMoney(amount);
            player:SendNotification( "Успешно! Удалось украсть " .. amount .. " медных монет" )
            playersRubberyTime[selection:GetName()] = os.time();
            return true;
        end

        if (targetMoney >= 500) then
            local amount = math.random(50, 150);
            selection:ModifyMoney(-amount);
            player:ModifyMoney(amount);
            player:SendNotification( "Успешно! Удалось украсть " .. amount .. " медных монет" )
            playersRubberyTime[selection:GetName()] = os.time();
            return true;
        end

        return true;

	elseif (spellId == 90005) then -- GOB, case spell "start/stop a building mode"
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
    elseif ((spellId >= 88005 and spellId <= 88008) or (spellId >= 91154 and spellId <= 91162)) then
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
    elseif (spellId == 91179) then -- кости судьбы аое

        local energyAura = player:GetAura(ENERGY_SYSTEM_AURA) -- аура энергии
        if energyAura ~= nil then
            local rand = math.random(1,4)
            player:SendBroadcastMessage(player:GetName().." бросает кость на массовую атаку. Количество пораженных целей: |cFF79ed21  ".. rand .."|r")

            local playerEnergy = energyAura:GetStackAmount()

            if playerEnergy - 1  < 1 then
                player:RemoveAura(ENERGY_SYSTEM_AURA)
            else
                energyAura:SetStackAmount(playerEnergy - 1)
            end

            local nearPlayers = player:GetPlayersInRange(140, 0, 0)
            for index, nearPlayer in pairs(nearPlayers) do
                if player:IsInSameRaidWith(nearPlayer) then
                    nearPlayer:SendBroadcastMessage(player:GetName().." бросает Кости Судьбы на массовую атаку. Энергия снижается на 1. Количество пораженных целей: |cFF79ed21  ".. rand .."|r")
                end
            end

            local nearPlayers = player:GetPlayersInRange(40, 0, 0)
            for index, nearPlayer in pairs(nearPlayers) do
                if (player:IsInSameRaidWith(nearPlayer) ~= true) then
                    nearPlayer:SendBroadcastMessage(player:GetName().." бросает Кости Судьбы на массовую атаку. Энергия снижается на 1. Количество пораженных целей: |cFF79ed21  ".. rand .."|r")
                end
            end

        else
            player:SendBroadcastMessage(player:GetName()..": не достаточно энергии для проведения массовой атаки.")
        end
	end
end
RegisterPlayerEvent(EVENT_ON_CAST, castEvent);


CREATIVE_PHASE_AURA = 88052
FLY_AURA = 88054
function string:split(sep)
    local sep, fields = sep or ",", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end
---------------------Проверка условий третий ДМки-----------------------
function IsThirdDM(player)
	if player:HasAura(CREATIVE_PHASE_AURA) and player:GetPhaseMask() == 1024 and player:GetDmLevel() == 3 then
		return true
	else
		return false
	end
end
---------------------------- Ограничения на спавны -----------------------

local function isDeprecatedNpcEntry(entry)
	return (entry >= 100000 and entry < 2000000);
end

local function isDeprecatedNpcType(spawnedCreature)
	return (spawnedCreature:GetVehicleKit() or spawnedCreature:IsVendor() or spawnedCreature:IsInnkeeper() or spawnedCreature:IsBanker() or spawnedCreature:IsSpiritHealer() or spawnedCreature:IsSpiritGuide() or spawnedCreature:IsTaxi() or spawnedCreature:IsServiceProvider())
end

-------------------------- Спавн существ ----------------------------
function spawnDMCreature(player, entry, save)
    local x, y, z, o = player:GetLocation();
    local pid = player:GetGUIDLow();
    local map = player:GetMapId();
    local phase = player:GetPhaseMask();
    local DMcreature = PerformIngameSpawn( 1, entry, map, 0, x, y, z, o, save, pid, 0, phase);
    return DMcreature;
end

local function performDmCreatureSpawn(player, entry, save)
	if(entry == nil or isDeprecatedNpcEntry(entry))then
		player:SendBroadcastMessage("ОШИБКА: некорректное значение! Допустимы только целые числа в разрешенном диапазоне.")
	else
		PrintError(player:GetName().." поставил НПС: "..entry);
		local spawnedCreature = spawnDMCreature(player, entry, save);
		if (isDeprecatedNpcType(spawnedCreature)) then
			spawnedCreature:Delete();
		end
	end
end
-------------------Снять все ауры вайт-листа-----------------

function ClearWhiteAuras(player)
	for i,v in pairs(aura_whitelist) do
		if(player:HasAura( v )) then
			player:RemoveAura( v );
		end
	end

end

------------------------- Агро после подчинения --------------------

--[[function dmCreatureCombatStop(event, creature, diff)
	PrintError(" п123");
	if(creature:IsInCombat())then
		creature:AttackStop();
        	creature:ClearInCombat();
		creature:ClearThreatList();
		ClearUniqueCreatureEvents( creature:GetGUIDLow(), creature:GetInstanceId(), 7 );		
	end
end]]--
------------------------- Спавн гошек ------------------------------
local function performGobjectSpawn(player, gobEntry, save)
	if (gobEntry < 300000) then
		local x, y, z, o = player:GetLocation();
		local pid = player:GetGUIDLow();
		local map = player:GetMapId();
		local phase = player:GetPhaseMask();
		local DMobject = PerformIngameSpawn( 2, gobEntry, map, 0, x, y, z, o, save, pid, 0, phase);
		player:SendBroadcastMessage('Объект ID: '..DMobject:GetGUIDLow()..' ['..DMobject:GetName()..'] установлен.');
		PrintError(player:GetName().." поставил ГОБ: "..gobEntry);
        return DMobject;
	else
		player:SendBroadcastMessage("Данный объект недоступен для использования. Используйте объекты с ID меньше 300000")
	end
end
local function performDm3GobjectSpawn(player, gobEntry, save)
	local queryType = WorldDBQuery("SELECT type FROM `world`.`gameobject_template` WHERE entry = "..gobEntry.."")
	local gobType = queryType:GetInt32(0)
	if gobEntry < 300000 or (gobType == 0 or gobType == 5 or gobType == 7 or gobType == 9 or gobType == 10 or gobType == 32 or gobType == 34) then
		local x, y, z, o = player:GetLocation();
		local pid = player:GetGUIDLow();
		local map = player:GetMapId();
		local phase = player:GetPhaseMask();
		local DMobject = PerformIngameSpawn( 2, gobEntry, map, 0, x, y, z, o, save, pid, 0, 1024);
		player:SendBroadcastMessage('Объект ID: '..DMobject:GetGUIDLow()..' ['..DMobject:GetName()..'] установлен.');
		PrintError(player:GetName().." поставил ГОБ: "..gobEntry);
        return DMobject;
	else
		player:SendBroadcastMessage("Объект имеет запрещенный тип.")
	end
end
--------------------------- Меню призыва ---------------------------
dmTeleportMenuId = 6000;
ThirdDmTeleportMenuId = 6100;
ThirdDmAppearMenuId = 6101;
PlayerDmSummon = {}
PlayerDMAppear = {}
function OnGossipDmTeleport(event, player, object)
	player:GossipClearMenu() -- required for player gossip    
    player:GossipMenuAddItem(1, "Принять телепорт от "..object:GetName(), 1, 1, false, "Вы будете телепортированы.")
    player:GossipMenuAddItem(1, "Выход", 1, 2, false, nil, nil, false)
    PlayerDmSummon[player:GetGUIDLow()] = object:GetName();
    player:GossipSendMenu(1, player, dmTeleportMenuId) -- MenuId required for player gossip
end
function OnGossipThirdDmTeleport(event, player, object)
	player:GossipClearMenu() -- required for player gossip    
    player:GossipMenuAddItem(1, "Принять телепорт в творческую фазу от "..object:GetName(), 1, 1, false, "Вы будете телепортированы в творческую фазу. Выйти из фазы можно командой .leavephase")
    player:GossipMenuAddItem(1, "Выход", 1, 2, false, nil, nil, false)
    PlayerDmSummon[player:GetGUIDLow()] = object:GetName();
    player:GossipSendMenu(1, player, ThirdDmTeleportMenuId) -- MenuId required for player gossip
end

function OnGossipThirdDmAppear(event, player, object)
	player:GossipClearMenu() -- required for player gossip    
    player:GossipMenuAddItem(1, "Принять запрос на телепортацию к вам "..object:GetName(), 1, 1, false, "К вам переместится игрок"..object:GetName())
    player:GossipMenuAddItem(1, "Выход", 1, 2, false, nil, nil, false)
    PlayerDMAppear[player:GetGUIDLow()] = object:GetName();
    player:GossipSendMenu(1, player, ThirdDmTeleportMenuId) -- MenuId required for player gossip
end
local function OnGossipSelectTeleport(event, player, object, sender, intid, code, menuid)
	-- case 1 - открыть вложенное меню для перемещения объекта
    if (intid == 1) then
        local summoner = GetPlayerByName( PlayerDmSummon[player:GetGUIDLow()] )
		local phase = summoner:GetPhaseMask()
        local x, y, z, o = summoner:GetLocation();
        local map = summoner:GetMapId();
		if phase == 1024 and not player:GetPhaseMask() == 1024 then
			player:SendBroadcastMessage("Вы не можете быть перемещены в творческую фазу игроком не обладающим пакетом ДМ-доступа 3 уровня.")
			PlayerDmSummon[player:GetGUIDLow()] = nil;
			player:GossipComplete()
			return false
		end
        player:Teleport( map, x, y, z, o )
		player:SetPhaseMask(phase)
        PlayerDmSummon[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    elseif (intid == 2) then
        PlayerDmSummon[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    end
end
local function OnGossipSelectThirdDMTeleport(event, player, object, sender, intid, code, menuid)
    if (intid == 1) then
        local summoner = GetPlayerByName( PlayerDmSummon[player:GetGUIDLow()] )
		local phase = summoner:GetPhaseMask()
        local x, y, z, o = summoner:GetLocation();
        local map = summoner:GetMapId();
        player:Teleport( map, x, y, z, o )
		player:SetPhaseMask(1024)
		player:AddAura(CREATIVE_PHASE_AURA,player)
		player:SendBroadcastMessage("Вы были перемещены в творческую фазу. Выйти из фазы можно командой .leavephase.\n|cFFC43533ВНИМАНИЕ! Все поставленные ГО-Объекты нельзя будет вернуть обратно в инвентарь!")
        PlayerDmSummon[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    elseif (intid == 2) then
        PlayerDmSummon[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    end
end
local function OnGossipSelectThirdDMAppear(event, player, object, sender, intid, code, menuid)
	-- case 1 - открыть вложенное меню для перемещения объекта
    if (intid == 1) then
        local summoner = GetPlayerByName( PlayerDMAppear[player:GetGUIDLow()] )
		local phase = player:GetPhaseMask()
        local x, y, z, o = player:GetLocation();
        local map = player:GetMapId();
        summoner:Teleport( map, x, y, z, o )
		summoner:SetPhaseMask(1024)
		summoner:AddAura(CREATIVE_PHASE_AURA,summoner)
        PlayerDMAppear[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    elseif (intid == 2) then
        PlayerDMAppear[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    end
end
RegisterPlayerGossipEvent(dmTeleportMenuId, 2, OnGossipSelectTeleport)
RegisterPlayerGossipEvent(ThirdDmTeleportMenuId, 2, OnGossipSelectThirdDMTeleport)
RegisterPlayerGossipEvent(ThirdDmTeleportMenuId, 2, OnGossipSelectThirdDMAppear)

--------------------------- Меню морфа ---------------------------

dmSkinMenuId = 6001;
PlayerDmSkin = {}

function OnGossipDmSkin(event, player, object)
	player:GossipClearMenu() -- required for player gossip    
    player:GossipMenuAddItem(1, "Принять морф от "..object:GetName(), 1, 1, false, "Ваш облик будет изменен.")
    player:GossipMenuAddItem(1, "Выход", 1, 2, false, nil, nil, false)
    player:GossipSendMenu(1, player, dmSkinMenuId) -- MenuId required for player gossip
end

local function OnGossipSelectSkin(event, player, object, sender, intid, code, menuid)
	-- case 1 - открыть вложенное меню для перемещения объекта
    if (intid == 1) then
        local displayID = PlayerDmSkin[player:GetGUIDLow()];
        player:SetDisplayId(displayID);
        PlayerDmSkin[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    elseif (intid == 2) then
        PlayerDmSkin[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    end
end
RegisterPlayerGossipEvent(dmSkinMenuId, 2, OnGossipSelectSkin)

--------------------------- Меню порога ролла ---------------------------

rollDiffNumMenuId = 6002;
rollDiffNumTempStore = {}

function OnGossipRollDiff(event, player, object)
	player:GossipClearMenu() -- required for player gossip    
    player:GossipMenuAddItem(1, "Принять модификатор костей судьбы от "..object:GetName(), 1, 1, false, "Ваш модификатор костей судьбы будет изменен.")
    player:GossipMenuAddItem(1, "Выход", 1, 2, false, nil, nil, false)
    player:GossipSendMenu(1, player, rollDiffNumMenuId) -- MenuId required for player gossip
end

local function OnGossipSelectRollDiff(event, player, object, sender, intid, code, menuid)
	-- case 1 - открыть вложенное меню для перемещения объекта
    if (intid == 1) then
        local diffNum = rollDiffNumTempStore[player:GetGUIDLow()]; 
	if(diffNum == 0)then
	    diffNum = nil;
	end       
        roleCombat.diff_number[player:GetGUIDLow()] = diffNum;
        rollDiffNumTempStore[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    elseif (intid == 2) then
        rollDiffNumTempStore[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    end
end
RegisterPlayerGossipEvent(rollDiffNumMenuId, 2, OnGossipSelectRollDiff)

--------------------------- Меню аур ---------------------------

auraMenuId = 6003;
PlayerTempAura = {}

function OnGossipAura(event, player, object)
	player:GossipClearMenu() -- required for player gossip    
    player:GossipMenuAddItem(1, "Принять ауру от "..object:GetName(), 1, 1, false, "К вам будет применена аура, снять все ауры можно командой .clearauras")
    player:GossipMenuAddItem(1, "Выход", 1, 2, false, nil, nil, false)
    player:GossipSendMenu(1, player, auraMenuId) -- MenuId required for player gossip
end

local function OnGossipSelectAura(event, player, object, sender, intid, code, menuid)
	-- case 1 - открыть вложенное меню для перемещения объекта
    if (intid == 1) then
        local aura = PlayerTempAura[player:GetGUIDLow()];
		player:AddAura( aura, player );
        PlayerTempAura[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    elseif (intid == 2) then
        PlayerTempAura[player:GetGUIDLow()] = nil;
        player:GossipComplete()
    end
end
RegisterPlayerGossipEvent(auraMenuId, 2, OnGossipSelectAura)

--------------------------- Обработчик комманд ---------------------------

local function OnPlayerCommandWArg(event, player, code) -- command with argument
    if(player:GetDmLevel() > 0 or player:GetGMRank() > 0)then
        if(string.find(code, " "))then
	    PrintError(player:GetName().."---"..code);
            local arguments = {}
            local arguments = string.split(code, " ")
            if (arguments[1] == "npcadd" and #arguments == 2 ) then
                local entry = tonumber(arguments[2])
                performDmCreatureSpawn(player, entry, false)
                return false;
			elseif (arguments[1] == "npcput" and #arguments == 2 and player:GetDmLevel() >= 1) then
                local entry = tonumber(arguments[2])
                performDmCreatureSpawn(player, entry, true)
                return false;
            elseif (arguments[1] == "call" and #arguments == 2 ) then
				
                print(arguments[2])
                local target = GetPlayerByName( arguments[2] )
				if player:GetDmLevel() == 3 and player:GetPhaseMask() == 1024 then
					OnGossipThirdDmTeleport(event, target, player)
				else
					OnGossipDmTeleport(event, target, player)
                end
				return false;
			elseif (arguments[1] == "dmappear" and #arguments == 2 ) then
				
                print(arguments[2])
                local target = GetPlayerByName( arguments[2] )
				if player:GetDmLevel() == 3 and player:GetPhaseMask() == 1024 then
					OnGossipThirdDmAppear(event, target, player)
                end
				return false;
            elseif (arguments[1] == "skin" and #arguments == 2 ) then
                local entry = tonumber(arguments[2])
                local DM_target = player:GetSelectedUnit();
                if(entry == nil or entry == 987655)then -- or entry >= 100000
                    player:SendBroadcastMessage("ОШИБКА: некорректное значение! Допустимы только целые числа.")
                elseif(DM_target)then
                    local x, y, z, o = player:GetLocation();
                    local pid = player:GetGUIDLow();
                    local map = player:GetMapId();
                    local phase = 2
                    local DMcreature = PerformIngameSpawn( 1, entry, map, 0, x, y, z, o, false, pid, 0, phase);
                    if(DMcreature)then
                        local displayID = DMcreature:GetDisplayId(); 
                        if(not DMcreature:IsTrigger())then
                            local target_player = DM_target:ToPlayer();
                            if(target_player)then
                                PlayerDmSkin[target_player:GetGUIDLow()] = displayID;
                                OnGossipDmSkin(event, target_player, player)
                            else
                                DM_target:SetDisplayId(displayID);
                            end
                        else
                            player:SendBroadcastMessage("ОШИБКА: данная модель недоступна.")
                        end
                        DMcreature:Delete();
                    end
                else
                    player:SendBroadcastMessage("ОШИБКА: нет цели.")
                end
                return false;
            elseif (arguments[1] == "npcsay") then
                local DMcreature = player:GetTargetCreature();
                if(DMcreature:GetOwner() == player)then
                    local msg = "";
                    for i = 2, #arguments do
                        msg = msg.." "..arguments[i]
                    end
                    DMcreature:SendUnitSay(msg, 0);
                    return false;
                else
                    player:SendBroadcastMessage("ОШИБКА: NPC Вам не принадлежит.")
                    return false;
                end            
            elseif (arguments[1] == "npcemote") then
                local DMcreature = player:GetTargetCreature();
                if(DMcreature:GetOwner() == player)then
                    local msg = "";
                    for i = 2, #arguments do
                        msg = msg.." "..arguments[i]
                    end
                    DMcreature:SendUnitEmote(msg);
                    return false;
                else
                    player:SendBroadcastMessage("ОШИБКА: NPC Вам не принадлежит.")
                    return false;
                end            
            elseif (arguments[1] == "npcplayemote" and (#arguments == 2 or #arguments == 3)) then
                local DMcreature = player:GetTargetCreature();
                if(DMcreature:GetOwner() == player)then
                    local emoteid = tonumber(arguments[2])
                    if(emoteid == nil)then
                        player:SendBroadcastMessage("ОШИБКА: некорректное значение! Допустимы только целые числа.")
                    else
			if(#arguments == 2)then
                            DMcreature:Emote( emoteid )
			elseif(#arguments == 3)then
			    local param = tonumber(arguments[3])
			    if(param == 1)then
				DMcreature:EmoteState( emoteid )
			    end
			end
                    end
                    return false;
                else
                    player:SendBroadcastMessage("ОШИБКА: NPC Вам не принадлежит.")
                    return false;
                end
            elseif (arguments[1] == "npcroll" and #arguments == 3) then
                local DMcreature = player:GetTargetCreature();
                if(DMcreature:GetOwner() == player or player:GetGMRank() >= 1)then
                    local target = GetPlayerByName( arguments[2] )
                    if(target)then
                        attackRoll(DMcreature, target, arguments[3])
                    else
                        player:SendBroadcastMessage("ОШИБКА: Игрок с таким именем не найден.")
                    end
                    return false;
                else
                    player:SendBroadcastMessage("ОШИБКА: NPC Вам не принадлежит.")
                    return false;
                end
            elseif (arguments[1] == 'gobadd' and #arguments == 2) then
				local gobEntry = tonumber(arguments[2])
				performGobjectSpawn(player, gobEntry, false)
				return false
			elseif (arguments[1] == 'gobput' and #arguments == 2 and player:GetDmLevel() >= 1) then
				if IsThirdDM(player) then
					local gobEntry = tonumber(arguments[2])
					performDm3GobjectSpawn(player,gobEntry,true)
					return false	
				else
					if player:GetPhaseMask() == 1024 then
						player:SendBroadcastMessage("Вы не можете ставить объекты находясь в творческой фазе.")
						return false
					end
					local gobEntry = tonumber(arguments[2])
					performGobjectSpawn(player, gobEntry, true)
					return false
				end
			
			elseif (arguments[1] == 'auraput' and #arguments == 2 and (player:GetGMRank() >= 1 or IsThirdDM(player))) then
                local diff_number = tonumber(arguments[2])
                local target = player:GetSelectedUnit();
				if IsThirdDM(player) and not target:GetPhaseMask() == 1024 then
					player:SendBroadcastMessage("Игрок не находится в творческой фазе.")
					return false
				end
                if(target and diff_number)then                    
					for i,v in pairs(aura_whitelist) do
						if(tonumber(diff_number) == v) then
							local targetPlayer = target:ToPlayer();
							if(targetPlayer)then
								PlayerTempAura[targetPlayer:GetGUIDLow()] = diff_number;
								OnGossipAura(event, targetPlayer, player);
								return false;
							else
								player:AddAura(diff_number, target);
								return false;
							end
						end
					end                    
                end
            elseif (arguments[1] == 'wintadd' and #arguments == 3 and player:GetGMRank() > 1) then
				local gobEntry = tonumber(arguments[2])
                local gobSize = tonumber(arguments[3])
                if(gobEntry >=5041859 and gobEntry <= 5041869 and gobSize >= 0.01 and gobSize <= 3) then
                    local x, y, z, o = player:GetLocation();
                    local pid = player:GetGUIDLow();
                    local map = player:GetMapId();
                    local phase = player:GetPhaseMask();
                    local obj = PerformIngameSpawn( 2, gobEntry, map, 0, x, y, z, o, true, pid, 0, phase);
                    obj:SetScale(gobSize);
                end
				return false
            elseif (arguments[1] == 'gobsize' and #arguments == 3 and (player:GetGMRank() > 0 or IsThirdDM(player))) then
				local guidLow = tostring(arguments[2])
                local gobSize = tonumber(arguments[3])
				local gobjects = player:GetGameObjectsInRange(533);
				local rowCount = #gobjects;
				for var=1,rowCount,1 do	
					local targuid = tostring(gobjects[var]:GetDBTableGUIDLow());
					if( targuid == guidLow) then
						if((gobjects[var]:GetOwner() == player or player:GetGMRank() > 0) and gobSize >= 0.01 and gobSize <= 3)then
							local map = player:GetMap();	
							local gob = gobjects[var];
							gob:SetGoScale(gobSize);
							local phase = player:GetPhaseMask()
							gob:SetPhaseMask(4096)
							gob:SetPhaseMask(phase)
							player:SendBroadcastMessage('Размер изменен.');
                            return false;                            
						else
							player:SendBroadcastMessage('Ошибка: объект Вам не принадлежит или введены неверные данные.');
                            return false;
						end
					end
				end	
                player:SendBroadcastMessage('Объект не найден.');
				return false
            elseif (arguments[1] == 'removecorpse' and #arguments == 1) then
                if (player:GetGMRank() == 3) then
                    local worldObjectList = player:GetNearObjects( 10 )
                    for index, obj in pairs(worldObjectList ) do
                        if(obj:ToCorpse())then
                            local corpse = obj:ToCorpse();
                            obj:SetScale(0.01);
                        end
                    end	    	
                end
                return false
            elseif (arguments[1] == 'reloaddoors' and #arguments == 1) then
                if (player:GetGMRank() > 1) then
                    assignDoorsEvents();
                    assignFactionsData();  	
                end;
                return false
            elseif (arguments[1] == 'rolecombatprep' and #arguments == 2) then
                local radius = tonumber(arguments[2])
                --local moveTime = tonumber(arguments[3])
                if (player:GetGMRank() == 3 and radius) then
                    local combatArray = {};
                    
                    combatArray.created_time = os.time();
                    combatArray.updated_time = combatArray.created_time;
                    combatArray.creator = player:GetGUIDLow();
                    combatArray.map = player:GetMapId();
                    combatArray.x = player:GetX();
                    combatArray.y = player:GetY();
                    combatArray.z = player:GetZ();
                    combatArray.phase = player:GetPhaseMask();                    
                    combatArray.radius = radius;
                    --combatArray.moveTime = moveTime;
                    combatArray.active = false;
                    combatArray.factions = {};
                    
                    combatArray.roundFunction = roleCombatRound;
                    combatArray.cancelRoundFunction = false;
                    combatArray.roundId = 0;

                    local combatTrigger = PerformIngameSpawn( 1, 990002, combatArray.map, 0, combatArray.x, combatArray.y, combatArray.z, 0, true, combatArray.creator, 0, combatArray.phase);
                    combatArray.combatTrigger = combatTrigger:GetGUIDLow();
                    local combatBorder1 = PerformIngameSpawn( 2, 502552, combatArray.map, 0, combatArray.x+radius, combatArray.y-radius, combatArray.z+2, 0, false, combatArray.creator, 0, combatArray.phase);
                    local combatBorder2 = PerformIngameSpawn( 2, 502552, combatArray.map, 0, combatArray.x+radius, combatArray.y+radius, combatArray.z+2, 0, false, combatArray.creator, 0, combatArray.phase);
                    local combatBorder3 = PerformIngameSpawn( 2, 502552, combatArray.map, 0, combatArray.x-radius, combatArray.y-radius, combatArray.z+2, 0, false, combatArray.creator, 0, combatArray.phase);
                    local combatBorder4 = PerformIngameSpawn( 2, 502552, combatArray.map, 0, combatArray.x-radius, combatArray.y+radius, combatArray.z+2, 0, false, combatArray.creator, 0, combatArray.phase);
                    combatBorder1:SetScale(0.1);
                    combatBorder2:SetScale(0.1);
                    combatBorder3:SetScale(0.1);
                    combatBorder4:SetScale(0.1);
                    
                    combatArray.borders = { combatBorder1:GetGUIDLow(),
                                            combatBorder2:GetGUIDLow(),
                                            combatBorder3:GetGUIDLow(),
                                            combatBorder4:GetGUIDLow(),
                                            }
                    
                    table.insert(roleCombatArray, combatArray);
                    player:SendBroadcastMessage('Боевой айди: '..#roleCombatArray);
                end;
                return false
            elseif (arguments[1] == 'combataddfac' and #arguments == 5) then
                local combat_id = tonumber(arguments[2])
                local faction_bonus = tonumber(arguments[3])
                local faction_name = arguments[4]
                local leader_name = arguments[5]
                if (player:GetGMRank() == 3 and combat_id and faction_name) then
                    local faction_info = {};
                    faction_info.name = faction_name;
                    faction_info.leader_name = leader_name;
                    faction_info.army_bonus = faction_bonus;
                    faction_info.players_bonus = 0;
                    faction_info.members = {};
                    table.insert(roleCombatArray[combat_id].factions, faction_info);
                    player:SendBroadcastMessage('Фракция добавлена: '..#roleCombatArray[combat_id].factions.." "..faction_name);
                end;
                return false
            elseif (arguments[1] == 'combatstartprep' and #arguments == 2) then
                local combat_id = tonumber(arguments[2])
                if (player:GetGMRank() == 3 and combat_id) then
                    local combatBorder1 = GetGameObject(roleCombatArray[combat_id].borders[1], 502552, roleCombatArray[combat_id].map);
                    local combatBorder2 = GetGameObject(roleCombatArray[combat_id].borders[2], 502552, roleCombatArray[combat_id].map);
                    local combatBorder3 = GetGameObject(roleCombatArray[combat_id].borders[3], 502552, roleCombatArray[combat_id].map);
                    local combatBorder4 = GetGameObject(roleCombatArray[combat_id].borders[4], 502552, roleCombatArray[combat_id].map);
                    
                    combatBorder1:RemoveFromWorld();
                    combatBorder2:RemoveFromWorld();
                    combatBorder3:RemoveFromWorld();
                    combatBorder4:RemoveFromWorld();
                    
                    local combatTrigger = GetCreature(roleCombatArray[combat_id].combatTrigger, 990002, roleCombatArray[combat_id].map);
                    
                    local worldObjectList = combatTrigger:GetNearObjects( roleCombatArray[combat_id].radius, 16 )
                    for index, player_in_range in pairs(worldObjectList ) do
                        if(player_in_range:HasAura(88011))then
                            player_in_range:RemoveAura(88011);
                        end
                        local totalTime = player_in_range:GetTotalPlayedTime();
                        if(totalTime > 1)then
                            roleCombat.playerCombat[player_in_range:GetGUIDLow()] = combat_id;
                            roleCombat.ChooseFactionGossip(1, player_in_range, player_in_range)
                        else
                            player_in_range:SendBroadcastMessage('Персонаж провёл в мире менее 6 часов и не может учавствовать в битве.');
                        end
                    end
                    --player:SendBroadcastMessage('Фракция добавлена: '..#roleCombatArray[combat_id].factions.." "..faction_name);
                end;
                return false;
            elseif (arguments[1] == 'combatstart' and #arguments == 2) then
                local combat_id = tonumber(arguments[2])
                if (player:GetGMRank() == 3 and combat_id) then                
                    local roundFunction = CreateLuaEvent( roleCombatArray[combat_id].roundFunction, 240*1000, 1 );
                    roleCombatArray[combat_id].roundId = roundFunction;
                    
                    local combatTrigger = GetCreature(roleCombatArray[combat_id].combatTrigger, 990002, roleCombatArray[combat_id].map);
                    local namesArray = {};
                    
                    for index, faction in pairs(roleCombatArray[combat_id].factions) do
                        namesArray[index] = "|c00FF0632В битве на стороне "..faction.name..":|r"
                        for ind, member_name in pairs(faction.members) do
                            local member = GetPlayerByName(member_name);
                            if(member)then
                                namesArray[index] = namesArray[index].." "..member:GetName();
                                member:AddAura(88011, member);
                                member:SendBroadcastMessage('|c00FF0632Битва началась! Конец раунда через 4 минуты.|r');
                                member:SendAreaTriggerMessage('|c00FF0632Битва началась! Конец раунда через 4 минуты.|r');
                            end
                        end
                        local faction_leader = GetPlayerByName(faction.leader_name);
                        if(faction_leader)then
                            faction_leader:RemoveAura(88011);
                        end
                    end   

                    local worldObjectList = combatTrigger:GetNearObjects( roleCombatArray[combat_id].radius, 16 )
                    for ind, player_in_range in pairs(worldObjectList ) do
                        for index, faction in pairs(roleCombatArray[combat_id].factions) do
                            player_in_range:SendBroadcastMessage(namesArray[index]);
                        end
                    end                    
                end
                return false
            elseif (arguments[1] == 'combatstop' and #arguments == 2) then
                local combat_id = tonumber(arguments[2])
                if (player:GetGMRank() == 3 and combat_id ~= nil) then
                    local event_id = roleCombatArray[combat_id].roundId;
                    --RemoveEventById( event_id );
                    roleCombatArray[combat_id].roundId = nil;
                    for index, faction in pairs(roleCombatArray[combat_id].factions) do
                        for ind, member_name in pairs(faction.members) do
                            local member = GetPlayerByName(member_name);
                            if(member)then
                                member:RemoveAura(88011);
                                member:SendBroadcastMessage('|c00FF0632Битва завершилась! Одна из сторон бежит с поля боя.|r');
                                member:SendAreaTriggerMessage('|c00FF0632Битва завершилась! Одна из сторон бежит с поля боя.|r');
                                local wound = member:GetAura( 88013 );
                                if(wound)then
                                    local wound_stack = wound:GetStackAmount();
                                    local old_wound_stack = 0;
                                    local old_wound = member:GetAura( 88010 );
                                    if(old_wound)then
                                        old_wound_stack = old_wound:GetStackAmount();
                                    end
                                    if((wound_stack + old_wound_stack) >= 3)then
                                        --member:CreateCorpse();
                                        member:AddAura(8326, player);
                                    end
                                    member:RemoveAura(88013);
                                    member:RemoveAura(88010);
                                    local perm_wound = member:AddAura(88010, member);
                                    perm_wound:SetStackAmount(wound_stack+old_wound_stack);
                                end
                            end
                        end
                    end
                end;
                return false
            elseif (arguments[1] == 'setstat' and #arguments == 4) then
				if (player:GetGMRank() == 3) then
					local stat = tonumber(arguments[2]);
                    local val = tonumber(arguments[3]);
                    local apply = tonumber(arguments[4]);
                    local creature = player:GetSelectedUnit();
                    if(creature)then
                        if apply == 1 then
                            apply = true;
                        else
                            apply = false;
                        end;
                        creature:SetRoleStat(stat, val, apply)
                    end
				end;
				return false
            elseif (arguments[1] == 'removewounds' and #arguments == 2) then
				if (player:GetGMRank() == 3) then
					local players = GetPlayersInWorld();
                    for ind, pl in pairs(players) do
                        if(pl:HasAura(88013))then
                            local wound = pl:GetAura( 88013 );
                            if(wound)then
                                local wound_stack = wound:GetStackAmount();
                                pl:RemoveAura(88013);
                                local perm_wound = pl:AddAura(88010, pl);
                                perm_wound:SetStackAmount(wound_stack);
                            end
                        end
                        pl:RemoveAura(88014);
                    end
				end;
				return false
            elseif (arguments[1] == 'removeallwounds' and #arguments == 2) then
				if (player:GetGMRank() == 3) then
					local players = GetPlayersInWorld();
                    for ind, pl in pairs(players) do
                        if(pl:HasAura(88010))then
                            local wound = pl:GetAura( 88010 );
                            local wound_stack = wound:GetStackAmount();
                            if (wound_stack < 3)then
                                pl:RemoveAura(88010);
                            end
                        end
                    end
				end;
				return false
            elseif (arguments[1] == 'removecombat' and #arguments == 2) then
				if (player:GetGMRank() == 3) then
					local players = GetPlayersInWorld();
                    for ind, pl in pairs(players) do
                        if(pl:HasAura(88011))then
                            pl:RemoveAura(88011);
                        end
                    end
				end;
				return false
			elseif (arguments[1] == 'gobdel' and #arguments == 2) then
				local guidLow = tostring(arguments[2])			
				local gobjects = player:GetGameObjectsInRange(10)
				local rowCount = #gobjects;
				for var=1,rowCount,1 do	
					local targuid = tostring(gobjects[var]:GetGUIDLow());
					if( targuid == guidLow) then
						if(gobjects[var]:GetOwner() == player or player:GetGMRank() > 0 )then
							local map = player:GetMap();	
							local gob = gobjects[var];
							gob:RemoveFromWorld(true)
							player:SendBroadcastMessage('Объект удален.');				
						else
							player:SendBroadcastMessage('Ошибка: объект Вам не принадлежит.');
						end
					end
				end			
				return false
            elseif (arguments[1] == 'setdiff' and #arguments == 2) then
                local diff_number = tonumber(arguments[2])
                local target = player:GetSelectedUnit();
                if(target and diff_number)then
                    local targetPlayer = target:ToPlayer();
                    if(targetPlayer)then
                        rollDiffNumTempStore[targetPlayer:GetGUIDLow()] = diff_number;
                        OnGossipRollDiff(event, targetPlayer, player);
                        return false;
                    end
                end
            elseif (arguments[1] == 'raidsetdiff' and #arguments == 2) then
                local diff_number = tonumber(arguments[2])
                local playerGroup = player:GetGroup();
                if(playerGroup and diff_number)then
                    local groupMembers = playerGroup:GetMembers();
                    if(groupMembers)then
                        for index, target in pairs(groupMembers) do
                            rollDiffNumTempStore[target:GetGUIDLow()] = diff_number;
                            OnGossipRollDiff(event, target, player);
                        end
                        return false;
                    end
                end
			elseif (arguments[1] == 'telego' and #arguments == 2) then
                local guidLow = tostring(arguments[2])			
				local gobjects = player:GetGameObjectsInRange(10)
				local rowCount = #gobjects;
				for var=1,rowCount,1 do	
					local targuid = tostring(gobjects[var]:GetGUIDLow());
					if( targuid == guidLow) then
						if(gobjects[var]:GetOwner() == player or player:GetGMRank() > 0 )then
							local map = player:GetMap();	
							local gob = gobjects[var];
							gob:RemoveFromWorld(true)
							player:SendBroadcastMessage('Объект удален.');				
						else
							player:SendBroadcastMessage('Ошибка: объект Вам не принадлежит.');
						end
					end
				end			
			elseif (arguments[1] == 'changescale' and #arguments == 2) then
				local scale = tonumber(arguments[2])
                local DMcreature = player:GetTargetCreature()
				if(DMcreature:GetOwner() == player)then
					if scale <= 5 and scale >= 0.05 then
						DMcreature:SetScale(scale)
					else
						player:SendBroadcastMessage("Недопустимое значение. Значение не может быть меньше 0.05 и больше 5")
					end
				else
					player:SendBroadcastMessage("Существо вам не принадлежит")
				end
            elseif (arguments[1] == 'getvalue' and #arguments == 2) then
                if (player:GetGMRank() == 3) then
                    local playerGroup = player:GetGroup();
                    local groupMembers = playerGroup:GetMembers();
                    
                    for index, target in pairs(groupMembers) do
                        target:SetPhaseMask(phaseMask);
                    end
                    return false;
                end	
	    elseif (arguments[1] == 'pvpflag' and #arguments == 2) then
		if(player:GetGMRank() >= 2)then
                    local flag = tonumber(arguments[2])
                    local target = player:GetSelectedUnit();
                    if (target) then
		        target:SetPvP(flag);
                        return false;
                    end
		end
	    elseif (arguments[1] == 'setfaction' and #arguments == 2) then
			if(player:GetGMRank() >= 2)then
						local faction = tonumber(arguments[2])
						local target = player:GetSelectedUnit();
						if (target) then
					target:SetFaction(faction );
							return false;
						end
			end
            elseif (arguments[1] == 'raidphase' and #arguments == 2) then
                if(player:GetGMRank() >= 1)then
                    local phaseMask = tonumber(arguments[2])			
                    local playerGroup = player:GetGroup();
                    local groupMembers = playerGroup:GetMembers();
                    
                    for index, target in pairs(groupMembers) do
                        target:SetPhaseMask(phaseMask);
                    end
                end
				return false
			elseif (arguments[1] == "dmtele" and #arguments == 5 ) then
				if IsThirdDM(player) then
					local x = tonumber(arguments[2])
					local y = tonumber(arguments[3])
					local z = tonumber(arguments[4])
					local mapid = tonumber(arguments[5])
					player:Teleport( mapid, x, y, z, 1 )
					player:SetPhaseMask(1024,true)
				else
					player:SendBroadcastMessage("Вы не находитесь в творческой фазе или не обладаете ДМ-доступа 3 уровня.")
				end
			end
        end
        if(code == "npcdel")then
            local DMcreature = player:GetTargetCreature();
            if(DMcreature:GetOwner() == player)then
                DMcreature:Delete();
                return false;
            else
                player:SendBroadcastMessage("ОШИБКА: NPC Вам не принадлежит.")
                return false;
            end
		elseif (code == "delnearnpc") then
			local DMcreature = player:GetNearestCreature(10)
			if(DMcreature:GetOwner() == player)then
				DMcreature:Delete();
				return false;
			else
				player:SendBroadcastMessage("ОШИБКА: NPC Вам не принадлежит.")
				return false;
			end
        elseif(code == "npcposs")then
            local DMcreature = player:GetTargetCreature();
            if(DMcreature:GetOwner() == player)then
                player:CastSpell(DMcreature, 530, true);
                return false;
            else
                player:SendBroadcastMessage("ОШИБКА: NPC Вам не принадлежит.")
                return false;
            end
        elseif(code == "npcunposs")then
            local DMcreature = player:GetTargetCreature();
            if(DMcreature:GetOwner() == player)then
		--RegisterUniqueCreatureEvent(DMcreature:GetGUIDLow(), DMcreature:GetInstanceId(), 7, dmCreatureCombatStop);	
                DMcreature:RemoveAura( 530 );
                return false;
            else
                player:SendBroadcastMessage("ОШИБКА: NPC Вам не принадлежит.")
                return false;
            end
        elseif(code == "deskin")then
            local DM_target = player:GetSelectedUnit();
            if(DM_target)then
                DM_target:DeMorph();
                return false;
            else
                player:SendBroadcastMessage("ОШИБКА: нет цели.")
                return false;
            end
        elseif (code == "npcspanwer") then
            local DMcreature = player:GetTargetCreature();
            if(DMcreature:GetOwner())then
                player:SendBroadcastMessage("Owner ID: "..DMcreature:GetOwner());
                return false;
            else
                player:SendBroadcastMessage("ОШИБКА: NPC не имеет владельца.")
                return false;
            end	
		elseif (code == "speedup") then
			if IsThirdDM(player) then
				player:SetSpeed(1,5,true)
				player:SetSpeed(6,5,true)
			else
				player:SendBroadcastMessage("Вы не находитесь в творческой фазе или не имеете доступ к пакету ДМ-мастера 3 уровня")
			end
		elseif (code == "resetspeed") then
			if IsThirdDM(player) then
				player:SetSpeed(1,1,true)
				player:SetSpeed(6,1,true)
			end
		
        elseif (code == "gobnear") then
			local gobjects = player:GetGameObjectsInRange(10)
			local rowCount = #gobjects;
			for var=1,rowCount,1 do	
				if (player:GetGMRank() > 1) then	
					player:SendBroadcastMessage('ID: '..gobjects[var]:GetGUIDLow()..' ['..gobjects[var]:GetName()..']');				
					--player:SendBroadcastMessage('ID: '..gobjects[var]:GetGUIDLow()..' ['..gobjects[var]:GetName()..'] (account: '..gobjects[var]:GetOwner():GetAccountName()..')');
				elseif(gobjects[var]:GetOwner() == player )then
					player:SendBroadcastMessage('ID: '..gobjects[var]:GetGUIDLow()..' ['..gobjects[var]:GetName()..']');
				end
			end
			return false
		 elseif (code == "gobnear guid") then
			if player:GetGMRank() > 0 or IsThirdDM(player) then
				local gobjects = player:GetGameObjectsInRange(10)
				local rowCount = #gobjects;
				for var=1,rowCount,1 do	
					if (player:GetGMRank() > 1) then	
						player:SendBroadcastMessage('GUID: '..gobjects[var]:GetDBTableGUIDLow()..' ['..gobjects[var]:GetName()..']');				
						--player:SendBroadcastMessage('ID: '..gobjects[var]:GetGUIDLow()..' ['..gobjects[var]:GetName()..'] (account: '..gobjects[var]:GetOwner():GetAccountName()..')');
					elseif(gobjects[var]:GetOwner() == player )then
						player:SendBroadcastMessage('GUID: '..gobjects[var]:GetDBTableGUIDLow()..' ['..gobjects[var]:GetName()..']');
					end
				end
			end
			return false
		elseif (code == "neardis") then
			if player:GetGMRank() > 0 then
				local gobjects = player:GetGameObjectsInRange(5)
				local rowCount = #gobjects;
				for var=1,rowCount,1 do	
					if (player:GetGMRank() > 0) then	
						
						player:SendBroadcastMessage('Display: '..gobjects[var]:GetDisplayId()..' ['..gobjects[var]:GetName()..']');				
					end
				end
			end
			return false
		elseif (code == "targetdis") then
			if player:GetGMRank() > 0 then
				local gobject = player:GetNearestGameObject(5)
				player:SendBroadcastMessage('Display: '..gobject:GetDisplayId()..' ['..gobject:GetName()..']');				
			
			end
			return false
        elseif (code == "killwounded") then
            if (player:GetGMRank() == 3) then
                local players = GetPlayersInWorld();
                for ind, member in pairs(players) do
                    local wound = member:GetAura( 88010 );
                    if(wound)then
                        local wound_stack = wound:GetStackAmount();
                        local old_wound_stack = 0;
                        if((wound_stack + old_wound_stack) >= 3)then
                            --member:CreateCorpse();
                            member:AddAura(8326, member);
                        end
                    end
                end
                return false
            end
		elseif (code == "getfaction") then
                local target = player:GetSelectedUnit();
                if (target) then
		    player:SendBroadcastMessage(target:GetName().." "..target:GetFaction());
                    return false;
                end
        elseif (code == "getplayersplhase") then
            if (player:GetGMRank() == 3) then
                local players = GetPlayersInWorld();
                for ind, member in pairs(players) do
                    player:SendBroadcastMessage(member:GetName().." "..member:GetPhaseMask());
                end
                return false
            end
		elseif (code == "gotophase") then
			if player:GetDmLevel() == 3 then
				player:AddAura(CREATIVE_PHASE_AURA,player)
				player:SendBroadcastMessage("Вы были перемещены в творческую фазу. Выйти из фазы можно командой .leavephase.\n|cFFC43533ВНИМАНИЕ! Все поставленные ГО-Объекты нельзя будет вернуть обратно в инвентарь!")
				player:SetPhaseMask(1024,true)
				ClearWhiteAuras(player)
			end
		elseif (code == "kickphase") then
			if IsThirdDM(player) then
				local target = player:GetSelection()
				if target:GetPhaseMask() == 1024 then
					target:RemoveAura(CREATIVE_PHASE_AURA)
					player:RemoveAura(FLY_AURA)
					target:SetPhaseMask(1,true)
					ClearWhiteAuras(target)
				else
					player:SendBroadcastMessage("Игрок не находится в творческой фазе")
				end
			end
		elseif (code == "invis") then
			if IsThirdDM(player) then
				player:SetDisplayId(11686)
			else
				player:SendBroadcastMessage("Вы не находитесь в творческой фазе или не обладаете ДМ-доступом 3 уровня.")
			end
		elseif (code == "deinvis") then
			player:DeMorph()
			
		elseif code == "res" then
			if IsThirdDM(player) then
				local GM_target = player:GetSelectedUnit()
				if GM_target:GetPhaseMask() == 1024 then
					GM_target:ResurrectPlayer(100)
				else
					player:SendBroadcastMessage("Игрока нельзя воскресить, если он не находится в творческой фазе.")
				end
			end	
		elseif (code == "dmflyon") then
			if IsThirdDM(player) then
				player:AddAura(FLY_AURA,player)
			else
				player:SendBroadcastMessage("Вы не находитесь в творческой фазе или не обладаете ДМ-доступом 3 уровня.")
			end
		elseif (code == "dmflyoff") then
			if IsThirdDM(player) then
				player:RemoveAura(FLY_AURA)
			else
				player:SendBroadcastMessage("Вы не находитесь в творческой фазе или не обладаете ДМ-доступом 3 уровня.")
			end
		end	
    end
end
RegisterPlayerEvent(42, OnPlayerCommandWArg)
-- обработчики событий на создании, логине и логауте персонажа
-- также тут размещена часть кастомных команд, не распределенных по отдельным файлам
local EVENT_ON_LOGIN = 3;
local PLAYER_EVENT_ON_LOGOUT = 4;
local EVENT_ON_CAST = 5;
local PLAYER_EVENT_ON_FIRST_LOGIN = 30;
local TRIGGER_EVENT_ON_TRIGGER = 24;
local playerTempVariable;

--test
function Player:CustomFunc()
   --self is the player the method is used on
   self:SendBroadcastMessage(self:GetAccountId())
end
----------------- Белый список визуальных аур ----------------------------------------
aura_whitelist = {16592,88053, 34807, 48083, 52663, 54141, 56327, 64785, 68855,
    56741, 55708, 40158, 68862, 47503, 47335, 47428, 47704, 47705, 47706, 48795,
    49774, 49733, 62021, 51638, 63678, 52619, 52670, 53160, 57901, 56075, 55928,
    56102, 56740, 57551, 57887, 58429, 70491, 58712, 60857, 61372, 59908, 60342,
    61023, 61942, 62192, 62300, 62579, 62640, 63893, 63962, 64017, 64393, 64469,
    65593, 66969, 68302, 69136, 69198, 69422, 69658, 70022, 70571, 70763, 71304,
    71706, 71986, 71994, 72054, 72100, 72304, 72521, 72523, 73078, 74621, 75041,
    75498, 36945, 40158, 42571, 42586, 42610, 42656, 42709, 42744, 43085, 43328,
    45576, 46679, 46928, 46933, 46957, 47044, 47840, 50036, 50200, 51193, 51195,
    52855, 52952, 55474, 55664, 55766, 56093, 57446, 59044, 59069, 59562, 62192,
    67924, 68341, 47840, 51282, 57816, 58292, 58812, 58860, 60044, 61709, 62398,
    70789, 72712, 37450, 60451, 76006, 39284, 39295, 42146, 42294, 47417, 74836,
    61358, 74069, 74543, 75433, 75513, 48522, 48786, 49757, 50008, 51283, 56512,
    57598, 57613, 51201, 51518, 51619, 52148, 48044, 48141, 48308, 48311, 48312,
    48313, 55701, 56274, 57931, 59123, 60044, 58226, 58964, 60796, 65444, 65755,
    72366, 61358, 69861, 55664, 47044, 42075, 42525, 49310, 49311, 49837, 50057,
    50442, 50549, 50777, 51892, 51939, 52667, 59833, 53444, 53770, 53797, 54111,
    54134, 71025, 55949, 61236, 56133, 56717, 56914, 57630, 57687, 57932, 58016,
    58020, 58022, 58023, 59551, 59862, 62348, 62398, 62538, 62639, 63096, 63319,
    63369, 63084, 64416, 64690, 65087, 69663, 69703, 70300, 72130, 71947, 35994,
    40071, 42344, 42345, 42346, 42971, 43184, 43312, 45631, 45814, 46581, 68085,
    46583, 46767, 46934, 47172, 50381, 50544, 53143, 54690, 54942};

------------------ Донатные маунты -----------------------------------------

---- Кельдорайский белый конь
mount_white_horse_id = 1200006;
---- Козлик
mount_black_goat_id = 1200023;
mount_gold_goat_id = 1200024;
mount_white_goat_id = 1200025;
---- маунты реактивации Западная Долина
mount_zevra_id = 1200058;
mount_gien_id = 1200059;
mount_raptor_id = 1200060;


function checkWhiteHorseDonations(player)
	local accountId = player:GetAccountId();
	local result = AuthDBQuery("SELECT * FROM donations WHERE accountId = "..accountId .." and donateType='white_horse'");
	if(result ~= nil) then
		if((player:HasItem(mount_white_horse_id) or player:HasSpell(mount_white_horse_id)) == false) then
			local added = player:AddItem(mount_white_horse_id);                    
			if(added == nil)then
				SendMail( "Кель'дорайский белый конь", "Мы не смогли разместить спутника в вашем инвентаре. Спасибо за помощь проекту!", player:GetGUIDLow(), 0, 61, 0, 0, 0, mount_white_horse_id, 1 )
				player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентаре нет места. Приобретенный вами ездовой спутник - Кель'дорайский белый конь - отправлен по почте. Спасибо за помощь проекту!");
			else
				player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентарь добавлен приобретенный вами ездовой спутник - Кель'дорайский белый конь. Спасибо за помощь проекту!");
			end
		end	
    end
end
function checkBlackGoatDonations(player)
	local accountId = player:GetAccountId();
	local result = AuthDBQuery("SELECT * FROM donations WHERE accountId = "..accountId .." and donateType='black_goat'");
	if(result ~= nil) then

		if((player:HasItem(mount_black_goat_id) or player:HasSpell(mount_black_goat_id)) == false) then
			local added = player:AddItem(mount_black_goat_id);
			if(added == nil)then
				SendMail( "Черный козлик", "Мы не смогли разместить спутника в вашем инвентаре. Спасибо за помощь проекту!", player:GetGUIDLow(), 0, 61, 0, 0, 0, mount_black_goat_id, 1 )
				player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентаре нет места. Приобретенный вами ездовой спутник - Черный козлик - отправлен по почте. Спасибо за помощь проекту!");
			else
				player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентарь добавлен приобретенный вами ездовой спутник - Черный козлик. Спасибо за помощь проекту!");
			end
		end
    end
end
function checkGoldGoatDonations(player)
	local accountId = player:GetAccountId();
	local result = AuthDBQuery("SELECT * FROM donations WHERE accountId = "..accountId .." and donateType='gold_goat'");
	if(result ~= nil) then

		if((player:HasItem(mount_gold_goat_id) or player:HasSpell(mount_gold_goat_id)) == false) then
			local added = player:AddItem(mount_gold_goat_id);
			if(added == nil)then
				SendMail( "Золотой козлик", "Мы не смогли разместить спутника в вашем инвентаре. Спасибо за помощь проекту!", player:GetGUIDLow(), 0, 61, 0, 0, 0, mount_gold_goat_id, 1 )
				player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентаре нет места. Приобретенный вами ездовой спутник - Золотой козлик - отправлен по почте. Спасибо за помощь проекту!");
			else
				player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентарь добавлен приобретенный вами ездовой спутник - Золотой козлик. Спасибо за помощь проекту!");
			end
		end
    end
end
function checkWhiteGoatDonations(player)
	local accountId = player:GetAccountId();
	local result = AuthDBQuery("SELECT * FROM donations WHERE accountId = "..accountId .." and donateType='white_goat'");
	if(result ~= nil) then

		if((player:HasItem(mount_white_goat_id) or player:HasSpell(mount_white_goat_id)) == false) then
			local added = player:AddItem(mount_white_goat_id);
			if(added == nil)then
				SendMail( "Белый козлик", "Мы не смогли разместить спутника в вашем инвентаре. Спасибо за помощь проекту!", player:GetGUIDLow(), 0, 61, 0, 0, 0, mount_white_goat_id, 1 )
				player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентаре нет места. Приобретенный вами ездовой спутник - Белый козлик - отправлен по почте. Спасибо за помощь проекту!");
			else
				player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентарь добавлен приобретенный вами ездовой спутник - Белый козлик. Спасибо за помощь проекту!");
			end
		end
    end
end
function checkZevraDonations(player)
    local accountId = player:GetAccountId();
    local result = AuthDBQuery("SELECT * FROM donations WHERE accountId = "..accountId .." and donateType='zevra'");
    if(result ~= nil) then

        if((player:HasItem(mount_zevra_id) or player:HasSpell(mount_zevra_id)) == false) then
            local added = player:AddItem(mount_zevra_id);
            if(added == nil)then
                SendMail( "Жевра Западной Долины", "Мы не смогли разместить спутника в вашем инвентаре. Приятной игры!", player:GetGUIDLow(), 0, 61, 0, 0, 0, mount_zevra_id, 1 )
                player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентаре нет места. Выбранный вами ездовой спутник - Жевра Западной Долины - отправлен по почте. Приятной игры!");
            else
                player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентарь добавлен выбранный вами ездовой спутник - Жевра Западной Долины. Приятной игры!");
            end
        end
    end
end
function checkGienDonations(player)
    local accountId = player:GetAccountId();
    local result = AuthDBQuery("SELECT * FROM donations WHERE accountId = "..accountId .." and donateType='gien'");
    if(result ~= nil) then

        if((player:HasItem(mount_gien_id) or player:HasSpell(mount_gien_id)) == false) then
            local added = player:AddItem(mount_gien_id);
            if(added == nil)then
                SendMail( "Гиена диких степей", "Мы не смогли разместить спутника в вашем инвентаре. Приятной игры!", player:GetGUIDLow(), 0, 61, 0, 0, 0, mount_gien_id, 1 )
                player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентаре нет места. Выбранный вами ездовой спутник - Гиена диких степей - отправлен по почте. Приятной игры!");
            else
                player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентарь добавлен выбранный вами ездовой спутник - Гиена диких степей. Приятной игры!");
            end
        end
    end
end
function checkRaptorDonations(player)
    local accountId = player:GetAccountId();
    local result = AuthDBQuery("SELECT * FROM donations WHERE accountId = "..accountId .." and donateType='raptor'");
    if(result ~= nil) then

        if((player:HasItem(mount_raptor_id) or player:HasSpell(mount_raptor_id)) == false) then
            local added = player:AddItem(mount_raptor_id);
            if(added == nil)then
                SendMail( "Джунглевый раптор", "Мы не смогли разместить спутника в вашем инвентаре. Приятной игры!", player:GetGUIDLow(), 0, 61, 0, 0, 0, mount_raptor_id, 1 )
                player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентаре нет места. Выбранный вами ездовой спутник - Джунглевый раптор - отправлен по почте. Приятной игры!");
            else
                player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500В инвентарь добавлен выбранный вами ездовой спутник - Джунглевый раптор. Приятной игры!");
            end
        end
    end
end
----------------- Обновление способностей персонажа BEGIN -----------------
local skill_version = 8;
local class_spell_list = {  [1] = {88005, 88006, 88007, 88008, 91154, 91155, 91156, 91157, 91158, 91159, 91160, 91161, 91162, 75}, -- Воин
                            [2] = {88005, 88006, 88007, 88008, 91154, 91155, 91156, 91157, 91158, 91159, 91160, 91161, 91162}, -- Паладин
                            [3] = {88005, 88006, 88007, 88008, 91154, 91155, 91156, 91157, 91158, 91159, 91160, 91161, 91162, 75}, -- Охотник
                            [4] = {88005, 88006, 88007, 88008, 91154, 91155, 91156, 91157, 91158, 91159, 91160, 91161, 91162, 75}, -- Разбойник
                            [5] = {88005, 88006, 88007, 88008, 91154, 91155, 91156, 91157, 91158, 91159, 91160, 91161, 91162}, -- Жрец
                            [6] = {88005, 88006, 88007, 88008, 91154, 91155, 91156, 91157, 91158, 91159, 91160, 91161, 91162}, -- Рыцарь Смерти
                            [7] = {88005, 88006, 88007, 88008, 91154, 91155, 91156, 91157, 91158, 91159, 91160, 91161, 91162}, -- Шаман
                            [8] = {88005, 88006, 88007, 88008, 91154, 91155, 91156, 91157, 91158, 91159, 91160, 91161, 91162}, -- Маг
                            [9] = {88005, 88006, 88007, 88008, 91154, 91155, 91156, 91157, 91158, 91159, 91160, 91161, 91162}, -- Чернокнижник
                            [11] = {88005, 88006, 88007, 88008, 91154, 91155, 91156, 91157, 91158, 91159, 91160, 91161, 91162} -- Друид
                            }
local function updateCharacterSpells(player, playerGUID)
    local class = player:GetClass()
	player:LearnSpell(668);
    player:LearnSpell(75); -- автоматическая стрельба
	player:LearnSpell(33389); -- верховая езда
    player:LearnSpell(90005); -- режим строительства
    player:LearnSpell(90010); -- поднять объект
    player:LearnSpell(91000); -- обычный костер
    player:LearnSpell(26659); -- аура сэма
    --player:LearnSpell(18960); -- телепорт на лунку

    player:SetSkill(673,1,300,300); -- Низкий всеобщий.
    player:SetSkill(98,1,300,300); -- Всеобщий.

    -- броня и оружие
    player:SetSkill(673,1,300,300);
    player:SetSkill(44,1,300,300);
    player:SetSkill(45,1,300,300);
    player:SetSkill(415,1,300,300);
    player:SetSkill(226,1,300,300);
    player:SetSkill(173,1,300,300);
    player:SetSkill(95,1,300,300);
    player:SetSkill(118,1,300,300);
    player:SetSkill(46,1,300,300);
    player:SetSkill(54,1,300,300);
    player:SetSkill(229,1,300,300);
    player:SetSkill(433,1,300,300);
    player:SetSkill(136,1,300,300);
    player:SetSkill(43,1,300,300);
    player:SetSkill(176,1,300,300);
    player:SetSkill(172,1,300,300);
    player:SetSkill(160,1,300,300);
    player:SetSkill(55,1,300,300);
    player:SetSkill(162,1,300,300);
    player:SetSkill(228,1,300,300);

    --local playerGUID = player:GetGUIDLow()
    local spellsNeedUpdate = false;
    local result = CharDBQuery("SELECT version FROM character_spells_version WHERE ID = "..playerGUID)
    if result then
        repeat
            local version = result:GetUInt32(0)
            if(version < skill_version)then
                spellsNeedUpdate = true;
            end
        until not result:NextRow()
    else
        spellsNeedUpdate = true;
    end
    if(spellsNeedUpdate)then
        local entry = 86000
        --for entry=86000,87011,1 do
        repeat
            if(player:HasSpell(entry))then
                local needRemove = true;
                for i,allowed_entry in ipairs(class_spell_list[class]) do 
                    if(entry == allowed_entry)then
                        needRemove = false;
                        break;                    
                    end
                end
                if(needRemove)then
                    player:RemoveSpell( entry )
                end
            end
            entry = entry + 1;
            if(entry == 86019)then -- последняя способность диапозона 86xxx + 1. Скачком к 87xxx ускоряем проходимость цикла.
                entry = 87000
            end
        until not(entry <= 87011)
        --end
        for i,entry in ipairs(class_spell_list[class]) do 
            player:LearnSpell(entry);
        end
        CharDBExecute("REPLACE INTO character_spells_version (ID, version) VALUES ("..playerGUID..", "..skill_version..")")
    end
    player:SendBroadcastMessage("Способности обновлены");
end
----------------- Обновление способностей персонажа END -----------------

----------------- Очистка с персонажа аур, навешиваемых фичами типа лодки, дилижанса, etc
function cleanForcedAuras(player)
    if(player:HasAura(84047)) then -- весло на лодке
        player:RemoveAura(84047);
    end
    if(player:HasAura(60968)) then -- аура1 дилижанса
        player:RemoveAura(60968);
    end
    if(player:HasAura(65635)) then -- аура2 дилижанса
        player:RemoveAura(65635);
    end
    player:SendBroadcastMessage("Сломанные ауры почищены");
end

-----------------------------------------------------------------------------------
--------------------- ОБРАБОЧИК СОБЫТИЙ ПРИ ЛОГИНЕ В ИГРУ -------------------------
-----------------------------------------------------------------------------------
function loginEvent(event, player, arg2, arg3, arg4)	

    local playerGUID = player:GetGUIDLow();
    local accountId = player:GetAccountId();

    ----------- возвращаем игрока в основную фазу (перманентная и творческая обрабатываются позже в этом же методе)
    player:SetPhaseMask( 1, true );

    ----------- убираем с игрока лишние ауры
    cleanForcedAuras(player)

    ----------- инициируем стартовый квест
    local welcome_quest_status = player:GetQuestStatus( 110005 );
    if(welcome_quest_status == 3 or welcome_quest_status == 0)then
        player:AddQuest( 110005 );
    end

    ------------- обновляем абилки персонажа
    updateCharacterSpells(player, playerGUID)


    --------- Выдаем донатные плюшки (маунты и т.п.)
	checkWhiteHorseDonations(player);
	checkBlackGoatDonations(player);
	checkGoldGoatDonations(player);
	checkWhiteGoatDonations(player);
    checkZevraDonations(player);
    checkGienDonations(player);
    checkRaptorDonations(player);


    ----------- применяем перманентный рост, морф, фазу
    local result = CharDBQuery("SELECT display_id, height, phase FROM character_customs WHERE char_id = "..playerGUID)
    if result then
        repeat
            local display_id = result:GetUInt32(0)
            local height = result:GetFloat(1)
            local phase = result:GetUInt32(2)
            if(display_id > 0)then
                player:SetDisplayId( display_id );
                player:SendBroadcastMessage("Перманентный морф активирован");
            end
            if(height > 0 and height < 10)then
                player:SetScale( height );
                player:SendBroadcastMessage("Кастомный рост установлен");
            end
            ------///
            if(phase > 1)then
                player:SetPhaseMask( phase, true );
                player:SendBroadcastMessage("Персонаж перенесен в перманентную фазу");
            end
            ------///
        until not result:NextRow()
    end

    --------- обработываем творческую фазу (творческая фаза имеет больший приоритет, чем перманентная, потому обрабатывается позже)
    if player:HasAura(CREATIVE_PHASE_AURA) then-- Если игрок в Творческой фазе, то вернуть его в нее
        player:SetPhaseMask(1024, true );
        player:SendBroadcastMessage("Вы находитесь в творческой фазе. Выйти из фазы можно командой .leavephase.\n|cFFC43533ВНИМАНИЕ! Все поставленные ГО-Объекты нельзя будет вернуть обратно в инвентарь!")
    end
    
    if (accountId == 3) then -- митон посылал розальбе открытку на день святого валентина
        local currentTime = os.time();
        if (not player:HasItem( 300025 ) and currentTime >= 1550094000 and currentTime <= 1550350800) then
            playerTempVariable = player:GetName();
            local id = CreateLuaEvent( sendValentine, 4000, 1 );  
        end
    end
end

--------------------------- Обработчик кастомных комманд (кроме дм-ских) --------------
local function OnPlayerCommand(event, player, command)
    ---------------- звания --------------------------------------
	if (string.match(command, 'addtitle %d+$')) then -- Присвоение игроком себе звания
		local title = string.match(command, '%d+$')
		player:SetKnownTitle( title )
        return false
    elseif (string.match(command, 'deltitle %d+$')) then -- Удаление игроком у себя звания
		local title = string.match(command, '%d+$')
		player:UnsetKnownTitle( title )
        return false
    elseif (command == "test gossip") then
        OnGossipHello(event, player, player)
        return false
	---------------------- АУРЫ ----------------------------------
	elseif (string.match(command, 'clearauras')) then -- Удаление игроком у себя всех аур белого списка, доступно всем + удаление багованных аур от лодок и т.п.
		for i,v in pairs(aura_whitelist) do
			if(player:HasAura( v )) then
				player:RemoveAura( v );
				player:SendBroadcastMessage("Удалена аура " .. v);
			end
        end
        cleanForcedAuras(player)
        return false
	elseif (string.match(command, 'cleartargetauras')) then -- Удаление игроком у цели всех аур белого списка, доступно всем
		if(player:GetGMRank() > 0)then
			local target = player:GetSelectedUnit();
			for i,v in pairs(aura_whitelist) do
				if(target:HasAura( v )) then
					target:RemoveAura( v );
					player:SendBroadcastMessage("Удалена аура " .. v .. " с цели " .. target:GetName());
				end
			end
		end
        return false
	elseif (string.match(command, 'auradisp %d+$')) then -- снять ауру с цели
		if(player:GetGMRank() > 0)then
			local aura = string.match(command, '%d+$');
			for i,v in pairs(aura_whitelist) do
				if(tonumber(aura) == v) then
					local target = player:GetSelectedUnit();
					target:RemoveAura( v );
					player:SendBroadcastMessage("Удалена аура " .. v .. " с цели " .. target:GetName());
				end
			end
		end
        return false
    ------------------- гошки-телепортаторы установка, изменение -----------------------
	elseif (string.match(command, 'gobtele %d+$')) then -- Привязка телепорта к гошке
        local guid = string.match(command, '%d+$')
        if(player:GetGMRank() > 0 or IsThirdDM(player))then
            local entryQ = WorldDBQuery('SELECT id,owner_id FROM gameobject where guid = ' .. guid );
            if(entryQ ~= nil) then 
                local entry = entryQ:GetString(0);
				local ownerId = entryQ:GetInt32(1)
				if player:GetGMRank() == 0 and IsThirdDM(player) then
					if not ownerId == player:GetGUID() then
						player:SendBroadcastMessage("Нельзя назначить телепорт для объекта который вам не принадлежит")
						return false
					end
				end
                local x, y, z, o = player:GetLocation();
                local map = player:GetMapId();
                local pid = player:GetAccountId();
                local phase = player:GetPhaseMask();
                if(phase == 4294967295)then
                    phase = 1;
                end
                local guidQ = WorldDBQuery('SELECT * FROM gameobject_teleport where guid = ' .. guid );	
                if(guidQ ~= nil) then
                    WorldDBQuery('UPDATE gameobject_teleport SET map = ' .. map ..', position_x = ' .. x .. ', position_y = ' .. y .. ', position_z = ' .. z .. ', orientation = ' .. o .. ', user = ' .. pid .. ', phase = ' .. phase ..' where guid = ' .. guid );	
                    player:SendBroadcastMessage("Телепорт для объекта " ..guid.. " ОБНОВЛЕН!");	
                else
                    WorldDBQuery('INSERT INTO gameobject_teleport (guid, entry, map, position_x, position_y, position_z, orientation, user, phase ) VALUES (' .. guid ..',' .. entry ..', '.. map ..',' .. x .. ', ' .. y .. ',' .. z .. ',' .. o .. ', ' .. pid .. ', ' .. phase .. ')');
                    RegisterGameObjectGossipEvent(entry, 1, GoMovable.onGoTeleportGossip);				
                    player:SendBroadcastMessage("Телепорт для объекта " ..guid.. " СОЗДАН!");	
                end
            else	
                print ('error');
                player:SendBroadcastMessage("Ошибка - неверно введен GUID объекта!");	
                return false			
            end
        end
        return false
    ----------------------- мастерское добавление итемов ----------------------------
	elseif (string.match(command, 'itemadd %d+$')) then
		local entry = tonumber(string.match(command, '%d+$'))
		if (player:GetGMRank() > 1 and entry > 2110896) then -- 2110896 - с этого ID начинаются созданные мастерами итемы	
			if (entry == 2110926 or entry == 2110924 or entry == 2110923 or entry == 2110922 or entry == 2110921) then
				player:SendBroadcastMessage("Forbidden - excluded item id");
				return false;
			end
			local GM_target = player:GetSelectedUnit();
            if(GM_target)then
                GM_target:AddItem(entry);
                return false;
            else
                player:AddItem(entry);
                return false;
            end			
		end
        return false	
    elseif (string.match(command, 'characcount .+$')) then -- Получение имени аккаунта по персонажу
        local arguments = string.split(command, " ");
        local charName = string.gsub(arguments[2], '"', '');
        local charName = string.gsub(charName, "'", "");
        if(player:GetGMRank() > 1 and #arguments == 2)then
            local charQ = CharDBQuery("SELECT account, deleteInfos_Account FROM characters where name = '" .. charName .. "' or deleteInfos_Name = '" .. charName .."'");	
            if(charQ ~= nil)then
                local rowCount = charQ:GetRowCount();
                for var=1,rowCount,1 do			
                    local accountId = charQ:GetUInt32(0);               
                    local deletedAccountId = charQ:GetUInt32(1);
                    local accQ;
                    if(accountId > 0)then
                        accQ = AuthDBQuery('SELECT username from account where id = '.. accountId);
                        player:SendBroadcastMessage(charName..' - аккаунт: '.. accQ:GetString(0));
                    else
                        accQ = AuthDBQuery('SELECT username from account where id = '.. deletedAccountId);
                        player:SendBroadcastMessage(charName..' - Удален - аккаунт: '.. accQ:GetString(0));
                    end
                    charQ:NextRow();
                end
            end
            return false;
        end	
    elseif (string.match(command, 'charcust$')) then -- Получение внешности персонажа        
		local custQ = CharDBQuery('SELECT skin, face, hairStyle, hairColor, facialStyle FROM characters where guid = ' .. player:GetGUIDLow() );	
		if(custQ ~= nil)then
			player:SendBroadcastMessage("skin: "..custQ:GetUInt32(0).." face: "..custQ:GetUInt32(1).." hairStyle: "..custQ:GetUInt32(2).." hairColor: "..custQ:GetUInt32(3).." facialStyle: "..custQ:GetUInt32(4));
		end        
    elseif (string.match(command, 'areasound %d+$')) then -- Звук на область
        if(player:GetGMRank() >= 1)then
            local sound = tonumber(string.match(command, '%d+$'));
            player:PlayDistanceSound(sound);            
        end
        return false
    elseif (string.match(command, 'playsound %d+$')) then -- Звук себе
        local sound = tonumber(string.match(command, '%d+$'));
        player:PlayDistanceSound(sound, player);
        return false
    elseif (string.match(command, 'goblever %d+ %d+$')) then -- Привязка телепорта к гошке
        if(player:GetGMRank() > 1)then
            local guid = string.match(command, '%d+ ')
            local gate_guid = string.match(command, '%d+$')
            local entryQ = WorldDBQuery('SELECT id FROM gameobject where guid = ' .. guid );
            local gate_entryQ = WorldDBQuery('SELECT id FROM gameobject where guid = ' .. gate_guid );
            if(entryQ ~= nil and gate_entryQ ~= nil) then
                local entry = entryQ:GetString(0);
                local gate_entry = gate_entryQ:GetString(0);
                local pid = player:GetAccountId();
                local guidQ = WorldDBQuery('SELECT * FROM gameobject_lever where guid = ' .. guid );	
                if(guidQ ~= nil) then
                    WorldDBQuery('UPDATE gameobject_lever SET gate_guid = '.. gate_guid ..', gate_entry = '.. gate_entry ..', user = ' .. pid .. ' where guid = ' .. guid );	
                    player:SendBroadcastMessage("Lever for gob " ..guid.. " UPDATED!");	
                else
                    WorldDBQuery('INSERT INTO gameobject_lever (guid, entry, gate_guid, gate_entry, user ) VALUES (' .. guid ..',' .. entry ..', ' .. gate_guid .. ',' .. gate_entry .. ', ' .. pid .. ')');
                    RegisterGameObjectGossipEvent(entry, 1, Door.onGoLeverGossip);				
                    player:SendBroadcastMessage("Lever for gob " ..guid.. " CREATED!");	
                end
            else	
                print ('error');
                player:SendBroadcastMessage("Error - wrong gob guid!");	
                return false			
            end
        end
        return false
	end
end

--------------------------- Обработчик событий при логауте ---------------------------

local function logoutEvent(event, player, arg2, arg3, arg4)	
    -- nothing
end


local function OnAreaTrigger(event, player, triggerId)
    --player:SendBroadcastMessage(triggerId);
    local borderAngles = {[5697] = {4.7123, 4066.6, 5733.31},
                          [5740] = {1.5708, 3966.6, 5733.31}, 
                          [5742] = {0, 4016.6, 5699.98},
                          [5752] = {3.1415, 4016.6, 5766.64}};
    
    if(triggerId == 1)then
        player:Teleport( 1338, -889.445, 1562.098, 29.971, 3.032 ) --¬ старый √илнеас
    elseif(triggerId == 5873)then
        player:Teleport( 0, -762.440, 1550.5792, 20.5084, 6.069 ) --»з старого √илнеаса
    elseif(triggerId == 5813)then
        local vehicle = player:GetVehicle();
        player:Teleport( 901, 54.197, 138.743, 98.675, 0.017 ) --¬рата в ƒаларан
        if(vehicle)then
            local vehicle_unit = vehicle:GetOwner();
            vehicle_unit:NearTeleport(-99.93, 230.12, 53.45, 4.33);
        end
    elseif(triggerId == 5814)then
        player:Teleport( 901, -7.673, 93.251, 74.393, 2.574 ) --¬рата из ƒаларана
    elseif(triggerId == 5697 or triggerId == 5740 or triggerId == 5742 or triggerId == 5752)then
        local vehicle = player:GetVehicle();
        if(vehicle)then
            local vehicle_unit = vehicle:GetOwner();
            if(vehicle_unit:GetEntry() == 995000)then
                local angle = vehicle_unit:GetO() + borderAngles[triggerId][1];
                if(angle > 6.283185307178)then
                    angle = angle - 6.283185307178;
                end
                if(angle > 3.141592653589)then
                    vehicle_unit:SetFacing( 2 * borderAngles[triggerId][1] - vehicle_unit:GetO() );                      
                end   
            end
        end
    elseif(triggerId == 5660 or triggerId == 5689)then
        local vehicle = player:GetVehicle();
        if(vehicle)then
            local vehicle_unit = vehicle:GetOwner();
            if(vehicle_unit:GetEntry() == 995000)then
                local aura = vehicle_unit:GetAura( 84045 )
                if(aura)then  
		    if(footBall.lastHit[vehicle_unit:GetGUIDLow()])then
			vehicle_unit:SendUnitYell( footBall.lastHit[vehicle_unit:GetGUIDLow()].." забил гол!", 0 );
		    end                  
		    vehicle_unit:DespawnOrUnsummon();
                    player:CastSpell( player, 64885, true );
                    player:CastSpell( player, 62077, true ); --50444
		    player:Teleport( 907, 4016.6, 5733.31, 50.41, 4.33);
		    local ball = PerformIngameSpawn( 1, 995000, 907, 0, 4016.6, 5733.31, 50.41, 4.33, false, 0, 0, 1);
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







----------------------- ниже просто тестовый неразобранный код, чисто чтоб не забыть оставлено ----------------------

--[[local function castEvent(event, playerq, spell, skipCheck)
	if (event == 5) then
		playerq:SendBroadcastMessage("Test  cast!!!");
		playerq:CustomFunc();
	end
end]]

local entry = 40
local on_combat = 1
local function OnCombat(event, creature, target)
    creature:SendUnitYell("OOOOOOOOO!", 0);
end

RegisterCreatureEvent(entry, on_combat, OnCombat)

function sendValentine()
    local player = GetPlayerByName(playerTempVariable);
    local text = "Моя милая Сашенька, я очень старался, чтобы исполнить твоё желание и создать какой-нибудь миленький предметик для тебя ^^. Надеюсь, что у меня неплохо вышло? Ты нашла его сама, да. А теперь, каждый раз открывая и смотря его, читая это, вспоминай и знай, как я сильно тебя люблю. Ты лучшая.  Твой Андрей.";
    player:SendAddonMessage("VALENTINE_INJECT", text, 7, player);
    player:AddItem( 300025 );
    playerTempVariable = nil;
end

local function onState(event, gob, state)
	print('STATE');
	print(gob:GetEntry());
end
RegisterGameObjectEvent(194982, 10, onState)



local function onDIALOG(event, player, gob)
	print('DIALOG');
	print(gob:GetEntry());	
end
RegisterGameObjectEvent(194982, 6, onDIALOG)

local function onLOOT(event, gob, state)
	print('LOOT');
	print(gob:GetEntry());
end
RegisterGameObjectEvent(194982, 9, onLOOT)

local function onDUMMY(event, caster, spellid, effindex, gob)
	print('DUMMY');
	print(gob:GetEntry());
	print(caster:GetEntry());
end
RegisterGameObjectEvent(194982, 3, onDUMMY)
--¤лочный рай

local EVENT_ITEM_ON_USE = 2;
local item_entry = 4536;

function onItemUse(event, player, item, target)
	local x, y, z, o = player:GetLocation();
	player:SendBroadcastMessage(x.." "..y.." "..z.." "..o);
	local gob_entry = 190554;
	
	--gameObj = player:SummonGameObject( gob_entry, x, y, z, o, 0 );-- временный спавн, не пишет в базу 0-до релода сервера
	--gameObj:SaveToDB(); - не работает как хотелось бы, суммон не дает айдишника
	--print(gameObj:GetDBTableGUIDLow());
	
	--local myworldObject = PerformIngameSpawn( 2, 190554, 571, 0, x, y, z, o, true ); идеально работает (на карте 571 - это в нордсколе)
	local myworldObject = PerformIngameSpawn( 2, gob_entry, 1, 0, x, y, z, o, true);
	--myworldObject:SetRespawnTime(3)
	--print(myworldObject:GetDBTableGUIDLow());
	
	--myworldObject:SaveToDB();
	--print(myworldObject:GetDBTableGUIDLow());
end

---RegisterItemEvent(item_entry, EVENT_ITEM_ON_USE, onItemUse)
--¤лочный рай END


local GO_EVENT_ON_SPAWN = 2;
local GAMEOBJECT_EVENT_ON_REMOVE = 13;
local tikva = 375; --сделать карету на юз
local apple = 190554;
local bush = 400005;
local sm_tree = 400004;
local md_tree = 400001;
local lg_tree = 400003;


local function onRemoveEvent(event, gameobject)
	print("Start");
	local entity = gameobject:GetEntry();
	local map = gameobject:GetMapId();
	local x, y, z, o = gameobject:GetLocation();
	
	if entity == apple then
		PerformIngameSpawn( 2, bush, map, 0, x, y, z, o, false, 2);  
    elseif entity == bush then			
		PerformIngameSpawn( 2, sm_tree, map, 0, x, y, z, o, false, 2); 		
    elseif entity == sm_tree then		
		PerformIngameSpawn( 2, md_tree, map, 0, x, y, z, o, false, 2);  
	elseif entity == md_tree then
		PerformIngameSpawn( 2, lg_tree, map, 0, x, y, z, o, false );  
    else
		print("Error");
    end
end



--[[RegisterGameObjectEvent(apple, GAMEOBJECT_EVENT_ON_REMOVE, onRemoveEvent );
RegisterGameObjectEvent(bush, GAMEOBJECT_EVENT_ON_REMOVE, onRemoveEvent );
RegisterGameObjectEvent(sm_tree, GAMEOBJECT_EVENT_ON_REMOVE, onRemoveEvent );
RegisterGameObjectEvent(md_tree, GAMEOBJECT_EVENT_ON_REMOVE, onRemoveEvent );]]

function onSpawnApleEvent(event, go)
	print("Spawn");
	lol = go:RegisterEvent(goDel,5000,0);
	print(lol);
end

function goDel(event, delay, pCall, gameobject)
	print("Despawn");
end

RegisterGameObjectEvent(apple, 12, onSpawnApleEvent );
RegisterCreatureEvent(24475,5,onSpawnApleEvent);

-- — –»ѕ“ јЌƒ–≈я

local GAMEOBJECT_EVENT_ON_ADD = 9;

local function blabla(event, gobject)
 local player = gobject:GetOwner();
 local msg = gobject:GetDisplayId();
 if(player)then  
  player:Say("јЋЋј’ ј Ѕј–", 0);
  print("test");
 end;
end;

RegisterGameObjectEvent(2857, GAMEOBJECT_EVENT_ON_ADD, blabla);

local GobId = 123
local NpcId = 16222
local ItemId = 123 -- Item needs to have spell on use
local MenuId = 123 -- Unique ID to recognice player gossip menu among others

local function OnGossipHello(event, player, object)
print('111111111')
    player:GossipClearMenu() -- required for player gossip
    player:GossipMenuAddItem(0, "Open submenu", 1, 1)
    player:GossipMenuAddItem(0, "Test popup box", 1, 2, false, "Test popup")
    player:GossipMenuAddItem(0, "Test codebox", 1, 3, true, nil)
    player:GossipMenuAddItem(0, "Test money requirement", 1, 4, nil, nil, 50000)
    player:GossipSendMenu(1, object, MenuId) -- MenuId required for player gossip
end

local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
    if (intid == 1) then
        player:GossipMenuAddItem(0, "Close gossip", 1, 5)
        player:GossipMenuAddItem(0, "Back ..", 1, 6)
        player:GossipSendMenu(1, object, MenuId) -- MenuId required for player gossip
    elseif (intid == 2) then
        OnGossipHello(event, player, object)
    elseif (intid == 3) then
        player:SendBroadcastMessage(code)
        OnGossipHello(event, player, object)
    elseif (intid == 4) then
        if (player:GetCoinage() >= 50000) then
            player:ModifyMoney(-50000)
        end
        OnGossipHello(event, player, object)
    elseif (intid == 5) then
        player:GossipComplete()
    elseif (intid == 6) then
        OnGossipHello(event, player, object)
    end
end

RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect)

RegisterGameObjectGossipEvent(GobId, 1, OnGossipHello)
RegisterGameObjectGossipEvent(GobId, 2, OnGossipSelect)

--RegisterItemGossipEvent(ItemId, 1, OnGossipHello)
--RegisterItemGossipEvent(ItemId, 2, OnGossipSelect)

RegisterPlayerEvent(EVENT_ON_LOGIN, loginEvent);
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGOUT, logoutEvent);
RegisterPlayerEvent(42, OnPlayerCommand)
RegisterPlayerGossipEvent(MenuId, 2, OnGossipSelect)

RegisterServerEvent(TRIGGER_EVENT_ON_TRIGGER, OnAreaTrigger)

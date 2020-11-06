-- Определяем массивы для группировки методов и их массивы-хранилища.
local PlayerPortal = {} -- пользовательские порталы
PlayerPortal.targetportal = {}

GoMovable = {} -- передвигаемые GameObjects
GoTeleport = {} -- гошки - телепортаторы (Саша 27/05/2017)
local DoorTeleport = {} -- двери-"телепорты"
Wheel = {} -- штурвалы кораблей
local LocationTeleport = {} -- порталы с фиксированной точкой перемещения.
local PlayerContainer = {} -- сундуки с хранением пользовательских предметов.
local MusicMachine = {}
local TowerClock = {}
local Basement = {}
Door = {}
-- ID меню для окон.
GoMovable.MenuId = 5000 -- Манипуляции с Gobject 
Wheel.wheelMenuId = 5001 -- Штурвал
PlayerPortal.portalMenuId = 5003

-- gossip event for chair gameobject type (interaction with movable chairs. This is needed for compatibility of default chair interaction(sit on chair) with spell "bring gameobject - 90010")
function GoMovable.onChairGOSSIP(event, player, object)
	local questId = 110000;
	if(player:HasQuest(questId)) then
		local owner = object:GetOwner();
		if (owner == player) then
			local guid = object:GetGUID();
			PlayerBuild.targetgobject[player:GetGUIDLow()] = guid
			GoMovable.OnGossipMovable(event, player, player)		
		else
			player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFFORBIDDEN|r");
		end		
	else
		return false
	end
end

function GoMovable.assignChairGossipEvents()
	local chairQuery = WorldDBQuery('SELECT entry FROM gameobject_template WHERE (entry BETWEEN 500001 AND 500050)  or (entry > 499000 AND entry < 499101)'); -- diapason for tradable chairs type
	local rowCount = chairQuery:GetRowCount();
	local entry;
	for var=1,rowCount,1 do	
		entry = chairQuery:GetString(0);
		RegisterGameObjectGossipEvent(entry, 1, GoMovable.onChairGOSSIP);
		chairQuery:NextRow();
	end
end

GoMovable.assignChairGossipEvents(); -- Регистрируем события на стулья.


--------------------------------------
--- Гошки с кастомным текстом --------
--------------------------------------
local red = "|cffff0000"
local blue = "|cff00ccff"
local gray = "|cffbbbbbb"
local white = "|cffffffff"
local green = "|cff71C671"
local choco = "|cffCD661D"
local cyan = "|cff00ffff"
local sexpink = "|cffC67171"
local sexblue = "|cff00E5EE"
local sexhotpink = "|cffFF6EB4"
local purple = "|cffDA70D6"
local greenyellow = "|cffADFF2F"
local max_char = 2000

function GoMovable.sendMenuCustomSignColor(player, object)
	player:GossipClearMenu()
	player:GossipMenuAddItem(1,"Пергамент", 1, 14)
	player:GossipMenuAddItem(1,"Камень", 1, 15)
	player:GossipMenuAddItem(1,"Бронза", 1, 16)	
	player:GossipMenuAddItem(1,"Серебро", 1, 17)
	player:GossipMenuAddItem(1,"Мрамор", 1, 18)
	player:GossipMenuAddItem(1,"Валентинка", 1, 19)
	player:GossipMenuAddItem(1,"Закрыть", 1, 13)		
	player:GossipSendMenu(1, object, GoMovable.MenuId)
end



function GoMovable.onCustomSignGOSSIP(event,player,gob)
		local player_id = player:GetGUIDLow()	
		local gob_guid = gob:GetDBTableGUIDLow()
		local signQuery = WorldDBQuery("SELECT * FROM world.custom_signs where guid = '" .. gob_guid .."' LIMIT 1")
		if signQuery == nil then
			WorldDBQuery("INSERT INTO `world`.`custom_signs` (`guid`, `entry`, `owner_id`) VALUES ('"..gob_guid.."', '"..gob:GetEntry() .."', '"..player_id.."')")
			signQuery = WorldDBQuery("SELECT * FROM world.custom_signs where guid = '" .. gob_guid .."' LIMIT 1")
		end
		
		if signQuery ~= nil then
			if player:HasQuest(110000) then
				local owner = gob:GetOwner();
				if (owner == player) then
					local guid = gob:GetGUID();
					PlayerBuild.targetgobject[player:GetGUIDLow()] = guid
					GoMovable.OnGossipMovable(event, player, player)
				else
					player:SendBroadcastMessage("|cffff0000Данный объект вам не принадлежит")
				end
			else
				if signQuery:GetString(3) then
					player:SendAddonMessage("CUSTOMSIGN_GET_TEXT",signQuery:GetInt32(4) .."#".. signQuery:GetString(3),7,player)
				end
			end
		end
end

function GoMovable.assignCustomSignGossipEvents()
	local CustomSignQuery = WorldDBQuery('SELECT entry FROM gameobject_template WHERE (entry > 500050 AND entry < 500100)'); -- diapason for tradable chairs type
	local rowCount = CustomSignQuery:GetRowCount();
	local entry;
	for var=1,rowCount,1 do	
		entry = CustomSignQuery:GetString(0);	
		RegisterGameObjectGossipEvent(entry, 1, GoMovable.onCustomSignGOSSIP);
		CustomSignQuery:NextRow();
	end
end

GoMovable.assignCustomSignGossipEvents(); -- Регистрируем события на гошки с кастомным текстом.
--------------------------------------
-- END Гошки с кастомным текстом -----
--------------------------------------

function GoMovable.OnGossipMovable(event, player, object)
	
	local pid = player:GetGUIDLow();
	local map = player:GetMap();
	local gobGUID = PlayerBuild.targetgobject[pid];			
	local gob = map:GetWorldObject(gobGUID);
	player:SendBroadcastMessage("Выбран объект GUID: " .. tostring(gameObject:GetDBTableGUIDLow()));
	
    player:GossipClearMenu() -- required for player gossip
    player:GossipMenuAddItem(1, "Переместить объект", 1, 1, false, nil, nil, false)
    player:GossipMenuAddItem(1, "Забрать объект", 1, 2, false, "Забрать объект?")	

	if(gob:GetEntry() > 500050 and gob:GetEntry() < 500100) then	
		player:GossipMenuAddItem(1, "Изменить текст", 1, 11, true,"Вы дейтвительно хотите изменить текст? Весь старый текст будет удален.")
		player:GossipMenuAddItem(1, "Изменить фон", 1, 12, false,"Вы дейтвительно хотите изменить фон?")
	end
		
    if(player:GetGMRank() == 3 and (player:GetAccountId() == 1 or player:GetAccountId() == 3))then        
        if(gob:GetEntry() == 500274)then
            player:GossipMenuAddItem(1, "Построить подвал", 1, 9, false, "Построить подвал?")
	    player:GossipMenuAddItem(1, "Бур", 1, 10, false, "Бур тест")
        end
    end
    player:GossipSendMenu(1, object, GoMovable.MenuId) -- MenuId required for player gossip
end

function GoMovable.OnChangeLocation(player, object)
	player:GossipMenuAddItem(1, "Перместить по вертикали (вверх: +, вниз: -)", 1, 3, true)
	player:GossipMenuAddItem(1, "Повернуть вокруг своей оси (по часовой стрелке: +, против часовой: -, шаг: 1, полный оборот: 360)", 1, 4, true)
	player:GossipMenuAddItem(1, "Подвинуть на север/юг (север: +, юг: -)", 1, 5, true)
	player:GossipMenuAddItem(1, "Подвинуть на запад/восток (запад: +, восток: -)", 1, 6, true)
	player:GossipMenuAddItem(1, "Переместить по направлению взгляда персонажа (вперед: +, назад: -)", 1, 7, true)
	player:GossipMenuAddItem(1, "Изменить размер (доступны размеры от 10 до 300 процентов от стандартного)", 1, 20, true)
	player:GossipMenuAddItem(0, "Назад ..", 1, 8)
	player:GossipSendMenu(1, object, GoMovable.MenuId)
end

function GoMovable.formTargetGob(player)
	local pid = player:GetGUIDLow();
	local map = player:GetMap();
	local gobGUID = PlayerBuild.targetgobject[pid];			
	local gob = map:GetWorldObject(gobGUID);
	return gob;
end

-- обработка выбора пункта меню в gossip при взаимодействии с gameobject movable (переносной объект)
function GoMovable.OnGossipSelectGoMovable(event, player, object, sender, intid, code, menuid)
	-- case 1 - открыть вложенное меню для перемещения объекта
    if (intid == 1) then
        GoMovable.OnChangeLocation(player, object);
		
	-- case 2 - забрать объект  
    elseif (intid == 2) then 
		if(player:GetGMRank() == 2 or player:GetGMRank() == 1)then
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFДоступ запрещен для вашего типа аккаунта.|r");
            return false;
        end
		local map = player:GetMap();
		local gobGUID = PlayerBuild.targetgobject[player:GetGUIDLow()];
		local gob = map:GetWorldObject(gobGUID)
		if gob:GetPhaseMask() == 1024 then --Нельзя забирать гошки в 1024 фазе (Творческая фаза)
			player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFВы не можете забирать объекты в творческой фазе.|r");
			return false
		end
		local entry = gob:GetEntry();
		local item = player:AddItem(entry);
        if(item == nil)then
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНет места.|r");
            return false;
        end
        
		gob:RemoveFromWorld(true)
        player:GossipComplete()
		
	-- case 3 - переместить объект по вертикали (шаг - 0.01)
    elseif (intid == 3) then 
		local numX = tonumber(code)
		if(numX == nil) then
			player:SendBroadcastMessage("ОШИБКА: некорректное значение! Допустимы только целые числа")
		else
			local num = math.floor(numX);
			if(num > 300) then
				player:SendBroadcastMessage("ОШИБКА: максимальное значение: 300")
			elseif(num < -300) then
				player:SendBroadcastMessage("ОШИБКА: минимальное значение: -300")
			else
				local pid = player:GetGUIDLow();
				local map = player:GetMap();
				local gobGUID = PlayerBuild.targetgobject[pid];			
				local gob = map:GetWorldObject(gobGUID);
				local x, y, z, o = gob:GetLocation()
				local result = z+num/100;			
				local newGob = gob:MoveGameObject(x, y, result, o);
				local guid = newGob:GetGUID()
				PlayerBuild.targetgobject[player:GetGUIDLow()] = guid			
			end  		
		end
		      
        GoMovable.OnChangeLocation(player, object);
		
	-- case 4 - разворот объекта вокруг своей оси 
    elseif (intid == 4) then 
		local numX = tonumber(code)        
		if(numX == nil) then
			player:SendBroadcastMessage("ОШИБКА: некорректное значение! Допустимы только целые числа")
		else
			local num = math.floor(numX);
			if(num > 359) then
				player:SendBroadcastMessage("ОШИБКА: максимальное значение: 359")
			elseif(num < -359) then
				player:SendBroadcastMessage("ОШИБКА: минимальное значение: -359")
			else	
				local pid = player:GetGUIDLow();
				local map = player:GetMap();
				local gobGUID = PlayerBuild.targetgobject[pid];			
				local gob = map:GetWorldObject(gobGUID);				
				local x, y, z, o = gob:GetLocation();				
				local pass = 6.2831/360*num; -- 6.28 - полный оборот (0-север, 3.14 - юг)
				local result = o-pass;		
				local newGob = gob:MoveGameObject(x, y, z, result);		
				local guid = newGob:GetGUID()
				PlayerBuild.targetgobject[player:GetGUIDLow()] = guid				
			end     
		end		   
        GoMovable.OnChangeLocation(player, object);
	-- case 5 - переместить объект по оси х (шаг - 0.05)
	elseif (intid == 5) then 
		local numX = tonumber(code)
		if(numX == nil) then
			player:SendBroadcastMessage("ОШИБКА: некорректное значение! Допустимы только целые числа")
		else
			local num = math.floor(numX);
			if(num > 500) then
				player:SendBroadcastMessage("ОШИБКА: максимальное значение: 500")
			elseif(num < -500) then
				player:SendBroadcastMessage("ОШИБКА: минимальное значение: -500")
			else
				local pid = player:GetGUIDLow();
				local map = player:GetMap();
				local gobGUID = PlayerBuild.targetgobject[pid];			
				local gob = map:GetWorldObject(gobGUID);
				local x, y, z, o = gob:GetLocation()
				local result = x+num/100;			
				local newGob = gob:MoveGameObject(result, y, z, o);		
				local guid = newGob:GetGUID()
				PlayerBuild.targetgobject[player:GetGUIDLow()] = guid			
			end  		
		end		      
		GoMovable.OnChangeLocation(player, object);		
	-- case 6 - переместить объект по оси y (шаг - 0.05)
	elseif (intid == 6) then 
		local numX = tonumber(code)
		if(numX == nil) then
			player:SendBroadcastMessage("ОШИБКА: некорректное значение! Допустимы только целые числа")
		else
			local num = math.floor(numX);
			if(num > 500) then
				player:SendBroadcastMessage("ОШИБКА: максимальное значение: 500")
			elseif(num < -500) then
				player:SendBroadcastMessage("ОШИБКА: минимальное значение: -500")
			else
				local pid = player:GetGUIDLow();
				local map = player:GetMap();
				local gobGUID = PlayerBuild.targetgobject[pid];			
				local gob = map:GetWorldObject(gobGUID);
				local x, y, z, o = gob:GetLocation()
				local result = y+num/100;			
				local newGob = gob:MoveGameObject(x, result, z, o);		
				local guid = newGob:GetGUID()
				PlayerBuild.targetgobject[player:GetGUIDLow()] = guid			
			end  		
		end		      
		GoMovable.OnChangeLocation(player, object);			
	-- case 7 - переместить объект по направлению взгляда
	elseif (intid == 7) then 
		local numX = tonumber(code)
		if(numX == nil) then
			player:SendBroadcastMessage("ОШИБКА: некорректное значение! Допустимы только целые числа")
		else
			local num = math.floor(numX);
			if(num > 50) then
				player:SendBroadcastMessage("ОШИБКА: максимальное значение: 50")
			elseif(num < -50) then
				player:SendBroadcastMessage("ОШИБКА: минимальное значение: -50")
			else
				local pid = player:GetGUIDLow();
				local map = player:GetMap();
				local po = player:GetO();
				local gobGUID = PlayerBuild.targetgobject[pid];			
				local gob = map:GetWorldObject(gobGUID);
				local x, y, z, o = gob:GetLocation()
				local resultx = x+num/10*(math.cos(po));
				local resulty = y+num/10*(math.sin(po));
				local newGob = gob:MoveGameObject(resultx, resulty, z, o);		
				local guid = newGob:GetGUID();
				PlayerBuild.targetgobject[player:GetGUIDLow()] = guid;
			end  		
		end		      
		GoMovable.OnChangeLocation(player, object);
	elseif (intid == 20) then
		local numX = tonumber(code)
		if(numX == nil) then
			player:SendBroadcastMessage("ОШИБКА: некорректное значение! Допустимы только целые числа")
		else
			local num = math.floor(numX);
			if(num > 300) then
				player:SendBroadcastMessage("ОШИБКА: максимальное значение: 300 процентов")
			elseif(num < 10) then
				player:SendBroadcastMessage("ОШИБКА: минимальное значение: 10 процентов")
			else
				local gob = GoMovable.formTargetGob(object);
				local result = num/100;
				gob:SetGoScale(result)
				local phase = player:GetPhaseMask()
				gob:SetPhaseMask(4096)
				gob:SetPhaseMask(phase)
				player:SendBroadcastMessage('Размер изменен');
                local guid = gob:GetGUID();
				PlayerBuild.targetgobject[player:GetGUIDLow()] = guid;
			end
		end
		GoMovable.OnChangeLocation(player, object);
		-- case 5 - закрыть меню
    --elseif (intid == 5) then 
        --player:GossipComplete()
		
	-- case 8 - запустить начальное меню (выход из подменюшек)
    elseif (intid == 8) then 
        GoMovable.OnGossipMovable(event, player, object)
    elseif (intid == 9) then
        local pid = player:GetGUIDLow();
        local map = player:GetMap();
        local gobGUID = PlayerBuild.targetgobject[pid];			
        local gob = map:GetWorldObject(gobGUID);
        Basement.basementBuilderGossip(event, player, gob)
    elseif (intid == 10) then
        local pid = player:GetGUIDLow();
        local map = player:GetMap();
        local gobGUID = PlayerBuild.targetgobject[pid];			
        local gob = map:GetWorldObject(gobGUID);
        Basement.molemachineBuilderGossip(event, player, gob)
	elseif  intid == 13 then
		 player:GossipComplete()
	elseif intid == 12 then -- меню для переносных гошек с кастомным текстом
		GoMovable.sendMenuCustomSignColor(player, object)
	elseif intid == 11 then 
		local gob = GoMovable.formTargetGob(object);
		local new_text = ""
		for S in string.gmatch(code, "[^\"\'\\]") do
			if string.len(new_text) < max_char then
				new_text = (new_text..S)
			else
				player:SendBroadcastMessage(red.."Введеный текст содержит болee "..max_char.." символов (примечание: кириллица считается за 2 символа).")
				break
			end
		end
		player:SendBroadcastMessage(green.."Новый текст установлен!")
		WorldDBQuery("UPDATE `world`.`custom_signs` SET `text`='" .. tostring(new_text) .. "' WHERE  `guid`='"..gob:GetDBTableGUIDLow().."'")
		player:GossipComplete()
	elseif intid == 14 then
		local gob = GoMovable.formTargetGob(object);
		WorldDBQuery("UPDATE `world`.`custom_signs` SET `background`='" .. 0 .. "' WHERE  `guid`='"..gob:GetDBTableGUIDLow().."'")
		player:GossipComplete()
	elseif intid == 15 then	
		local gob = GoMovable.formTargetGob(object);
		WorldDBQuery("UPDATE `world`.`custom_signs` SET `background`='" .. 1 .. "' WHERE  `guid`='"..gob:GetDBTableGUIDLow().."'")
		player:GossipComplete()
	elseif intid == 16 then
		local gob = GoMovable.formTargetGob(object);
		WorldDBQuery("UPDATE `world`.`custom_signs` SET `background`='" .. 2 .. "' WHERE  `guid`='"..gob:GetDBTableGUIDLow().."'")
		player:GossipComplete()
	elseif intid == 17 then
		local gob = GoMovable.formTargetGob(object);
		WorldDBQuery("UPDATE `world`.`custom_signs` SET `background`='" .. 3 .. "' WHERE  `guid`='"..gob:GetDBTableGUIDLow().."'")
		player:GossipComplete()
	elseif intid == 18 then
		local gob = GoMovable.formTargetGob(object);
		WorldDBQuery("UPDATE `world`.`custom_signs` SET `background`='" .. 4 .. "' WHERE  `guid`='"..gob:GetDBTableGUIDLow().."'")
		player:GossipComplete()
	elseif intid == 19 then
		local gob = GoMovable.formTargetGob(object);
		WorldDBQuery("UPDATE `world`.`custom_signs` SET `background`='" .. 5 .. "' WHERE  `guid`='"..gob:GetDBTableGUIDLow().."'")
		player:GossipComplete()
	end  
end

-- DoorTeleport и LocationTeleport - в целом похожего действия.
function DoorTeleport.onDoorTeleportGOSSIP(event, player, object)
    local entry = object:GetEntry();
    local guid = object:GetDBTableGUIDLow();
	if(entry == 300400) then
        if(guid == 183402)then
            player:Teleport( 901, 1451.25, -1688.88, 23.31, 1 )
        end
	elseif(entry == 300401) then
        if(guid == 183416)then
            player:Teleport( 901, 1466.54, -1660.21, 69.3, 3.14 )
        elseif(guid == 200991)then
            player:Teleport( 901, 1522.61, -1670.25, 69.83, 3.14 )
        elseif(guid == 257269)then
            player:Teleport( 801, 1365.58, -942.02, 134.1, 3.91 )
        end
    elseif(entry == 540005) then
        if(guid == 201000)then
            player:Teleport( 901, 1505.48, -1671.33, -3.63, 1 )
        elseif(guid == 257268)then
	    player:Teleport( 801, 1370.67, -947.99, 99.75, 0.73 )
	else
            return false;
        end
    end
end

function LocationTeleport.onLocationTeleportGOSSIP(event, player, object)
    local faction = player:IsAlliance()
    if(object:GetDBTableGUIDLow() == 198779 or object:GetDBTableGUIDLow() == 198780)then
        if(faction) then
            player:Teleport( 901, 8403.27, -4443.26, 47.72, 2.42 )
        else
            player:Teleport( 530, 6771.24, -7791.82, 151.7, 0.6 )
        end
    elseif(object:GetDBTableGUIDLow() == 207258)then
        player:Teleport( 1, 9671, 980.7, 1293, 1.9 )
    elseif(object:GetDBTableGUIDLow() == 207259)then
        player:Teleport( 1, 2793, -369, 108, 3.43 )
    end
end

function Wheel.onWheelGOSSIP(event, player, object)
    Wheel.OnGossipWheelMenu(event, player, object);
    local guid = object:GetGUID();
    PlayerBuild.targetgobject[player:GetGUIDLow()] = guid
    player:SendBroadcastMessage(object:GetEntry());
end

function Wheel.OnGossipWheelMenu(event, player, object)	
    player:GossipClearMenu() -- required for player gossip
    player:GossipMenuAddItem(1, "Встать за штурвал", 1, 1, false, nil, nil, false)
    player:GossipMenuAddItem(1, "Отмена", 1, 2, false, "Выйти из меню?")
    player:GossipSendMenu(1, player, Wheel.wheelMenuId) -- wheelMenuId required for player gossip
end

function Wheel.OnGossipSelectWheel(event, player, object, sender, intid, code, menuid)
    if (intid == 1) then		
        vehicleEnter(player);
        player:GossipComplete();
    elseif (intid == 2) then
        player:GossipComplete();
    end
end

function PlayerPortal.onPortalTeleportCoordGOSSIP(event, player, object)
    player:GossipClearMenu() -- required for player gossip
    player:GossipMenuAddItem(1, "Долгота", 1, 3, true)
    player:GossipMenuAddItem(1, "Широта", 1, 4, true)
	player:GossipMenuAddItem(1, "Высота", 1, 5, true)
    player:GossipMenuAddItem(0, "Назад ..", 1, 6)
    player:GossipSendMenu(1, player, PlayerPortal.portalMenuId)
end

function PlayerPortal.onPortalTeleportGOSSIP(event, player, object)
    player:GossipClearMenu() -- required for player gossip
    
    if(PlayerPortal.targetportal[player:GetGUIDLow()] == nil)then
        local guid = object:GetGUID();
        PlayerPortal.targetportal[player:GetGUIDLow()] = {}        
		PlayerPortal.targetportal[player:GetGUIDLow()].guid = guid
        PlayerPortal.targetportal[player:GetGUIDLow()].x = 0;
        PlayerPortal.targetportal[player:GetGUIDLow()].y = 0;
        PlayerPortal.targetportal[player:GetGUIDLow()].z = 0;
    end
    player:GossipMenuAddItem(1, "Ввести координаты", 1, 1, false, nil, nil, false)
    player:GossipMenuAddItem(1, "Активировать", 1, 2, false, "Активировать?")
    player:GossipSendMenu(1, player, PlayerPortal.portalMenuId)
end

function PlayerPortal.OnGossipSelectPortal(event, player, object, sender, intid, code, menuid)
    if (intid == 1) then 
        PlayerPortal.onPortalTeleportCoordGOSSIP(event, player, object)
    elseif (intid == 2) then 
        local pid = player:GetGUIDLow();
		local mapid = player:GetMapId();
        local map = player:GetMap();
		local phase = player:GetPhaseMask();
        local gobGUID = PlayerPortal.targetportal[player:GetGUIDLow()].guid
        local gob = map:GetWorldObject(gobGUID);
        local x, y, z, o = gob:GetLocation()
		local myworldObject = PerformIngameSpawn( 2, 300301, mapid, 0, x, y, z, o, true, pid, 0, phase);
        PlayerPortal.targetportal[pid] = nil
        player:GossipComplete();
    elseif (intid == 3) then 
		local numX = tonumber(code)
		if(numX == nil) then
			player:SendBroadcastMessage("ОШИБКА: некорректное значение! Допустимы только целые числа")
		else
            PlayerPortal.targetportal[player:GetGUIDLow()].x = numX
			player:SendBroadcastMessage(numX)
		end
        PlayerPortal.onPortalTeleportCoordGOSSIP(event, player, object)
    elseif (intid == 4) then 
        local numY = tonumber(code)
		if(numY == nil) then
			player:SendBroadcastMessage("ОШИБКА: некорректное значение! Допустимы только целые числа")
		else
            PlayerPortal.targetportal[player:GetGUIDLow()].y = numY
			player:SendBroadcastMessage(numY)
		end
        PlayerPortal.onPortalTeleportCoordGOSSIP(event, player, object)
    elseif (intid == 5) then 
        local numZ = tonumber(code)
		if(numZ == nil) then
			player:SendBroadcastMessage("ОШИБКА: некорректное значение! Допустимы только целые числа")
		else
            PlayerPortal.targetportal[player:GetGUIDLow()].z = numZ
			player:SendBroadcastMessage(numZ)
		end
        PlayerPortal.onPortalTeleportCoordGOSSIP(event, player, object)
    elseif (intid == 6) then 
        PlayerPortal.onPortalTeleportGOSSIP(event, player, object)
    end
end

MusicMachine.activeMachine = {};

function MusicMachine.onMusicMachineGOSSIP(event, player, object)
    local questId = 110000;
    if(player:HasQuest(questId)) then
		local owner = object:GetOwner();
		if (owner == player) then
			local guid = object:GetGUID();
			PlayerBuild.targetgobject[player:GetGUIDLow()] = guid
			GoMovable.OnGossipMovable(event, player, player)		
		else
			player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFFORBIDDEN|r");
		end		
	else        
        local worldObjectList = object:GetNearObjects( 15, 16 );     
        for index, target in pairs(worldObjectList) do
            object:PlayDistanceSound(22753, target);
        end
	end
end

----------------------------- Ратуша Янтарной мельницы -----------------------------
TowerClock.soundMechGobjectGUID = GetObjectGUID( 239302, 300304 );

function TowerClock.playDingDong()
    if(TowerClock.soundMechGobjectGUID)then
        local map = GetMapById( 901 );
        local clockSoundObject = GetCreature(226914, 990001, 901);
        if(clockSoundObject)then
            local worldObjectList = clockSoundObject:GetNearObjects( 240, 16 );     
            for index, target in pairs(worldObjectList) do
                clockSoundObject:PlayDistanceSound(51000, target);
            end
        end
    end
end

function TowerClock.hourEvent()
    eventClosestHour = nil;
    local eventHour = CreateLuaEvent( TowerClock.hourEvent, 3600*1000, 1 );
    
    local hour = tonumber(os.date('%I', os.time()));
    
    local eventSound = CreateLuaEvent( TowerClock.playDingDong, 2*1000, hour );
end

cannonControlerInfo = {};
local function CannonControlDelay()
    local player = GetPlayerByGUID(cannonControlerInfo.player);
    local map = player:GetMap();
    local cannon = map:GetWorldObject(cannonControlerInfo.cannon);
    player:CastSpell(cannon, 88002);
end

local function CannonControlEvent(event, player, object)
    if(player:GetItemByEntry( 300000 ) and cannonControlerInfo.player == nil)then
        player:Teleport( 901, -112.934998, 806.650024, 100.498003, 1.650521 );
        local cannon = PerformIngameSpawn( 1, 987666, 901, 0, -112.934998, 806.650024, 100.398003, 1.650521, false);
        cannonControlerInfo.cannon = cannon:GetGUID();
        cannonControlerInfo.player = player:GetGUIDLow();
        cannonControlerInfo.console = object:GetGUID();
        local cannonControlEvent = CreateLuaEvent( CannonControlDelay, 500, 1 )
        object:SetGoState(0);
    else 
        player:SendBroadcastMessage("|c00B571B4У вас нет ключа к механизму.|r");
    end
end

RegisterGameObjectGossipEvent(300305, 1, CannonControlEvent);

local function AlarmControlEvent(event, player, object)
    if(player:GetItemByEntry( 300000 ))then
        local alarmEvent = CreateLuaEvent( TowerClock.playDingDong, 1*1000, 10 )
        local worldObjectList = object:GetNearObjects( 250, 16 );     
        for index, target in pairs(worldObjectList) do
            target:SendBroadcastMessage("|c00FF0632По всей Янтарной мельнице раздаётся звон колокола ратуши, оповещающий об объявленной тревоге.|r");
        end
        return false;
    else 
        player:SendBroadcastMessage("|c00B571B4У вас нет ключа к механизму.|r");
    end
end

RegisterGameObjectGossipEvent(300306, 1, AlarmControlEvent);

local hourEventDelay = os.time() - math.fmod(os.time(), 3600) + 3600;
local eventClosestHour = CreateLuaEvent( TowerClock.hourEvent, (hourEventDelay-os.time())*1000, 1 )
-------------------------------------------------------------------


--Регистрация меню для игроков.
RegisterPlayerGossipEvent(GoMovable.MenuId, 2, GoMovable.OnGossipSelectGoMovable);
RegisterPlayerGossipEvent(Wheel.wheelMenuId, 2, Wheel.OnGossipSelectWheel);
RegisterPlayerGossipEvent(PlayerPortal.portalMenuId, 2, PlayerPortal.OnGossipSelectPortal);

--Регистрация событий при клике по дверям-"телепортам".
RegisterGameObjectGossipEvent(300400, 1, DoorTeleport.onDoorTeleportGOSSIP);
RegisterGameObjectGossipEvent(300401, 1, DoorTeleport.onDoorTeleportGOSSIP);
RegisterGameObjectGossipEvent(540005, 1, DoorTeleport.onDoorTeleportGOSSIP);
--Регистрация события при клике по порталу с фиксированной точкой перемещения.
RegisterGameObjectGossipEvent(300301, 1, LocationTeleport.onLocationTeleportGOSSIP);
--Регистрация события при клике по штурвалу корабля.
RegisterGameObjectGossipEvent(300300, 1, Wheel.onWheelGOSSIP);
--Регистрация события при клике по пользовательскому порталу.
RegisterGameObjectGossipEvent(300302, 1, PlayerPortal.onPortalTeleportGOSSIP);

RegisterGameObjectGossipEvent(300303, 1, MusicMachine.onMusicMachineGOSSIP);


PlayerContainers = {}
PlayerContainerSession = {}
PlayerContainerFirstUse = {}

function PlayerContainers.OpenGossip(event, player, object)
    player:SendAddonMessage("PLAYER_CONTAINER_OPEN", string.format("%2d", object:GetContainerSize()) .. object:GetContainerItemList(), 7, player);
    PlayerContainerSession[player:GetGUIDLow()] = object:GetGUID();
    return false;
end

function PlayerContainers.StateChangeGossip(event, go, state)
    if(state == 3)then
        local goGUID = go:GetGUID();
        local goGUIDLow = go:GetDBTableGUIDLow();
        for index, container in pairs(PlayerContainerSession) do
            if(container == goGUID)then
                --[[if(not(PlayerContainerFirstUse[goGUIDLow]))then
                    PlayerContainerFirstUse[goGUIDLow] = true;
                else]]
                    PlayerContainerSession[index] = nil;
                    go:SetRespawnTime( 1 )
                --end
            end
        end
    end    
end

function PlayerContainers.assignChestGossipEvents()
	local chestQuery = WorldDBQuery('SELECT entry FROM gameobject_template WHERE type = 3 AND Data17 > 0'); -- diapason for chest type
	local rowCount = chestQuery:GetRowCount();
	local entry;
	for var=1,rowCount,1 do	
		entry = chestQuery:GetString(0);
        RegisterGameObjectGossipEvent(entry, 1, PlayerContainers.OpenGossip);
        RegisterGameObjectEvent(entry, 9, PlayerContainers.StateChangeGossip);
		chestQuery:NextRow();
	end
end

--PlayerContainers.assignChestGossipEvents();

--RegisterPlayerGossipEvent(6666, 2, TestSelect)
--RegisterGameObjectGossipEvent(4149, 1, PlayerContainers.OpenGossip);
--RegisterGameObjectEvent(4149, 9, PlayerContainers.StateChangeGossip);
--RegisterGameObjectEvent(153454, 14, TESTESTGossip); --153454

----------------------------- Подвалы -----------------------------
function Basement.basementBuilderGossip(event, player, object)
    if(player:GetGMRank() == 3 and object:GetEntry() == 500274)then
        local pid = player:GetGUIDLow();
        local map = player:GetMap();
        local gobO = object:GetO();	
        local phase = player:GetPhaseMask();
		local mapid = player:GetMapId();
        local x, y, z, o = object:GetLocation()
        
        local gobO1 = gobO+0.1972657952;
        local resultx = x+3.2*(math.cos(gobO1));
        local resulty = y+3.2*(math.sin(gobO1));
        local basementGO = PerformIngameSpawn( 2, 300500, mapid, 0, resultx, resulty, z-14, o+3.14155, true, pid, 0, phase);
        
        local gobO2 = gobO+2.00713;
        resultx = x+0.4*(math.cos(gobO2));
        resulty = y+0.4*(math.sin(gobO2));
        local enterGO = PerformIngameSpawn( 2, 300308, mapid, 0, resultx, resulty, z, o, true, pid, 0, phase);
        
        local gobO3 = gobO+3.14155;
        resultx = x+0.8582*(math.cos(gobO3));
        resulty = y+0.8582*(math.sin(gobO3));      
        local exitGO = PerformIngameSpawn( 2, 300307, mapid, 0, resultx, resulty, z-13.25, o, true, pid, 0, phase);        
        --local newGob = object:MoveGameObject(resultx, resulty, z, o);
    end
end

function Basement.basementEnterGossip(event, player, object)
    local pid = player:GetGUIDLow();
    local mapid = player:GetMapId();
    local x, y, z, o = object:GetLocation()
    local resultx = x-0.3*(math.cos(o));
    local resulty = y-0.3*(math.sin(o));
    player:Teleport( mapid, resultx, resulty, z-11.15, o+3.14155 );
end

function Basement.basementExitGossip(event, player, object)
    local pid = player:GetGUIDLow();
    local mapid = player:GetMapId();
    local x, y, z, o = object:GetLocation()
    local resultx = x+0.6*(math.cos(o));
    local resulty = y+0.6*(math.sin(o));
    player:Teleport( mapid, resultx, resulty, z+13.26, o+3.14155 );
end
RegisterGameObjectGossipEvent(300307, 1, Basement.basementExitGossip);
RegisterGameObjectGossipEvent(300308, 1, Basement.basementEnterGossip);
--------------------------------
moleMachineExitAvaible = 1;
function Basement.molemachineBuilderGossip(event, player, object)
    if(player:GetGMRank() == 3 and object:GetEntry() == 500274)then
        local pid = player:GetGUIDLow();
        local map = player:GetMap();
        local phase = player:GetPhaseMask();
		local mapid = player:GetMapId();
        local x, y, z, o = object:GetLocation()
    
        local basementGO = PerformIngameSpawn( 2, 300501, mapid, 0, x, y, z-100, o, true, pid, 0, phase);
        local enterGO = PerformIngameSpawn( 2, 300407, mapid, 0, x, y, z, o, true, pid, 0, phase);
    end
end

function Basement.molemachineEnterGossip(event, player, object)
    if(player:GetItemByEntry( 300002 ) and moleMachineExitAvaible == 1)then
        local mapid = player:GetMapId();
        local x, y, z, o = object:GetLocation()

        player:Teleport( mapid, x, y, z-97.5, o );
    else
        --player:SendBroadcastMessage("|c00B571B4У вас нет ключа к механизму.|r");
    end
end

function Basement.molemachineExitGossip(event, player, object)
    if(moleMachineExitAvaible == 1)then
	local mapid = player:GetMapId();
	local x, y, z, o = object:GetLocation()

	player:Teleport( mapid, x, y, z+95, o );
    end
end
RegisterGameObjectGossipEvent(300406, 1, Basement.molemachineExitGossip);
RegisterGameObjectGossipEvent(300407, 1, Basement.molemachineEnterGossip);
------------------------------------------------------------------------
----------------------------- Парилка Аста -----------------------------
local function steamVentGossip(event, player, object)
    local worldObjectList = object:GetNearObjects( 10, 32 );
    object:SetPhaseMask(2);
    local worldObjectList2 = object:GetNearObjects( 10, 32 );
    object:SetPhaseMask(1);
    for index, gameObject in pairs(worldObjectList) do
        if(gameObject:GetEntry() == 2552)then
            gameObject:SetPhaseMask(2);
        end
    end
    for index, gameObject in pairs(worldObjectList2) do
        if(gameObject:GetEntry() == 2552)then
            gameObject:SetPhaseMask(1);
        end
    end
end
RegisterGameObjectGossipEvent(300309, 1, steamVentGossip);
-------------------------------------------------------------------------
function LadderGossip(event, player, object) -- REMOVE
    if(object:GetDBTableGUIDLow() == 245543)then
        local pid = player:GetGUIDLow();
        local mapid = player:GetMapId();
        player:Teleport( mapid, 2871.63, 1814.321, 8.058, 3.2 );
    end
end
RegisterGameObjectGossipEvent(500570, 1, LadderGossip);

-----------------------------------------------------------------------------------
------------------------ ГОШКИ - ТЕЛЕПОРТАТОРЫ ------------------------------------
-----------------------------------------------------------------------------------
-- Принцип работы: игрок ставит гошку, после чего идет в destination печатает команду .gobtele 4324121
-- В этот момент в базу складывается запись с текущей координатой игрока, регается ивент госсип.
-- Дальше при клике на гошку игрока будет телепортировать по этим координатам.
function GoMovable.onGoTeleportGossip(event, player, object)
	local guid = object:GetDBTableGUIDLow();
	local coordsQuery = WorldDBQuery('SELECT map, position_x, position_y, position_z, orientation, phase FROM gameobject_teleport where guid = ' .. guid );	
	if(coordsQuery ~= nil) then
		local coords = coordsQuery:GetRow();
		player:SetPhaseMask( coords['phase']);
		player:Teleport( coords['map'], coords['position_x'], coords['position_y'], coords['position_z'], coords['orientation'] );		
	else	
		return false
	end
end

function GoTeleport.assignGobjectTeleportEvents()
	local goTeleQuery = WorldDBQuery('SELECT DISTINCT entry FROM gameobject_teleport');
	if (goTeleQuery ~= nil) then
		local rowCount = goTeleQuery:GetRowCount();	
		local entry;
		for var=1,rowCount,1 do
			entry = goTeleQuery:GetString(0);
			RegisterGameObjectGossipEvent(entry, 1, GoMovable.onGoTeleportGossip);
			goTeleQuery:NextRow();
		end
	end	
end
GoTeleport.assignGobjectTeleportEvents(); -- Регистрируем события на двери.

-----------------------------------------------------------------------------------
------------------------ ГОШКИ - РЫЧАГИ -------------------------------------------
-----------------------------------------------------------------------------------
-- .goblevel <level_id> <gate_id>
function Door.onGoLeverGossip(event, player, object)
	local guid = object:GetDBTableGUIDLow();
	local gateQuery = WorldDBQuery('SELECT gate_guid, gate_entry FROM gameobject_lever where guid = ' .. guid );	
	if(gateQuery ~= nil) then
        local map = player:GetMap()
        local gate_info = gateQuery:GetRow();
		local gateObject = GetGameObject(gate_info['gate_guid'], gate_info['gate_entry'], map:GetMapId());
        if(gateObject)then
            if(gateObject:GetGoState() == 0)then
                gateObject:SetGoState(1);
            elseif(gateObject:GetGoState() == 1)then
                gateObject:SetGoState(0);
            else
                return false
            end
        end
	else	
		return false
	end
end

function Door.assignGobjectLeverEvents()
	local goLeverQuery = WorldDBQuery('SELECT DISTINCT entry FROM gameobject_lever');
	if (goLeverQuery ~= nil) then
		local rowCount = goLeverQuery:GetRowCount();	
		local entry;
		for var=1,rowCount,1 do
			entry = goLeverQuery:GetString(0);
			RegisterGameObjectGossipEvent(entry, 1, Door.onGoLeverGossip);
			goLeverQuery:NextRow();
		end
	end	
end
Door.assignGobjectLeverEvents(); -- Регистрируем события на рычаге.
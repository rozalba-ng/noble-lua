--	ФУНКЦИИ ДЛЯ РАБОТЫ С ЭЛЕМЕНТАМИ СИСТЕМЫ ШТОРМГРАДА

--	Экшн время, диапазон серверного времени в часах под активную игру.
--	По-умолчанию (С учетом разницы во времени):
--	local actiontime = { 17, 20 }
local actiontime = { 18, 21 }
--	Время для более спокойного социала
--	По-умолчанию (С учетом разницы во времени):
--	local socialtime = { 15, 23 }
local socialtime = { 13, 23 }

--	Количество часов в течении которого владелец предприятия не сможет закрыть дверь после её взлома.
--	(На самом деле секунды, поэтому добавлено умножение на 3600)
local door_break_time = 2 *3600

--	Королевство Штормград
law_faction = 1162
--	Тени Штормграда
thiefs_faction = 1163

amount_reputation_friendly = 3000;
amount_reputation_honored = 9000;
amount_reputation_revered = 21000;
amount_reputation_exalted = 42000;

--	Перечень зон основного полигона.
mainPlaygroundZones = {
	aura = 91065, -- Аура гильдхолла на территории Штормграда.
	1519, -- Штормград
	--	Какие-то зоны с карты.
	--	Список ниже необходимо пересобрать после того как мы убедимся в том что все зоны на карте размечены правильно.
	10237,
	10236,
	10235,
	10199,
	10234,
	10214,
	10197,
	10160,
	10179,
	10232,
	10233,
	12,
}

-- Игрок на основном полигоне?
function Player:InMainPlayground()
	if self:HasAura( mainPlaygroundZones.aura ) then
		return true
	else
		local zone = self:GetZoneId()
		for i = 1, #mainPlaygroundZones do
			if mainPlaygroundZones[i] == zone then
				return true
			end
		end
	end
	return false
end

--	Сейчас время актива или нет?
function ActionTime()
	local t = tonumber( os.date("%H") )
	if t >= actiontime[1] and t <= actiontime[2] then return true
	else return false end
end

-- Сейчас время социала или нет?
function SocialTime()
	local t = tonumber( os.date("%H") )
	if t >= socialtime[1] and t <= socialtime[2] then return true
	else return false end
end

--	Является ли дверь дверью предприятия?
function GameObject:IsStormwindStore()
	if self:ToGameObject() then
		local guid = self:GetDBTableGUIDLow()
		if lockedDoorArray[guid] and lockedDoorArray[guid].region_id == 1 and lockedDoorArray[guid].can_own_faction == 1 then
			return true
		end
	end
	return false
end

--	Получение GUID'а двери привязанной к сундуку предприятия.
function GameObject:GetStoreDoor()
	if self:ToGameObject() then
		local chestGuid = self:GetDBTableGUIDLow()
		local doorsQ = CharDBQuery( "SELECT door_guid FROM doors_config WHERE chest_guid = "..chestGuid )
		if doorsQ then
			return doorsQ:GetUInt32(0)
		end
	end
	return nil
end

--	Получение GUID'а сундука привязанного к двери предприятия.
function GameObject:GetStoreChest()
	if self:ToGameObject() then
		local doorGuid = self:GetDBTableGUIDLow()
		local doorsQ = CharDBQuery( "SELECT chest_guid FROM doors_config WHERE door_guid = "..doorGuid )
		if doorsQ then
			return doorsQ:GetUInt32(0)
		end
	end
	return nil
end

--	Получение параметров двери предприятия по объекту сундука или двери
--	Возвращает таблицу вида:
--[[
	{
		level = 0,		- Уровень предприятия
		lock = 0,		- Уровень замка (0 это его отсутствие)
		trap = 0,		- Уровень ловушки (0 это его отсутствие)
		signal = 0,		- Уровень сигнализации (0 это его отсутствие)
	}
]]--
function GameObject:GetStoreConfig()
	if self:ToGameObject() then
		local guid = self:GetDBTableGUIDLow()
		local doorsQ = CharDBQuery( "SELECT door_level, slot_lock, slot_trap, slot_signaling FROM doors_config WHERE chest_guid = "..guid.." OR door_guid = "..guid )
		if doorsQ then
			local T = {}
			T.level = doorsQ:GetUInt8(0)
			T.lock = doorsQ:GetUInt8(1)
			T.trap = doorsQ:GetUInt8(2)
			T.signal = doorsQ:GetUInt8(3)
			return T
		end
	end
	return nil
end


--	Получение текущего баланса предприятия
function GameObject:GetStoreBalance()
	if self:ToGameObject() then
		local balanceQ
		local guid = self:GetDBTableGUIDLow()
		balanceQ = CharDBQuery( "SELECT balance FROM doors_config WHERE chest_guid = "..guid.." OR door_guid = "..guid )
		if balanceQ then
			return balanceQ:GetInt32(0)
		end
	end
	return nil
end

--	Установка баланса предприятия
function GameObject:SetStoreBalance(balance)
	if self:ToGameObject() and tonumber(balance) then
		local guid = self:GetDBTableGUIDLow()
		CharDBQuery( "UPDATE doors_config SET balance = '"..balance.."' WHERE door_guid = "..guid.." OR chest_guid = "..guid )
	end
end

--	Модификация текущего баланса предприятия (Прибавить/Отнять)
function GameObject:ModStoreBalance(num)
	if self:ToGameObject() and tonumber(num) then
		local balance = self:GetStoreBalance()
		if ( balance + num ) >= 0 then
			self:SetStoreBalance( balance + num )
			return true
		else return false end
	end
	return nil
end

--	Принудительное открытие двери предприятия (Владелец не сможет закрыть)
function GameObject:LockStoreDoor(unlock)
	local guid = self:GetDBTableGUIDLow()
	if not unlock then
	--	Принудительно открыть и запретить закрытие в ближайшее время
		CharDBQuery( "UPDATE doors_config SET door_break_time = '"..( os.time() ).."' WHERE door_guid = "..guid )
		CharDBQuery( "UPDATE doors_owners SET open = 1 WHERE door_guid = "..guid )
		lockedDoorArray[guid].open = 1
	else
	--	Вернуть в прежнее состояние (Разблокировать функционал для владельца)
		CharDBQuery( "UPDATE doors_config SET door_break_time = '0' WHERE door_guid = "..guid )
	end
end

--	Дверь предприятия принудительно открыта? (Владелец не может открыть)
--	TRUE если дверь взломана, иначе FALSE
function GameObject:IsStoreDoorBroken()
	local guid = self:GetDBTableGUIDLow()
	local Q = CharDBQuery( "SELECT door_break_time FROM doors_config WHERE door_guid = "..guid.." OR chest_guid = "..guid )
	if Q then
		local t = Q:GetUInt32(0)
		if t == 0 then return false
		else
		--	Проверка на то, не вышло ли время принудительного открытия.
			if ( os.time() - t ) > door_break_time then
				self:LockStoreDoor(0) -- Открываем дверь
				return false
			else return true end
		end
	end
end

--[[  ??	attempt to call method 'IsInFront' (a nil value)
function GameObject:IsThiefNear()
	local T = robbery_system.current_robberies[self:GetDBTableGUIDLow()]
	if not T then return nil end
	local player = GetPlayerByGUID(T.player)
	if player then
		if self:IsInFront(player) and ( self:GetExactDistance(player) > 20 ) then
			return true
		end
	end
	return false
end
]]
function GameObject:IsThiefNear()
	local T = robbery_system.current_robberies[self:GetDBTableGUIDLow()]
	if not T then return nil end
	local player = GetPlayerByGUID(T.player)
	if player then
		if self:GetExactDistance(player) <= 20 then
			return true
		end
	end
	return false
end

function Player:GetRobbedStoreChest(range)
	local playerGuid = self:GetGUIDLow()
	range = range or 30
	local chests = self:GetGameObjectsInRange( range, store_system.entry_chest )
	for i = 1, #chests do
		if robbery_system.current_robberies[ chests[i]:GetDBTableGUIDLow() ] then
			if robbery_system.current_robberies[ chests[i]:GetDBTableGUIDLow() ].player == playerGuid then
				return chests[i]
			end
		end
	end
	return nil
end

--[[
────────────────────────────────
───────────────██████████───────
──────────────████████████──────
──Салам───────██────────██──────
──────────────██▄▄▄▄▄▄▄▄▄█──────
──────────────██▀███─███▀█──────
█─────────────▀█────────█▀──────
██──────────────────█───────────
─█──────────────██──────────────
█▄────────────████─██──████
─▄███████████████──██──██████ ──
────█████████████──██──█████████
─────────────████──██─█████──███
──────────────███──██─█████──███
──────────────███─────█████████
──────────────██─────████████▀
────────────────██████████
────────────────██████████
─────────────────████████
──────────────────██████████▄▄
────────────────────█████████▀
─────────────────────████──███
────────────────────▄████▄──██
────────────────────██████───▀
────────────────────▀▄▄▄▄▀____
]]
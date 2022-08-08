
--[[	ГЛОБАЛЬНАЯ ФУНЦИЯ ДЛЯ КОНТРОЛЯ ЛОКАЛЬНОЙ ПОГОДЫ	]]--

function Player:SetLocalWeather( weather_type, weather_strength )
	local packet = CreatePacket( 756, 9 )
	packet:WriteUByte( weather_type )
	packet:WriteUByte( 0 )
	packet:WriteUByte( 0 )
	packet:WriteUByte( 0 )
	packet:WriteFloat( weather_strength )
	packet:WriteUByte( 0 )
	
	self:SendPacket( packet )
end

--[[	КОМАНДА ДЛЯ КОНТРОЛЯ ЛОКАЛЬНОЙ ПОГОДЫ	]]--

local weather = {}

weather.SAVE_ALL_WEATHER_CHANGES = true -- ЕСЛИ TRUE все изменения погоды от сервера сохраняются в таблицу. Игроки могут использовать .weather cancel и возвращаться к стандартной погоде без перезахода на персонажа.
if weather.SAVE_ALL_WEATHER_CHANGES then
	weather.savedWeather = {}
end

weather.allowedTypes = {
	--	Новые типы погоды можно добавлять в эту таблицу.
	--	В шестнадцатеричном виде ID указывать не обязательно.
	{ 0x0, "Солнце" },
	{ 0x5, "Дождь" },
	{ 0x8, "Снег" },
	{ 0x2A, "Буря" },
	
--[[
	ВЗЯТО С https://elunaluaengine.github.io/Map/SetWeather.html
	Не понятно, работает плохо, в некоторых локациях не работает вовсе, но при желании систему можно расширить, если разобраться. Наверное.
	P.S. Возможно есть только 4 типа погоды, а остальное - плотность осадков. Но я все равно оставлю это здесь на всякий случай.
	0, -- WEATHER_TYPE_FINE
	1, -- WEATHER_TYPE_RAIN
	2, -- WEATHER_TYPE_SNOW
	3, -- WEATHER_TYPE_STORM
	86, -- WEATHER_TYPE_THUNDERS
	90, -- WEATHER_TYPE_BLACKRAIN
]]

}

weather.players = {}								                            --	Таблица с игроками для которых установлена перманентная погода.

weather.OnCommand = function( _, player, command )	                            --	Команда для локальной смены погоды конкретному игроку или группе(рейду)
	if player:GetGMRank() > 0 or player:GetDmLevel() > 0 then					--	Проверка на доступ к команде
		if command == "weather" then				                            --	Справка
			local text = ".weather <id> [<интенсивность от 0 до 10> [<имя игрока>]]\n\nЕсли не указано имя игрока - применяется к текущей цели или ко всем в группе/рейде."
			if weather.SAVE_ALL_WEATHER_CHANGES then
				text = text.."\n.weather cancel\nВозвращение к стандартной погоде без перезахода."
			end
			text = text.."\nДоступные ID:"
			for i = 1, #weather.allowedTypes do
				text = text.."\n["..i.."] "..weather.allowedTypes[i][2]
			end
			player:SendBroadcastMessage( text )
			return false
		elseif string.find( command, " " ) then
			command = string.split( command, " " )
			if command[1] == "weather" then			--	Основной функционал команды
			
				if ( weather.SAVE_ALL_WEATHER_CHANGES ) and ( command[2] == "cancel" ) then		--	Возвращение стандартной погоды
					weather.players[player:GetName()] = nil
					player:SendBroadcastMessage("Стандартная погода возвращена.")
					if weather.savedWeather[tostring(player:GetZoneId())] then
						local W = weather.savedWeather[tostring(player:GetZoneId())]
						player:SetLocalWeather( W[1], W[2] )
					else
						player:SetLocalWeather( 0x0, 0 )
					end
					return false
				end
																								--	Установка уникальной погоды
				command[2] = tonumber(command[2]) or 1 -- ID типа погоды из LUA таблицы weather.allowedTypes
				if ( command[2] < 1 ) or ( command[2] > #weather.allowedTypes ) then
					player:SendBroadcastMessage("Указан неверный ID погоды.")
					return false
				end
				
				local weather_type = weather.allowedTypes[command[2]][1] -- Получаем реальный ID погоды по указанному пользователем индексу из weather.allowedTypes
				local weather_strength = tonumber(command[3]) or 5	--	Плотность осадков от 0 до 10, после становится от 0 до 1 с дрообной частью
				
				if ( weather_type == 0x0 ) or ( weather_strength <= 0 ) then	--	Если погода солнечная интенсивность осадков нужно ставить в 0
					weather_strength = 0
				elseif weather_strength >= 10 then
					weather_strength = 1
				else
					weather_strength = weather_strength * 0.1	--	Переводим введённое пользователем число в float от 0 до 1
				end
				
				if command[4] or ( player:GetSelection() and player:GetSelection():ToPlayer() ) then
					local target
					if command[4] then
						target = GetPlayerByName(tostring(command[4]))
						if not target then
							player:SendBroadcastMessage("Вы указали неправильное имя игрока.")
							return false
						end
					else
						target = player:GetSelection()
					end

					target:SetLocalWeather( weather_type, weather_strength )
					if weather.SAVE_ALL_WEATHER_CHANGES then
						target:SendBroadcastMessage( player:GetName().." устанавливает вам уникальную погоду.\nИспользуйте .weather cancel чтобы вернуться к оригинальной погоде в локации." )
					end
					player:SendBroadcastMessage( "Погодные условия \""..(weather.allowedTypes[command[2]][2]).."\" установлены для "..target:GetName() )
					
					weather.players[target:GetName()] = { weather_type, weather_strength }
					return false
				end
				if player:IsInGroup() then
					local targets = player:GetGroup():GetMembers()
					for i = 1, #targets do
						targets[i]:SetLocalWeather( weather_type, weather_strength )
						
						if weather.SAVE_ALL_WEATHER_CHANGES then
							targets[i]:SendBroadcastMessage( player:GetName().." устанавливает вам уникальную погоду.\nИспользуйте .weather cancel чтобы вернуться к оригинальной погоде в локации." )
						end
						
						weather.players[targets[i]:GetName()] = { weather_type, weather_strength }
					end
				else
					player:SetLocalWeather( weather_type, weather_strength )
					
					weather.players[player:GetName()] = { weather_type, weather_strength }
				end
				return false
			end
		end
	elseif weather.SAVE_ALL_WEATHER_CHANGES then
		if command == "weather" then
			player:SendBroadcastMessage(".weather cancel\nВозвращение к стандартной погоде без перезахода.")
		elseif command == "weather cancel" then
			weather.players[player:GetName()] = nil
			player:SendBroadcastMessage("Стандартная погода возвращена.")
			if weather.savedWeather[tostring(player:GetZoneId())] then
				local W = weather.savedWeather[tostring(player:GetZoneId())]
				player:SetLocalWeather( W[1], W[2] )
			else
				player:SetLocalWeather( 0x0, 0 )
			end
		end
	end
end
RegisterPlayerEvent( 42, weather.OnCommand ) -- PLAYER_EVENT_ON_COMMAND

weather.OnWeatherCanceled = function( event, player ) -- Вызывается, когда автоматический пакет от сервера сбивает настройки погоды игрока.
	if event == 27 then
		if weather.players[player:GetName()] then
			local name = player:GetName()
			player:SetLocalWeather( weather.players[name][1], weather.players[name][2] )
		end
	else -- Аргумент функции player здесь недоступен
		for name, weather_settings in pairs(weather.players) do
			local player = GetPlayerByName(name)
			if player then
				player:SetLocalWeather( weather_settings[1], weather_settings[2] )
			end
		end
	end
end
RegisterPlayerEvent( 27, weather.OnWeatherCanceled ) -- PLAYER_EVENT_ON_UPDATE_ZONE
RegisterServerEvent( 25, weather.OnWeatherCanceled ) -- WEATHER_EVENT_ON_CHANGE

weather.OnPlayerExitGame = function( _, player )
	if weather.players[player:GetName()] then
		weather.players[player:GetName()] = nil
	end
end
RegisterPlayerEvent( 4, weather.OnPlayerExitGame ) -- PLAYER_EVENT_ON_LOGOUT

--	Сделать отмену погоды так: сейвим при каждой смене погоды на сервере реальную погду в переменную и сетаем при отмене

weather.OnWeatherChangedByServer = function( _, zoneId, state, grade )
	weather.savedWeather[tostring(zoneId)] = { state, grade }
end
if weather.SAVE_ALL_WEATHER_CHANGES then
	RegisterServerEvent( 25, weather.OnWeatherChangedByServer ) -- WEATHER_EVENT_ON_CHANGE
end
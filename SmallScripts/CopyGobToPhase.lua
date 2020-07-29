function IsNumberUniquePhase(value)
  local initValue = 1
  while (initValue < value) do
    initValue = initValue*2
  end
  if (initValue == value) then
    return true
  else
    return false
  end
end


--  2 аргумент - расстояние, 3 - новая фаза, 4 - ID гошки
local CopiedGameObjects = {}

function CopyGobToPhase(event, player, command)
	if(string.find(command, " ")) then
		local arguments = {}
		local arguments = string.split(command, " ")
		-- Проверка соответствия всем условиям. Сюда можно вставить проверку на ГМку
		if ( arguments[1] == "gobcopy" and #arguments == 3 and player:GetGMRank() > 0 ) then
			arguments[2] = tonumber(arguments[2])
			arguments[3] = tonumber(arguments[3])
			if ( arguments[2] < 16 and IsNumberUniquePhase(arguments[3]) ) then
				local AllGameObjects = {}
				local FilteredGameObjects = {}
				local AllGameObjects = player:GetNearObjects(arguments[2])
				
			-- Выделение ГОшек из всех полученных объектов
				for i = 1, #AllGameObjects do
					local go = AllGameObjects[i]:ToGameObject()
					if go ~= nil then
						table.insert(FilteredGameObjects,go)
					end
				end
				
			-- КОПИРОВАНИЕ ОБЪЕКТА В ФАЗУ
				for i = 1, #FilteredGameObjects do -- Для каждой отфильтрованной ГОшки
					local GameObjectGuid = FilteredGameObjects[i]:GetDBTableGUIDLow()
					if ( CheckCopiedGameObjects(GameObjectGuid) == false ) then -- Проверка на недавнее копирование (АнтиДубликат)
						PerformIngameSpawn(2, FilteredGameObjects[i]:GetEntry(), FilteredGameObjects[i]:GetMapId(), 0, FilteredGameObjects[i]:GetX(), FilteredGameObjects[i]:GetY(), FilteredGameObjects[i]:GetZ(), FilteredGameObjects[i]:GetO(), true,0, 0, arguments[3])
						table.insert(CopiedGameObjects,GameObjectGuid) -- Сохранение скопированной ГОшки
					end
				end
				player:SendBroadcastMessage("Было скопировано "..#CopiedGameObjects	.." объектов.")
			
			-- СООБЩЕНИЯ ОБ ОШИБКАХ
			elseif ( arguments[2] == nil or arguments[2] >= 16 ) then -- Радиус слишком большой
				player:SendBroadcastMessage(".gobcopy Радиус Фаза")
				player:SendBroadcastMessage("Радиус копирования должен быть меньше 16!")
			elseif ( arguments[3] == nil or IsNumberUniquePhase(arguments[3]) == false ) then -- Фаза задевает первую
				player:SendBroadcastMessage(".gobcopy Радиус Фаза")
				player:SendBroadcastMessage("Номер фазы должен быть степенью двойки (1, 2, 4, ..)!")
			end
		end
	end
return false;
end

		-- ПРОВЕРКА НА НЕДАВНЕЕ КОПИРОВАНИЕ - функция для проверки
function CheckCopiedGameObjects(GameObjectGuid)
	for i = 1, #CopiedGameObjects do
		if ( GameObjectGuid == CopiedGameObjects[i] ) then
			return true;
		end
	end
	return false;
end

RegisterPlayerEvent( 42, CopyGobToPhase )

local smallfolk = require 'smallfolk'
-- .txt файл хранящий сохранённые из игры маршруты
local txtToSaveThePath = "lua_scripts\\OtherFiles\\SaveTaxiPath.txt"
local maxNumOfPathsPerNpc = 8 -- Максимальное кол-во маршрутов на одного NPC

local pathTable = {}
local path = {}

local FlightMasters = {}
local CurrentFlightMaster = {}

--[[	Обновление меню для настройки мастера полётов	]]

local function UpdateGossip(player)
	if player:GetSelection() and not player:GetSelection():ToPlayer() then
		player:GossipMenuAddItem( 2, "Добавить маршрут по ID", 1, 1, true, "Укажите параметры разделённые пробелом:\n[ID маршрута]\n[Цена за полёт в медных (Можно указать 0)]\n[Название точки полёта]" )
		player:GossipMenuAddItem( 2, "Удалить маршрут по номеру в меню", 1, 2, true, "Укажите порядковый номер маршрута который нужно удалить." )
		player:GossipMenuAddItem( 4, "Установить модель маунта по ID npc", 1, 3, true )
		player:GossipMenuAddItem( 0, "Установить текст приветствия", 1, 4, true )
		player:GossipMenuAddItem( 3, "Сохранить изменения", 1, 5 )
		local target = player:GetSelection()
		local entry, guid = target:GetEntry(), target:GetDBTableGUIDLow()
		local allPathsNames = ""
		if FlightMasters[entry] and FlightMasters[entry][guid] then
			local allPaths = FlightMasters[entry][guid].pathTable
			for i = 1, #allPaths do
				allPathsNames = allPathsNames.."\n ["..i.."] "..allPaths[i].text
			end
		end
		player:GossipSetText( "Вы редактируете "..player:GetSelection():GetName()..allPathsNames, 202019061 )
		player:GossipSendMenu( 202019061, player, 202019060 )
	else
		player:SendBroadcastMessage("|cffFF4500[!!]|r Вашей целью должен быть NPC.")
	end
end

--[[	Команды .taxi	]]

function taxiCommand(event, player, command)
	if player:GetGMRank() > 0 then -- Проверка на гмку.
		if(string.find(command, " ")) then
			local arguments = {}
			local arguments = string.split(command, " ")
			if arguments[1] == "taxi" then
				if arguments[2] == "help" then
					player:SendBroadcastMessage('|cffFF4500[1] |rКак правило эта команда используется для создания "Точек полётов".\n|cffFF4500[2] |rОна не подойдёт для создания наземного транспорта.\n|cffFF4500[3] |rКаждый раз, когда вы вводите |cff00FF7F.taxi add [ID маршрута]|r в месте, где стоит ваш персонаж, создаётся новая точка.\n|cffFF4500[4] |rПлавный полёт между точками просчитывается автоматически, старайтесь не ставить точки рядом друг с другом.\n|cffFF4500[5] |rПервая точка должна стоять рядом с игроком.\n|cffFF4500[6] |rПри достижении последней точки игрок автоматически покинет транспорт.\n|cffFF4500[7] |rИгрок не может управлять полётом.\n|cffFF4500[8] |rID транспорта это entry NPC, а не его display ID.')
				elseif arguments[2] == "create" then -- СОЗДАНИЕ МАРШРУТА.
					local emptyTable = {}
					table.insert(pathTable,emptyTable)
					player:SendBroadcastMessage("Новый маршрут создан! Его ID - |cffFF4500"..#pathTable.."|r\nИспользуйте |cff00FF7F.taxi add "..#pathTable.."|r для добавления точек.")
				elseif arguments[2] == "add" then -- ДОБАВЛЕНИЕ НОВОЙ ТОЧКИ.
					if arguments[3] and tonumber(arguments[3]) then
						local id = tonumber(arguments[3])
						if id > 0 and id <= #pathTable then
							if pathTable[id] then
								local x,y,z = player:GetLocation()
								x,y,z = string.format("%.1f", x), string.format("%.1f", y), string.format("%.1f", z)
								local map = player:GetMapId()
								local playerPos = {map,x,y,z}
								table.insert(pathTable[id],playerPos)
								player:SendBroadcastMessage("|cff00FF7F["..id.."]|r Точка |cffFF4500"..#pathTable[id].."|r добавлена.")
							end
						else player:SendBroadcastMessage("|cffFF4500[!!]|r Вы ввели неверный ID маршрута.") end
					end
				elseif arguments[2] == "save" then -- ЗАВЕРШЕНИЕ СОЗДАНИЯ МАРШРУТА.
					if arguments[3] and tonumber(arguments[3]) then
						local id = tonumber(arguments[3])
						if id > 0 and id <= #pathTable then -- Проверяем маршрут
							if #pathTable[id] < 3 then
								player:SendBroadcastMessage("|cffFF4500[!!]|r Маршрут слишком короткий.")
								return
							end
							if arguments[4] and tonumber(arguments[4]) then -- Проверяем маунт id
								local mountId = tonumber(arguments[4])
								local MountQ = WorldDBQuery('SELECT scale FROM creature_template WHERE entry = ' ..mountId)
								if MountQ then -- У нас всё ок. Мы русские.
									if not path[id] then -- Если маршрут создаётся
										path[id] = AddTaxiPath(pathTable[id],mountId,mountId)
										player:SendBroadcastMessage("Маршрут с ID |cffFF4500"..id.."|r сохранён и доступен до перезагрузки сервера!")
									elseif path[id] then -- Если маршрут обновляется.
										path[id] = AddTaxiPath(pathTable[id],mountId,mountId,0,path[id])
										player:SendBroadcastMessage("Маршрут с ID |cffFF4500"..id.."|r обновлён и доступен до перезагрузки сервера!")
									end
								else player:SendBroadcastMessage("|cffFF4500[!!]|r Вы ввели неверный ID NPC.") end
							else player:SendBroadcastMessage("|cffFF4500[!!] |cff00FF7F.taxi save "..id.." [ID маунта]") end
						else player:SendBroadcastMessage("|cffFF4500[!!]|r Вы ввели неверный ID маршрута.") end
					end
				elseif arguments[2] == "go" then -- ОТПРАВКА ИГРОКА ПО МАРШРУТУ.
					local playerTarget = player:GetSelection()
					if playerTarget and playerTarget:ToPlayer() then
						if arguments[3] and tonumber(arguments[3]) then
							local id = tonumber(arguments[3])
							if path[id] then
								local x,y,z = pathTable[id][1][2], pathTable[id][1][3], pathTable[id][1][4]
								if playerTarget:GetDistance(x,y,z) <= 10 then -- максимальное РАССТОЯНИЕ от игрока до точки старта (6.5 по умолчанию)
									playerTarget:StartTaxi(path[id])
								else player:SendBroadcastMessage("|cffFF4500[!!]|r Игрок слишком далеко от стартовой точки.") end
							else player:SendBroadcastMessage("|cffFF4500[!!]|r Маршрут не создан или ещё не сохранён.") end
						end
					else player:SendBroadcastMessage("|cffFF4500[!!]|r Возьмите игрока в цель.") end
				elseif arguments[2] == "tele" then -- ТЕЛЕПОРТ НА ТОЧКУ МАРШРУТА
					if arguments[3] and tonumber(arguments[3]) then
						local id = tonumber(arguments[3])
						if id > 0 and id <= #pathTable then -- Проверяем маршрут
							if arguments[4] and tonumber(arguments[4]) then
								local posId = tonumber(arguments[4])
								if posId <= #pathTable[id] and posId > 0 then
									player:Teleport( pathTable[id][posId][1], pathTable[id][posId][2], pathTable[id][posId][3], pathTable[id][posId][4], 0 )
									player:SendBroadcastMessage("|cff00FF7F["..id.."]|r Точка |cffFF4500"..posId.."|r из |cffFF4500"..#pathTable[id].."|r.")
								else player:SendBroadcastMessage("|cffFF4500[!!]|r Такой точки не существует.") end -- Дурак опять накосячил.
							elseif not arguments[4] and #pathTable[id] > 0 then
								player:Teleport( pathTable[id][1][1], pathTable[id][1][2], pathTable[id][1][3], pathTable[id][1][4], 0 )
								player:SendBroadcastMessage("Вы телепортированы в начало маршрута |cffFF4500"..id.."|r.")
							end
						else player:SendBroadcastMessage("|cffFF4500[!!]|r Вы ввели неверный ID маршрута.") end
					end
				elseif arguments[2] == "del" then -- УДАЛЕНИЕ ТОЧКИ МАРШРУТА
					if arguments[3] and tonumber(arguments[3]) then
						local id = tonumber(arguments[3])
						if id > 0 and id <= #pathTable then -- Проверяем маршрут
							if arguments[4] and tonumber(arguments[4]) then
								local posId = tonumber(arguments[4])
								if posId <= #pathTable[id] and posId > 0 then
									table.remove(pathTable[id],posId)
									player:SendBroadcastMessage("|cff00FF7F["..id.."]|r Точка |cffFF4500"..posId.."|r удалена.")
								else player:SendBroadcastMessage("|cffFF4500[!!]|r Такой точки не существует.") end
							end
						else player:SendBroadcastMessage("|cffFF4500[!!]|r Вы ввели неверный ID маршрута.") end
					end
				elseif arguments[2] == "move" then -- ПЕРЕМЕЩЕНИЕ ТОЧКИ МАРШРУТА
					if arguments[3] and tonumber(arguments[3]) then
						local id = tonumber(arguments[3])
						if id > 0 and id <= #pathTable then -- Проверяем маршрут
							if arguments[4] and tonumber(arguments[4]) then
								local posId = tonumber(arguments[4])
								if posId <= #pathTable[id] and posId > 0 then
									local x,y,z = player:GetLocation()
									x,y,z = string.format("%.1f", x), string.format("%.1f", y), string.format("%.1f", z)
									local map = player:GetMapId()
									local playerPos = {map,x,y,z}
									pathTable[id][posId] = playerPos
									player:SendBroadcastMessage("|cff00FF7F["..id.."]|r Точка |cffFF4500"..posId.."|r перемещена.")
								else player:SendBroadcastMessage("|cffFF4500[!!]|r Такой точки не существует.") end
							end
						else player:SendBroadcastMessage("|cffFF4500[!!]|r Вы ввели неверный ID маршрута.") end
					end
				elseif arguments[2] == "insert" then -- ВСТАВКА ТОЧКИ МАРШРУТА
					if arguments[3] and tonumber(arguments[3]) then
						local id = tonumber(arguments[3])
						if id > 0 and id <= #pathTable then -- Проверяем маршрут
							if arguments[4] and tonumber(arguments[4]) then
								local posId = tonumber(arguments[4])
								if posId <= #pathTable[id] and posId > 0 then
									local x,y,z = player:GetLocation()
									x,y,z = string.format("%.1f", x), string.format("%.1f", y), string.format("%.1f", z)
									local map = player:GetMapId()
									local playerPos = {map,x,y,z}
									table.insert(pathTable[id],(posId + 1),playerPos)
									player:SendBroadcastMessage("|cff00FF7F["..id.."]|r Точка добавлена.")
								else player:SendBroadcastMessage("|cffFF4500[!!]|r Такой точки не существует.") end
							end
						else player:SendBroadcastMessage("|cffFF4500[!!]|r Вы ввели неверный ID маршрута.") end
					end
				elseif arguments[2] == "txt" and player:GetGMRank() == 3 then -- СОХРАНЕНИЕ МАРШРУТА В ФАЙЛ
					if arguments[3] and tonumber(arguments[3]) then
						local id = tonumber(arguments[3])
						if id > 0 and id <= #pathTable then -- Проверяем маршрут
							local txtFile = io.open(txtToSaveThePath,"w")
							local textTable, textTableElement
							textTable = "Автоматически сгенерированная таблица точек из маршрута "..id..":\n{ "
							for i = 1,#pathTable[id] do
								textTable = (textTable.."{ "..pathTable[id][i][1]..", "..pathTable[id][i][2]..", "..pathTable[id][i][3]..", "..pathTable[id][i][4].." }, ")
							end
							textTable = textTable.."}"
							txtFile:write(textTable)
							txtFile:close()
							player:SendBroadcastMessage("|cff00FF7F["..id.."]|r Таблица сохранена в файл.")
						else player:SendBroadcastMessage("|cffFF4500[!!]|r Вы ввели неверный ID маршрута.") end
					else player:SendBroadcastMessage("Правильное использование - |cff00FF7F.taxi txt [ID маршрута]") end
				elseif arguments[2] == "npc" and player:GetGMRank() >= 2 then -- Создание или редактирование мастера полётов.
					local target = player:GetSelection()
					if target and not target:ToPlayer() then
						local entry, guid = target:GetEntry(), target:GetDBTableGUIDLow()
						if FlightMasters[entry] and FlightMasters[entry][guid] then
							CurrentFlightMaster[player:GetName()] = FlightMasters[entry][guid]
						else
							CurrentFlightMaster[player:GetName()] = {
								helloText = "...",
								mount = 20504,
								owner = 0,
								pathTable = {},
								taxi = {},
							}
						end
						player:GossipClearMenu()
						UpdateGossip(player)
					else
						player:SendBroadcastMessage("|cffFF4500[!!]|r Возьмите NPC в цель.")
					end
				end
			end
		end
		if command == "taxi" then
			player:SendBroadcastMessage("|cff00FF7F.taxi create|r для создания нового пути.\n|cff00FF7F.taxi add [ID маршрута]|r для добавления точки полёта.\n|cff00FF7F.taxi save [ID маршрута] [ID маунта]|r для завершения создания или обновления маршрута.\n|cff00FF7F.taxi go [ID маршрута]|r для отправки выбранного игрока\n|cff00FF7F.taxi tele [ID маршрута] {Номер точки}|r для телепорта на одну из созданных точек.\n|cff00FF7F.taxi insert [ID маршрута] [Номер точки]|r для вставки точки после указанной.\n|cff00FF7F.taxi del [ID маршрута] [Номер точки]|r для удаления точки.\n|cff00FF7F.taxi move [ID маршрута] [Номер точки]|r для переноса существующей точки на вашу позицию.\n|cffFF4500[!!]|r Используйте |cff00FF7F.taxi help|r, если пользуетесь этой командой в первый раз!")
			if player:GetGMRank() >= 2 then
				player:SendBroadcastMessage("|cff00E5EE[2ГМ] |cff00FF7F.taxi npc|r для настройки собственного мастера полётов (|cffFF4500Возьмите NPC в таргет|r).")
			end
			if player:GetGMRank() == 3 then
				player:SendBroadcastMessage("|cff00E5EE[3ГМ] |cff00FF7F.taxi txt [ID маршрута]|r для сохранения точек в .txt файл.")
			end
		end
	end
end
RegisterPlayerEvent(42,taxiCommand)

--[[	Кастомные мастера полётов	]]

local function FlightMaster(event, player, creature, sender, intid)
	local entry, guid = creature:GetEntry(), creature:GetDBTableGUIDLow()
	if FlightMasters[entry][guid] then
		if event == 1 then -- ON_HELLO
			player:GossipClearMenu()
			player:GossipSetText(FlightMasters[entry][guid].helloText,20062020)
			for i = 1, #FlightMasters[entry][guid].pathTable do
				if FlightMasters[entry][guid].pathTable[i].price > 0 then -- Платный полёт
					player:GossipMenuAddItem(0,FlightMasters[entry][guid].pathTable[i].text,1,i,false,"Стоиомсть полёта:",FlightMasters[entry][guid].pathTable[i].price)
				else -- Бесплатный полёт
					player:GossipMenuAddItem(0,FlightMasters[entry][guid].pathTable[i].text,1,i)
				end
			end
			player:GossipSendMenu(20062020, creature)
		else -- ON_SELECT
			if player:GetDistance(creature) <= 2.5 then
				player:StartTaxi(FlightMasters[entry][guid].taxi[intid])
			end
			player:GossipComplete()
		end
	end
end

local function FlightMasterCreation(event, player, object, sender, intid, code, menu_id)
	local target = player:GetSelection()
	local playerName = player:GetName()
	local entry, guid = target:GetEntry(), target:GetDBTableGUIDLow()
	if intid == 1 and code then -- Добавление маршрута в мастера полётов
		if #CurrentFlightMaster[playerName].pathTable <= maxNumOfPathsPerNpc then
			if(string.find(code, " ")) then
				local arguments = {}
				local arguments = string.split(code, " ")
				if #arguments >= 3 then
					if tonumber(arguments[1]) and tonumber(arguments[2]) then
						local id, price, text = tonumber(arguments[1]), tonumber(arguments[2])
						if path[id] then
							price = (price > 0) and price or 0
							local text = table.concat(arguments, " ", 3)
							local currentPath = {
								xyzTable = pathTable[id],
								text = text,
								price = price,
							}
							table.insert(CurrentFlightMaster[playerName].pathTable,currentPath)
						else
							player:SendBroadcastMessage("|cffFF4500[!!]|r Вы ввели неверный ID маршрута.")
						end
					end
				end
			else
				player:SendBroadcastMessage("|cffFF4500[!!]|r Произошла ошибка. Вероятно, всё дело в вас. Отдел разработки не виноват!")
			end
		else player:SendBroadcastMessage("|cffFF4500[!!]|r Максимальное кол-во маршрутов для одного NPC - "..maxNumOfPathsPerNpc) end
	elseif intid == 2 and code then -- Удаление маршрута из мастера полётов
		if tonumber(code) then
			code = tonumber(code)
			if code > 0 and code <= #CurrentFlightMaster[playerName].pathTable then
				table.remove(CurrentFlightMaster[playerName].pathTable,code)
			else
				player:SendBroadcastMessage("|cffFF4500[!!]|r Маршрут с таким номером не найден в менюшке мастера полётов.")
			end
		end
	elseif intid == 3 and code then -- Установка модели маунта
		if tonumber(code) then
			local MountQ = WorldDBQuery('SELECT scale FROM creature_template WHERE entry = ' ..code)
			if MountQ then
				CurrentFlightMaster[playerName].mount = code
			else player:SendBroadcastMessage("|cffFF4500[!!]|r Вы ввели неверный ID NPC.") end
		end
	elseif intid == 4 and code then -- Установка текста приветствия в госсипе
		CurrentFlightMaster[playerName].helloText = code
	elseif intid == 5 then -- Сохранение мастера полётов
		CurrentFlightMaster[playerName].owner = player:GetAccountId()
		if FlightMasters[entry] and FlightMasters[entry][guid] then -- Перезапись
			FlightMasters[entry][guid] = CurrentFlightMaster[playerName]
			
			-- MySQL запрос
			local helloText = FlightMasters[entry][guid].helloText
			local mountID = FlightMasters[entry][guid].mount
			
			local mysql_pathTable = FlightMasters[entry][guid].pathTable
			mysql_pathTable = smallfolk.dumps(mysql_pathTable)
			WorldDBQuery([[UPDATE custom_flight_masters SET helloText = ']]..helloText..[[', pathTable = ']]..mysql_pathTable..[[', mountID = ]]..mountID..[[, gm_account_id = ]]..CurrentFlightMaster[playerName].owner..[[ WHERE guid = ]]..guid)
			player:SendBroadcastMessage("Мастер полётов обновлён.")
		else -- Новое сохранение
			if not FlightMasters[entry] then
				FlightMasters[entry] = {}
				RegisterCreatureGossipEvent( entry, 1, FlightMaster)
				RegisterCreatureGossipEvent( entry, 2, FlightMaster)
			end
			FlightMasters[entry][guid] = CurrentFlightMaster[playerName]
			
			-- MySQL запрос
			local helloText = FlightMasters[entry][guid].helloText
			local mountID = FlightMasters[entry][guid].mount
			
			local mysql_pathTable = FlightMasters[entry][guid].pathTable
			mysql_pathTable = smallfolk.dumps(mysql_pathTable)
			WorldDBQuery([[INSERT INTO custom_flight_masters (entry,guid,helloText,pathTable,mountID,gm_account_id) values (]]..entry..[[,]]..guid..[[,']]..helloText..[[',']]..mysql_pathTable..[[',]]..mountID..[[,]]..CurrentFlightMaster[playerName].owner..[[)]])
			player:SendBroadcastMessage("Мастер полётов сохранён.")
		end
		for i = 1, #FlightMasters[entry][guid].pathTable do
			if FlightMasters[entry][guid].pathTable[i].price > 0 then
				FlightMasters[entry][guid].taxi[i] = AddTaxiPath(FlightMasters[entry][guid].pathTable[i].xyzTable, FlightMasters[entry][guid].mount, FlightMasters[entry][guid].mount, FlightMasters[entry][guid].pathTable[i].price)
			else
				FlightMasters[entry][guid].taxi[i] = AddTaxiPath(FlightMasters[entry][guid].pathTable[i].xyzTable, FlightMasters[entry][guid].mount, FlightMasters[entry][guid].mount)
			end
		end
		CurrentFlightMaster[playerName] = nil
		player:GossipComplete()
		return
	end
	UpdateGossip(player)
end
RegisterPlayerGossipEvent( 202019060, 2, FlightMasterCreation )

-- Загрузка мастеров полёта из БД в кэш при старте элуны
local function FlightMastersLoad()
	local FlightMastersQ = WorldDBQuery("SELECT entry,guid,helloText,pathTable,mountID FROM custom_flight_masters")
	if FlightMastersQ then
		for i = 1, FlightMastersQ:GetRowCount() do
			local entry = FlightMastersQ:GetInt32(0)
			local guid = FlightMastersQ:GetInt32(1)
			local helloText = FlightMastersQ:GetString(2)
			local pathTable = FlightMastersQ:GetString(3)
			local mountID = FlightMastersQ:GetInt32(4)
			pathTable = smallfolk.loads(pathTable)
			if not FlightMasters[entry] then
				FlightMasters[entry] = {}
				RegisterCreatureGossipEvent( entry, 1, FlightMaster)
				RegisterCreatureGossipEvent( entry, 2, FlightMaster)
			end
			FlightMasters[entry][guid] = {
				helloText = helloText,
				mount = mountID,
				owner = 0, -- Какой-то костыль, пускай будет. В БД всегда хранит правильного владельца.
				pathTable = pathTable,
				taxi = {}
			}
			for i = 1, #FlightMasters[entry][guid].pathTable do
				if FlightMasters[entry][guid].pathTable[i].price > 0 then
					FlightMasters[entry][guid].taxi[i] = AddTaxiPath(FlightMasters[entry][guid].pathTable[i].xyzTable, FlightMasters[entry][guid].mount, FlightMasters[entry][guid].mount, FlightMasters[entry][guid].pathTable[i].price)
				else
					FlightMasters[entry][guid].taxi[i] = AddTaxiPath(FlightMasters[entry][guid].pathTable[i].xyzTable, FlightMasters[entry][guid].mount, FlightMasters[entry][guid].mount)
				end
			end
			FlightMastersQ:NextRow()
		end
	end
	FlightMastersQ = nil
end
FlightMastersLoad()

--[[
	╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═
	╩═╦═╩═╦═╩═╦▄████▄═╦▄████▄═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦
	╦═╩═╦═╩═╦═╩██▀▀██═╩██▀▀██═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦
	╩═╦═╩═╦═╩═╦██──██═╦██──██═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═
	╦═╩═╦═╩═╦═╩██──██═╩██──██═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═
	╩═╦═╩═╦═╩═╦██──██═╦██──██═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦
	╦═╩═╦═╩═╦═╩██──██═╩██──██═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═
	╩═╦═╩═╦═╩═▄██──██████──██▄╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═
	╦═╩═╦═╩═▄███▀──────────▀███▄╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦╔════════════════════════════════════════╗═╦═╩═╦═╩═╦
	╩═╦═╩═╦██▀────────────────▀██═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩║╔═╗░╔═╦═╦╗░░░░░░╔══╗░░░░░░░░░░░░░░░░░╔═╗║═╩═╦═╩═╦═╩═
	╦═╩═╦═███─────██─────██────███╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦║║╬╠╦╣═╣═╬╬═╗╔═╦╗╚╗╗╠═╦═╦═╦═╦╗╔═╦═╦═╦╦╣═╣║═╦═╩═╦═╩═╦
	╩═╦═╩═██──────██─────██─────██╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩║║╗╣║╠═╠═║║╬╚╣║║║╔╩╝║╩╬╗║╔╣╩╣╚╣╬║╬║╩╣╔╬═║║═╩═╦═╩═╦═╩
	╦═╩═╦═██─██▄██▄─────────────██╩▄▄▄╩═█▄╩═▄▄▄═╦═╩═╦═╩═╦═╩═╦═╩═╦║╚╩╩═╩═╩═╩╩══╩╩═╝╚══╩═╝╚═╝╚═╩═╩═╣╔╩═╩╝╚═╝║═╦═╩═╦═╩═╦
	╩═╦═╩═██─██████─────────────██╦═▀▀▀▄██▄▀▀▀╦═╩═╦═╩═╦═╩═╦═╩═╦═╩╚═══════════════════════════════╚╝═══════╝═╩═╦═╩═╦═
	╦═╩═╦▄███████▀───▒▒▒────────██╩═╦═█▒▒▒▒█╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦
	╩═╦▄█████▀─────────────────▄██╦═╩███████╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩
	╦═▐█████▄▄───────────────▄▄██═╩═▄███▒▒▒█╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═
	╩═▐████▀▀█████▄▄▄▄▄▄▄█████▀▀╩═╦▄████▒▒██╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩
	╦═▐█████▄▄▄██▀▀▀▀▀▀▀▀▀██▄▄▄▄████████▒▒██╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═
	╩═╦▀████████████▄▄▄██████████████▀╦█▒▒▒█╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩
	╦═╩═╦▀████████████████████████▀═╦═╩█▒▒▒█╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦
]]
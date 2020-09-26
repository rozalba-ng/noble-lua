--	КОМАНДА ДЛЯ БОЛЕЕ ПРОСТОГО ПЕРЕХОДА ПЕРЕХОДА В УНИКАЛЬНЫЕ И СМЕШАННЫЕ ФАЗЫ
--	Использование
--	.ph [Номер уникальной фазы от 1 до 30] {Номер уникальной фазы} {...}
--	Команда доступна начиная с 1 уровня ГМ доступа.

--	Всего доступно 2^31 уникальных фаз. Но фаз все равно 32, если учитывать 2^0 (1 фаза).
--	4294967295 - ГМская фаза отображающая сразу все существующие фазы.
--	4294967296 (2^32) не существует.

--	Планы:
--	1. Прикрутить .?

local function PhCommand(event, player, command)
	if command == "ph" and player:GetGMRank() > 0 then
		--	Подсказка
		player:SendBroadcastMessage("|cff00FF7F.ph [Номер уникальной фазы от 1 до 30]|r - Переход в указанную фазу.\n|cff00FF7F.ph [1-30] {1-30} {...}|r - Нахождение сразу в нескольких фазах указанных через пробел.\nИспользуйте аргументы |cff00FF7Fgm|r или |cff00FF7Fall|r для просмотр содержимого сразу всех фаз, |cff00FF7Fr|r для переноса в фазу всего рейда цели.")
	elseif string.find( command, " " ) and player:GetGMRank() > 0 then
		command = string.split(command, " ")
		if command[1] == "ph" and command[2] then
			--	Основной функционал
			local phase = 0
			local raid, gm
			for i = 2, #command do
				if not gm and tonumber( command[i] ) then
					command[i] = tonumber(command[i])
					-- 	Проверка на дибила
					if command[i] >= 1 and command[i] <= 30 and math.floor( command[i] ) == command[i] then
						command[i] = 2^( command[i] - 1 ) -- Потому что 2^0 это 1 фаза, а 2^1 это уже 2 фаза.
						phase = phase + command[i]
					else player:SendBroadcastMessage("|cffFF4500[!!]|r Номер фазы должен быть из диапазона |cff00FF7F1|r-|cff00FF7F30|r.") return end
				elseif command[i] == "r" or command[i] == "raid" then
					raid = true
				elseif command[i] == "gm" or command[i] == "all" then
					phase = 4294967295 -- "Мультифаза", смешанная фаза отображающая сразу все.
					gm = true
				else player:SendBroadcastMessage("|cffFF4500[!!]|r Вы должны указать номер фазы.") return end
			end
			local target = player:GetSelection()
			if target and not target:ToPlayer() then raid = nil end
			--	Массовый переход в фазу
			if raid then
				local groupObject
				if target then
					groupObject = target:GetGroup()
				else
					groupObject = player:GetGroup()
				end
				if not groupObject then player:SendBroadcastMessage("|cffFF4500[!!]|r Группа не найдена.") return end
				local players = groupObject:GetMembers()
				for i = 1, #players do
					players[i]:SetPhaseMask( phase )
				end
				return
			end
			--	Одиночный переход в фазу
			if target then
				target:SetPhaseMask( phase )
			else
				player:SetPhaseMask( phase )
				if gm then
					player:SendAreaTriggerMessage("Вы видите содержимое всех фаз.")
				elseif phase == 1 then
					player:SendAreaTriggerMessage("Вы находитесь в основной фазе.")
				elseif phase == 1024 then
					player:SendAreaTriggerMessage("Вы находитесь в творческой фазе. (|cff00FF7F1024|r)")
				else
					player:SendAreaTriggerMessage("Вы находитесь в |cff00FF7F"..phase.."|r фазе.")
				end
			end
		end
	end
end
RegisterPlayerEvent( 42, PhCommand )
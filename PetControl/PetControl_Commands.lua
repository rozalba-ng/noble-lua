
PetControlAIO = PetControlAIO or {}

--[[
	Фунции из таблицы PetControlAIO ищи в файле PetControl_Server.lua
]]

function PetControlAIO.PlayerCommands( _, player, command )
	if command == "pet" then -- Вывод справки
		player:SendBroadcastMessage("|cffFF4500(!)|r Для использования этих команд нужно взять спутника в ЦЕЛЬ.\n|cff00FF7F.pet say [Текст]|r - Реплика от лица спутника.\n|cff00FF7F.pet emote [Текст]|r - Текстовая эмоция от лица спутника.\n|cff00FF7F.pet stay|r - Спутник стоит на месте.\n|cff00FF7F.pet follow {Дистанция (0-5)} {Угол следования (0-360)}|r - Спутник следует за вами.\n|cff00FF7F.pet play [ID] {Повтор}|r - Спутник проигрывает анимацию.\nЕсли на месте |cff00FF7F{Повтор}|r указать любое значение анимация будет повторяться бесконечно.\n|cff00FF7F.pet pos [0, 1 или 3]|r - Стоять, сидеть или лежать.\n|cff00FF7F.pet tele|r - Телепорт спутника к персонажу.")
	elseif string.find( command, " " ) then
		command = string.split( command, " " )
		if command[1] == "pet" then -- Команды
			if command[2] == "say" then
				if command[3] then
					local text = ""
					for i = 3, #command do
						text = text..tostring(command[i]).." "
					end
					PetControlAIO.Say( player, text )
					return
				end
			----------
			elseif command[2] == "emote" then
				if command[3] then
					local text = ""
					for i = 3, #command do
						text = text..tostring(command[i]).." "
					end
					PetControlAIO.Emote( player, text )
					return
				end
			----------
			elseif command[2] == "stay" then
				PetControlAIO.Follow( player, 0 )
				return
			----------
			elseif command[2] == "follow" then
				PetControlAIO.Follow( player, 1, command[3], command[4] )
				return
			----------
			elseif command[2] == "play" then
				if command[3] and tonumber( command[3] ) then
					local creature = player:GetSelection()
					if creature and ( creature:GetControllerGUID() == player:GetGUID() ) and not ( creature:HasAura(91072) ) then
						if command[4] then
							creature:EmoteState( command[3] )
						else
							creature:Emote( command[3] )
						end
						return
					else player:SendNotification("Вы не можете управлять этим существом.") end
				end
			----------
			elseif command[2] == "pos" then
				if command[3] and tonumber( command[3] ) then
					PetControlAIO.Byte1( player, command[3] )
					return
				end
			----------
			elseif command[2] == "tele" then
				local creature = player:GetSelection()
				if creature and ( creature:GetControllerGUID() == player:GetGUID() ) and not ( creature:HasAura(91072) ) then
					local x,y,z,o = player:GetLocation()
					creature:NearTeleport(x,y,z,o)
					return
				else player:SendNotification("Вы не можете управлять этим существом.") end
			----------
			else
				player:SendBroadcastMessage("|cffFF4500[!!]|r Вы ошиблись в написании команды.\nИспользуйте |cff00FF7F.pet|r для просмотра доступных вам команд.")
			end
		end
	end
end
RegisterPlayerEvent( 42, PetControlAIO.PlayerCommands ) -- PLAYER_EVENT_ON_COMMAND
function GobInfo(event, player, command)
    local arguments = {}
    local arguments = string.split(command, " ")
    if ( arguments[1] == "gobinfo") then
        local gobGuid = nil
		local nearGo = nil
        -- ПРОВЕРКА НА НАЛИЧИЕ ДОП.АРГУМЕНТА и получение GUID
        if arguments[2] == nil then -- Если не указан GUID ГОшки - берем ближайшую ГОшку
            nearGo = player:GetNearestGameObject(15)
			if nearGo == nil then
				player:SendBroadcastMessage("GO-объектов в радиусе 15 не обнаружено.")
				return false
			else
				gobGuid = nearGo:GetDBTableGUIDLow()
			end
        else -- Если указан GUID ГОшки
            arguments[2] = tonumber(arguments[2])
            gobGuid = arguments[2]
        end
		
		-- ПОИСК ГОШКИ В ТАБЛИЦЕ и получение информации	
		local GobQ = WorldDBQuery('SELECT owner_id,date,id FROM gameobject WHERE guid = ' ..gobGuid )
		
		local GobOwnerID = GobQ:GetInt32(0) -- ID персонажа
		local GobDate = GobQ:GetString(1) -- Дата установки
		local gobId = GobQ:GetInt32(2)
		-- Поиск персонажа владельца ГОшки
		local GobQ = CharDBQuery('SELECT account,name FROM characters WHERE guid = ' ..GobOwnerID )
		local characterInfo = ""
		if GobQ then
			local GobOwnerAccountID = GobQ:GetInt32(0) -- ID аккаунта
			local GobOwnerChar = GobQ:GetString(1) -- Имя персонажа
			local GobOwnerAccount = AuthDBQuery('SELECT username FROM account WHERE id = ' ..GobOwnerAccountID ):GetString(0) -- Поиск аккаунта
			local GmLevelQ = AuthDBQuery('SELECT gmlevel FROM account_access WHERE id = ' ..GobOwnerAccountID)-- Проверка на уровень ГМки
			local GmLevel = 0
			if GmLevelQ then
				GmLevel = GmLevelQ:GetInt32(0)
				GobOwnerGm = "ГМ аккаунт"
			else
				GobOwnerGm = "Игрок"
			end
			characterInfo = ".\nПерсонаж |cffffffff" ..GobOwnerChar.."|r ( " ..GobOwnerAccount.." ).\nСтатус аккаунта: |cffffffff"..GobOwnerGm.."|r ["..GmLevel.." уровень].|r "
		else
			characterInfo = ".\n|cffffffffОбъект поставлен сервером или персонажа уже не существует.|r"
		end
		local gobName = ""
		if nearGo then
			gobName = " [|cffffffff"..nearGo:GetName().."|r]"
		end
		player:SendBroadcastMessage("GUID: "..gobGuid..gobName..characterInfo.."\n|rДата установки: |cffffffff"..GobDate.."|r")
		
    end
end

RegisterPlayerEvent( 42, GobInfo )
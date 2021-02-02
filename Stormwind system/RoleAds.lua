local SQL_databaseCreation = [[
CREATE TABLE IF NOT EXISTS `roleADS` (
	`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	`text` TEXT NOT NULL,
	`lastUseTime` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`countOfUses` TINYINT(3) UNSIGNED NOT NULL DEFAULT '5',
	`creator` INT(10) UNSIGNED NULL DEFAULT NULL,
	PRIMARY KEY (`id`)
)
COMMENT='Used for RoleAds.lua\r\nРолевые объявления в Штормграде и его окрестностях.'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]
CharDBQuery( SQL_databaseCreation )

local function RoleAdv()
	if SocialTime() then
		local Q = CharDBQuery( "SELECT id, text, countOfUses FROM roleADS WHERE ( countOfUses > 0 ) AND ( "..os.time().." - lastUseTime ) > 900" ) --3000
		if Q then
			if Q:GetRowCount() > 2 then
				for i = 1, math.random( 1, ( Q:GetRowCount() - 1 ) ) do -- Выбор случайного объявления из доступных.
					Q:NextRow()
				end
			end
			local id, text, countOfUses
			id = Q:GetUInt32(0)
			text = Q:GetString(1)
			countOfUses = Q:GetUInt8(2)
			countOfUses = countOfUses - 1
			if ( countOfUses == 0 ) then
				CharDBQuery( "DELETE FROM roleADS WHERE id = "..id )
			else
				CharDBQuery( "UPDATE roleADS SET lastUseTime = "..os.time()..",  countOfUses = "..countOfUses.." WHERE id = "..id )
			end
		--	Отправка сообщения игрокам
			local players = GetPlayersInWorld()
			for i = 1, #players do
				if players[i]:InMainPlayground() then
					players[i]:SendBroadcastMessage( "[|cff7eff47РОЛЕВОЕ ОБЪЯВЛЕНИЕ|r]\n|cff8cd7ff"..text )
					players[i]:PlayDirectSound( 61, players[i] )
				end
			end
		end
	end
end
CreateLuaEvent( RoleAdv, 5*60000, 0 ) -- 60000-умножение на миллисекунды. Т.Е. Указываем кол-во минут.

local function RoleAdv_Command( _, player, command )
	if player:GetGMRank() > 1 then
		if ( command == "adv" ) or ( command == "advertise" ) then
			player:SendBroadcastMessage(".advertise create [Текст]\n.advertise delete [id]\n.advertise list - Отображает список созданных вами объявлений.")
		elseif string.find( command, " " ) then
			command = string.split( command, " " )
			if ( command[1] == "adv" ) or ( command[1] == "advertise" ) then
				if command[2] == "create" then
					local text = ""
					for i = 3, #command do
						text = text..command[i]
					end
					if text ~= "" then
						CharDBQuery('INSERT INTO roleADS ( text, creator ) values ( "'..text..'", '..player:GetAccountId()..' )')
						player:SendBroadcastMessage("Объявление создано. Теперь оно будет показываться игрокам.")
					end
				elseif ( command[2] == "delete" ) and ( command[3] ) and ( tonumber( command[3] ) ) then
					CharDBQuery( "DELETE FROM roleADS WHERE id = "..tonumber( command[3] ) )
					player:SendBroadcastMessage( command[3].." - удалено." )
				elseif command[2] == "list" then
					local Q = CharDBQuery( "SELECT id, text, countOfUses FROM roleADS WHERE owner = "..player:GetAccountId() )
					if Q then
						for i = 1, Q:GetRowCount() do
							local id = Q:GetUInt32(0)
							local text = Q:GetString(1)
							local countOfUses = Q:GetUInt8(2)
							player:SendBroadcastMessage( "["..id.."] - "..countOfUses.."\n"..text )
							Q:NextRow()
						end
					else
						player:SendBroadcastMessage("Созданных вами объявлений не найдено.")
					end
				else
					player:SendBroadcastMessage(".advertise create [Текст]\n.advertise delete [id]\n.advertise list - Отображает список созданных вами объявлений.")
				end
			end
		end
	end
end
RegisterPlayerEvent( 42, RoleAdv_Command )
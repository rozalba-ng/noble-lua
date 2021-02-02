local SQL_databaseCreation = [[
CREATE TABLE IF NOT EXISTS `roleADS` (
	`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	`text` TEXT NOT NULL,
	`lastUseTime` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`countOfUses` TINYINT(3) UNSIGNED NOT NULL DEFAULT '5',
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
		local Q = CharDBQuery( "SELECT id, text, countOfUses FROM roleADS WHERE ( countOfUses > 0 ) AND ( "..os.time().." - lastUseTime ) > 100" ) --3000
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
					players[i]:SendBroadcastMessage( "[|cff7eff47РОЛЕВОЕ ОБЪЯВЛЕНИЕ|r]\n|cff81b6e6"..text )
					players[i]:PlayDirectSound( 61, players[i] )
				end
			end
		end
	end
end
CreateLuaEvent( RoleAdv, 0.5*60000, 0 ) -- 60000-умножение на миллисекунды. Т.Е. Указываем кол-во минут.
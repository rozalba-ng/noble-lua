--	СКРИПТОВАННЫЕ ЧАСТИ ШТОРМГРАДСКИХ КВЕСТОВ
--	Охота за контрабандой - Навсегда исчезающие после сбора лута сундуки.

--[[	ОХОТА ЗА КОНТРАБАНДОЙ	]]--

local SQL_databaseCreation = [[
CREATE TABLE IF NOT EXISTS `gameobject_chest_events` (
	`entry` INT(11) UNSIGNED NOT NULL COMMENT 'Chest entry'
)
COMMENT='Used for quests_stormwind.lua'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]
WorldDBQuery( SQL_databaseCreation )

local function STQ_OnChestLooted( event, object, state )
	if state == 1 then
	--	Когда все предметы в сундуке закончились.
		object:RemoveFromWorld( true ) -- Удаляем предмет из мира и из базы данных.
	end
end

local function STQ_ChestCommand( event, player, command )
	if( string.find( command, " " ) ) then
		command = string.split(command, " ")
		if command[1] == "chestevent" and player:GetGMRank() > 1 then
			if command[2] then
				if command[2] == "reload" then
					local chestQ = WorldDBQuery("SELECT entry FROM gameobject_chest_events")
					if chestQ then
						for i = 1, chestQ:GetRowCount() do
							local entry = chestQ:GetUInt32(0)
							RegisterGameObjectEvent( entry, 9, STQ_OnChestLooted ) -- GAMEOBJECT_EVENT_ON_LOOT_STATE_CHANGE
							chestQ:NextRow()
						end
						player:SendBroadcastMessage("Таблица загружена.")
					end
				elseif command[2] == "add" then
					if command[3] and tonumber(command[3]) then
						command[3] = tonumber(command[3])
						WorldDBQuery( "INSERT INTO gameobject_chest_events ( entry ) VALUES ("..command[3]..")" )
						player:SendBroadcastMessage("ГОшка добавлена в базу данных.")
					else player:SendBroadcastMessage(".chestevent add [ENTRY]\n.chestevent reload") end
				end
			else player:SendBroadcastMessage(".chestevent add [ENTRY]\n.chestevent reload") end
		end
	elseif command == "chestevent" then
		player:SendBroadcastMessage(".chestevent add [ENTRY]\n.chestevent reload")
	end
end
RegisterPlayerEvent( 42, STQ_ChestCommand ) -- PLAYER_EVENT_ON_COMMAND

local chestQ = WorldDBQuery("SELECT entry FROM gameobject_chest_events")
if chestQ then
	for i = 1, chestQ:GetRowCount() do
		local entry = chestQ:GetUInt32(0)
		RegisterGameObjectEvent( entry, 9, STQ_OnChestLooted ) -- GAMEOBJECT_EVENT_ON_LOOT_STATE_CHANGE
		chestQ:NextRow()
	end
end
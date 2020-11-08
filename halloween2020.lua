--	СКРИПТЫ ХЭЛЛУИНОВСКИХ ИВЕНТОВ 2020 ГОДА
--		Разбегающиеся тараканы
local entry_cockroach = 110002

local SQL_databaseCreation = [[
CREATE TABLE IF NOT EXISTS `Halloween2020` (
	`player_guid` INT(10) UNSIGNED NOT NULL,
	`quest_stage` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`player_guid`)
)
COMMENT='Used for halloween2020.lua'
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
;
]]
WorldDBQuery( SQL_databaseCreation )

--[[	ХРУСТЯЩИЕ ТАРАКАНЫ	]]--

--	Поимка таракана
local function Gossip_ScaredCockroach( event, player, creature )
	player:Kill( creature )
	player:Emote( 60 )
	creature:DespawnOrUnsummon( 1500 )
end
RegisterCreatureGossipEvent( entry_cockroach, 1, Gossip_ScaredCockroach )

--[[	ТЫКВА НА ЛУННОЙ ПОЛЯНЕ	]]--

local function PlayerData( event, player )
	if event == 3 then
	--	Заход в игру
		local guid = tostring( player:GetGUID() )
		local playerQ = WorldDBQuery( "SELECT quest_stage FROM Halloween2020 WHERE player_guid = '"..guid.."'" )
		if playerQ then
			PlayerData( 28, player )
			local quest_stage = playerQ:GetUInt8(0)
			if quest_stage == 2 then
				WorldDBQuery("UPDATE Halloween2020 SET quest_stage = 3 WHERE player_guid = '"..guid.."'")
				local lowguid = player:GetGUIDLow()
				SendMail( "Письмо от Владика", "Дорогой друг, Тыквовин закончился и я улетаю в тёплые края! Спасибо за помощь с моим огородом и с прочими мелкими проблемами. Кто знает, быть может судьба снова сведёт нас через несколько столетий?\n\nНе-вампир Владик.", lowguid, 0, 41, 5000, 0, 0, 33226, 2 )
			elseif quest_stage == 3 then return
			else
				WorldDBQuery("DELETE FROM Halloween2020 WHERE player_guid = '"..guid.."'")
			end
			player:SendBroadcastMessage( "|cffff7588Ужасы Страхвилля отпускают вас." )
		end
	else
		if player:GetMapId() == 9001 and player:GetGMRank() < 2 then
		--	Выбрасывание игрока с карты, если он не ГМ2+
			player:SendBroadcastMessage("|cffff7588Не-вампир Владик куда-то пропал, а вместе с ним и весь городок.")
			player:Teleport( 1, 7796, -2574, 489, 0 )
		end
	end
end
RegisterPlayerEvent( 3, PlayerData ) -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent( 28, PlayerData ) -- PLAYER_EVENT_ON_MAP_CHANGE
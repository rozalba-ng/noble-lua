--[[	ИЗМЕНЕНИЕ СКОРОСТИ ПЕРЕДВИЖЕНИЯ КАСТОМНЫХ NPC-маунтов	]]--
--	В основе своей используется для летающих нпс.
--	Все значения хранятся в базе данных

local SQL_databaseCreation = [[
CREATE TABLE IF NOT EXISTS `creature_template_speed` (
	`npc_entry` INT(11) UNSIGNED NOT NULL DEFAULT '0',
	`walk` FLOAT UNSIGNED NULL DEFAULT '1',
	`run` FLOAT UNSIGNED NULL DEFAULT '1',
	`runBack` FLOAT UNSIGNED NULL DEFAULT '1',
	`swim` FLOAT UNSIGNED NULL DEFAULT '1',
	`swimBack` FLOAT UNSIGNED NULL DEFAULT '1',
	`turnRate` FLOAT UNSIGNED NULL DEFAULT '1',
	`flight` FLOAT UNSIGNED NULL DEFAULT '1',
	`flightBack` FLOAT UNSIGNED NULL DEFAULT '1',
	`pitchRate` FLOAT UNSIGNED NULL DEFAULT '1',
	PRIMARY KEY (`npc_entry`)
)
COMMENT='Used for CustomVehiclesSpeed.lua'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]
WorldDBQuery( SQL_databaseCreation )

--	Спелл кастующийся при залезании на транспорт
local entry_spell = 60968

local function OnMount( event, player, spell )
	if spell:GetEntry() == entry_spell then
		local creature = spell:GetTarget()
		local entry = creature:GetEntry()
		local Q = WorldDBQuery( "SELECT walk, run, runBack, swim, swimBack, turnRate, flight, flightBack, pitchRate FROM creature_template_speed WHERE npc_entry = "..entry )
		for i = 0, 8 do
			creature:SetSpeed( Q:GetUInt(i) )
		end
	end
end
RegisterPlayerEvent( 5, OnMount ) -- PLAYER_EVENT_ON_SPELL_CAST
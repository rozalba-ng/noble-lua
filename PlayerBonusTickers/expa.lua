local SQL_databaseCreation_CharExp = [[
CREATE TABLE `character_noblegarden_exp` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`add_datetime` DATETIME NULL DEFAULT NULL,
	`char_guid` INT(11) NULL DEFAULT NULL,
	`char_name` VARCHAR(255) NULL DEFAULT NULL,
	`exp` INT(11) NULL DEFAULT NULL,
	`added` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]
CharDBQuery( SQL_databaseCreation_CharExp )

local PRIMETIME_MODIFICATOR = 2

local function countExpForPlayer(player)
    local exp = 0
    local Q = CharDBQuery( "SELECT sum(exp), id FROM character_noblegarden_exp WHERE char_guid = ".. player:GetGUIDLow().." and added = 0 limit 1")
    if Q then
        if Q:GetUInt32(0) > 0 then
            exp = Q:GetUInt32(0)
            local ID = Q:GetUInt32(1)
            CharDBQuery( "UPDATE character_noblegarden_exp SET added = 1 where id <= "..ID.." and char_guid = ".. player:GetGUIDLow())
        end
    end

    return exp
end

local function addExpToPlayers()
    local onlinePlayers = GetPlayersInWorld(2); --[[ 2-neutral, both horde and aliance]]
    for _, player in ipairs(onlinePlayers) do
        local exp = countExpForPlayer(player)
        --	Бонусы за онлайн
        if (ActionTime()) then
            exp = exp * PRIMETIME_MODIFICATOR
        end

        if player and exp > 0 then
            player.AddNobleXp(exp)
        end
    end
end


CreateLuaEvent(addExpToPlayers, 300000, 0)
local SQL_databaseCreation_CharExp = [[
CREATE TABLE IF NOT EXISTS `character_noblegarden_exp` (
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
local BOOSTER_SPELL_X2 = 91341

local function countExpForPlayer(player)
    local exp = 0
    local Q = CharDBQuery( "SELECT sum(exp), max(id) FROM character_noblegarden_exp WHERE char_guid = ".. player:GetGUIDLow().." and added = 0 limit 1")
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
        local currentLevel = player:GetNobleLevel()

        -- с 18-го вместо опыта тикают денежки, без бустов и модификаторов
        if currentLevel > 18 then
            player:ModifyMoney(math.ceil(exp/2));
            player:SendBroadcastMessage("Полученный опыт конвертирован в монеты: " .. tostring(exp)  .." медных.")
            return
        end

        -- правила начисления бонусной экспы
        if exp > 500 then -- больше 500 бывает только бонусная экспа
            if currentLevel > 14 then -- бонусное хп выше 14-го не начисляется
                return
            end

            player:AddNobleXp(exp)
            player:SendBroadcastMessage("Начислен бонусный опыт: " .. tostring(exp) )

            currentLevel = player:GetNobleLevel()
            if currentLevel > 14 then -- если после начисления левл стал выше 14-го - лишнее убираем
                player:SetNobleLevel(14)
                player:SendBroadcastMessage("Установлен 14 уровень персонажа: максимально допустимый за бонусный опыт.")
                return
            end

            return
        end

        --	Модификатор за праймтайм
        if ActionTime() then
            exp = exp * PRIMETIME_MODIFICATOR
        end

        if player and exp > 0 then
            player:AddNobleXp(exp)
            player:SendBroadcastMessage("Начислено " .. tostring(exp) .." опыта." )

            if player:HasAura(BOOSTER_SPELL_X2) then -- бустер на х2 опыта
                player:AddNobleXp(exp)
                player:SendBroadcastMessage("Прозорливость: Начислено дополнительно " .. tostring(exp) .." опыта." )
            end
        end
    end
end


CreateLuaEvent(addExpToPlayers, 300000, 0)
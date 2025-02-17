local SQL_databaseCreation_CharExp = [[
CREATE TABLE IF NOT EXISTS `character_noblegarden_exp` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`add_datetime` DATETIME NULL DEFAULT NULL,
	`char_guid` INT(11) NULL DEFAULT NULL,
	`char_name` VARCHAR(255) NULL DEFAULT NULL,
	`exp` INT(11) NULL DEFAULT NULL,
	`added` INT(11) NULL DEFAULT NULL,
	`comment` VARCHAR(100) NULL DEFAULT 'online',
	PRIMARY KEY (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]
CharDBQuery( SQL_databaseCreation_CharExp )

local PRIMETIME_MODIFICATOR = 2
local BOOSTER_SPELL_X2 = 91341

local ONLINE_COMMENT = 'online' -- используется для начислений за онлайн, действуют модификаторы и множители
local EXTRA_COMMENT = 'extra' -- используется для начислений при дополнительном опыте или пеерносе - можификаторы не действуют, предел 14 левл
local REWARD_COMMENT = 'reward'-- используется для наградных награждений, до 20-го уровня включительно
-- для остальных бонусов предел 18-й левл, так что для опыта за прошлые полигоны всегда надо ставить коммент extra

local function addExtraExp(player, exp)
    if exp == 0 then
        return
    end

    local currentLevel = player:GetNobleLevel()

    if currentLevel >= 14 then -- бонусное хп выше 14-го не начисляется
        player:SendBroadcastMessage("Начисление дополнительного опыта невозможно: персонаж выше 14-го уровня.")
        return
    end

    player:AddNobleXp(exp)
    player:SendBroadcastMessage("Начислен дополнительный опыт: " .. tostring(exp) )

    currentLevel = player:GetNobleLevel()
    if currentLevel >= 14 then -- если после начисления левл стал выше 14-го - лишнее убираем
        player:SetNobleLevel(14)
        player:SendBroadcastMessage("Установлен 14 уровень персонажа: максимально допустимый за дополнительный опыт.")
        return
    end

    return
end

local function addBonusExp(player, exp)
    if exp == 0 then
        return
    end

    local currentLevel = player:GetNobleLevel()

    if currentLevel >= 18 then -- бонусное хп выше 18-го не начисляется
        player:SendBroadcastMessage("Начисление бонусного опыта невозможно: персонаж выше 18-го уровня.")
        return
    end

    player:AddNobleXp(exp)
    player:SendBroadcastMessage("Начислен бонусный опыт: " .. tostring(exp) )

    currentLevel = player:GetNobleLevel()
    if currentLevel >= 18 then -- если после начисления левл стал выше 14-го - лишнее убираем
        player:SetNobleLevel(18)
        player:SendBroadcastMessage("Установлен 18 уровень персонажа: максимально допустимый за бонусный опыт.")
        return
    end

    return

end

local function addRewardExp(player, exp)
    if exp == 0 then
        return
    end

    local currentLevel = player:GetNobleLevel()

    if currentLevel >= 20 then -- бонусное хп выше 20-го не начисляется
        player:SendBroadcastMessage("Начисление наградного опыта невозможно: персонаж выше 20-го уровня.")
        return
    end

    player:AddNobleXp(exp)
    player:SendBroadcastMessage("Начислен наградной опыт: " .. tostring(exp) )

    currentLevel = player:GetNobleLevel()
    if currentLevel >= 20 then -- если после начисления левл стал выше 14-го - лишнее убираем
        player:SetNobleLevel(20)
        player:SendBroadcastMessage("Установлен 20 уровень персонажа: максимально допустимый за наградной опыт.")
        return
    end

    return
end

local function addExp(player, exp)
    local currentLevel = player:GetNobleLevel()
    -- с 18-го вместо опыта тикают денежки, без бустов и модификаторов
    if currentLevel >= 18 and exp > 0 then
        local money = math.ceil(exp/2)
        player:ModifyMoney(money);
        player:SendBroadcastMessage("Полученный опыт конвертирован в монеты: " .. tostring(money)  .." медных.")
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

local function countExpForPlayers(usersList, expTbl)
    local Q = CharDBQuery( "SELECT id, exp, char_guid, comment FROM character_noblegarden_exp WHERE added = 0 and char_guid in (" .. usersList .. ")")
    if Q then
        local rowCount = Q:GetRowCount();
        for var = 1, rowCount, 1 do
            local ID = Q:GetUInt32(0)
            local exp = Q:GetUInt32(1)
            local charGuid = Q:GetUInt32(2)
            local comment = Q:GetString(3)

            if expTbl[charGuid] ~= nil then
                table.insert(expTbl.ids, tostring(ID))

                if comment == ONLINE_COMMENT then
                    expTbl[charGuid].exp = expTbl[charGuid].exp + exp
                elseif comment == EXTRA_COMMENT then
                    expTbl[charGuid].extraExp = expTbl[charGuid].extraExp + exp
                elseif comment == REWARD_COMMENT then
                    expTbl[charGuid].rewardExp = expTbl[charGuid].rewardExp + exp
                else
                    expTbl[charGuid].bonusExp = expTbl[charGuid].bonusExp + exp
                end
            end
            Q:NextRow();
        end
    end
    return expTbl
end


local function addExpToPlayers()
    local onlinePlayers = GetPlayersInWorld(2); --[[ 2-neutral, both horde and aliance]]
    local count, usersTable, expTbl = 0, {}, {}
    expTbl.ids = {}

    for _, player in ipairs(onlinePlayers) do
        count = count+1
        local guid = player:GetGUIDLow()
        table.insert(usersTable, tostring(guid))
        expTbl[guid] = {}
        expTbl[guid].guid = guid
        expTbl[guid].exp = 0
        expTbl[guid].bonusExp = 0
        expTbl[guid].extraExp = 0
        expTbl[guid].rewardExp = 0
    end
    local usersList = table.concat(usersTable, ",")

    if count == 0 then
        return
    end

    expTbl = countExpForPlayers(usersList, expTbl)
    local idsList = table.concat(expTbl.ids, ",")
    if idsList ~= '' then
        CharDBQuery( "UPDATE character_noblegarden_exp SET added = 1 where id in ("..idsList .. ")")
    end

    for _, player in ipairs(onlinePlayers) do
        addExp(player, expTbl[player:GetGUIDLow()].exp)
        addBonusExp(player, expTbl[player:GetGUIDLow()].bonusExp)
        addExtraExp(player, expTbl[player:GetGUIDLow()].extraExp)
        addRewardExp(player, expTbl[player:GetGUIDLow()].rewardExp)
    end
end


CreateLuaEvent(addExpToPlayers, 240000, 0)
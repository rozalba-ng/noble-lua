-- RoleStatSystem.lua
ROLE_STAT_STRENGTH = 0;
ROLE_STAT_AGLILITY = 1;
ROLE_STAT_INTELLECT = 2;
ROLE_STAT_STAMINA = 3;
ROLE_STAT_VERSA = 4;
ROLE_STAT_WILL = 5;
ROLE_STAT_SPIRIT = 6;
ROLE_STAT_CHARISMA = 7;
ROLE_STAT_AVOID = 8;
ROLE_STAT_LUCK = 9;
ROLE_STAT_STEALTH = 10;
ROLE_STAT_INIT = 11;
ROLE_STAT_PERCEPT = 12;
ROLE_STAT_HEALTH = 100;
ROLE_STAT_ARMOR = 101;

statDbNames = {
    [ROLE_STAT_STRENGTH] = "STR",
    [ROLE_STAT_AGLILITY] = "AGI",
    [ROLE_STAT_INTELLECT] = "INTEL",
    [ROLE_STAT_STAMINA] = "VIT",
    [ROLE_STAT_VERSA] = "DEX",
    [ROLE_STAT_WILL] = "WILL",
    [ROLE_STAT_SPIRIT] = "SPI",
    [ROLE_STAT_HEALTH] = "HEALTH", -- инициатива
    [ROLE_STAT_ARMOR] = "ARMOR", -- восприятие
}

statAllowedInBattle = {
    [ROLE_STAT_STRENGTH] = 1, -- силе
    [ROLE_STAT_AGLILITY] = 1, -- ловкости
    [ROLE_STAT_INTELLECT] = 1, -- интеллекту
    [ROLE_STAT_STAMINA] = 0, -- стойкости
    [ROLE_STAT_VERSA] = 0, -- сноровке
    [ROLE_STAT_WILL] = 0, -- воле
    [ROLE_STAT_SPIRIT] = 1, -- дух
    [ROLE_STAT_CHARISMA] = 0, -- харизма
    [ROLE_STAT_AVOID] = 0, -- избегание
    [ROLE_STAT_LUCK] = 0, -- удача
    [ROLE_STAT_STEALTH] = 0, -- скрытность
    [ROLE_STAT_INIT] = 0, -- инициатива
    [ROLE_STAT_PERCEPT] = 0, -- восприятие
}

-- массовый ролевой бой (альтерак)
roleCombatArray = {};
roleCombat = {};
roleCombat.playerCombat = {};
roleCombat.playerCombatMove = {};
roleCombat.playerCombatFaction = {};
roleCombat.menuID = 6010;
roleCombat.diff_number = {};

--BattleManager.lua
listPlayersInBattle = {}

TURN_AURA = 88037
IS_IN_BATTLE_AURA = 88057
LEAVER_AURA = 88058
HP_AURA =  88059
WOUND_AURA = 88010
DOUBLE_ATTACK_AURA = 88076
DEAD_AURA = 45801

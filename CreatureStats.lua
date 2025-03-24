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
ROLE_STAT_ENERGY = 102;
ROLE_STAT_PHARMOR = 103;
ROLE_STAT_MAGARMOR = 104;
ROLE_STAT_BRON = 105;
ROLE_STAT_DAMAGE = 106;
ROLE_STAT_HASTE = 107;
ROLE_STAT_POWER = 108;
ROLE_STAT_ATAKA = 109;


EBS_HP_AURA = 88038
EBS_ARMOR_AURA = 88050 --
EBS_ENERGY_AURA = 88060
EBS_PHARMOR_AURA = 102050
EBS_MAGARMOR_AURA = 102051
EBS_BRON_AURA = 95014
EBS_DAMAGE_AURA = 95013
EBS_POWER_AURA = 95018
EBS_ATAKA_AURA = 95005
EBS_HASTE_AURA = 95012


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
    [ROLE_STAT_ENERGY] = "ENERGY",
    [ROLE_STAT_PHARMOR] = "PHARMOR",
    [ROLE_STAT_MAGARMOR] = "MAGARMOR",
    [ROLE_STAT_BRON] = "BRON",
    [ROLE_STAT_DAMAGE] = "DAMAGE",
    [ROLE_STAT_HASTE] = "HASTE",
    [ROLE_STAT_POWER] = "POWER",
    [ROLE_STAT_ATAKA] = "ATAKA",

}

npcStats = {}
tempNpcStats = {}
npcStatsTemplate = {}
--WorldDBQuery('UPDATE creature_role_stats SET STR = ' .. STR ..', AGI = ' .. AGI .. ', INTEL = ' .. INTEL .. ', VIT = ' .. VIT .. ', DEX = ' .. DEX .. ', WILL = ' .. WILL .. ', SPI = ' .. SPI ..', HEALTH = ' .. HEALTH ..', ARMOR = ' .. ARMOR ..' where guid = ' .. guid );
--WorldDBQuery('INSERT INTO creature_role_stats (guid, STR, AGI, INTEL, VIT, DEX, WILL, SPI, HEALTH, ARMOR) VALUES (' .. guid ..',' .. STR ..', '.. AGI ..',' .. INTEL .. ', ' .. VIT .. ',' .. DEX .. ',' .. WILL .. ',' .. SPI .. ', ' .. HEALTH .. ', ' .. ARMOR .. ')');


function getNpcStatsPrint(player, creature)
    local guid = creature:GetDBTableGUIDLow();
    local guidLow = creature:GetGUIDLow();

    if guid then
        if not npcStats[guid] then
            player:SendBroadcastMessage("не установлены")
            return
        end
        player:SendBroadcastMessage(string.format("Сила: %u", npcStats[guid][ROLE_STAT_STRENGTH]))
        player:SendBroadcastMessage(string.format("Ловк: %u", npcStats[guid][ROLE_STAT_AGLILITY]))
        player:SendBroadcastMessage(string.format("Инта: %u", npcStats[guid][ROLE_STAT_INTELLECT]))
        player:SendBroadcastMessage(string.format("Физ.уст: %u", npcStats[guid][ROLE_STAT_VERSA]))
        player:SendBroadcastMessage(string.format("Маг.уст: %u", npcStats[guid][ROLE_STAT_WILL]))
    else
        player:SendBroadcastMessage("не установлены")
    end
    return
end

-- удаляем лишние статы
function deleteRoleStatsForDeletedNpc()
    local toDeleteQuery = WorldDBQuery('SELECT guid FROM creature_role_stats crs WHERE not exists (SELECT * FROM creature c WHERE c.guid = crs.guid)');
    if toDeleteQuery then
        local toDeleteCount = toDeleteQuery:GetRowCount()

        for i = 1, toDeleteCount do
            local guid = toDeleteQuery:GetString(0);
            WorldDBQuery('DELETE FROM creature_role_stats WHERE guid = ' .. guid);

            toDeleteQuery:NextRow()
        end
    end
    toDeleteQuery = nil;

end

local function loadDefaultCreatureStats(event, creature)
    local entry = creature:GetEntry();
    local guid = creature:GetDBTableGUIDLow();
    if not npcStats[guid] and npcStatsTemplate[entry] then
        setNpcStats(creature, ROLE_STAT_STRENGTH, npcStatsTemplate[entry][ROLE_STAT_STRENGTH])
        setNpcStats(creature, ROLE_STAT_AGLILITY, npcStatsTemplate[entry][ROLE_STAT_AGLILITY])
        setNpcStats(creature, ROLE_STAT_INTELLECT, npcStatsTemplate[entry][ROLE_STAT_INTELLECT])
        setNpcStats(creature, ROLE_STAT_STAMINA, npcStatsTemplate[entry][ROLE_STAT_STAMINA])
        setNpcStats(creature, ROLE_STAT_VERSA, npcStatsTemplate[entry][ROLE_STAT_VERSA])
        setNpcStats(creature, ROLE_STAT_WILL, npcStatsTemplate[entry][ROLE_STAT_WILL])
        setNpcStats(creature, ROLE_STAT_HEALTH, npcStatsTemplate[entry][ROLE_STAT_HEALTH])
        setNpcStats(creature, ROLE_STAT_ARMOR, npcStatsTemplate[entry][ROLE_STAT_ARMOR])-- PREV. VER
        setNpcStats(creature, ROLE_STAT_ENERGY, npcStatsTemplate[entry][ROLE_STAT_ENERGY])
        setNpcStats(creature, ROLE_STAT_PHARMOR, npcStatsTemplate[entry][ROLE_STAT_PHARMOR])
        setNpcStats(creature, ROLE_STAT_MAGARMOR, npcStatsTemplate[entry][ROLE_STAT_MAGARMOR])
        setNpcStats(creature, ROLE_STAT_BRON, npcStatsTemplate[entry][ROLE_STAT_BRON])
        setNpcStats(creature, ROLE_STAT_DAMAGE, npcStatsTemplate[entry][ROLE_STAT_DAMAGE])
        setNpcStats(creature, ROLE_STAT_HASTE, npcStatsTemplate[entry][ROLE_STAT_HASTE])
        setNpcStats(creature, ROLE_STAT_POWER, npcStatsTemplate[entry][ROLE_STAT_POWER])
        setNpcStats(creature, ROLE_STAT_ATAKA, npcStatsTemplate[entry][ROLE_STAT_ATAKA])
    end

    if npcStats[guid] then
        creature:RemoveAura(EBS_HP_AURA)
        if tonumber(npcStats[guid][ROLE_STAT_HEALTH]) ~= nil and tonumber(npcStats[guid][ROLE_STAT_HEALTH]) > 0 then
            local hpAura = creature:AddAura(EBS_HP_AURA, creature)
            hpAura:SetStackAmount(npcStats[guid][ROLE_STAT_HEALTH])
        end

        creature:RemoveAura(EBS_ARMOR_AURA)
        if tonumber(npcStats[guid][ROLE_STAT_ARMOR]) ~= nil and tonumber(npcStats[guid][ROLE_STAT_ARMOR]) > 0 then
            local ammoAura = creature:AddAura(EBS_ARMOR_AURA, creature)
            ammoAura:SetStackAmount(npcStats[guid][ROLE_STAT_ARMOR])
--PREV.VER
        creature:RemoveAura(EBS_ENERGY_AURA)
        if tonumber(npcStats[guid][ROLE_STAT_ENERGY]) ~= nil and tonumber(npcStats[guid][ROLE_STAT_ENERGY]) > 0 then
            local EnAura = creature:AddAura(EBS_ENERGY_AURA, creature)
            EnAura:SetStackAmount(npcStats[guid][ROLE_STAT_ENERGY])
        end

        creature:RemoveAura(EBS_PHARMOR_AURA)
        if tonumber(npcStats[guid][ROLE_STAT_PHARMOR]) ~= nil and tonumber(npcStats[guid][ROLE_STAT_PHARMOR]) > 0 then
            local PHArmAura = creature:AddAura(EBS_PHARMOR_AURA, creature)
            PHArmAura:SetStackAmount(npcStats[guid][ROLE_STAT_PHARMOR])
        end 

        creature:RemoveAura(EBS_MAGARMOR_AURA)
        if tonumber(npcStats[guid][ROLE_STAT_MAGARMOR]) ~= nil and tonumber(npcStats[guid][ROLE_STAT_MAGARMOR]) > 0 then
            local MAGArmAura = creature:AddAura(EBS_MAGARMOR_AURA, creature)
            MAGArmAura:SetStackAmount(npcStats[guid][ROLE_STAT_MAGARMOR])
        end

        creature:RemoveAura(EBS_BRON_AURA)
        if tonumber(npcStats[guid][ROLE_STAT_BRON]) ~= nil and tonumber(npcStats[guid][ROLE_STAT_BRON]) > 0 then
            local BronAura = creature:AddAura(EBS_BRON_AURA, creature)
            BronAura:SetStackAmount(npcStats[guid][ROLE_STAT_BRON])
        end

        creature:RemoveAura(EBS_HASTE_AURA)
        if tonumber(npcStats[guid][ROLE_STAT_HASTE]) ~= nil and tonumber(npcStats[guid][ROLE_STAT_HASTE]) > 0 then
            local HasteAura = creature:AddAura(EBS_HASTE_AURA, creature)
            HasteAura:SetStackAmount(npcStats[guid][ROLE_STAT_HASTE])
        end

        creature:RemoveAura(EBS_POWER_AURA)
        if tonumber(npcStats[guid][ROLE_STAT_POWER]) ~= nil and tonumber(npcStats[guid][ROLE_STAT_POWER]) > 0 then
            local PowerAura = creature:AddAura(EBS_POWER_AURA, creature)
            PowerAura:SetStackAmount(npcStats[guid][ROLE_STAT_POWER])
        end

        creature:RemoveAura(EBS_ATAKA_AURA)
        if tonumber(npcStats[guid][ROLE_STAT_ATAKA]) ~= nil and tonumber(npcStats[guid][ROLE_STAT_ATAKA]) > 0 then
            local AtakaAura = creature:AddAura(EBS_ATAKA_AURA, creature)
            AtakaAura:SetStackAmount(npcStats[guid][ROLE_STAT_ATAKA])
        end

        end
    end
end

function loadAllCreatureTemplateRollStats()
    local creatureTemplateStatsQuery = WorldDBQuery('SELECT c.* FROM creature_template_role_stats c join creature_template t on c.entry = t.entry where 1');

    if creatureTemplateStatsQuery then
        local creatureTemplsteStatsCount = creatureTemplateStatsQuery:GetRowCount()

        for i = 1, creatureTemplsteStatsCount do

            local entry = tonumber(creatureTemplateStatsQuery:GetString(0))
            if not npcStatsTemplate[entry] then
                npcStatsTemplate[entry] = {}
            end

            npcStatsTemplate[entry][ROLE_STAT_STRENGTH] = tonumber(creatureTemplateStatsQuery:GetString(1));
            npcStatsTemplate[entry][ROLE_STAT_AGLILITY] = tonumber(creatureTemplateStatsQuery:GetString(2));
            npcStatsTemplate[entry][ROLE_STAT_INTELLECT] = tonumber(creatureTemplateStatsQuery:GetString(3));
            npcStatsTemplate[entry][ROLE_STAT_STAMINA] = tonumber(creatureTemplateStatsQuery:GetString(4));
            npcStatsTemplate[entry][ROLE_STAT_VERSA] = tonumber(creatureTemplateStatsQuery:GetString(5));
            npcStatsTemplate[entry][ROLE_STAT_WILL] = tonumber(creatureTemplateStatsQuery:GetString(6));
            npcStatsTemplate[entry][ROLE_STAT_SPIRIT] = tonumber(creatureTemplateStatsQuery:GetString(7));
            npcStatsTemplate[entry][ROLE_STAT_HEALTH] = tonumber(creatureTemplateStatsQuery:GetString(8));
            npcStatsTemplate[entry][ROLE_STAT_ARMOR] = tonumber(creatureTemplateStatsQuery:GetString(9)); -- PREV. VER
            npcStatsTemplate[entry][ROLE_STAT_ENERGY] = tonumber(creatureTemplateStatsQuery:GetString(10));
            npcStatsTemplate[entry][ROLE_STAT_PHARMOR] = tonumber(creatureTemplateStatsQuery:GetString(11));
            npcStatsTemplate[entry][ROLE_STAT_MAGARMOR] = tonumber(creatureTemplateStatsQuery:GetString(12));
            npcStatsTemplate[entry][ROLE_STAT_BRON] = tonumber(creatureTemplateStatsQuery:GetString(13));
            npcStatsTemplate[entry][ROLE_STAT_DAMAGE] = tonumber(creatureTemplateStatsQuery:GetString(14));
            npcStatsTemplate[entry][ROLE_STAT_HASTE] = tonumber(creatureTemplateStatsQuery:GetString(15));
            npcStatsTemplate[entry][ROLE_STAT_POWER] = tonumber(creatureTemplateStatsQuery:GetString(16));
            npcStatsTemplate[entry][ROLE_STAT_ATAKA] = tonumber(creatureTemplateStatsQuery:GetString(17));

            -- Регаем ивенты на все заранее настроенные нпс
            RegisterCreatureEvent(entry, 5, loadDefaultCreatureStats)

            creatureTemplateStatsQuery:NextRow()
        end
    end
    creatureTemplateStatsQuery = nil;
end

function loadAllCreatureRollStats()
    local creatureStatsQuery = WorldDBQuery('SELECT * FROM creature_role_stats c join creature t ON c.guid = t.guid WHERE 1');
    if creatureStatsQuery then
        local creatureStatsCount = creatureStatsQuery:GetRowCount()

        for i = 1, creatureStatsCount do
            local guid = tonumber(creatureStatsQuery:GetString(0))

            if not npcStats[guid] then
                npcStats[guid] = {}
            end
            npcStats[guid][ROLE_STAT_STRENGTH] = tonumber(creatureStatsQuery:GetString(1));
            npcStats[guid][ROLE_STAT_AGLILITY] = tonumber(creatureStatsQuery:GetString(2));
            npcStats[guid][ROLE_STAT_INTELLECT] = tonumber(creatureStatsQuery:GetString(3));
            npcStats[guid][ROLE_STAT_STAMINA] = tonumber(creatureStatsQuery:GetString(4));
            npcStats[guid][ROLE_STAT_VERSA] = tonumber(creatureStatsQuery:GetString(5));
            npcStats[guid][ROLE_STAT_WILL] = tonumber(creatureStatsQuery:GetString(6));
            npcStats[guid][ROLE_STAT_SPIRIT] = tonumber(creatureStatsQuery:GetString(7));
            npcStats[guid][ROLE_STAT_HEALTH] = tonumber(creatureStatsQuery:GetString(8));
            npcStats[guid][ROLE_STAT_ARMOR] = tonumber(creatureStatsQuery:GetString(9)); -- Prev. ver.
            npcStats[guid][ROLE_STAT_ENERGY] = tonumber(creatureStatsQuery:GetString(10));
            npcStats[guid][ROLE_STAT_PHARMOR] = tonumber(creatureStatsQuery:GetString(11));
            npcStats[guid][ROLE_STAT_MAGARMOR] = tonumber(creatureStatsQuery:GetString(12));
            npcStats[guid][ROLE_STAT_BRON] = tonumber(creatureStatsQuery:GetString(13));
            npcStats[guid][ROLE_STAT_DAMAGE] = tonumber(creatureStatsQuery:GetString(14));
            npcStats[guid][ROLE_STAT_HASTE] = tonumber(creatureStatsQuery:GetString(15));
            npcStats[guid][ROLE_STAT_POWER] = tonumber(creatureStatsQuery:GetString(16));
            npcStats[guid][ROLE_STAT_ATAKA] = tonumber(creatureStatsQuery:GetString(17));

            creatureStatsQuery:NextRow()
        end
    end
    creatureStatsQuery = nil

    local noTeplateButSetQuery = WorldDBQuery('SELECT distinct c.id FROM creature_role_stats crs JOIN creature c ON c.guid = crs.guid LEFT JOIN creature_template_role_stats ctrs ON ctrs.entry = c.id WHERE ctrs.entry IS NULL');
    if noTeplateButSetQuery then
        local noTeplateButSetCount = noTeplateButSetQuery:GetRowCount()

        for i = 1, noTeplateButSetCount do
            local entry = tonumber(noTeplateButSetQuery:GetString(0));
            RegisterCreatureEvent(entry, 5, loadDefaultCreatureStats)

            noTeplateButSetQuery:NextRow()
        end
    end
    noTeplateButSetQuery = nil;
end

function setNpcStats(creature, stat, value)
    local guid = creature:GetDBTableGUIDLow();
    local guidLow = creature:GetGUIDLow();
    value = tonumber(value);
    if not (statDbNames[stat] and value~=nil and value >=0) then
        return false
    end
    if guid then
        if not npcStats[guid] then
            npcStats[guid] = {}
        end
        npcStats[guid][stat] = value

        local guidQ = WorldDBQuery('SELECT * FROM creature_role_stats where guid = ' .. guid );
        if(guidQ ~= nil) then
            WorldDBQuery('UPDATE creature_role_stats SET ' .. statDbNames[stat] ..' = ' .. value .. ' where guid = ' .. guid );
        else
            WorldDBQuery('INSERT INTO creature_role_stats (guid, STR, AGI, INTEL, VIT, DEX, WILL, SPI, HEALTH, ARMOR, ENERGY, PHARMOR, MAGARMOR, BRON, DAMAGE, HASTE, POWER, ATAKA) VALUES (' .. guid ..',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)');
            WorldDBQuery('UPDATE creature_role_stats SET ' .. statDbNames[stat] ..' = ' .. value .. ' where guid = ' .. guid );
        end
    else
        if not tempNpcStats[guidLow] then
            tempNpcStats[guidLow] = {}
        end
        tempNpcStats[guidLow][stat] = value
    end
    return true
end

function getStatsByCreature(target)
    if npcStats[target:GetDBTableGUIDLow()] then
        return npcStats[target:GetDBTableGUIDLow()]
    elseif tempNpcStats[target:GetGUIDLow()] then
        return tempNpcStats[target:GetGUIDLow()]
    end

    return nil
end

deleteRoleStatsForDeletedNpc();
loadAllCreatureRollStats();
loadAllCreatureTemplateRollStats();
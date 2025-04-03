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
EBS_ARMOR_AURA = 88050 
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
    [ROLE_STAT_HEALTH] = "HEALTH", -- Р С‘Р Р…Р С‘РЎвЂ Р С‘Р В°РЎвЂљР С‘Р Р†Р В°
    [ROLE_STAT_ARMOR] = "ARMOR", -- Р Р†Р С•РЎРѓР С—РЎР‚Р С‘РЎРЏРЎвЂљР С‘Р Вµ
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
            player:SendBroadcastMessage("РЅРµ СѓСЃС‚Р°РЅРѕРІР»РµРЅС‹")
            return
        end
        player:SendBroadcastMessage(string.format("РЎРёР»Р°: %u", npcStats[guid][ROLE_STAT_STRENGTH]))
        player:SendBroadcastMessage(string.format("Р›РѕРІРє: %u", npcStats[guid][ROLE_STAT_AGLILITY]))
        player:SendBroadcastMessage(string.format("РРЅС‚Р°: %u", npcStats[guid][ROLE_STAT_INTELLECT]))
        player:SendBroadcastMessage(string.format("Р¤РёР·.СѓСЃС‚: %u", npcStats[guid][ROLE_STAT_VERSA]))
        player:SendBroadcastMessage(string.format("РњР°Рі.СѓСЃС‚: %u", npcStats[guid][ROLE_STAT_WILL]))
    else
        player:SendBroadcastMessage("РЅРµ СѓСЃС‚Р°РЅРѕРІР»РµРЅС‹")
    end
    return
end

-- РЎС“Р Т‘Р В°Р В»РЎРЏР ВµР С Р В»Р С‘РЎв‚¬Р Р…Р С‘Р Вµ РЎРѓРЎвЂљР В°РЎвЂљРЎвЂ№
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
    local entry = creature:GetEntry()
    local guid = creature:GetDBTableGUIDLow()

    -- If the live npcStats for this GUID havenвЂ™t been set yet, load them from the template.
    if not npcStats[guid] and npcStatsTemplate[entry] then
        setNpcStats(creature, ROLE_STAT_STRENGTH,   npcStatsTemplate[entry][ROLE_STAT_STRENGTH])
        setNpcStats(creature, ROLE_STAT_AGLILITY,   npcStatsTemplate[entry][ROLE_STAT_AGLILITY])
        setNpcStats(creature, ROLE_STAT_INTELLECT,  npcStatsTemplate[entry][ROLE_STAT_INTELLECT])
        setNpcStats(creature, ROLE_STAT_STAMINA,    npcStatsTemplate[entry][ROLE_STAT_STAMINA])
        setNpcStats(creature, ROLE_STAT_VERSA,      npcStatsTemplate[entry][ROLE_STAT_VERSA])
        setNpcStats(creature, ROLE_STAT_WILL,       npcStatsTemplate[entry][ROLE_STAT_WILL])
        setNpcStats(creature, ROLE_STAT_HEALTH,     npcStatsTemplate[entry][ROLE_STAT_HEALTH])
        setNpcStats(creature, ROLE_STAT_ARMOR,      npcStatsTemplate[entry][ROLE_STAT_ARMOR]) -- Previous version
        setNpcStats(creature, ROLE_STAT_ENERGY,     npcStatsTemplate[entry][ROLE_STAT_ENERGY])
        setNpcStats(creature, ROLE_STAT_PHARMOR,    npcStatsTemplate[entry][ROLE_STAT_PHARMOR])
        setNpcStats(creature, ROLE_STAT_MAGARMOR,   npcStatsTemplate[entry][ROLE_STAT_MAGARMOR])
        setNpcStats(creature, ROLE_STAT_BRON,       npcStatsTemplate[entry][ROLE_STAT_BRON])
        setNpcStats(creature, ROLE_STAT_DAMAGE,     npcStatsTemplate[entry][ROLE_STAT_DAMAGE])
        setNpcStats(creature, ROLE_STAT_HASTE,      npcStatsTemplate[entry][ROLE_STAT_HASTE])
        setNpcStats(creature, ROLE_STAT_POWER,      npcStatsTemplate[entry][ROLE_STAT_POWER])
        setNpcStats(creature, ROLE_STAT_ATAKA,      npcStatsTemplate[entry][ROLE_STAT_ATAKA])
    end

    if npcStats[guid] then
        -- Helper to remove an aura, log the current value, and then add the aura if the value is valid.
        local function applyAura(statConstant, auraConstant, statName)
            local statVal = npcStats[guid][statConstant]
            creature:RemoveAura(auraConstant)
            if statVal == nil then
                print("WARNING: " .. statName .. " is nil for creature GUID " .. tostring(guid))
            elseif tonumber(statVal) < 0 then
                print("WARNING: " .. statName .. " is negative (" .. tostring(statVal) .. ") for creature GUID " .. tostring(guid))
            elseif tonumber(statVal) >= 256 then
                print("WARNING: " .. statName .. " is out of expected range (" .. tostring(statVal) .. ") for creature GUID " .. tostring(guid))
            else
                local auraObj = creature:AddAura(auraConstant, creature)
                auraObj:SetStackAmount(statVal)
                --print("Applied " .. statName .. " aura with value " .. tostring(statVal) .. " for creature GUID " .. tostring(guid))
            end
        end

        -- Process each aura stat.
        applyAura(ROLE_STAT_HEALTH,    EBS_HP_AURA,       "Health")
        applyAura(ROLE_STAT_ARMOR,     EBS_ARMOR_AURA,    "Armor")
        applyAura(ROLE_STAT_ENERGY,    EBS_ENERGY_AURA,   "Energy")
        applyAura(ROLE_STAT_PHARMOR,   EBS_PHARMOR_AURA,  "Physical Armor")
        applyAura(ROLE_STAT_MAGARMOR,  EBS_MAGARMOR_AURA, "Magical Armor")
        applyAura(ROLE_STAT_BRON,      EBS_BRON_AURA,     "Bron")
        applyAura(ROLE_STAT_HASTE,     EBS_HASTE_AURA,    "Haste")
        applyAura(ROLE_STAT_POWER,     EBS_POWER_AURA,    "Power")
        applyAura(ROLE_STAT_ATAKA,     EBS_ATAKA_AURA,    "Ataka")
    else
        print("WARNING: npcStats for GUID " .. tostring(guid) .. " is missing, cannot apply auras.")
    end
end
        

function loadAllCreatureTemplateRollStats()
    local creatureTemplateStatsQuery = WorldDBQuery('SELECT c.* FROM creature_template_role_stats c join creature_template t on c.entry = t.entry where 1')

    if creatureTemplateStatsQuery then
        local creatureTemplateStatsCount = creatureTemplateStatsQuery:GetRowCount()

        for i = 1, creatureTemplateStatsCount do
            local entry = tonumber(creatureTemplateStatsQuery:GetString(0))
            if not npcStatsTemplate[entry] then
                npcStatsTemplate[entry] = {}
            end

            -- Helper to load a stat and log if missing or suspicious.
            local function loadStat(index, statConstant, statName)
                local statVal = tonumber(creatureTemplateStatsQuery:GetString(index))
                if statVal == nil then
                    --print("WARNING: Missing " .. statName .. " for entry " .. tostring(entry) .. " (db column " .. index .. ")")
                elseif statVal < 0 then
                    --print("INFO: " .. statName .. " for entry " .. tostring(entry) .. " is non-positive: " .. tostring(statVal))
                elseif statVal >= 256 then
                    --print("WARNING: " .. statName .. " for entry " .. tostring(entry) .. " is unexpectedly high: " .. tostring(statVal))
                end
                npcStatsTemplate[entry][statConstant] = statVal
            end

            loadStat(1, ROLE_STAT_STRENGTH,   "Strength")
            loadStat(2, ROLE_STAT_AGLILITY,   "Agility")
            loadStat(3, ROLE_STAT_INTELLECT,  "Intellect")
            loadStat(4, ROLE_STAT_STAMINA,    "Stamina")
            loadStat(5, ROLE_STAT_VERSA,      "Versatility")
            loadStat(6, ROLE_STAT_WILL,       "Will")
            loadStat(7, ROLE_STAT_SPIRIT,     "Spirit")
            loadStat(8, ROLE_STAT_HEALTH,     "Health")
            loadStat(9, ROLE_STAT_ARMOR,      "Armor")         -- Previous version
            loadStat(10, ROLE_STAT_ENERGY,    "Energy")
            loadStat(11, ROLE_STAT_PHARMOR,   "Physical Armor")
            loadStat(12, ROLE_STAT_MAGARMOR,  "Magical Armor")
            loadStat(13, ROLE_STAT_BRON,      "Bron")
            loadStat(14, ROLE_STAT_DAMAGE,    "Damage")
            loadStat(15, ROLE_STAT_HASTE,     "Haste")
            loadStat(16, ROLE_STAT_POWER,     "Power")
            loadStat(17, ROLE_STAT_ATAKA,     "Ataka")

            -- Register the event so the creature will have its stats applied.
            RegisterCreatureEvent(entry, 5, loadDefaultCreatureStats)

            creatureTemplateStatsQuery:NextRow()
        end
    else
        print("ERROR: creatureTemplateStatsQuery is nil.")
    end

    creatureTemplateStatsQuery = nil
end

function loadAllCreatureRollStats()
    local creatureStatsQuery = WorldDBQuery('SELECT c.guid, c.STR, c.AGI, c.INTEL, c.VIT, c.DEX, c.WILL, c.SPI, c.HEALTH, c.ARMOR, c.ENERGY, c.PHARMOR, c.MAGARMOR, c.BRON, c.DAMAGE, c.HASTE, c.POWER, c.ATAKA FROM creature_role_stats c JOIN creature t ON c.guid = t.guid WHERE 1');
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

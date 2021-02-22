npcStats = {}
tempNpcStats = {}
npcStatsTemplate = {}


--WorldDBQuery('UPDATE creature_role_stats SET STR = ' .. STR ..', AGI = ' .. AGI .. ', INTEL = ' .. INTEL .. ', VIT = ' .. VIT .. ', DEX = ' .. DEX .. ', WILL = ' .. WILL .. ', SPI = ' .. SPI ..', HEALTH = ' .. HEALTH ..', ARMOR = ' .. ARMOR ..' where guid = ' .. guid );
--WorldDBQuery('INSERT INTO creature_role_stats (guid, STR, AGI, INTEL, VIT, DEX, WILL, SPI, HEALTH, ARMOR) VALUES (' .. guid ..',' .. STR ..', '.. AGI ..',' .. INTEL .. ', ' .. VIT .. ',' .. DEX .. ',' .. WILL .. ',' .. SPI .. ', ' .. HEALTH .. ', ' .. ARMOR .. ')');

function loadDefaultCreatureStats(event, creature, summoner)
    local entry = creature:GetEntry();
    local guid = creature:GetDBTableGUIDLow();
    if npcStatsTemplate[entry] then
        npcStats[guid][ROLE_STAT_STRENGTH] = npcStatsTemplate[entry][ROLE_STAT_STRENGTH];
        npcStats[guid][ROLE_STAT_AGLILITY] = npcStatsTemplate[entry][ROLE_STAT_AGLILITY];
        npcStats[guid][ROLE_STAT_INTELLECT] = npcStatsTemplate[entry][ROLE_STAT_INTELLECT];
        npcStats[guid][ROLE_STAT_STAMINA] = npcStatsTemplate[entry][ROLE_STAT_STAMINA];
        npcStats[guid][ROLE_STAT_VERSA] = npcStatsTemplate[entry][ROLE_STAT_VERSA];
        npcStats[guid][ROLE_STAT_WILL] = npcStatsTemplate[entry][ROLE_STAT_WILL];
        npcStats[guid][ROLE_STAT_SPIRIT] = npcStatsTemplate[entry][ROLE_STAT_SPIRIT];
        npcStats[guid][ROLE_STAT_HEALTH] = npcStatsTemplate[entry][ROLE_STAT_HEALTH];
        npcStats[guid][ROLE_STAT_ARMOR] = npcStatsTemplate[entry][ROLE_STAT_ARMOR];
    end
end

function loadAllCreatureTemplateRollStats()
    local creatureTemplateStatsQuery = WorldDBQuery('SELECT * FROM creature_template_role_stats where 1');
print(1);
    if creatureTemplateStatsQuery then
        local creatureTemplsteStatsCount = creatureTemplateStatsQuery:GetRowCount()
        print(2);
        for i = 1, creatureTemplsteStatsCount do
            print(3);
            local entry = creatureTemplateStatsQuery:GetString(0)

            if not npcStatsTemplate[entry] then
                npcStatsTemplate[entry] = {}
            end
            print(4);
            print(entry);
            npcStatsTemplate[entry][ROLE_STAT_STRENGTH] = creatureTemplateStatsQuery:GetString(1);
            npcStatsTemplate[entry][ROLE_STAT_AGLILITY] = creatureTemplateStatsQuery:GetString(2);
            npcStatsTemplate[entry][ROLE_STAT_INTELLECT] = creatureTemplateStatsQuery:GetString(3);
            npcStatsTemplate[entry][ROLE_STAT_STAMINA] = creatureTemplateStatsQuery:GetString(4);
            npcStatsTemplate[entry][ROLE_STAT_VERSA] = creatureTemplateStatsQuery:GetString(5);
            npcStatsTemplate[entry][ROLE_STAT_WILL] = creatureTemplateStatsQuery:GetString(6);
            npcStatsTemplate[entry][ROLE_STAT_SPIRIT] = creatureTemplateStatsQuery:GetString(7);
            npcStatsTemplate[entry][ROLE_STAT_HEALTH] = creatureTemplateStatsQuery:GetString(8);
            npcStatsTemplate[entry][ROLE_STAT_ARMOR] = creatureTemplateStatsQuery:GetString(9);
            print(5);
            -- Регаем ивенты на все заранее настроенные нпс
            RegisterCreatureEvent(entry, 22, loadDefaultCreatureStats)

            creatureTemplateStatsQuery:NextRow()
        end
    end
    creatureTemplateStatsQuery = nil;
end

function loadAllCreatureRollStats()
    local creatureStatsQuery = WorldDBQuery('SELECT * FROM creature_role_stats where 1');
    if creatureStatsQuery then
        local creatureStatsCount = creatureStatsQuery:GetRowCount()

        for i = 1, creatureStatsCount do
            local guid = creatureStatsQuery:GetString(0)

            if not npcStats[guid] then
                npcStats[guid] = {}
            end
            npcStats[guid][ROLE_STAT_STRENGTH] = creatureStatsQuery:GetString(1);
            npcStats[guid][ROLE_STAT_AGLILITY] = creatureStatsQuery:GetString(2);
            npcStats[guid][ROLE_STAT_INTELLECT] = creatureStatsQuery:GetString(3);
            npcStats[guid][ROLE_STAT_STAMINA] = creatureStatsQuery:GetString(4);
            npcStats[guid][ROLE_STAT_VERSA] = creatureStatsQuery:GetString(5);
            npcStats[guid][ROLE_STAT_WILL] = creatureStatsQuery:GetString(6);
            npcStats[guid][ROLE_STAT_SPIRIT] = creatureStatsQuery:GetString(7);
            npcStats[guid][ROLE_STAT_HEALTH] = creatureStatsQuery:GetString(8);
            npcStats[guid][ROLE_STAT_ARMOR] = creatureStatsQuery:GetString(9);

            creatureStatsQuery:NextRow()
        end
    end
    creatureStatsQuery = nil;
end

function setNpcStats(GM_target, stat, value)
    local guid = GM_target:GetDBTableGUIDLow();
    local guidLow = GM_target:GetGUIDLow();
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
            WorldDBQuery('INSERT INTO creature_role_stats (guid, STR, AGI, INTEL, VIT, DEX, WILL, SPI, HEALTH, ARMOR) VALUES (' .. guid ..',0,0,0,0,0,0,0,0,0)');
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

loadAllCreatureTemplateRollStats();
loadAllCreatureRollStats();
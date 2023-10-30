ItemForge = {} -- перековка предмеов

local forgeSpells = {
    [88087] = 1,
    [88088] = 1,
    [88089] = 1,
    [88090] = 1,
    [88091] = 1,
    [88092] = 1,
    [88093] = 1,
    [88094] = 1,
    [88095] = 1,
    [88096] = 1,
    [88097] = 1,
    [88098] = 1,
    [88099] = 1,
    [88100] = 1,
    [88101] = 1,
    [88102] = 1,
    [88103] = 1,
    [88104] = 1,
    [88105] = 1,
    [88106] = 1,
    [88107] = 1,
    [88108] = 1,
    [88109] = 1,
    [88110] = 1,
    [88111] = 1,
    [88112] = 1,
    }
local slot9 = 9
local slot10 = 10

local str1 = 4000
local agi1 = 4005
local int1 = 4010
local sta1 = 4015
local ver1 = 4020
local wil1 = 4025
local spi1 = 4030

local str2 = 4001
local agi2 = 4006
local int2 = 4011
local sta2 = 4016
local ver2 = 4021
local wil2 = 4026
local spi2 = 4031

local allStatsPlusOne = {str1,agi1,int1,sta1,ver1,wil1,spi1}
local allStatsPlusTwo = {str2,agi2,int2,sta2,ver2,wil2,spi2}
local allNum = 7

local allDefPlusOne = {sta1,ver1,wil1 }
local defNum = 3
local allAttackPlusOne = {str1,agi1,int1 }
local attackNum = 3

function ItemForge.CheckIsForgeSpell(spellID)
    if forgeSpells[spellID] ~= nil then
        return true
    end

    return false
end

function ItemForge.OnForge(event, player, spell)
    local item = spell:GetTarget();
    local spellId = spell:GetEntry();

    -- очищаем слоты статов
    item:ClearEnchantment(slot9)
    item:ClearEnchantment(slot10)

    if item == nil then return end

    if spellId == 88086 or spellId == 88094 then -- хаос 1 (рандомный стат +1 на плечи, грудь, шапку, ноги, перчи
        local chant = math.random(1,allNum)
        item:SetEnchantment(allStatsPlusOne[chant],slot9)
    elseif spellId == 88087 or spellId == 88095 then -- хаос 2 (рандомный стат +2 на плечи, грудь, шапку, ноги, перчи
        local chant = math.random(1,allNum)
        item:SetEnchantment(allStatsPlusOne[chant],slot9)
        chant = math.random(1,allNum)
        item:SetEnchantment(allStatsPlusOne[chant],slot10)

    elseif spellId == 88088 then -- атака 1 на плечи, грудь, шапку, ноги, перчи
        local chant = math.random(1,attackNum)
        item:SetEnchantment(allAttackPlusOne[chant],slot9)
    elseif spellId == 88089 then -- защита на плечи, грудь, шапку, ноги, перчи
        local chant = math.random(1,defNum)
        item:SetEnchantment(allDefPlusOne[chant],slot9)
    elseif spellId == 88090 then -- дух 1 на плечи, грудь, шапку, ноги, перчи
        item:SetEnchantment(spi1,slot9)

    elseif spellId == 88091 then -- атака +2 на плечи, грудь, шапку, ноги, перчи
        local chant = math.random(1,attackNum)
        item:SetEnchantment(allAttackPlusOne[chant],slot9)
        chant = math.random(1,attackNum)
        item:SetEnchantment(allAttackPlusOne[chant],slot10)
    elseif spellId == 88092 then -- защита +2 на плечи, грудь, шапку, ноги, перчи
        local chant = math.random(1,defNum)
        item:SetEnchantment(allDefPlusOne[chant],slot9)
        chant = math.random(1,defNum)
        item:SetEnchantment(allDefPlusOne[chant],slot10)
    elseif spellId == 88093 then -- дух 2 на плечи, грудь, шапку, ноги, перчи //here
        local variant = math.random(1,100)
        if variant < 6 then
            item:SetEnchantment(spi2,slot9)
            item:SetEnchantment(wil1,slot10)
        elseif variant < 11 then
            item:SetEnchantment(spi1,slot9)
            item:SetEnchantment(wil2,slot10)
        elseif variant < 41 then
            item:SetEnchantment(spi2,slot9)
        elseif variant < 71 then
            item:SetEnchantment(wil2,slot9)
        else
            item:SetEnchantment(spi1,slot9)
            item:SetEnchantment(wil1,slot10)
        end
    elseif spellId == 88096 then -- мощь
        local variant = math.random(1,100)
        if variant < 6 then
            item:SetEnchantment(str2,slot9)
            item:SetEnchantment(sta1,slot10)
        elseif variant < 11 then
            item:SetEnchantment(str1,slot9)
            item:SetEnchantment(sta2,slot10)
        elseif variant < 41 then
            item:SetEnchantment(str2,slot9)
        elseif variant < 71 then
            item:SetEnchantment(sta2,slot9)
        else
            item:SetEnchantment(str1,slot9)
            item:SetEnchantment(sta1,slot10)
        end
    elseif spellId == 88097 then -- проворство
        local variant = math.random(1,100)
        if variant < 6 then
            item:SetEnchantment(agi2,slot9)
            item:SetEnchantment(ver1,slot10)
        elseif variant < 11 then
            item:SetEnchantment(agi1,slot9)
            item:SetEnchantment(ver2,slot10)
        elseif variant < 41 then
            item:SetEnchantment(agi2,slot9)
        elseif variant < 71 then
            item:SetEnchantment(ver2,slot9)
        else
            item:SetEnchantment(agi1,slot9)
            item:SetEnchantment(ver1,slot10)
        end
    elseif spellId == 88098 then -- разум
        local variant = math.random(1,100)
        if variant < 6 then
            item:SetEnchantment(int2,slot9)
            item:SetEnchantment(wil1,slot10)
        elseif variant < 11 then
            item:SetEnchantment(int1,slot9)
            item:SetEnchantment(wil2,slot10)
        elseif variant < 41 then
            item:SetEnchantment(int2,slot9)
        elseif variant < 71 then
            item:SetEnchantment(wil2,slot9)
        else
            item:SetEnchantment(int1,slot9)
            item:SetEnchantment(wil1,slot10)
        end
    elseif spellId == 88099  then -- табарда, воля +1
        item:SetEnchantment(wil1,slot9)
    elseif spellId == 88100  then -- табарда, сноровка +1
        item:SetEnchantment(ver1,slot9)
    elseif spellId == 88101  then -- пояс, воля +1
        item:SetEnchantment(wil1,slot9)
    elseif spellId == 88102  then -- пояс, сноровка +1
        item:SetEnchantment(ver1,slot9)
    elseif spellId == 88103  then -- рубашка, воля +1
        item:SetEnchantment(wil1,slot9)
    elseif spellId == 88104  then -- рубашка, сноровка +1
        item:SetEnchantment(ver1,slot9)
    elseif spellId == 88105  then -- грудь и др +3
        item:SetEnchantment(str2,slot9)
        item:SetEnchantment(str1,slot10)
    elseif spellId == 88106  then -- грудь и др +3
        item:SetEnchantment(agi2,slot9)
        item:SetEnchantment(agi1,slot10)
    elseif spellId == 88107  then -- грудь и др +3
        item:SetEnchantment(int2,slot9)
        item:SetEnchantment(int1,slot10)
    elseif spellId == 88108  then -- грудь и др +3
        item:SetEnchantment(spi2,slot9)
        item:SetEnchantment(spi1,slot10)
    elseif spellId == 88109  then -- оружие +1
        item:SetEnchantment(str1,slot9)
    elseif spellId == 88110  then -- оружие +1
        item:SetEnchantment(agi1,slot9)
    elseif spellId == 88111  then -- оружие +1
        item:SetEnchantment(int1,slot9)
    elseif spellId == 88112  then -- оружие +1
        item:SetEnchantment(spi1,slot9)
    end
end
ItemForge = {} -- перековка предмеов

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

local allDefPlusOne = {sta1,ver1,wil1}
local allAttackPlusOne = {str1,agi1,int1}

function ItemForge.OnForge(event, player, spell)
    local item = spell:GetTarget();
    local spellId = spell:GetEntry();

    -- очищаем слоты статов
    item:ClearEnchantment(slot9)
    item:ClearEnchantment(slot10)

    if item == nil then return end

    if spellId == 88086 then -- хаос 1 (рандомный стат +1 на плечи, грудь, шапку, ноги, перчи
        local chant = math.random(1,allNum)
        item:SetEnchantment(allStatsPlusOne[chant],slot9)
    elseif spellId == 88087 then -- хаос 2 (рандомный стат +2 на плечи, грудь, шапку, ноги, перчи
        local chant = math.random(1,allNum)
        item:SetEnchantment(allStatsPlusTwo[chant],slot9)
    end
end
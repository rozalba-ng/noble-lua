--	NPC заменяющий зону Штормграда (Если есть в радиусе 25 ярдов)
local entry_npc = 1211001
--	NPC создающий зону с бонусом (Для общесерв ивентов)
local entry_bonus_npc = 1211002

local guildzone_stormwind_aura = 91065
local guildzone_boralus_aura = 91175

local quel_faction = 1165

venture_faction = 1168
ekspedition_faction = 1169
zulhetis_faction = 1170
brothers_faction = 1171
blacksun_faction = 1173
korus_faction = 1172
zlato_faction = 1174
theramore_faction = 1175
brando_faction = 1177
krasnogor_faction = 1179
horde_faction = 1166

reputation_friendly = 3000
reputation_honored = 9000
reputation_revered = 21000

local function countMoneyBonus(player)
    player:ModifyMoney(25);
    local guild = player:GetGuild();
    if (guild ~= nil) then
        player:ModifyMoney(-7);
        guild:DepositBankMoney(player, 12)
    end
end

local function countBoralusBonus(player)
    local zone = player:GetZoneId()
    if (player:HasAura(guildzone_boralus_aura) or zone == 8567 or zone == 8717) then
        local moneyItem = 600252

        if player:GetData("boralus_playtime_iterations") == 3 then
            --	Игрок отыграл 4 итерации, выдаем награду
            local added = player:AddItem(moneyItem);
            if (added == nil) then
                SendMail("Мешочек монет", "Мешочек монет не влез в ваши карманы и был выслан на почту.", player:GetGUIDLow(), 0, 61, 20, 0, 0, moneyItem, 1)
                player:SendBroadcastMessage("|cff629404[-X-] |cff8bad4cМешочек монет не влез в ваши карманы и был выслан на почту.")
            else
                player:SendBroadcastMessage("|cff629404[-X-] |cff8bad4cВы получаете мешочек монет за активную игру.")
            end
            player:PlayDirectSound(120, player)

            player:SetData("boralus_playtime_iterations", nil)
        elseif player:GetData("boralus_playtime_iterations") == nil then
            -- первая итерация (после сброса или только вошел)
            player:SetData("boralus_playtime_iterations", 1)
        else
            local num = player:GetData("boralus_playtime_iterations") + 1;
            player:SetData("boralus_playtime_iterations", num)
        end
    end
end

local function countStormwindReputation(player)
    local faction
    if player:GetQuestStatus(110052) == 6 then
        --	Игрок выполнил квест на вступление в Тени Штормграда
        faction = thiefs_faction
    elseif player:GetQuestStatus(110053) == 6 then
        --	Игрок выполнил квест на вступление в Королевство Штормград
        faction = law_faction
    end
    if faction then
        local zone, trueZone, r = player:GetZoneId(), false, 0
        if (zone == 1519) then
            --	Игрок в Штормграде
            r = 6
            trueZone = true
        elseif (zone == 10237 or player:HasAura(guildzone_stormwind_aura) or zone == 10236 or zone == 10235 or zone == 10199 or zone == 10234 or zone == 10214 or zone == 10197 or zone == 10160 or zone == 10179 or zone == 10232 or zone == 10233 or zone == 12) then
            --	Игрок играет на полигоне
            r = 4
            trueZone = true
        end
        if trueZone and ActionTime() then
            --	Если время суперактива - идёт маленький бонус.
            r = r + 3
        end

        --	Начисление репутации
        player:SetReputation(faction, player:GetReputation(faction) + r)
    end

    local faction2
    if player:GetQuestStatus(110210) == 6 then
        --	Игрок выполнил квест на Златоземье
        faction2 = zlato_faction
    end
    if faction2 then
        local zone, trueZone2, r2 = player:GetZoneId(), false, 0
        if (zone == 10179) then
            --	Игрок в Злато
            r2 = 10
            trueZone2 = true
        elseif (zone == 10237 or player:HasAura(guildzone_stormwind_aura) or zone == 1519 or zone == 10236 or zone == 10235 or zone == 10199 or zone == 10234 or zone == 10214 or zone == 10197 or zone == 10160 or zone == 10232 or zone == 10233 or zone == 12) then
            --	Игрок играет на полигоне
            r2 = 6
            trueZone2 = true
        end
        if trueZone2 and ActionTime() then
            --	Если время суперактива - идёт маленький бонус.
            r2 = r2 + 5
        end

        --	Начисление репутации
        player:SetReputation(faction2, player:GetReputation(faction2) + r2)
    end
end

local function countTheramoreReputation(player)
    local faction
    if player:GetQuestStatus(110236) == 6 then
        --	Игрок выполнил квест Таверна Терамора
        faction = theramore_faction
    end
    if faction then
        local zone, trueZone, r = player:GetZoneId(), false, 0
        if (zone == 10429 or zone == 15) then
            --	Игрок в Пылевых Топях
            r = 10
            trueZone = true
        elseif (false) then -- сюда потом дописать другие локации калимдора
            --	Игрок играет на полигоне
            r = 6
            trueZone = true
        end
        if trueZone and ActionTime() then
            --	Если время суперактива - идёт маленький бонус.
            r = r + 5
        end
		--
		--r = r * 0.75 -- УПАДОК!
		
        --	Начисление репутации
        player:SetReputation(faction, player:GetReputation(faction) + r)
    end
end

local function countZdReputation(player)
    local map, zone, trueZone, r = player:GetMapId(), player:GetZoneId(), false, 0
    if (zone == 10267) then
        --	Игрок в Корусе
        player:SetReputation(korus_faction, player:GetReputation(korus_faction) + 15)
    end

    local faction
    if player:GetQuestStatus(110133) == 6 then
        --	Игрок выполнил квест на вступление в Тени Штормграда
        faction = venture_faction
    elseif player:GetQuestStatus(110124) == 6 then
        --	Игрок выполнил квест на вступление в Королевство Штормград
        faction = ekspedition_faction
    elseif player:GetQuestStatus(110169) == 6 then
        --	Игрок выполнил квест на вступление в Королевство Штормград
        faction = zulhetis_faction
    elseif player:GetQuestStatus(110168) == 6 then
        --	Игрок выполнил квест на вступление в Королевство Штормград
        faction = brothers_faction
    elseif player:GetQuestStatus(110170) == 6 then
        --	Игрок выполнил квест на вступление в Королевство Штормград
        faction = blacksun_faction
    end

    if faction then
        local map, r = player:GetMapId(), 0
        if (map == 9006) then
            --	Игрок в Корусе
            r = 15
        end

        --	Начисление репутации
        player:SetReputation(faction, player:GetReputation(faction) + r)
    end
end

local function countQueltalasReputation(player)
    local faction
    if player:HasAura(100024) or player:HasAura(100025) then
        --	Игрок выполнил квест на выбор фракции луносвета
        faction = quel_faction
    end
    if faction then
        local map, x = player:GetMapId(), player:GetX()
        if (map == 901 and x > 3524) or player:HasAura(91198) then
            --	Игрок в Кельталасе
            player:SetReputation(faction, player:GetReputation(faction) + 25)
        end

    end
end

local function CountBrandoReputation(player)
    local map = player:GetMapId()
    local rep = 10
    if (map == 9010) then
        --	Игрок в Параисо
        if ActionTime() then
            --	Если время суперактива - идёт маленький бонус.
            rep = rep + 5
        end
        player:SetReputation(brando_faction, player:GetReputation(brando_faction) + rep)
    end
end

local function CountKrasnogorReputation(player)
    local map, zone = player:GetMapId(), player:GetZoneId()
    local rep = 10
    if (map == 901 and (zone == 10197 or zone == 44)) then
        --	Игрок в Красногорье
        if ActionTime() then
            --	Если время суперактива - идёт маленький бонус.
            rep = rep + 10
        end
        player:SetReputation(krasnogor_faction, player:GetReputation(krasnogor_faction) + rep)
    end
end

local function CountKrasnogorReputation(player)
    local map, zone = player:GetMapId(), player:GetZoneId()
    local rep = 10
    if (map == 901 and (zone == 3)) then
        --	Игрок в Бесплодных
        if ActionTime() then
            --	Если время суперактива - идёт маленький бонус.
            rep = rep + 10
        end
        player:SetReputation(horde_faction, player:GetReputation(horde_faction) + rep)
    end
end

--[[Every 15 minutes runs script of online bonuses for all players in world]]
local function calculateBonuses()
    local onlinePlayers = GetPlayersInWorld(2); --[[ 2-neutral, both horde and aliance]]
    for _, player in ipairs(onlinePlayers) do
        if (player:IsAFK() == false) then
            --	Добавление денег
            countMoneyBonus(player)
            --	Бонусы за онлайн
            if (player:GetPhaseMask() == 1) then
                countStormwindReputation(player)
                countBoralusBonus(player)
                countQueltalasReputation(player)
                countZdReputation(player)
                countTheramoreReputation(player)
                CountBrandoReputation(player)
                CountKrasnogorReputation(player)
            end
        end;
    end
end

CreateLuaEvent(calculateBonuses, 900000, 0) --
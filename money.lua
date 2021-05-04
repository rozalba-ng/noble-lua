--	NPC заменяющий зону Штормграда (Если есть в радиусе 25 ярдов)
local entry_npc = 1211001
--	NPC создающий зону с бонусом (Для общесерв ивентов)
local entry_bonus_npc = 1211002

local guildzone_stormwind_aura = 91065
local guildzone_boralus_aura = 91175

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
            local added = player:AddItem(money);
            if (added == nil) then
                SendMail("Мешочек монет", "Мешочек монет не влез в ваши карманы и был выслан на почту.", player:GetGUIDLow(), 0, 61, 20, 0, 0, money, 1)
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

        -- бонус за финал сюжета
        r = r * 3;

        --	Начисление репутации
        player:SetReputation(faction, player:GetReputation(faction) + r)
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
            if (SocialTime() and player:GetPhaseMask() == 1) then
                countStormwindReputation(player)
                countBoralusBonus(player)
            end
        end;
    end
end

CreateLuaEvent(calculateBonuses, 9000, 0)
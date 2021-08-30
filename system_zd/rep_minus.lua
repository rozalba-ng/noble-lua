local friendly_creatures = {987753 }
local korus_faction = 1172
local PLAYER_EVENT_ON_KILL_CREATURE = 7

local function onCreatureKill(event, player, killed)
    for i = 1, #friendly_creatures do
        if friendly_creatures[i] == killed:GetEntry() then
            player:SetReputation(korus_faction, player:GetReputation(korus_faction) - 100)
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFУбийство невинных привело к понижению репутации с Поротом Корус.")

            local Group = player:GetGroup()
            if Group == nil then
                return
            end

            local GroupMembers = Group:GetMembers()
            local RowGroup = #GroupMembers;
            for var=1,RowGroup,1 do
                if GroupMembers[var] ~= player then
                    GroupMembers[var]:SetReputation(korus_faction, GroupMembers[var]:GetReputation(korus_faction) - 100)
                    GroupMembers[var]:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFУбийство невинных привело к понижению репутации с Поротом Корус.")
                end
            end

            return
        end
    end
end

RegisterPlayerEvent(PLAYER_EVENT_ON_KILL_CREATURE, onCreatureKill)
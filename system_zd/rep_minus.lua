local friendly_creatures = {987753}

local function onCreatureKill(event, player, killed)
    for i = 1, #friendly_creatures do
        if friendly_creatures[i] == killed:GetEntry() then
            player:SetReputation(korus_faction, player:GetReputation(korus_faction) - 100)
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFУбийство невинных привело к понижению репутации с Поротом Корус.")

            local Group = player:GetGroup():GetMembers()
            local RowGroup = #Group;
            for var=1,RowGroup,1 do
                Group[var]:SetReputation(korus_faction, Group[var]:GetReputation(korus_faction) - 100)
                Group[var]:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFУбийство невинных привело к понижению репутации с Поротом Корус.")
            end

            return
        end
    end

end

RegisterPlayerEvent(PLAYER_EVENT_ON_KILL_CREATURE, onCreatureKill)
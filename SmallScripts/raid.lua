local function OnMakeRaidCommand(player)
    local group = player:GetGroup()
    if not group then
        player:Print("Вы не состоите в группе.")
        return false
    end

    if group:IsRaidGroup() then
        player:Print("Вы уже находитесь в рейде.")
        return false
    end

    if not group:IsLeader( player:GetGUIDLow()) then
        player:Print("Вы не лидер группы.")
        return false
    end

    group:ConvertToRaid()

    if group:IsRaidGroup() then
        player:Print("Рейд успешно создан.")
    else
        player:Print("Не удалось создать рейд.")
    end
    return false

end
RegisterCommand("makeraid", OnMakeRaidCommand)
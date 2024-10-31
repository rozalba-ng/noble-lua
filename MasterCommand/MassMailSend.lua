local function GetGUIDsByNames(playerList)
    -- Prepare player names for SQL IN clause
    local nameList = {}
    for _, playerName in ipairs(playerList) do
        table.insert(nameList, "'" .. playerName .. "'")
    end
    local namesString = table.concat(nameList, ",")

    -- Query all players' GUIDs in a single query using the IN clause
    local query = "SELECT name, guid FROM characters WHERE name IN (" .. namesString .. ")"
    local result = CharDBQuery(query)

    -- Create a table to store the result
    local guidList = {}

    if result then
        repeat
            local name = result:GetString(0) -- Name of the player
            local guid = result:GetUInt32(1) -- GUID of the player
            guidList[name] = guid -- Store GUID by player name
        until not result:NextRow()
    end

    return guidList
end

local function OnMassMailSendCommand(player,playerNames,itemID)
    if player:GetGMRank() < 2 then
        player:Print("Недостаточный ГМ уровень.")
        return
    end
    -- Extract parameters: player names and item ID
    if not playerNames or not itemID then
        player:Print("Usage: .massmailsend player1,player2,player3 item_id")
        return
    end

    -- Split player names by comma
    local playerList = string.split(playerNames, ",")

    -- Convert itemID to a number
    itemID = tonumber(itemID)

    -- Mail Subject and Body (can be customized)
    local subject = "Награда за ивент"
    local body = "Приятной игры"

    local guidList = GetGUIDsByNames(playerList)
    for _, playerName in ipairs(playerList) do
        local guid = guidList[playerName]
        if guid then
            -- Send mail with the item to the player
            SendMail(subject, body, guid, 0, 61, 0, 0, 0, itemID, 1)
            player:Print("Mail sent to " .. playerName)
        else
            player:Print("Player " .. playerName .. " not found in the database.")
        end
    end
    return false
end

RegisterCommand("massmailsend",OnMassMailSendCommand)
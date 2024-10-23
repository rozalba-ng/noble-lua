local AIO = AIO or require("AIO")

local GoMover = AIO.AddHandlers("GOM_Handlers", {})

playersCooldowns = {}

function copysign(value, valuetocopy)
    return value * (valuetocopy / math.abs(valuetocopy))
end


function FromQuatToEuler(x, y, z, w)

    local sinr_cosp = 2 * (w * x + y * z);
    local cosr_cosp = 1 - 2 * (x * x + y * y);
    local roll = math.atan2(sinr_cosp, cosr_cosp);
    local sinp = 2 * (w * y - z * x);
    local pitch = 0
    if (math.abs(sinp) >= 1) then
        pitch = copysign(math.pi() / 2, sinp)
    else
        pitch = math.asin(sinp);
    end
    local siny_cosp = 2 * (w * z + x * y);
    local cosy_cosp = 1 - 2 * (y * y + z * z);
    local yaw = math.atan2(siny_cosp, cosy_cosp);
    return yaw, pitch, roll
end

function GoMover.StartRotate(player, guid, value, rotateType)
    if (not playersCooldowns[player:GetName()] or (os.time() - playersCooldowns[player:GetName()]) > 0.3) then
        playersCooldowns[player:GetName()] = os.time()
        q = WorldDBQuery('SELECT rotation0, rotation1,rotation2,rotation3 FROM gameobject WHERE guid =' .. guid)
        local x, y, z = FromQuatToEuler(q:GetFloat(0), q:GetFloat(1), q:GetFloat(2), q:GetFloat(3))
        AIO.Handle(player, "GOM_Handlers", "RotateGo", rotateType, x, y, z, value)
    end
end

function GoMover.StartMove(player, guid, value, moveType)
    if (not playersCooldowns[player:GetName()] or (os.time() - playersCooldowns[player:GetName()]) > 0.3) then
        playersCooldowns[player:GetName()] = os.time()
        q = WorldDBQuery('SELECT position_x, position_y,position_z,orientation FROM gameobject WHERE guid =' .. guid)
        local x, y, z, o = q:GetFloat(0), q:GetFloat(1), q:GetFloat(2), q:GetFloat(3)
        local po = player:GetO()
        AIO.Handle(player, "GOM_Handlers", "MoveGo", moveType, x, y, z, po, value)
    end
end

function GoMover.StartScale(player, guid, value, scaleType)
    if (not playersCooldowns[player:GetName()] or (os.time() - playersCooldowns[player:GetName()]) > 0.3) then
        playersCooldowns[player:GetName()] = os.time()
        AIO.Handle(player, "GOM_Handlers", "ScaleGo", scaleType, value)
    end
end

function GoMover.ReturnToInventory(player, guid)
    player:SendBroadcastMessage("Для того чтобы забрать объект воспользуйтесь кнопкой в главном меню режима строительства")
end

function GOM_OpenEditAddon(player, gob)
    AIO.Handle(player, "GOM_Handlers", "SetName", gob:GetName())
    AIO.Handle(player, "GOM_Handlers", "GetGUID", gob:GetDBTableGUIDLow())
end

local function GatherGosByRadius(player, radius)
    if radius <= 10 then
        local gos = player:GetGameObjectsInRange(tonumber(radius))
        if (player:GetGMRank() == 2 or player:GetGMRank() == 1) then
            player:Print("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFДоступ запрещен для вашего типа аккаунта.|r")
            return false
        end
        for i, gob in pairs(gos) do
            if gob:GetOwner() == player and gob:GetPhaseMask() ~= 1024 then
                local map = player:GetMap()
                local entry = gob:GetEntry()
                local item = player:AddItem(entry)
                if (item == nil) then
                    player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНет места.|r")
                    return false
                end
                gob:RemoveFromWorld(true)
            end
        end
    else
        player:Print("Некорректно задан радиус сбора игровых объектов")
    end
end

local function ReturnGosByRadius(player, radius)
    if radius <= 10 then
        local gos = player:GetGameObjectsInRange(tonumber(radius))
        if not (player:GetGMRank() > 1 or player:GetDmLevel() == 5) then
            player:Print("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFДоступ запрещен для вашего типа аккаунта.|r")
            return false
        end

        local ownerIDs = {}
        for i, gob in pairs(gos) do
            local ownerIdObj = gob:GetOwnerId()
            local ownerId = tostring(ownerIdObj)
            if gob:GetPhaseMask() == 1 and ownerId ~= 0 then
                table.insert(ownerIDs, tostring(ownerId))
            end
        end
        if #ownerIDs == 0 then
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНет объектов, которые можно вернуть пользователям.|r")
            return
        end
        local owners = table.concat(ownerIDs, ", ")
        local ownersList = {}
        local Q = CharDBQuery("SELECT c.guid FROM characters.characters c WHERE c.guid in (" .. owners .. ") and c.account not in (select a.id from auth.account_access a where 1)")
        if Q then
            for i = 1, Q:GetRowCount() do
                local c_guid = Q:GetUInt32(0)
                local str_c_guid = tostring(c_guid)
                ownersList[str_c_guid] = str_c_guid
                Q:NextRow()
            end
        else
            player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНет объектов, которые можно вернуть пользователям.|r")
            return
        end

        for i, gob in pairs(gos) do
            local ownerIdObj = gob:GetOwnerId()
            local ownerId = tostring(ownerIdObj)
            local ownerIdNum = tonumber(ownerId)

            if gob:GetPhaseMask() == 1 and ownersList[ownerId] ~= nil then
                local entry = gob:GetEntry()
                if entry >495000 and entry < 509999 then
                    local itemGUIDlow = SendMail("Возврат", "Возврат имущества", ownerIdNum, 0, 61, 0, 0, 0, entry, 1)
                    player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОтправлен объект " .. entry .. " пользователю " .. ownerIdNum .. ".|r")
                else
                    player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFОбъект " .. entry .. " удален из мира.|r")
                end

                gob:RemoveFromWorld(true)
            end
        end
    else
        player:Print("Некорректно задан радиус сбора игровых объектов")
    end
end

local function GetGameObjectByGUIDLow(player, guidLow)
    -- Query the world database to get the entry ID for the game object with the specified GUID
    local query = WorldDBQuery("SELECT id FROM gameobject WHERE guid = " .. guidLow)
    if query then
        local entry = query:GetUInt32(0)
        local mapID = player:GetMapId()
        local instanceID = player:GetInstanceId()

        local go = GetGameObject(guidLow, entry, mapID, instanceID)
        return go
    else
        return nil
    end
end

local function GetLastGameObjectAddedByPlayer(player)
    local playerGUID = player:GetGUIDLow()

    -- Query the world database to get the last game object added by the player
    local query = WorldDBQuery("SELECT guid, id FROM gameobject WHERE owner_id = " .. playerGUID .. " ORDER BY spawn_time DESC LIMIT 1")
    if query then
        local guidLow = query:GetUInt32(0)
        local entry = query:GetUInt32(1)
        local mapID = player:GetMapId()
        local instanceID = player:GetInstanceId()

        local go = GetGameObject(guidLow, entry, mapID, instanceID)
        return go
    else
        return nil
    end
end


local function OnPlayerCommandWithArg(event, player, code)
    local args = {}
    for word in string.gmatch(code, "%S+") do
        table.insert(args, word)
    end

    local command = args[1]
    if (command == "movego") then
        local nearestGo = player:GetNearestGameObject(10)
        if nearestGo then
            if (nearestGo:GetOwner() == player) or player:GetGMRank() > 0 then
                AIO.Handle(player, "GOM_Handlers", "SetName", nearestGo:GetName())
                AIO.Handle(player, "GOM_Handlers", "GetGUID", nearestGo:GetDBTableGUIDLow())
            else
                player:SendBroadcastMessage("Рядом стоящий объект вам не принадлежит")
            end
        else
            player:SendBroadcastMessage("Объектов в радиусе не было обнаружено")
        end
    elseif command == "movegoid" then
        local guidLow = tonumber(args[2])
        if guidLow then
            local go = GetGameObjectByGUIDLow(player, guidLow)
            if go then
                if (go:GetOwner() == player) or player:GetGMRank() > 0 then
                    AIO.Handle(player, "GOM_Handlers", "SetName", go:GetName())
                    AIO.Handle(player, "GOM_Handlers", "GetGUID", go:GetDBTableGUIDLow())
                else
                    player:SendBroadcastMessage("Этот объект вам не принадлежит")
                end
            else
                player:SendBroadcastMessage("Объект с указанным ID не найден")
            end
        else
            player:SendBroadcastMessage("Неверный ID объекта")
        end
    elseif command == "movegolast" then
        local go = GetLastGameObjectAddedByPlayer(player)
        if go then
            if (go:GetOwner() == player) or player:GetGMRank() > 0 then
                AIO.Handle(player, "GOM_Handlers", "SetName", go:GetName())
                AIO.Handle(player, "GOM_Handlers", "GetGUID", go:GetDBTableGUIDLow())
            else
                player:SendBroadcastMessage("Этот объект вам не принадлежит")
            end
        else
            player:SendBroadcastMessage("Вы не добавляли объекты или объект не найден")
        end
    elseif (command == "gathergos") then
        GatherGosByRadius(player, 5)
    elseif (command == "returngos") then
        ReturnGosByRadius(player, 5)
    end
end

RegisterPlayerEvent(42, OnPlayerCommandWithArg)
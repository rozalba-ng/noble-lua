local ELUNA_EVENT_ON_LUA_STATE_CLOSE = 16;

local function OnServerRestart(event)
    local players = GetPlayersInWorld();
    for ind, member in pairs(players) do
        member:ExitVehicle();
    end
end

RegisterServerEvent(ELUNA_EVENT_ON_LUA_STATE_CLOSE, OnServerRestart)
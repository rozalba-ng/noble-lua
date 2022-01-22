--
-- Created by IntelliJ IDEA.
-- User: Саша
-- Date: 11.01.2022
-- Time: 10:11
-- To change this template use File | Settings | File Templates.
--

local function ReloadAllNPCDatabases()
    ReloadAllNPC()
    --[[local players = GetPlayersInWorld()
    for i = 1, #players do
        if players[i]:GetGMRank() > 0 or players[i]:GetDmLevel() >= 1 then
            players[i]:SendBroadcastMessage("Перезагрузка баз npc. Инициирована системой.")
        end
    end]]
end

CreateLuaEvent(ReloadAllNPCDatabases, 300000, 0)
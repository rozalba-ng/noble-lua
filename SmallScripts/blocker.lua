
local serverReboots = false

function ServerReboot(event, code, mask)
    if event == 11 then
        if code == 2 then -- Если это рестарт
            serverReboots = true
        end
    end
    if event == 12 then -- Отмена перезагрузки
        serverReboots = false
    end
end

function PlayerTryingBuild(event, player, item, target)
    if serverReboots then
        player:SendBroadcastMessage("Во избежание ошибок функционал строительства ограничен до завершения перезагрузки сервера. Благодарим за понимание.")
        return false;
    end
end


local function LockUseOnRebootSpells()
	local q = WorldDBQuery("SELECT entry FROM item_template WHERE entry > 500000 and entry < 600000")
	
	for i = 1, q:GetRowCount() do
		local entry = q:GetInt32(0)
		RegisterItemEvent(entry,2,PlayerTryingBuild)
		q:NextRow()
	end
end
LockUseOnRebootSpells()

RegisterServerEvent( 11, ServerReboot )
RegisterServerEvent( 12, ServerReboot ) -- Когда перезагрузка отменена.
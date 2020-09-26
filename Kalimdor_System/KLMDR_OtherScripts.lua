
local ARENA_RADIUS = 300
local KALIMDOR_MID = 2105
local WARSONG_MID = 489
local function OnKalimdorItemUse(event, player, item, target)
	if player:GetMapId() ~= KALIMDOR_MID and player:GetMapId() ~= WARSONG_MID then
		player:SendBroadcastMessage("Для использования "..item:GetItemLink().." необходимо находиться на территории Калимдора.")
		if player:GetGMRank() > 1 then
			player:SendBroadcastMessage("!Использование предмета разрешено ГМ 2 +")
		else
			return false
		end
	end

end

local function LockKalimdorSpells()
	local q = WorldDBQuery("SELECT entry FROM item_template WHERE entry > 1110000 and entry < 1120000")
	
	for i = 1, q:GetRowCount() do
		local entry = q:GetInt32(0)
		RegisterItemEvent(entry,2,OnKalimdorItemUse)
		q:NextRow()
	end
end
LockKalimdorSpells()





--	ID ауры скрывающей текущую роль игрока:
local aura = {
	class = {
		91055, -- Дворянин
		91056, -- Духовенство
		91057, -- Магократия
		91058, -- Вольный житель
	},
	camouflage = 91062,
}
local entry_item = 123

--[[	НАВЕШИВАНИЕ АУРЫ АНОНИМНОСТИ	]]--

local function WhenItemUsed( event, player, item )
	if player:HasItem( entry_item, 1 ) then
		local nearestPlayers = player:GetPlayersInRange( 30 )
		if nearestPlayers then
			if player:IsInGroup() then
			--	Игрок в группе, нужно проверить всех ближайших игроков на вхождение в эту группу.
				for i = 1, #nearestPlayers do
					if not player:IsInSameGroupWith( nearestPlayers[i] ) then
						player:SendNotification("Неподалёку от вас есть игроки.")
						return false
					end
				end
			else
				player:SendNotification("Неподалёку от вас есть игроки.")
				return false
			end
		end
		for i = 1, #aura.class do
			if player:HasAura( aura.class[i] ) then
			--	Определена классовая принадлежность игрока.
				player:RemoveAura( aura.class[i] )
				player:AddAura( aura.camouflage, player )
				player:RemoveItem( entry_item, 1 )
				return true
			end
		end
	end
end
RegisterItemEvent( entry_item, 2, WhenItemUsed ) -- ITEM_EVENT_ON_USE

--[[	СНЯТИЕ АУРЫ ИГРОКОМ ИЛИ СЕРВЕРОМ	]]--

local function AuraCancelled( event, packet, player )
	-- Nothing
end
RegisterPacketEvent( 0x496, 7, AuraCancelled ) -- PACKET_EVENT_ON_PACKET_SEND, 0x496 - SMSG_AURA_UPDATE
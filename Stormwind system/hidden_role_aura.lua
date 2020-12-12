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
local entry_item = 600106

--[[	НАВЕШИВАНИЕ АУРЫ АНОНИМНОСТИ	]]--

local function WhenItemUsed( _, player, item )
	if player:HasItem( entry_item, 1 ) then
		local nearestPlayers = player:GetPlayersInRange( 30 )
		if nearestPlayers then
			for i = 1, #nearestPlayers do
				if nearestPlayers[i] ~= player then
					if not player:IsInGroup() or not player:IsInSameGroupWith(nearestPlayers[i]) then
						player:SendNotification("Неподалёку от вас есть игроки.")
						return false
					end
				end
			end
		end
		for i = 1, #aura.class do
			if player:HasAura( aura.class[i] ) then
			--	Определена классовая принадлежность игрока.
				player:RemoveAura( aura.class[i] )
				player:AddAura( aura.camouflage, player )
				player:SetData( "Camouflage", true )
				player:RemoveItem( entry_item, 1 )
				return true
			end
		end
	end
end
RegisterItemEvent( entry_item, 2, WhenItemUsed ) -- ITEM_EVENT_ON_USE

local function WhenPlayerEnterGame( _, player )
	if player:HasAura( aura.camouflage ) then
		player:SetData( "Camouflage", true )
	end
end
RegisterPlayerEvent( 3, WhenPlayerEnterGame )

--[[	СНЯТИЕ АУРЫ ИГРОКОМ ИЛИ СЕРВЕРОМ	]]--

local function AuraCancelled( _, packet, player )
	if player:GetData("Camouflage") and not player:HasAura( aura.camouflage ) then
		player:SetData( "Camouflage", nil )
		local Q = CharDBQuery( "SELECT city_class FROM character_citycraft_config WHERE character_guid = "..player:GetGUIDLow() )
		if Q then
			local aura = Q:GetUInt32(0)
			player:AddAura( aura, player )
		else player:SendBroadcastMessage("Произошла ошибка и вы не смогли получить ауру своей социальной роли. Сделайте скриншот этого сообщения, пожалуйста, и свяжитесь с администрацией.") end
	end
end
RegisterPacketEvent( 0x496, 7, AuraCancelled ) -- PACKET_EVENT_ON_PACKET_SEND, 0x496 - SMSG_AURA_UPDATE
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
local auraCityRoles = {
	91103,
	91104,
	91105,
	91106,
	91107,
	91108,
	91109,
	91110,
	91111,
	91112,
	91113,
	91114,
	91115,
	91116,
	91117,
	91118,
	91119,
	91120,
	91121,
	91122,
	91123,
	91124,
	91125,
	91126,
	91127,
	91128,
	91129,
	91130,
	91131,
	91132,
	91133,
	91134,
	91135,
	91136,
	91137,
	91138,
	91139,
	91140,
	91141,
	91142,
	91143,
	91144,
	91145,
	91146,
	91147,
	91148,
	91149,
	91150,
	91151,
	91152,
	91153
}

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
				player:PlayDirectSound( 3781, player )
				return true
			end
		end
	end
end
RegisterItemEvent( entry_item, 2, WhenItemUsed ) -- ITEM_EVENT_ON_USE

local function WhenPlayerEnterGame( _, player )
	player:RemoveAura( 91070 )
	player:RemoveAura( 91069 )
	player:RemoveAura( 91068 )
	player:RemoveAura( 91067 )
	if ((player:GetReputation( law_faction ) >= amount_reputation_exalted) or (player:GetReputation( thiefs_faction ) >= amount_reputation_exalted)) then
		player:AddAura( 91070, player )
	elseif ((player:GetReputation( law_faction ) >= amount_reputation_revered) or (player:GetReputation( thiefs_faction ) >= amount_reputation_revered)) then
		player:AddAura( 91069, player )
	elseif ((player:GetReputation( law_faction ) >= amount_reputation_honored) or (player:GetReputation( thiefs_faction ) >= amount_reputation_honored)) then
		player:AddAura( 91068, player )
	elseif ((player:GetReputation( law_faction ) >= amount_reputation_friendly) or (player:GetReputation( thiefs_faction ) >= amount_reputation_friendly)) then
		player:AddAura( 91067, player )
	end

	if player:HasAura( aura.camouflage ) then
		player:SetData( "Camouflage", true )
	else
		local Q = CharDBQuery( "SELECT city_class FROM character_citycraft_config WHERE character_guid = "..player:GetGUIDLow() )
		if Q then
			local aura = Q:GetUInt32(0)
			if not player:HasAura( aura ) then
				player:AddAura( aura, player )
			end
		end
	end

	for _, roleAura in ipairs(auraCityRoles) do
		player:RemoveAura( roleAura )
	end
	local SRQ = CharDBQuery( "SELECT spell_id FROM citycraft_roles WHERE current_owner_char_name = '"..player:GetName() .. "'")
	if SRQ then
		local playerCityRoleAura = SRQ:GetUInt32(0)
		if not player:HasAura( playerCityRoleAura ) and playerCityRoleAura > 0 then
			player:AddAura( playerCityRoleAura, player )
		end
	end
end
RegisterPlayerEvent( 3, WhenPlayerEnterGame )

--[[	СНЯТИЕ АУРЫ ИГРОКОМ ИЛИ СЕРВЕРОМ	]]--

--local function AuraCancelled( _, packet, player )
--	if player:GetData("Camouflage") and not player:HasAura( aura.camouflage ) then
--		player:SetData( "Camouflage", nil )
--		local Q = CharDBQuery( "SELECT city_class FROM character_citycraft_config WHERE character_guid = "..player:GetGUIDLow() )
--		if Q then
--			local aura = Q:GetUInt32(0)
--			player:AddAura( aura, player )
--			player:PlayDirectSound( 3780, player )
--		else player:SendBroadcastMessage("Произошла ошибка и вы не смогли получить ауру своей социальной роли. Сделайте скриншот этого сообщения, пожалуйста, и свяжитесь с администрацией.") end
--	end
--end
--RegisterPacketEvent( 0x496, 7, AuraCancelled ) -- PACKET_EVENT_ON_PACKET_SEND, 0x496 - SMSG_AURA_UPDATE
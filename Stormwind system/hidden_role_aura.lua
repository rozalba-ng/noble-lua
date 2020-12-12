--	ID ауры скрывающей текущую роль игрока:
local entry_aura = 91062
--	Когда аура 
local function AuraCancelled( event, packet, player )
	if player then player:SendBroadcastMessage("123") end
end
-- Когда сервер обновил ауру
--RegisterPacketEvent( 0x496, 5, AuraCancelled ) -- PACKET_EVENT_ON_PACKET_RECEIVE, 0x136 - SMSG_AURA_UPDATE -- ВЕРОЯТНО НЕ НУЖНО
RegisterPacketEvent( 0x496, 7, AuraCancelled ) -- PACKET_EVENT_ON_PACKET_SEND, 0x136 - SMSG_AURA_UPDATE
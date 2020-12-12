--	ID ауры скрывающей текущую роль игрока:
local entry_aura = 91062
--	Когда аура 
local function AuraCancelled( event, packet, player )
	print("== NEW PACKET ==")
	print(event)
	print( packet:GetOpcode() )
	print("== END ==")
end
-- Когда игрок отменил себе ауру
RegisterPacketEvent( 0x136, 5, AuraCancelled ) -- PACKET_EVENT_ON_PACKET_RECEIVE, 0x136 - CMSG_CANCEL_AURA
RegisterPacketEvent( 0x136, 7, AuraCancelled ) -- PACKET_EVENT_ON_PACKET_SEND, 0x136 - CMSG_CANCEL_AURA -- ВЕРОЯТНО НЕ НУЖНО
-- Когда сервер обновил ауру
RegisterPacketEvent( 0x496, 5, AuraCancelled ) -- PACKET_EVENT_ON_PACKET_RECEIVE, 0x136 - SMSG_AURA_UPDATE -- ВЕРОЯТНО НЕ НУЖНО
RegisterPacketEvent( 0x496, 7, AuraCancelled ) -- PACKET_EVENT_ON_PACKET_SEND, 0x136 - SMSG_AURA_UPDATE
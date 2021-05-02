
local function OnPlayerChangeMap( event, player )
	if ( player:GetMapId() == 13 ) then
		player:SetSpeed( 1, 2 ) -- MOVE_RUN, 2x
	end
end
RegisterPlayerEvent( 28, OnPlayerChangeMap ) -- PLAYER_EVENT_ON_MAP_CHANGE
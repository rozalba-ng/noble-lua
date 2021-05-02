
local function OnPlayerChangeMap( event, player )
	if ( player:GetMapId() == 13 ) then
		player:SetSpeed( 1, 3 )
	elseif ( player:GetData("LastMapID") and player:GetData("LastMapID") == 13 ) then
		player:SetSpeed( 1, 1 )
	end
	player:SetData( "LastMapID", player:GetMapId() )
end
RegisterPlayerEvent( 28, OnPlayerChangeMap ) -- PLAYER_EVENT_ON_MAP_CHANGE

local event = {
	entry = {
		item = 5057535,
		creature = 1001148,
	},
}

--[[	ЗАПУСК ФОНАРИКОВ	]]--

function event.FlyingLamp( _,_,_, creature )
	creature:SetScale( creature:GetScale()+0.1 )
	local x,y,z = creature:GetLocation()
	creature:MoveJump( x+math.random(-4,4), y+math.random(-4,4), z+math.random(1,2), 0.2, 3 )
end

function event.OnSpawnLamp( _,_,_, creature )
	local x,y,z = creature:GetLocation()
	creature:MoveJump( x, y, z+4, 0.4, 1 )
	creature:RegisterEvent( event.FlyingLamp, 15000, 26 )
end

function event.OnUseLamp( _, player, item, target )
	player:CastSpell( player, 44940, true )
	local x,y,z,o = player:GetLocation()
	local creature
	creature = player:SpawnCreature( event.entry.creature, x+math.random(-1,1), y+math.random(-1,1), z+1.2, o, 3, 420000 ) -- TEMPSUMMON_TIMED_DESPAWN
	creature:RegisterEvent( event.OnSpawnLamp, 3000, 1 )
	creature:SetDisableGravity(true)
	local guid = player:GetGUIDLow()
	creature:SetOwnerGUID( guid )
	creature:SetCreatorGUID( guid )
	player:RemoveItem( item, 1 )
	player:PlayDirectSound( 12901, player )
	return true
end
RegisterItemEvent( event.entry.item, 2, event.OnUseLamp ) -- ITEM_EVENT_ON_USE
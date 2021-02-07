
local event = {
	playersCanUseLamps = false,
	entry = {
		item = 5057489,
		creature = 9931054,
		fireworks = {
			11542,
			11543,
			11544,
			55420,
		}
	}
}

function event.FlyingLamp( _,_,_, creature )
	if math.random(1,4) == 1 then -- 25% шанс
		creature:CastSpell( creature, ( event.entry.fireworks[math.random(1,#fireworks)] ), true )
	end
	local x,y,z = creature:GetLocation()
	creature:MoveJump( x+math.random(-4,4), y+math.random(-4,4), z+math.random(1,2), 0.2, 3 )
end

function event.OnSpawnLamp( _,_,_, creature )
	local x,y,z = creature:GetLocation()
	creature:MoveJump( x, y, z+4, 0.4, 1 )
	creature:RegisterEvent( event.FlyingLamp, 15000, 26 )
end

function event.OnUseLamp( _, player, item, target )
	if event.playersCanUseLamps then
		if player:GetZoneId() == 1519 then
			player:CastSpell( player, 6245, true )
			local x,y,z,o = player:GetLocation()
			local creature = player:SpawnCreature( event.entry.creature, x+math.random(-1,1), y+math.random(-1,1), z+1.2, o, 3, 420000 ) -- TEMPSUMMON_TIMED_DESPAWN
			creature:RegisterEvent( event.OnSpawnLamp, 3000, 1 )
			creature:SetDisableGravity(true)
			local guid = player:GetGUIDLow()
			creature:SetOwnerGUID( guid )
			creature:SetCreatorGUID( guid )
			player:RemoveItem( item, 1 )
			return true
		else
			player:SendNotification("Вы должны использовать это в Штормграде.")
		end
	else
		player:SendNotification("Вы не можете использовать это сейчас.")
	end
	return false
end
RegisterItemEvent( event.entry.item, 2, event.OnUseLamp ) -- ITEM_EVENT_ON_USE
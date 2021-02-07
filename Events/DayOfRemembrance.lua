
local event = {
	playersCanUseLamps = false,
	entry = {
		item = 5057489,
		item2 = 5057520,
		creature = 9931054,
		creature2 = 9931060,
		fireworks = {
			11542,
			11543,
			11544,
			55420,
		}
	}
}

function event.FlyingLamp( _,_,_, creature )
	if ( creature:GetEntry() == event.entry.creature2 ) then -- Красный, дорогой
		if math.random(1,2) == 1 then -- 50% шанс
			creature:CastSpell( creature, ( event.entry.fireworks[math.random(1,#event.entry.fireworks)] ), true )
		end
	else -- Синий, обычный
		if math.random(1,4) == 1 then -- 25% шанс
			creature:CastSpell( creature, ( event.entry.fireworks[math.random(1,#event.entry.fireworks)] ), true )
		end
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
	if ( event.playersCanUseLamps ) or ( item:GetEntry() == event.entry.item2 ) then
		if ( player:GetZoneId() == 1519 ) or ( item:GetEntry() == event.entry.item2 ) then
			player:CastSpell( player, 6245, true )
			local x,y,z,o = player:GetLocation()
			local creature
			if ( item:GetEntry() == event.entry.item2 ) then
				creature = player:SpawnCreature( event.entry.creature2, x+math.random(-1,1), y+math.random(-1,1), z+1.2, o, 3, 420000 ) -- TEMPSUMMON_TIMED_DESPAWN
			else
				creature = player:SpawnCreature( event.entry.creature, x+math.random(-1,1), y+math.random(-1,1), z+1.2, o, 3, 420000 ) -- TEMPSUMMON_TIMED_DESPAWN
			end
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
RegisterItemEvent( event.entry.item2, 2, event.OnUseLamp ) -- ITEM_EVENT_ON_USE

--[[	КОМАНДА ДЛЯ РАЗРЕШЕНИЯ ФОНАРИКОВ	]]--

function event.GMCommand( _, player, command )
	if player:GetGMRank() > 0 then
		if command == "lamp" then
			if event.playersCanUseLamps then
				player:SendBroadcastMessage("В данный момент игроки могут запустить фонарики.\nИспользуй .lamp off")
			else
				player:SendBroadcastMessage("В данный момент игроки не могут запустить фонарики.\nИспользуй .lamp on")
			end
		elseif string.find( command, " " ) then
			command = string.split( command, " " )
			if command[1] == "lamp" then
				if command[2] == "on" then
					event.playersCanUseLamps = true
					player:SendBroadcastMessage("Фонарики включены.")
				elseif command[2] == "off" then
					event.playersCanUseLamps = false
					player:SendBroadcastMessage("Фонарики выключены.")
				end
			end
		end
	end
end
RegisterPlayerEvent( 42, event.GMCommand ) -- PLAYER_EVENT_ON_COMMAND

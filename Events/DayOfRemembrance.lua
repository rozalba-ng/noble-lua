--[[	Рабочий фрагмент кода деактивирован до следующих ивентов.
local event = {
	playersCanUseLamps = false,
	entry = {
		item = 5057489,
		item2 = 5057520,
		creature = 9931054,
		creature2 = 9931060,
		gameobject = 5049822,
		fireworks = {
			11542,
			11543,
			11544,
			55420,
		},
		auras = {
			91098, -- Малое подношение
			91099, -- Щедрое подношение
			91100, -- Меценат
		}
	}
}
]]
local event = {
	entry = {
		item2 = 5057520,
		creature2 = 9931060,
		fireworks = {
			11542,
			11543,
			11544,
			55420,
		},
	},
}

--[[	ЗАПУСК ФОНАРИКОВ	]]--

function event.FlyingLamp( _,_,_, creature )
	if ( creature:GetEntry() == event.entry.creature2 ) then -- Красный, дорогой
		if math.random(1,2) == 1 then -- 50% шанс
			creature:CastSpell( creature, ( event.entry.fireworks[math.random(1,#event.entry.fireworks)] ), true )
		end
--[[	Рабочий фрагмент кода деактивирован до следующих ивентов.
	else -- Синий, обычный
		if math.random(1,4) == 1 then -- 25% шанс
			creature:CastSpell( creature, ( event.entry.fireworks[math.random(1,#event.entry.fireworks)] ), true )
		end
]]
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
--	if ( event.playersCanUseLamps ) or ( item:GetEntry() == event.entry.item2 ) then
	--	if ( player:GetZoneId() == 1519 ) or ( item:GetEntry() == event.entry.item2 ) then
			player:CastSpell( player, 6245, true )
			local x,y,z,o = player:GetLocation()
			local creature
		--	if ( item:GetEntry() == event.entry.item2 ) then
				creature = player:SpawnCreature( event.entry.creature2, x+math.random(-1,1), y+math.random(-1,1), z+1.2, o, 3, 420000 ) -- TEMPSUMMON_TIMED_DESPAWN
		--	else
		--		creature = player:SpawnCreature( event.entry.creature, x+math.random(-1,1), y+math.random(-1,1), z+1.2, o, 3, 420000 ) -- TEMPSUMMON_TIMED_DESPAWN
		--	end
			creature:RegisterEvent( event.OnSpawnLamp, 3000, 1 )
			creature:SetDisableGravity(true)
			local guid = player:GetGUIDLow()
			creature:SetOwnerGUID( guid )
			creature:SetCreatorGUID( guid )
			player:RemoveItem( item, 1 )
			player:PlayDirectSound( 12901, player )
			return true
	--	else
	--		player:SendNotification("Вы должны использовать это в Штормграде.")
	--	end
--	else
--		player:SendNotification("Вы не можете использовать это сейчас.")
--	end
--	return false
end
--RegisterItemEvent( event.entry.item, 2, event.OnUseLamp ) -- ITEM_EVENT_ON_USE
RegisterItemEvent( event.entry.item2, 2, event.OnUseLamp ) -- ITEM_EVENT_ON_USE

--[[	КОМАНДА ДЛЯ РАЗРЕШЕНИЯ ФОНАРИКОВ	]]--
--[[	Рабочий фрагмент кода деактивирован до следующих ивентов.

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

--[	ПОДНОШЕНИЯ	]--

function event.Donations( eventID, object1, object2, sender, intid )
	if eventID == 14 then
		local player, gob = object2, object1
		local text
		player:GossipClearMenu()
		if not ( player:HasAura(event.entry.auras[1]) or player:HasAura(event.entry.auras[2]) or player:HasAura(event.entry.auras[3]) ) then
			text = "<Блестящая куча монет задорно звенит каждый раз, когда туда кидают деньги. На жертвующих глядят с нескрываемым одобрением. Вы явно можете стать одним из них.>\n\n|cff003608Пожертвование денег временно удвоит получаемую вами репутацию. Срок действия бонуса зависит от суммы пожертвования. Вы можете узнать про это подробнее, нажав на один из вариантов ниже.\n\n|cff360004Вы не сможете пожертвовать деньги повторно!"
			player:GossipMenuAddItem( 0, "<Малое подношение.>", 1, 1, false, "Бонус от этого подношения будет\nдействовать до 10.02", 2000 )
			player:GossipMenuAddItem( 0, "<Щедрое подношение.>", 1, 2, false, "Бонус от этого подношения будет\nдействовать до 14.02", 5000 )
			player:GossipMenuAddItem( 0, "<Кинуть золотую монетку.>", 1, 3, false, "Бонус от этого подношения будет\nдействовать до 21.02", 10000 )
		else
			text = "|cff003608Вы уже совершили пожертвование."
		end
		player:GossipSetText( text, 07022101 )
		player:GossipSendMenu( 07022101, gob )
	elseif eventID == 2 then
		local player = object1
		if not ( player:HasAura(event.entry.auras[1]) or player:HasAura(event.entry.auras[2]) or player:HasAura(event.entry.auras[3]) ) then
			if intid == 1 then
				if ( player:GetCoinage() >= 2000 ) then
					player:ModifyMoney(-2000)
					player:AddAura( event.entry.auras[1], player )
				end
			elseif intid == 2 then
				if ( player:GetCoinage() >= 5000 ) then
					player:ModifyMoney(-5000)
					player:AddAura( event.entry.auras[2], player )
				end
			else
				if ( player:GetCoinage() >= 10000 ) then
					player:ModifyMoney(-10000)
					player:AddAura( event.entry.auras[3], player )
				end
			end
		end
		player:PlayDirectSound( 104875, player )
		player:GossipComplete()
	end
end
RegisterGameObjectEvent( event.entry.gameobject, 14, event.Donations ) -- GAMEOBJECT_EVENT_ON_USE
RegisterGameObjectGossipEvent( event.entry.gameobject, 2, event.Donations ) -- GOSSIP_EVENT_ON_SELECT

]]
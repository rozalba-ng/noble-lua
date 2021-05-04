local AIO = AIO or require("AIO")
PetControlAIO = AIO.AddHandlers("PetControl", {})


function PetControlAIO.PlayerIsCompanionOwner( player )
	if ( player:GetSelection():GetControllerGUID() == player:GetGUID() ) and not ( player:GetSelection():HasAura(91072) ) then
		AIO.Handle( player, "PetControl", "ShowPetControlButton", true )
	else
		AIO.Handle( player, "PetControl", "ShowPetControlButton", false )
	end
end

function PetControlAIO.Byte1( player, byte1 )
	local creature = player:GetSelection()
	if creature and ( creature:GetControllerGUID() == player:GetGUID() ) and not ( creature:HasAura(91072) ) then
		byte1 = tonumber(byte1) or 0
		if ( byte1 == 0 ) or ( byte1 == 1 ) or ( byte1 == 3 ) then
			creature:SetByteValue( 6+68, 0, byte1 )
		end
	else player:SendNotification("Вы не можете управлять этим существом.") end
end

function PetControlAIO.Follow( player, follow, distance, angle )
	local creature = player:GetSelection()
	if creature and ( creature:GetControllerGUID() == player:GetGUID() ) and not ( creature:HasAura(91072) ) then
		if follow == 1 then
			if distance and tonumber(distance) then
				distance = tonumber(distance) - 2
				if ( distance > 3 ) or ( distance < -2 ) then
					player:SendNotification("Укажите дистанцию следования от 0 до 5.")
					return
				end
				if angle and tonumber(angle) then
					angle = tonumber(angle) * 3.141 / 180 -- Перевод градусов в радианы.
					creature:MoveFollow( player, distance, angle )
				else
					creature:MoveFollow( player, distance, 0.78 )
				end
			else
				creature:MoveFollow( player )
			end
		else
			creature:MoveExpire()
		end
	else player:SendNotification("Вы не можете управлять этим существом.") end
end

function PetControlAIO.Say( player, text )
	local creature = player:GetSelection()
	if creature and ( creature:GetControllerGUID() == player:GetGUID() ) and not ( creature:HasAura(91072) ) then
		if text then
			text = tostring(text)
			if ( string.utf8len(text) < 254 ) then
				creature:SendUnitSay( text, 0 )
			end
		end
	else player:SendNotification("Вы не можете управлять этим существом.") end
end

function PetControlAIO.Emote( player, text )
	local creature = player:GetSelection()
	if creature and ( creature:GetControllerGUID() == player:GetGUID() ) and not ( creature:HasAura(91072) ) then
		if text then
			text = tostring(text)
			if ( string.utf8len(text) < 254 ) then
				creature:SendUnitEmote( creature:GetName().." "..text )
			end
		end
	else player:SendNotification("Вы не можете управлять этим существом.") end
end
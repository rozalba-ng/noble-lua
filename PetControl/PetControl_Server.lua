local AIO = AIO or require("AIO")
PetControlAIO = AIO.AddHandlers("PetControl", {})


function PetControlAIO.PlayerIsCompanionOwner( player )
	if ( player:GetSelection():GetOwnerGUID() == player:GetGUIDLow() ) and not ( player:GetSelection():HasAura(91072) ) then
		AIO.Handle( player, "PetControl", "ShowPetControlButton", true )
	else
		AIO.Handle( player, "PetControl", "ShowPetControlButton", false )
	end
end

function PetControlAIO.Byte1( player, byte1 )
	local creature = player:GetSelection()
	if creature and ( creature:GetOwnerGUID() == player:GetGUIDLow() ) and not ( creature:HasAura(91072) ) then
		byte1 = tonumber(byte1) or 0
		if ( byte1 == 0 ) or ( byte1 == 1 ) or ( byte1 == 3 ) then
			creature:SetByteValue( 6+68, 0, byte1 )
		end
	else player:SendNotification("Вы не можете управлять этим существом.") end
end

function PetControlAIO.Follow( player, follow )
	local creature = player:GetSelection()
	if creature and ( creature:GetOwnerGUID() == player:GetGUIDLow() ) and not ( creature:HasAura(91072) ) then
		if follow == 1 then
			creature:MoveFollow( player )
		else
			creature:MoveExpire()
		end
	else player:SendNotification("Вы не можете управлять этим существом.") end
end

function PetControlAIO.Say( player, text )
	local creature = player:GetSelection()
	if creature and ( creature:GetOwnerGUID() == player:GetGUIDLow() ) and not ( creature:HasAura(91072) ) then
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
	if creature and ( creature:GetOwnerGUID() == player:GetGUIDLow() ) and not ( creature:HasAura(91072) ) then
		if text then
			text = tostring(text)
			if ( string.utf8len(text) < 254 ) then
				--creature:SendUnitEmote( "|cfffcba03["..player:GetName().."]|r "..text ) На случай абуза механики
				creature:SendUnitEmote( text )
			end
		end
	else player:SendNotification("Вы не можете управлять этим существом.") end
end
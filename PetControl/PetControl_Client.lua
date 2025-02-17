local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local PetControlAIO = AIO.AddHandlers("PetControl", {})

PetControl = PetControl or {}

function PlayerIsCompanionOwner()
	AIO.Handle( "PetControl", "PlayerIsCompanionOwner" )
end

function PetControlAIO.ShowPetControlButton( _, allowed )
	if allowed then
		PetControlButton:Show()
		PetControlButton:Enable()
		PetControl.Target = true
	else
		PetControlButton:Disable()
	end
end


function PetControl.Byte1( byte1 )
	AIO.Handle( "PetControl", "Byte1", byte1 )
end

function PetControl.Follow( follow )
	AIO.Handle( "PetControl", "Follow", follow )
end

function PetControl.Say( text )
	AIO.Handle( "PetControl", "Say", text )
end

function PetControl.Emote( text )
	AIO.Handle( "PetControl", "Emote", text )
end
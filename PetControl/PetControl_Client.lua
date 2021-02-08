local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local PetControlAIO = AIO.AddHandlers("PetControl", {})

function PlayerIsCompanionOwner()
	AIO.Handle( "PetControl", "PlayerIsCompanionOwner" )
end

function PetControlAIO.ShowPetControlButton( _, allowed )
	if allowed then
		PetControlButton:Show()
		PetControlButton:Enable()
	else
		PetControlButton:Disable()
	end
end

PetControl = PetControl or {}

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
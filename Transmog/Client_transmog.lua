local lastIdPressed
local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end
local Handlers = AIO.AddHandlers("TransmogHandlers", {})



function TransmogItem(slot,code)
	AIO.Handle("TransmogHandlers","TransmogItem", slot-1,code)
end

function Transmog_DropDownMenu1:SetValue3()
AIO.Handle("TransmogHandlers","TransmogItem", Transmog_ItemSlotID-1,44724)

end

function CallIds()
	AIO.Handle("TransmogHandlers","CallIds")
end

function ResetItemTransmog(slot)
	AIO.Handle("TransmogHandlers","ResetTransmog", slot-1)
end

function ApplyAccessory(id)
	AIO.Handle("TransmogHandlers","ApplyAccessory", tonumber(id))
end

function ChangeVisual(state, number)
	AIO.Handle("TransmogHandlers","ChangeVisual", tonumber(state),tonumber(number))
end

function TransmogSetOnCharacter(code, state)
	AIO.Handle("TransmogHandlers","TransmogSet", code, state)
end
function Handlers.OpenTmog(player)
	Transmog_MainPanelOnOff()
end
function Handlers.LateModelFrameUpdate(player)
	UpdateTransmogModel()
end

function Handlers.UpdateUsedAura(player,aurasOnChar)
	Transmog_SavedAura = aurasOnChar;
	Transmog_DataRefreshAll();
end
function Handlers.UpdatePresets(player,sets,bags,belts)
	
	Transmog_DefaultPresetName = sets.names
	Transmog_DefaultPresetCode = sets.codes
	Transmog_BagsPresetName = bags.names
	Transmog_BagsPresetCode = bags.ids
	Transmog_BeltPresetName = belts.names
	Transmog_BeltPresetCode = belts.ids
end
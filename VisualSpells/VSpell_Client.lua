local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end
local VisualSpellHandlers = AIO.AddHandlers("VisualSpellHandlers", {})


function VisualSpellHandlers.UpdateSpellList(player,cash_spells)
	
	SpellGroup = cash_spells
end
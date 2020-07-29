local AIO = AIO or require("AIO")

local VisualSpellHandlers = AIO.AddHandlers("VisualSpellHandlers", {})
local cash_spells = {}
local function UpdateVisualSpellsCash()
	local spell_cash = WorldDBQuery("SELECT * FROM visual_spell_list")
	if spell_cash then
		for i = 1, spell_cash:GetRowCount() do
			cash_spells[i] = spell_cash:GetRow()
			spell_cash:NextRow()
		end
	end
end
UpdateVisualSpellsCash()
local function OnPlayerLogin (event, player)
	AIO.Handle(player,"VisualSpellHandlers","UpdateSpellList",cash_spells)
end

local function OnPlayerCommand(event, player,command)
	gmRank = player:GetGMRank()
	if(string.match(command,'spellreset')) then
		player:SendAddonMessage("Reset_spells", "1", 1, player);
	elseif(string.match(command,'castvisualspell [0-9]+')) then
		local buffer = string.len(string.match(command,'[a-zA-Z]+'))+1
		local spell_id = string.match(command,'[0-9]+',buffer)
		for i = 1, #cash_spells do
			if tonumber(cash_spells[i].ID) == tonumber(spell_id) then
				player:CastSpell(player,spell_id)
			end
		end
		return false
	elseif(string.match(command,'npccastvisual [0-9]+')) then
		if gmRank > 0 then
			local buffer = string.len(string.match(command,'[a-zA-Z]+'))+1
			local spell_id = string.match(command,'[0-9]+',buffer)
			for i = 1, #cash_spells do
				if tonumber(cash_spells[i].ID) == tonumber(spell_id) then
					local selection = player:GetSelection()
					selection:CastSpell(selection,spell_id)
				end
			end
			return false
		end
	elseif(string.match(command,'stopspell')) then
		if gmRank > 0 then
			local selection = player:GetSelection()
			selection:StopSpellCast()
		end
	end
	

end

	

RegisterPlayerEvent(42, OnPlayerCommand)
RegisterPlayerEvent(3, OnPlayerLogin)
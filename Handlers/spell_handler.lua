local ADD_REROLL = 91463
local ADD_RENAME = 91464

function Player:AddReroll()
	local character_guid = IntGuid(self:GetGUID())
	self:Print("Добавляем реролл... ")
	CharDBQuery("UPDATE auth.account a "..
					"JOIN characters.characters c "..
					"ON a.id = c.account "..
					"SET a.reroll_avaliable = a.reroll_avaliable + 1 "..
					"WHERE c.guid = "..tostring(character_guid)..";")
end

function Player:AddRename()
	local character_guid = IntGuid(self:GetGUID())
	self:Print("Добавляем ренейм... ")
	CharDBQuery("UPDATE auth.account a "..
					"JOIN characters.characters c "..
					"ON a.id = c.account "..
					"SET a.renames_avaliable = a.renames_avaliable + 1 "..
					"WHERE c.guid = "..tostring(character_guid)..";")
end

local function OnSpellCast(event, player, spell, skipCheck)
	if spell:GetEntry() == ADD_RENAME then
		player:AddRename()
    elseif spell:GetEntry() == ADD_REROLL then
		player:AddReroll()
    end
end

RegisterPlayerEvent(5,OnSpellCast)
function GiveItemToPlayer(playerGUID)
	local itemID = 301393
	local itemCount = 1
	if playerGUID == UnitGUID("player") then
		local player = GetPlayerByGUID(playerGUID)
		if player then
			player:AddItem(itemID, itemCount)
		end
	end
end

local function OnAddonMessage(prefix, message, channel, sender)
	if prefix == "GiveItemToPlayer" then
		local playerGUID = message
		GiveItemToPlayer(playerGUID)
	end
end

local frame = CreateFrame("FRAME", "MyAddonFrame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", OnAddonMessage)
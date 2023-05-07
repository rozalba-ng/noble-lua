function ItemGiveaway()
	item = Player:AddItem ( 301394, 1)
end

local function OnAddonMessage(prefix, message, channel, sender)
    if prefix == "GiveItem" then
        ItemGiveaway()
    end
end

local frr = CreateFrame("FRAME", "MyAddonFrame")
frr:RegisterEvent("CHAT_MSG_ADDON")
frr:SetScript("OnEvent", OnAddonMessage)
frr:RegisterAddonMessagePrefix("GiveItem")
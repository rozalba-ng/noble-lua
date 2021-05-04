GlypsWhiteList = {
2111525,
2111524,
2111505,
2111504,
2111503,
2111501,
2111500,
2111499,
2111498,
2111497,
2111496,
2111495,
2111494,
2111493,
2111492,
2111488,
2111486,
2111485,
2111484,
2111475
}
local function OnPlayerCommand(event, player,command)
	if(string.match(command,'giveglyph %d+$')) then
		if (player:GetAccountId() == 146 or player:GetGMRank() > 1 ) then
        local GlyphItem = string.match(command, '%d+$');
            for i,v in pairs(GlypsWhiteList) do
                if(tonumber(GlyphItem) == v) then
                    local TargetSelection = player:GetSelection()
                    local PlayerReciever = TargetSelection:ToPlayer()
                    if TargetSelection:ToPlayer() then
                        local Given_Item = PlayerReciever:AddItem(GlyphItem)
                            if Given_Item then
                                player:SendBroadcastMessage(Given_Item:GetItemLink(8).. "|cff71C671 был выдан игроку |cff00ccff"..PlayerReciever:GetName())
                            else
                                player:SendBroadcastMessage("|cffff0000 У игрока полон инвентарь!")
                            end
                    else
                        player:SendBroadcastMessage("|cffff0000Ошибка! Не выбран игрок. Выберите игрока, которому хотите отправить итем.")
                    end
                end
            end
		end
	end
	return false
end

RegisterPlayerEvent(42, OnPlayerCommand)
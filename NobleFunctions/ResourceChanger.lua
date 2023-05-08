local function GiveItem (event, player, command)
	if command == "give" then
		local isItem
		isItem = player:HasItem(301393, 1)
		if (isItem == true) then
			player:SendBroadcastMessage("Yes")
			player:RemoveItem(301393, 1)
			player:AddItem(301394, 1)
		else
			player:SendBroadcastMessage("No")			
		end
	end
end

RegisterPlayerEvent (42, GiveItem)


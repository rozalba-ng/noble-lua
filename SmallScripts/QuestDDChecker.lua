local function OnDailyDDQeustAccept(event, player, go, quest)
	if not (player:HasAura(88033)) then
		player:RemoveQuest(quest:GetId())
		player:SendBroadcastMessage("Ваш персонаж не является участником сюжета \"День Дракона\"")
	end
end



RegisterGameObjectEvent(5045320,4, OnDailyDDQeustAccept)
RegisterGameObjectEvent(5045321 ,4, OnDailyDDQeustAccept)
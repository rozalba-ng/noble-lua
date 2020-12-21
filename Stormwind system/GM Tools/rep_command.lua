
local rank_strings = {
	[0] = "|cff882222Ненависть",
	[1] = "|cffFF0B15Враждебность",
	[2] = "|cffEE6622Неприязнь",
	[3] = "|cffF1FF0AРавнодушие",
	[4] = "|cff17FF0EДружелюбие",
	[5] = "|cff00FF88Уважение",
	[6] = "|cff00FFC2Почтение",
	[7] = "|cff1DC6F1Превознесение",
}

local function Command( _, player, command )
	if ( command == "rep" or command == "reputation" ) and ( player:GetGMRank() > 0 ) then
		local target = player:GetSelection()
		if ( not target ) or ( target:ToPlayer() ) then
			player:SendAreaTriggerMessage("|cffFF4500[!!]|r Выберите игрока в цель.")
		else
			local rank_thief = player:GetReputationRank(thiefs_faction)
			local rank_law = player:GetReputationRank(law_faction)
			player:SendBroadcastMessage( target:GetName().." имеет:\n "..rank_strings[rank_law].."|r у Штормграда.\n "..rank_strings[rank_thief].."|r у Теней." )
		end
 	end
end
RegisterPlayerEvent( 42, Command ) -- PLAYER_EVENT_ON_COMMAND
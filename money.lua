--[[Every 15 minutes player recieve 10 copper. If pleyer is in guild, he auto-deposit 3 copper to guild, but resieve 1 additional copper]]
local function calculateMoney()
	local onlinePlayers = GetPlayersInWorld( 2 ); --[[ 2-neutral, both horde and aliance]]		
	for _, player in ipairs(onlinePlayers) do	
		if (player:IsAFK() == false) then
			player:ModifyMoney( 10 );
			local guild = player:GetGuild();
			if (guild ~= nil) then		
				player:ModifyMoney( 2 );
				guild:DepositBankMoney( player, 5 )				
			end			
		end;	  
	end
end

CreateLuaEvent(calculateMoney, 900000, 0);
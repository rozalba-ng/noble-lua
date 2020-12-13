
--	NPC заменяющий зону Штормграда (Если есть в радиусе 25 ярдов)
local entry_npc = 1211001
--	NPC создающий зону с бонусом (Для общесерв ивентов)
local entry_bonus_npc = 1211002

--[[Every 15 minutes player recieve 10 copper. If pleyer is in guild, he auto-deposit 10 copper to guild, but resieve 5 additional copper]]
local function calculateMoney()
	local onlinePlayers = GetPlayersInWorld( 2 ); --[[ 2-neutral, both horde and aliance]]		
	for _, player in ipairs( onlinePlayers ) do	
		if ( player:IsAFK() == false ) then
		--	Добавление денег
			player:ModifyMoney( 40 );
			local guild = player:GetGuild();
			if ( guild ~= nil ) then		
				player:ModifyMoney( -5 );
				guild:DepositBankMoney( player, 15 )
			end
		--	Добавление репутации
			if SocialTime() then
				local f
				if player:GetQuestStatus( 110052 ) == 6 then
				--	Игрок выполнил квест на вступление в Тени Штормграда
					f = thiefs_faction
				elseif player:GetQuestStatus( 110053 ) == 6 then
				--	Игрок выполнил квест на вступление в Королевство Штормград
					f = law_faction
				end
				if f and player:GetPhaseMask() == 1 then
				--	Игрок выполнил один из квестов и находится в 1 фазе
					local zone, trueZone, r = player:GetZoneId(), false, 0
					if zone == 1519 then
					--	Игрок в Штормграде
						r = 3
						trueZone = true
					elseif zone == 10237 or zone == 10214 or zone == 10197 or zone == 10160 or zone == 10179 or zone == 10232 or player:GetNearestCreature( 25, entry_npc ) then
					--	Игрок играет на полигоне
						r = 2
						trueZone = true
					end
					if trueZone and ActionTime() then
					--	Если время суперактива - идёт маленький бонус.
						r = r + 2
					end
					if trueZone and player:GetNearestCreature( 30, entry_bonus_npc ) then
					--	Если рядом есть НПС дарующий бонус
						r = r + 2
					end
					--	Начисление репутации
					player:SetReputation( f, player:GetReputation( f ) + r )
				end
			end
		end;	  
	end
end
CreateLuaEvent( calculateMoney, 900000, 0 )
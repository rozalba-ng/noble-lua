
--	NPC заменяющий зону Штормграда (Если есть в радиусе 25 ярдов)
local entry_npc = 1211001
--	NPC создающий зону с бонусом (Для общесерв ивентов)
local entry_bonus_npc = 1211002

local guildzone_aura = 91065

--[[Every 15 minutes player recieve 25 copper. If pleyer is in guild, he auto-deposit 15 copper to guild, but resieve 5 additional copper]]
local function calculateMoney()
	local onlinePlayers = GetPlayersInWorld( 2 ); --[[ 2-neutral, both horde and aliance]]
	for _, player in ipairs( onlinePlayers ) do
		if ( player:IsAFK() == false ) then
		--	Добавление денег
			player:ModifyMoney( 25 );
			local guild = player:GetGuild();
			if ( guild ~= nil ) then
				player:ModifyMoney( -7 );
				guild:DepositBankMoney( player, 12 )
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
					if ( zone == 1519 ) then
					--	Игрок в Штормграде
						r = 6
						trueZone = true
					elseif ( zone == 10237 or player:HasAura(guildzone_aura) or zone == 10236 or zone == 10235 or zone == 10199 or zone == 10234 or zone == 10214 or zone == 10197 or zone == 10160 or zone == 10179 or zone == 10232 or zone == 10233 or zone == 12) then
					--	Игрок играет на полигоне
						r = 4
						trueZone = true
					end
					if trueZone and ActionTime() then
					--	Если время суперактива - идёт маленький бонус.
						r = r + 3
					end
--					if trueZone and player:HasAura(CREATIVE_PHASE_AURA) then
--					--	Если рядом есть НПС дарующий бонус
--						r = r + 2
--					end
					--	Начисление репутации
					player:SetReputation( f, player:GetReputation( f ) + r )
					--	Снятие репутации UPD ROZALBA: отменяем снятие репутации
--					if f == thiefs_faction then
--					--	Снятие репутации у законников
--						player:SetReputation( law_faction, player:GetReputation( law_faction ) - r )
--					else
--					--	Снятие репутации у плохишей
--						player:SetReputation( thiefs_faction, player:GetReputation( thiefs_faction ) - r )
--					end
				end
			end
		end;
	end
end
CreateLuaEvent( calculateMoney, 900000, 0 )
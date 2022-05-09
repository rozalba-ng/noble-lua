
local bossEntryID =  987880
local boss_stage = nil
local TRIGGER_NPC = 987824


local function BossJumpStages(_,_,_,boss)
    --boss:CastCustomSpell( (boss:GetNearestPlayer(15,1,1)), spellKick,true,1,1,1)
	local players = boss:GetPlayersInRange(10)
	if #players > 0 then
		local target = players[math.random(1,#players)]
		local x,y,z,o = target:GetLocation()

		local t = boss:Jump(x, y, z, 10+((boss_stage-1)*7), 10)
		local flytime = (t*2)-250
		if flytime < 0 then
			flytime = 100
		end
		local randomVariable = math.random(1,8)
		if randomVariable == 1 then
			boss:SendUnitYell("Прыжок!",0)
		elseif randomVariable == 2 then
			boss:SendUnitYell("Главное не разбегайтесь!",0)
		elseif randomVariable == 3 then
			boss:SendUnitYell("Поймаю!",0)
		elseif randomVariable == 4 then
			boss:SendUnitYell("Лови!",0)
		end
		local stun_point = boss:SpawnCreature(TRIGGER_NPC, x, y, z, o, 3, ((t*2)+1500))
		stun_point:AddAura(64328, stun_point)
		stun_point:RegisterEvent(function(_,_,_, stun_point)
			stun_point:CastSpell(stun_point, 20549, true)
			local players = stun_point:GetPlayersInRange(5)
			for i = 1,#players do
				if players[i]:GetExactDistance(stun_point) < 5 then
					players[i]:CastSpell(players[i], 68848)
				end
			end
		end, flytime,1)

		
			
	end
	if boss_stage == 1 then
		boss:RegisterEvent(BossJumpStages,7*1000,1)
	elseif boss_stage == 2 then
		boss:RegisterEvent(BossJumpStages,4.5*1000,1)
	elseif boss_stage == 3 then
		boss:RegisterEvent(BossJumpStages,2*1000,1)
	end
end

local function BossEnterCombat(event, boss, target)
    boss_stage = 1
    local randomVariable = math.random(1,4)
	if randomVariable == 1 then
		boss:SendUnitYell("Готовьте свои яйца!",0)
	elseif randomVariable == 2 then
		boss:SendUnitYell("Знаете почему меня называют самым злобным, жестоким и раздражительным грызуном?!",0)
	elseif randomVariable == 3 then
		boss:SendUnitYell("Вас ведь предупреждали! *Злобно клацает зубами*",0)
	elseif randomVariable == 4 then
		boss:SendUnitYell("Ни одна священная граната меня не возьмет",0)
    end
	boss:RegisterEvent(BossJumpStages,2*1000,1)
end


local function BossDamageTaken(event, boss, attacker, damage)
    if boss:GetHealthPct() < 70 and boss_stage == 1 then
        boss_stage = 2
        --boss:RegisterEvent(BossSnowballStage,1*1000,1)
    elseif boss:GetHealthPct() < 15 and boss_stage == 2 then
        boss_stage = 3
        --BossLeave(boss)
    end
    if boss_stage == 3 then
        return true, 1
    end
end

local function BossLeaveCombat(event, boss)
	boss_stage = 0
end



-- Регистрация основных ивентов
RegisterCreatureEvent( bossEntryID, 1, BossEnterCombat )
RegisterCreatureEvent( bossEntryID, 2, BossLeaveCombat )
RegisterCreatureEvent( bossEntryID, 9, BossDamageTaken )

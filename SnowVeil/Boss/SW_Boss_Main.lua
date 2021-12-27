
local bossEntryID = 123 
local snowmans = {}
local boss_stage = nil
local spellKick = 10101 -- Отбрасывание игрока -- 65918 последствия
local spellSnowball = 21343
local snowmanEntry = 987834
local gigamanEntry = 987826
local BOSS_FIRST_JUMP = {x=-1068,y=111,z=8}
local gigamanData = {}
local rocketTarget = nil
local function Snowman(obj)
    local Snowman = {}
    Snowman.map = obj:GetMapId()
    Snowman.guid_low = obj:GetGUIDLow()
    Snowman.entry = obj:GetEntry()
    function Snowman:get()
        local mapObject = GetMapById(self.map)
		local guid = GetUnitGUID(self.guid_low,self.entry)
		local creature = mapObject:GetWorldObject(guid)
		if creature then
			return creature
		end
    end
    return Snowman
end

local function BossKickStage(_,_,_,boss)
    boss:CastSpell( (boss:GetNearestPlayer(15,1,1)), spellKick,true)
    if boss_stage == 1 or boss_stage == 2 then
        boss:RegisterEvent(BossKickStage,2.5*1000,1)
    end
    
end
local function BossSnowballStage(_,_,_,boss)
    local target = boss:GetNearestPlayer(40,1,1)
    if target and boss_stage == 2 then
        boss:CastSpell( target, spellSnowball,true)
        local dist = boss:GetDistance(target)
        local x,y,z = target:GetX(),target:GetY(),target:GetZ()
        boss:RegisterEvent(function(_,_,_,boss)
            local snowman = boss:SpawnCreature(snowmanEntry,x,y,z,0,1,5*60*1000)
            table.insert(snowmans,Snowman(snowman))
        end,dist/25*1000+100,1)
    end
    
    if boss_stage == 2 then
        boss:RegisterEvent(BossSnowballStage,5*1000,1)
    end
    
end

local function BossEnterCombat(event, boss, target)
    snowmans = {}
    boss_stage = 1
    local randomVariable = math.random(1,4)
	if randomVariable == 1 then
		boss:SendUnitYell("Этот праздник выдумали идиоты!",0)
	elseif randomVariable == 2 then

		boss:SendUnitYell("Я пущу вас на удобрение!",0)
	elseif randomVariable == 3 then
		boss:SendUnitSay("Я превращу вас в угольки! И этими угольками усыпаю Сноувейл!",0)
	elseif randomVariable == 4 then
		boss:SendUnitSay("Черт... я даже не успел раздется к вашему приходу",0)
    end
	boss:CastSpell( (boss:GetNearestPlayer(20,1,1)), spellKick,true)
    boss:RegisterEvent(BossKickStage,1*1000,1)
end

local function StunRockets(_,_,_,gigaman)
    local players =gigaman:GetPlayersInRange(29)
    local player = players[math.random(1,#players)]
    rocketTarget = player:GetName()
    local randomVariable = math.random(1,4)
	if randomVariable == 1 then
		gigaman:SendUnitYell(rocketTarget..", у.. меня .. для тебя подарок..",0)
	elseif randomVariable == 2 then
        gigaman:SendUnitYell("Обними.. друзей.. покрепче, "..rocketTarget,0)
	elseif randomVariable == 3 then
		gigaman:SendUnitYell(rocketTarget..", ты любишь.... фей..рверки?",0)
	elseif randomVariable == 4 then
		gigaman:SendUnitYell(rocketTarget..", с пра... здником...!!!",0)
    end
    gigaman:RegisterEvent(function(_,_,_,gigaman)
        local p = GetPlayerByName(rocketTarget)
        if p then
            gigaman:CastSpell(p,25465)
            local dist = gigaman:GetDistance(p)
            p:RegisterEvent(function(_,_,_,playerEx)
                local players = playerEx:GetPlayersInRange(6)
                for i, player in ipairs(players) do
                    player:AddAura(25495,player)
                    
                end
            end,dist/15*1000+150+1000,1)
        end
        gigaman:RegisterEvent(StunRockets,5*1000,1)
    end,3*1000,1)
end

local function BossLeave(boss)
    local players = boss:GetPlayersInRange(100)
    boss:SendUnitYell("Ой-ой...Дело дрянь. Не в этот раз, остолопы! Гигавик, покажи им что такое настоящая зима!!!",0)
    local gigaman = boss:SpawnCreature(gigamanEntry,boss:GetX(),boss:GetY(),boss:GetZ(),10*60*1000)
    gigaman:SetRooted()
    gigaman:SetScale(2)
    gigamanData = Snowman(gigaman)
    for i, data in ipairs(snowmans) do
        local snowman = data:get()
        if snowman then
            local t = snowman:Jump(boss:GetX(),boss:GetY(),boss:GetZ()+1, 10, 20)
            snowman:RegisterEvent(function(_,_,_,snowman)
                local gman = gigamanData:get()
                gman:SetScale(gman:GetScale()+0.25)
                gman:SetMaxHealth(gman:GetMaxHealth()+100)
                gman:SetHealth(gman:GetMaxHealth())
                snowman:DespawnOrUnsummon()
            end,t+250,1)
        end
    end
    local t = boss:Jump(BOSS_FIRST_JUMP.x, BOSS_FIRST_JUMP.y, BOSS_FIRST_JUMP.z, 16, 50)
    boss:RegisterEvent(function(_,_,_,boss)
        boss:DespawnOrUnsummon()
    end,t+250,1)
    gigaman:RegisterEvent(function(_,_,_,gigaman)
        gigaman:SetRooted(false)
        gigaman:SendUnitYell("БЕ..РЕ..ГИСЬ.... МЕ..ЛОЧЬ",0)
        gigaman:RegisterEvent(StunRockets,5*1000,1)
    end,3*1000,1)
end

local function BossDamageTaken(event, boss, attacker, damage)
    if boss:GetHealthPct() < 70 and boss_stage == 1 then
        boss_stage = 2
        boss:RegisterEvent(BossSnowballStage,1*1000,1)
    elseif boss:GetHealthPct() < 30 and boss_stage == 2 then
        boss_stage = 3
        BossLeave(boss)
    end
    if boss_stage == 3 then
        return true, 1
    end
end

local function BossLeaveCombat(event, boss)
    if boss_stage < 3 then
        for i, data in ipairs(snowmans) do
            local snowman = data:get()
            if snowman then
                snowman:DespawnOrUnsummon()
            end
        end
    end
end



-- Регистрация основных ивентов
RegisterCreatureEvent( bossEntryID, 1, BossEnterCombat )
RegisterCreatureEvent( bossEntryID, 2, BossLeaveCombat )
RegisterCreatureEvent( bossEntryID, 9, BossDamageTaken )

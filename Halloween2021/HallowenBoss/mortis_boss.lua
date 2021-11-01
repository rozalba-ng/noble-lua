Halloween = Halloween or {}

local text = {
	[1] = {
		"О, я так рад что вы пришли!",
		"Начнём битву!",
		"Я нападаю!",
		"Влад - вампир!",
	},
	[2] = {
		"Во мне пробуждается вампирская сила!",
		"Я уничтожу вас тыквами!",
		"У меня нет тени!",
	},
	[3] = {
		"Я чувствую приближение другого вампира...",
		"Я знаю, что вы тоже ослабли.",
	},
	[4] = {
		"Ты?!",
		"Друзья, я не вампир не Влад! Держитесь, я помогу вам!",
		"Берегитесь, этот гадкий вампир не в себе! Прячьтесь под мой щит!",
		"Под щит! Быстро!",
		"Он разошелся не на шутку! Быстро под щит!",
		"Под мой купол!",
		"Он стал сильнее! Под купол, живо!"
	},
	[5] = {
		"Старейшина предупреждал меня...",
	},
	[6] = {"|cffffff9fНе-вампир Владик говорит: Вы... сделали это!","|cffffff9fНе-вампир Владик говорит: Скажу честно... в детстве мне редко удавалось побороть его в схватках.","|cffffff9fНе-вампир Владик говорит: Но тогда со мной и не было свиты отборных живодеров!","|cffffff9fНе-вампир Владик говорит: Только молю всех чертей... не трогайте вы его зубы, это же мерзко."}
}
local mortisData = {x=104,y=-24.5,z=1,o=1.37}
local MORTIS_ENTRY = 987823
local CAMERA_SHAKE_SPELL = 69235
local TRIGGER_NPC = 987824
--stage 2
local MORTIS_DISPLAY = 8808 -- нетопырь
local PUMPKIN_NPC = 987826
local FAKE_PUMPKIN_NPC = 987827
local PUMPKIN_SPELL = 50066
local PUMPKIN_SPELL_DAMAGE = 6
--stage 3
local DARKBOLT_SPELL = 686
local DARKBOLT_SPELL_DAMAGE = 5
local VLAD_ENTRY = 987828

--

local VLAD_DISPLAY = 1955
local delayTable = {}
local vladInit = nil
local vladSpawnCoords = {x=153,y=83,z=92,o=3.9}
local thirdStageStart = false
local vladOnPoint = false
local rageStarted = false
local lastRage = os.time()+30
local notDead = true
local function GetMortis()
	if mortisData.init then
		local mapObject = GetMapById(mortisData.init.map)
		local guid = GetUnitGUID(mortisData.init.guid_low,MORTIS_ENTRY)
		local mortis = mapObject:GetWorldObject(guid)
		if mortis then
			return mortis
		end
	end
end
local function GetVlad()
	if vladInit then
	
		local mapObject = GetMapById(vladInit.map)
		local guid = GetUnitGUID(vladInit.guid_low,VLAD_ENTRY)
		local vlad = mapObject:GetWorldObject(guid)
		if vlad then
			return vlad
		end
	end

end

local function SpawnMortis(dearCreature)
	local mortis = dearCreature:SpawnCreature(MORTIS_ENTRY,mortisData.x,mortisData.y,mortisData.z,mortisData.o,6,15*1000)
	mortisData.init = {}
	mortisData.init.map = dearCreature:GetMapId()
	mortisData.init.guid_low = mortis:GetGUIDLow()
	vladToThird = false
	thirdStageStart = false
	pumpkinsDamage = 0
	pumpkins = 0
	pumpkinsDamage = 0
	Halloween.MortisStage = 0
	notDead = true
	lastFlyPoint = 0
	mortis:DespawnOrUnsummon(1500000) -- Деспавн через 25 минут
	return mortis
end

local function OnReloadEluna()
	local creature = GetMortis()
	local not_creature = GetVlad()
	if creature then
		creature:DespawnOrUnsummon()
	end
	if not_creature then
		not_creature:DespawnOrUnsummon()
	end
end
RegisterServerEvent( 16, OnReloadEluna ) -- ELUNA_EVENT_ON_LUA_STATE_CLOSE

function Halloween.BossAppear(dearCreature)
	--local mortis = SpawnMortis()
	local halloweenMap = GetMapById(9001)
	local playersOnMap = dearCreature:GetPlayersInRange(400)
	
	for i = 1, #playersOnMap do
		playersOnMap[i]:CastSpell( playersOnMap[i], CAMERA_SHAKE_SPELL, true )
	end
	
	local printQuery = QueryPrint(playersOnMap)
	printQuery:Add("|cffFF3F40Не-вампир Владик кричит: В чём дело?.. Я не понял!", 5000)
	printQuery:Add("|cffFF3F40Вампир Мортис кричит: БОЙТЕСЬ МОЕЙ ВАМПИРСКОЙ МЕСТИ!", 4000)
	printQuery:Add("|cffFF3F40Не-вампир Владик кричит: Ты?! Незванный гость!", 4000)
	printQuery:Add("|cffFF3F40Вампир Мортис кричит: Я вижу ты нашёл себе новых прислужников, Влад... ик!", 6000)
	printQuery:Add("|cffFF3F40Не-вампир Владик кричит: Убирайся прочь! Тебе здесь не рады.", 6000)
	printQuery:Add("|cffFF3F40Вампир Мортис кричит: НЕТ! Я... Я УНИЧТОЖУ ТВОЙ ЖАЛКИЙ ГОРОДИШКО, А ПОТОМ И ТЕБЯ!", 6000)
	printQuery:Add("|cffFF3F40Не-вампир Владик кричит: ГЕРОИ, ЗАЩИЩАЙТЕ МОЙ ОСОБНЯК! Кх-кхм. ЗАЩИЩАЙТЕ ДЕРЕВНЮ!\n|cffff7588...и явился страшный враг, и ждал он вас на въезде в город у тыквенной фермы. Но победили ли его герои?..", 8000)
	printQuery:Invoke()
	
	dearCreature:RegisterEvent(function(_,_,_, dearCreature)
		SpawnMortis(dearCreature)
	end, 30000,1)
end

Halloween.MortisStage = 0

local eventId_1
local jumpPoints = {
	{132.37, -6.2, 4.3},
	{81.697, -16.36, 0.9},
	{91.77, 12.66, 12.2},
}
local flyPoints = {
	{103.98, -11.73, 9.16},
	{114.4, 14.9, 12.87},
	{97.8, -4.56, 20.86},
	{108.7, 0.34, 11.28},
	{99, -4.55, 19.6},
}

local function nextJumpPoint(x)
	x = x+1
	if x > #jumpPoints then
		x = 1
	end
	return x
end

local lastFlyPoint = 0
local function GetFlyPoint()
	local r = math.random(1, #flyPoints)
	if r == lastFlyPoint then
		r = r+1
		if r > #flyPoints then
			r = 1
		end
	end
	lastFlyPoint = r
	return r
end

local function OnEnterCombat(_,mortis, target)
	mortis:SendUnitYell(text[1][math.random(1,#text[1])],  0)
	Halloween.MortisStage = 1
	eventId_1 = mortis:RegisterEvent(function(_,_,_, mortis)
		if math.random(1,2) == 1 and mortis:GetHealthPct() > 54 then
			local target = mortis:GetVictim()
			if target and (target:GetDistance(mortis) < 2) then
				local x,y,z,o = target:GetLocation()
				mortis:NearTeleport(x,y,z,o)
				local r = math.random(1,#jumpPoints)
				if mortis:GetDistance(jumpPoints[r][1], jumpPoints[r][2], jumpPoints[r][3]) < 10 then
					r = nextJumpPoint(r)
				end
				local t = mortis:Jump(jumpPoints[r][1], jumpPoints[r][2], jumpPoints[r][3], 20, 20)
				target:Jump(jumpPoints[r][1], jumpPoints[r][2], jumpPoints[r][3], 20, 20)
				
				local stun_point = mortis:SpawnCreature(TRIGGER_NPC, x, y, z, o, 3, ((t*2)+1500))
				stun_point:AddAura(64328, stun_point)
				stun_point:RegisterEvent(function(_,_,_, stun_point)
					stun_point:CastSpell(stun_point, 20549, true)
					local players = stun_point:GetPlayersInRange(5)
					for i = 1,#players do
						if players[i]:GetExactDistance(stun_point) < 5 then
							players[i]:CastSpell(players[i], 68848)
						end
					end
				end, (t*2)-250,1)
				
				target:RegisterEvent(function(_,_,_, player)
					player:CastSpell(player, 68848)
				end, t+250,1)
				mortis:RegisterEvent(function(_,_,_, mortis)
					local t = mortis:Jump(x,y,z, 30, 20)
					mortis:RegisterEvent(function(_,_,_, mortis)
						local x = mortis:GetNearestPlayer(100, 1)
						mortis:ClearThreatList()
						mortis:AddThreat(x, 10)
						mortis:AttackStart(x)
					end, t+250,1)
				end, t+250,1)
			end
		end
	end, 5000, 0)
end
RegisterCreatureEvent( MORTIS_ENTRY, 1, OnEnterCombat ) -- CREATURE_EVENT_ON_ENTER_COMBAT

local pumpkins = 0
local pumpkinsDamage = 0
local function Fly(_,_,_, mortis)
	if not mortis:IsInCombat() then
		mortis:MoveJump( mortisData.x, mortisData.y, mortisData.z, 20, 1 )
		mortis:SetRooted(false)
		return
	end
	if Halloween.MortisStage == 2 then
		mortis:SetRooted(false)
		local r = GetFlyPoint()
		local t = mortis:Jump(flyPoints[r][1], flyPoints[r][2], flyPoints[r][3], 5, 4)
		mortis:RegisterEvent(function(_,_,_, mortis)
			mortis:SetRooted(true)
			local players = mortis:GetPlayersInRange(45)
			local r = math.random(1,#players)
			if pumpkins < 6 then
				pumpkins = pumpkins + 1
				local x,y,z,o = players[r]:GetLocation()
				mortis:RegisterEvent(function(_,_,_, mortis)
					local pumpkin = mortis:SpawnCreature( PUMPKIN_NPC, x, y, z, o, 3, 120*1000 )
					pumpkin:SetRooted(true)
					pumpkin:RegisterEvent(function(_,_,_, pumpkin)
						pumpkin:SetRooted(false)
					end, 1800,1)
				end, 2000,1)
			end
			mortis:CastCustomSpell(players[r], PUMPKIN_SPELL, true, PUMPKIN_SPELL_DAMAGE+pumpkins)
		end, t,1)
		mortis:RegisterEvent(Fly, t+5000,1)
	end
end

RegisterCreatureEvent(PUMPKIN_NPC, 4, function(_, pumpkin)
	if Halloween.MortisStage == 2 then
		local x,y,z,o = pumpkin:GetLocation()
		pumpkin:SpawnCreature( FAKE_PUMPKIN_NPC, x, y, z, o, 3, 60*1000)
	end
	pumpkin:DespawnOrUnsummon()
	pumpkins = pumpkins - 1
end) -- CREATURE_EVENT_ON_DIED


local function MortisRageAttack(_,_,_,mortis)
	if not notDead then
		return false
	end
	if rageStarted then
		local players = mortis:GetPlayersInRange(40,1,1)
		for i, player in pairs (players) do
			if not player:GetNearestCreature(1.4,TRIGGER_NPC) then
				mortis:CastCustomSpell(player,DARKBOLT_SPELL, true, DARKBOLT_SPELL_DAMAGE*1.5)
			end
		end
		mortis:RegisterEvent(MortisRageAttack,1*1000,1)
	end
end

local function MortisRageStage(_,_,_,mortis)
	if not notDead then
		return false
	end
	rageStarted = true	
	lastRage = os.time()
	local shieldTime = 12
	local shieldObject = mortis:SpawnCreature(TRIGGER_NPC,105,-5,0.01,4.5,3,shieldTime*1000)
	local vlad = GetVlad()
	vlad:SendUnitYell(text[4][math.random(3,#text[4])],0)
	shieldObject:SetSpeed(1,0.25)
	shieldObject:SetScale(0.8)
	shieldObject:MoveTo(0,112,17.2,0.01)
	mortis:AddAura(47705,mortis) --Красная аура
	shieldObject:AddAura(40158,shieldObject) --Щит
	shieldObject:AddAura(60857,shieldObject) --Покраска щита в красный
	mortis:RegisterEvent(MortisRageAttack,1*1000,1)
	shieldObject:RegisterEvent(function(_,_,_,shieldObject)
		rageStarted = false
		local mortis = GetMortis()
		mortis:RegisterEvent(MortisThirdStage,300,1)
	end,shieldTime*1000,1)


end

function MortisThirdStage(_,_,_,mortis)
	mortis:RemoveAura(47705)
	if not notDead then
		return false
	end
	if not mortis:IsInCombat() then
		GetVlad():DespawnOrUnsummon()
		return
	end
	if thirdStageStart == false then
		local vlad = mortis:SpawnCreature(VLAD_ENTRY,153,83,92,3.9,3,60*60*60*1000)
		vladInit = {}
		vladInit.map = vlad:GetMapId()
		vladInit.guid_low = vlad:GetGUIDLow()
		thirdStageStart = true
		local t = vlad:Jump(108,10.2,11,10,10)
		vlad:RegisterEvent(function(_,_,_,vlad)
			local mortis = GetMortis()
			vlad:SetFacingToObject(mortis)
			vlad:SetRooted(true)
			mortis:SendUnitSay(text[4][1],0)
			vlad:SendUnitSay(text[4][2],0)
			vladOnPoint = true
			
			lastRage = os.time()-20
		end,t+1000,1)
	end
	local players = mortis:GetPlayersInRange(40,1,1)

	local id1 = math.random(1,#players)
	local id2 = math.random(1,#players)
	if #players > 1 then
		while id2 == id1 do
			id2 = math.random(1,#players)
		end
		mortis:CastCustomSpell(players[id2],DARKBOLT_SPELL, true, DARKBOLT_SPELL_DAMAGE)
	end
	
	mortis:CastCustomSpell(players[id1],DARKBOLT_SPELL, true, DARKBOLT_SPELL_DAMAGE)
	if (os.time()-lastRage) > 25 then
		mortis:RegisterEvent(MortisRageStage,4*1000,1)
	else
		mortis:RegisterEvent(MortisThirdStage,5.5*1000,1)
	end
end
local vladToThird = false
RegisterCreatureGossipEvent( FAKE_PUMPKIN_NPC, 1, function(_, player, pumpkin)
	if pumpkin:GetData("Click") then
		return
	end
	pumpkin:SetData("Click", true)
	if Halloween.MortisStage == 2 then
		local mortis = GetMortis()
		player:CastCustomSpell(mortis, PUMPKIN_SPELL, true, 1)
		mortis:RegisterEvent(function(_,_,_, mortis)
			pumpkinsDamage = pumpkinsDamage + 1
			if pumpkinsDamage > 9 and vladToThird == false then --					<--	9
				vladToThird = true
				mortis:SendUnitSay(text[3][math.random(1,#text[3])], 0)
				Halloween.MortisStage = 3
				mortis:DeMorph()
				mortis:CastSpell(mortis, 24085)
				mortis:SetRooted(false)
				mortis:SetScale(0.8)
				mortis:MoveExpire(true)
				local t = mortis:Jump(103.988, -15.34, 0.001, 10, 10)
				mortis:RegisterEvent(function(_,_,_, mortis)
					local z = mortis:GetZ()
					if z > 0.01 then
						local t = mortis:Jump(103.988, -15.34, 0.001, 10, 10)
						mortis:RegisterEvent(function(_,_,_, mortis)
							mortis:SetRooted(true)
							mortis:CastSpell(mortis, CAMERA_SHAKE_SPELL)
							vladOnPoint = false
							thirdStageStart = false
							lastRage = os.time()+100
							mortis:RegisterEvent(MortisThirdStage,1000,1)
						end, t+250,1)
					else
						mortis:SetRooted(true)
						mortis:CastSpell(mortis, CAMERA_SHAKE_SPELL)
						vladOnPoint = false
						thirdStageStart = false
						lastRage = os.time()+100
						mortis:RegisterEvent(MortisThirdStage,1000,1)
					end
					
				end, t+250,1)
			end
		end, 2000,1)
	end
	pumpkin:DespawnOrUnsummon()
end) -- GOSSIP_EVENT_ON_HELLO

local function OnDamageTaken(_, mortis, player, dmg)
	if Halloween.MortisStage == 1 and mortis:GetHealthPct() < 51 then
		mortis:SendUnitYell(text[2][math.random(1,#text[2])],  0)
		Halloween.MortisStage = 2
		mortis:RemoveEventById(eventId_1)
		mortis:SetDisplayId(MORTIS_DISPLAY)
		mortis:SetScale(5)
		mortis:CastSpell(mortis, 24085)
		local t = mortis:Jump(flyPoints[1][1], flyPoints[1][2], flyPoints[1][3], 20, 2)
		mortis:RegisterEvent(function(_,_,_, mortis)
			mortis:SetRooted(true)
			mortis:RegisterEvent(Fly, 2000,1)
		end, t,1)
	elseif Halloween.MortisStage == 2 then
		return true, 1
	end
end
RegisterCreatureEvent( MORTIS_ENTRY, 9, OnDamageTaken ) -- CREATURE_EVENT_ON_DAMAGE_TAKEN

local function OnLeaveCombat(_, mortis)
	pumpkins = 0
	pumpkinsDamage = 0
	lastFlyPoint = 0
	vladToThird = false
	thirdStageStart = false
	
	if Halloween.MortisStage == 1 then
		mortis:RemoveEventById(eventId_1)
	end
	if Halloween.MortisStage ~= 2 then
		mortis:MoveExpire(true)
		mortis:SetRooted(false)
	end
	Halloween.MortisStage = 0
	mortis:DeMorph()
	mortis:SetScale(0.8)
end
local function OnDead(event, creature, killer)
	creature:SendUnitYell(text[5][1],0)
	local players = creature:GetPlayersInRange(50)
	local vlad = GetVlad()
	local printQuery = QueryPrint(players)
	printQuery:Add(text[6][1],3000)
	printQuery:Add(text[6][2],5000)
	printQuery:Add(text[6][3],5000)
	printQuery:Add(text[6][4],5000)
	printQuery:Invoke()
	vlad:RegisterEvent(function(_,_,_,vlad)
		vlad:DespawnOrUnsummon()
		vladInit = nil
	end,22*1000,1)
	vladToThird = false
	pumpkinsDamage = 0
	pumpkins = 0
	pumpkinsDamage = 0
	Halloween.MortisStage = 0
	notDead = false
	lastFlyPoint = 0


end
RegisterCreatureEvent( MORTIS_ENTRY, 2, OnLeaveCombat ) -- CREATURE_EVENT_ON_LEAVE_COMBAT
RegisterCreatureEvent(MORTIS_ENTRY,4, OnDead)
local function TestCommand(_, player, command)
	if command == "mavrodi" and player:GetGMRank() > 1 then
		SpawnMortis(player)
		return false
	end
end
RegisterPlayerEvent( 42, TestCommand )
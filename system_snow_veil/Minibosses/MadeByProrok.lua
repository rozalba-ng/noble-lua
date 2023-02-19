local ProrokFruit = 501193
local OkorokID = 988019
local SpellFreeze = 46604

local CombatPhrases = {
	'Сначала я вас одолею, а затем сделаю из когтей медведя изюм!', 
	'На праздничном столе обязан стоять рулет сделанный из шкуры тигра!', 
	'Трепещи, олененос, я изобрёл грушеувеличительминатор!',
	'Драка с вами займёт меньше одного ч...',
	'Раздача бесплатных магических мечей для Лордеронцев, но... Ха! Я вас обманул!',
	'Рекомендую вам бить меня по рукам, чтобы я не мог бить вас в ответ! А ещё.. да погодите, я не закончил свои пожелания!',
	'Главное правило всей жизни - "Сделай и переделай!"'
}


local function DeleteProrokFruit (eventid, delay, repeats, player)
	local gobZ = player:GetGameObjectsInRange( 5, ProrokFruit )
	for i = 1, #gobZ do
		gobZ[i]:RemoveFromWorld( true )
	end
end

local function OnSpellCast (event, player, spell, skipCheck)
	if spell:GetEntry() == ProrokFruit then
		local x, y, z = spell:GetTargetDest()
		if x > -240 and x < -229 and y > 357 and y < 366 and player:GetMapId() == 9008 then
			if player:GetNearestCreature( 30, OkorokID, 0, 1 ) then
				return
			end
			player:RegisterEvent( DeleteProrokFruit, 200, 1 )
			local creature = player:SpawnCreature( OkorokID, -239.8, 364.1, 2.1, 5.8, 6, 120000 )
			creature:CastSpell(creature, 24085)
		end
	end
end

RegisterPlayerEvent( 5, OnSpellCast )

local lastPhraseTime = 0
local totalTakenDamage = 0
local function OnDamageTaken (event, creature, attacker, damage)
	if os.time()-lastPhraseTime > 15 then
		lastPhraseTime = os.time()
		creature:SendUnitSay( CombatPhrases[math.random(1,#CombatPhrases)], 0 )
	end
	totalTakenDamage = totalTakenDamage + damage
	if totalTakenDamage > 300 then
		totalTakenDamage = 0
		attacker:CastCustomSpell( attacker, SpellFreeze )
	end
end

RegisterCreatureEvent( OkorokID, 9, OnDamageTaken )

local function OnEnterCombat (event, creature, target)
	totalTakenDamage = 0
	lastPhraseTime = os.time()
end

RegisterCreatureEvent( OkorokID, 1, OnEnterCombat )
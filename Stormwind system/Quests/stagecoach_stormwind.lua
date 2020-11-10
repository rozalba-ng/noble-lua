--	СКРИПТОВАННЫЕ ЧАСТИ ШТОРМГРАДСКИХ КВЕСТОВ
--	Сопровождение дилижанса - Квест, нужно сопроводить дилижанс из Штормграда и ограбить/защитить его.

--[[	СОПРОВОЖДЕНИЕ ДИЛИЖАНСА		]]--

local entry_stagecoach = 44000
local entry_stagecoach_guardsBranch = 44001
local entry_stagecoach_banditsBranch = 44002
local entry_cabbie = 44003
local entry_captain = 44008
local entry_bandit = 44006
local entry_banditLeader = 44004
local entry_invisibleNPC = 9928196
local entry_log = 5049125
local quest_id = 110017
local quest_id2 = 110018
local savedPlayers
local defeatedPlayers = {}

local cabbie_phrases = {
	[15] = "Вы, главное, не тревожьтесь, доедем с ветерком.",
	[18] = "Я ведь и сам так - всю жизнь в дороге.",
	[22] = "Нынче разбойников в лесах многовато, вот господин меня и не отпускает без охраны.",
	[23] = "Интересно, он волнуется за меня или за наш товар?",
	[32] = "Ладно, а теперь смотрите в оба.",
	[38] = "Прошлый дилижанс ограбили где-то здесь.",
	[42] = "А это ещё кто? Пойди разберись с ним.",
}

local function STAGECOACH_Ride( event, creature, type, id )
	--	ФРАЗЫ
	--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
		local x,y,z = creature:GetLocation()
		x,y,z = string.format("%.1f", x), string.format("%.1f", y), string.format("%.1f", z)
		local Log_file = io.open("StagecoachLog.txt", "a")
		Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] .go " ..x.." "..y.." "..z.." "..creature:GetMapId().." | Waypoint: "..id.."\n")
		Log_file:close()
	--	--
	if id == 41 then
	--	Появление главаря разбойников
		local banditLeader = creature:SpawnCreature( entry_banditLeader, -9657.7, 250.1, 48, 0.1, 2, 600000 ) -- Деспавн после смерти или через 10 минут
		banditLeader:SendUnitSay( "А ну стоять, богатенькие бедолаги!", 0 )
		banditLeader:MoveTo( 27102000, -9648.9, 250.9, 46.6, true )
		if not creature:GetNearestGameObject( 50, entry_log ) then
			PerformIngameSpawn( 2, entry_log, 901, 0, -9652.56, 257.19, 46.5, 2.95, true )
			local emptyCreature = banditLeader:SpawnCreature( entry_invisibleNPC, -9652.56, 257.19, 46.6, 2.95, 2, 1000 )
			emptyCreature:CastSpell( emptyCreature, 63360 )
		end
	elseif id == 42 then
	--	Этап поездки завершён.
		creature:MoveStop()
		creature:SetRooted(true)
		local cabbie = creature:GetNearestCreature( 10, entry_cabbie )
		cabbie:SendUnitSay( cabbie_phrases[42], 0 )
		creature:DespawnOrUnsummon(600000)
	elseif cabbie_phrases[id] then
	--	Фразы во время поездки.
		local cabbie = creature:GetNearestCreature( 10, entry_cabbie )
		cabbie:SendUnitSay( cabbie_phrases[id], 0 )
	end
end
RegisterCreatureEvent( entry_stagecoach, 6, STAGECOACH_Ride ) -- CREATURE_EVENT_ON_REACH_WP

local function STAGECOACH_RideGuardsBranch( event, creature, type, id )
	--	ФРАЗЫ
	--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
		local x,y,z = creature:GetLocation()
		x,y,z = string.format("%.1f", x), string.format("%.1f", y), string.format("%.1f", z)
		local Log_file = io.open("StagecoachLog.txt", "a")
		Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] .go " ..x.." "..y.." "..z.." "..creature:GetMapId().." | Waypoint: "..id.."\n")
		Log_file:close()
	--	--
	if id == 10 then
		local cabbie = creature:GetNearestCreature( 10, entry_cabbie )
		cabbie:SendUnitSay( "Не знаю, что случилось бы со мной, если бы я поехал один. Даже думать о таком страшно.", 0 )
	elseif id == 18 then
		local cabbie = creature:GetNearestCreature( 10, entry_cabbie )
		cabbie:SendUnitSay( "Мы почти на месте.", 0 )
	elseif id == 27 then
	--	Этап поездки завершён.
		creature:MoveStop()
		creature:SetRooted(true)
		local cabbie = creature:GetNearestCreature( 10, entry_cabbie )
		cabbie:SendUnitSay( "Добрались.", 0 )
		creature:DespawnOrUnsummon(5000)
		for i = 1, #savedPlayers do
			local player = GetPlayerByName(savedPlayers[i])
			if player then
				player:CompleteQuest( quest_id )
			end
		end
	end
end
RegisterCreatureEvent( entry_stagecoach_guardsBranch, 6, STAGECOACH_RideGuardsBranch ) -- CREATURE_EVENT_ON_REACH_WP

function SCENE_CabbieDeath()
--	Костыльное получение NPC (loadCreature не работает с маунтами?)
	local banditLeader, banditStagecoach
	--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
		local Log_file = io.open("StagecoachLog.txt", "a")
		Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] Убийство извозчика.\n")
		Log_file:close()
	--	--
	for i = 1, #savedPlayers do
		local player = GetPlayerByName(savedPlayers[i])
		if player then
			banditLeader = player:GetNearestCreature( 30, entry_banditLeader )
			banditStagecoach = player:GetNearestCreature( 30, entry_stagecoach_banditsBranch )
			if banditLeader and banditStagecoach then
				if player:GetData("HasStagecoachRideQuest") then
					player:AddQuest(quest_id2)
					player:SendAreaTriggerMessage("Сопроводите украденный дилижанс.")
					player:SetData( "HasStagecoachRideQuest", false )
				end
			end
		end
	end
	if banditLeader and not banditStagecoach then
	--	Функционал
	--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
		local Log_file = io.open("StagecoachLog.txt", "a")
		if banditLeader:GetData("Scene") then
			Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] "..banditLeader:GetData("Scene").." этап.\n")
		else
			Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] 1 этап.\n")
		end
		Log_file:close()
	--	--
		if not banditLeader:GetData("Scene") and not addQuest then
		--	1 этап, убийство.
			local cabbie = banditLeader:GetNearestCreature( 30, entry_cabbie )
			local stagecoach = banditLeader:GetNearestCreature( 30, entry_stagecoach )
			banditLeader:SetData( "Scene", 2 )
			banditLeader:Kill(cabbie)
			local x,y,z,o = banditLeader:GetLocation()
			local emptyCreature = banditLeader:SpawnCreature( entry_invisibleNPC, x, y, z, o, 2, 6900 )
			emptyCreature:CastSpell( stagecoach, 60968 )
			timedFunction( SCENE_CabbieDeath, 2 )
		elseif banditLeader:GetData("Scene") == 2 then
			local stagecoach = banditLeader:GetNearestCreature( 30, entry_stagecoach )
			banditLeader:MoveFollow( stagecoach, 0 )
			banditLeader:SetData( "Scene", 3 )
			timedFunction( SCENE_CabbieDeath, 3 )
		elseif banditLeader:GetData("Scene") == 3 then
			banditLeader:SendUnitSay( "Не отставай, если хочешь получить свою награду.", 0 )
			banditLeader:SetData( "Scene", 4 )
			timedFunction( SCENE_CabbieDeath, 2 )
		elseif banditLeader:GetData("Scene") == 4 then
			local stagecoach = banditLeader:GetNearestCreature( 30, entry_stagecoach )
			banditLeader:CastSpell( stagecoach, 60968 )
			banditLeader:SetData( "Scene", 5 )
			timedFunction( SCENE_CabbieDeath, 1 )
		elseif banditLeader:GetData("Scene") == 5 then
			local stagecoach = banditLeader:GetNearestCreature( 30, entry_stagecoach )
			banditLeader:DespawnOrUnsummon(0)
			local badNPC = stagecoach:GetNearestCreature( 10, 385 )
			badNPC:DespawnOrUnsummon(0)
			badNPC = stagecoach:GetNearestCreature( 10, 385 )
			badNPC:DespawnOrUnsummon(0)
			badNPC = stagecoach:GetNearestCreature( 10, 9916334 )
			badNPC:DespawnOrUnsummon(0)
			local x,y,z = stagecoach:GetLocation()
			stagecoach:SpawnCreature( entry_stagecoach_banditsBranch, x, y, z, 3.1, 2, 60000 ) -- Деспавн через минуту
			stagecoach:DespawnOrUnsummon(0)
			timedFunction( SCENE_CabbieDeath, 1 )
		end
	elseif banditStagecoach then
		banditStagecoach:MoveWaypoint()
	end
end

local function BANDITLEADER_Gossip( event, player, creature, sender, intid )
	if creature:GetData("DialogueCompleted") then return end
	if event == 1 then
	--	Первый разговор
	--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
		local Log_file = io.open("StagecoachLog.txt", "a")
		Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] GOSSIP бандита вызван "..player:GetName().."\n")
		Log_file:close()
	--	--
		player:GossipClearMenu()
		if player:HasQuest( quest_id ) then
			player:GossipSetText( "У меня тут в кустах парочка ребят и они шустро намнут вам бока, приятель. В этих ящиках лежит оружие для тупоголовых вояк, но оно нужно нам.\n\nМожет договоримся? Я щедро заплачу.", 27102002 )
			player:GossipMenuAddItem( 0, "<Сразиться с бандитом.>", 0, 1 )
			player:GossipMenuAddItem( 0, "<Отдать дилижанс.>", 0, 2 )
			player:GossipMenuAddItem( 0, "Пропусти нас и я заплачу тебе 10 серебряников.", 0, 3, false, "Этот человек явно не из тех, кто держит своё слово. Он может обмануть вас.", 1000 )
			player:GossipSendMenu( 27102002, creature )
		else
			player:GossipSetText( "Я не с тобой разговариваю, приятель.", 27102001 )
			player:GossipSendMenu( 27102001, creature )
		end
	else
	--	Реакция на выбранный вариант
		--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
		local Log_file = io.open("StagecoachLog.txt", "a")
		Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] Вариант "..intid.." GOSSIPa выбрал "..player:GetName().."\n")
		Log_file:close()
	--	--
		if intid == 1 then
		--	Сражение
			creature:SetFaction(411)
			creature:Attack(player)
			creature:SendUnitSay( "Бей богачей!", 0 )
			for i = 1, 3 do
			--	Спавн трёх бандитов
				local bandit = creature:SpawnCreature( entry_bandit, -9651.8, 237.1, 48, 1, 2, 300000 )
				bandit:Attack(player)
			end
			defeatedPlayers = {}
		elseif intid == 2 then
		--	Игрок сдаётся
			creature:SendUnitSay( "Правильный выбор, - Мужчина выхватывает ружьё и стреляет в извозчика.", 0 )
			local cabbie = creature:GetNearestCreature( 30, entry_cabbie )
			creature:CastSpell( cabbie, 61862 )
			local stagecoach = creature:GetNearestCreature( 30, entry_stagecoach )
			timedFunction( SCENE_CabbieDeath, 1.5 )
			local players = creature:GetPlayersInRange(20)
			if players then
				for i = 1, #players do
					if players[i]:HasQuest(quest_id) then
						players[i]:FailQuest(quest_id)
						players[i]:RemoveQuest(quest_id)
						--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
							local Log_file = io.open("StagecoachLog.txt", "a")
							Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] Переход на ветку бандитов "..players[i]:GetName().."\n")
							Log_file:close()
						--	--
					end
				end
			end
		else
		--	ПОПЫТКА дать взятку
			player:ModifyMoney(-1000)
			if math.random(1,100) >= 50 then
			--	Прокатило. Дилижанс пропускают.
				creature:SendUnitSay( "Десять серебра? Ладно, в этот раз вам повезло, но в следующий раз заплатите больше.", 0 )
				creature:DespawnOrUnsummon(5000)
				local stagecoach = creature:GetNearestCreature( 30, entry_stagecoach )
				if stagecoach then
					local badNPC = stagecoach:GetNearestCreature( 10, 385 )
					badNPC:DespawnOrUnsummon(0)
					badNPC = stagecoach:GetNearestCreature( 10, 385 )
					badNPC:DespawnOrUnsummon(0)
					badNPC = stagecoach:GetNearestCreature( 10, 9916334 )
					badNPC:DespawnOrUnsummon(0)
					badNPC = stagecoach:GetNearestCreature( 10, entry_cabbie )
					badNPC:DespawnOrUnsummon(0)
					local x,y,z = stagecoach:GetLocation()
					guardsStagecoach = stagecoach:SpawnCreature( entry_stagecoach_guardsBranch, x, y, z, 3.1, 2, 300000 ) -- Деспавн через 5 минут
					stagecoach:DespawnOrUnsummon(0)
					local logOnRoad = guardsStagecoach:GetNearestGameObject( 50, entry_log )
					local cabbie = guardsStagecoach:GetNearestCreature( 10, entry_cabbie )
					if logOnRoad then
						cabbie:SendUnitSay( "Быстрее, убери бревно с дороги!", 0 )
					else
						cabbie:SendUnitSay( "Запрыгивай ко мне! Мы должны срочно доложить об этом в гарнизон!", 0 )
						guardsStagecoach:MoveWaypoint()
					end
					--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
						local Log_file = io.open("StagecoachLog.txt", "a")
						Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] "..player:GetName().." удачно даёт взятку. Бревно: "..tostring(logOnRoad).."\n")
						Log_file:close()
					--	--
				end
			else
			--	Не прокатило. Драка
				creature:SetFaction(411)
				creature:Attack(player)
				creature:SendUnitSay( "Думаешь что сможешь меня обдурить?!", 0 )
				for i = 1, 3 do
				--	Спавн трёх бандитов
					local bandit = creature:SpawnCreature( entry_bandit, -9650+i, 237.1, 50, 1, 2, 300000 )
					bandit:Attack(player)
				end
				defeatedPlayers = {}
				--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
					local Log_file = io.open("StagecoachLog.txt", "a")
					Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] "..player:GetName().." неудачно даёт взятку.\n")
					Log_file:close()
				--	--
			end
		end
		local players = creature:GetPlayersInRange(50)
		savedPlayers = {}
		for i = 1, #players do
			table.insert( savedPlayers, players[i]:GetName() )
			--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
				local Log_file = io.open("StagecoachLog.txt", "a")
				Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] "..players[i]:GetName().." сохранён.\n")
				Log_file:close()
			--	--
		end
		player:GossipComplete()
		creature:SetData( "DialogueCompleted", true )
	end
end
RegisterCreatureGossipEvent( entry_banditLeader, 1, BANDITLEADER_Gossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( entry_banditLeader, 2, BANDITLEADER_Gossip ) -- GOSSIP_EVENT_ON_SELECT

local function pizduyCommand( event, player, command )
	if command == "pizduy" and player:GetGMRank() > 1 then
		local target = player:GetSelection()
		if target then
			target:MoveWaypoint()
			player:SendBroadcastMessage("бля")
		end
	end
end
RegisterPlayerEvent( 42, pizduyCommand ) -- PLAYER_EVENT_ON_COMMAND

local function LOG_Despawn( event, object, player )
	if not object:GetData("Stage") then object:SetData( "Stage", 1 ) end
	local stage = object:GetData("Stage")
	if stage < 5 then
		player:SendAreaTriggerMessage("Бревно трещит... ["..stage.."/5]")
		object:SetData( "Stage", stage+1 )
	else
		player:SendAreaTriggerMessage("Бревно с треском ломается!")
		
		local stagecoach = object:GetNearestCreature( 50, entry_stagecoach_guardsBranch )
		if stagecoach then stagecoach:MoveWaypoint() end
		
		object:RemoveFromWorld(true)
	end
	player:Emote(389)
	player:CastSpell( player, 33016)
	--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
		local Log_file = io.open("StagecoachLog.txt", "a")
		Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] "..player:GetName().." ломает бревно.\n")
		Log_file:close()
	--	--
end
RegisterGameObjectEvent( entry_log, 14, LOG_Despawn ) -- GAMEOBJECT_EVENT_ON_USE

local function Battle_DefeatCondition( event, creature, victim )
--	Поиск выживших игроков поблизости
	table.insert( defeatedPlayers, victim:GetName() )
	local players = creature:GetPlayersInRange( 25, 1, 1 )
	if players then
		for i = 1, #players do
			if players[i]:HasQuest(quest_id) then return end
		end
	end
	for i = 1, #defeatedPlayers do
		local player = GetPlayerByName(defeatedPlayers[i])
		if player then
			player:FailQuest(quest_id)
			--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
				local Log_file = io.open("StagecoachLog.txt", "a")
				Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] "..player:GetName().." не смог защитить дилижанс.\n")
				Log_file:close()
			--	--
		end
	end
end
RegisterCreatureEvent( entry_bandit, 3, Battle_DefeatCondition ) -- CREATURE_EVENT_ON_TARGET_DIED
RegisterCreatureEvent( entry_banditLeader, 3, Battle_DefeatCondition ) -- CREATURE_EVENT_ON_TARGET_DIED

local function Battle_WinCondition( event, creature, player )
	local bandit = creature:GetNearestCreature( 50, entry_bandit )
	local banditLeader = creature:GetNearestCreature( 50, entry_banditLeader )
	if not bandit and not banditLeader then
	--	Все враги поблизости мертвы
		local stagecoach = creature:GetNearestCreature( 50, entry_stagecoach )
		if stagecoach then
		--	Если не слишком далеко от повозки
			local badNPC = stagecoach:GetNearestCreature( 10, 385 )
			badNPC:DespawnOrUnsummon(0)
			badNPC = stagecoach:GetNearestCreature( 10, 385 )
			badNPC:DespawnOrUnsummon(0)
			badNPC = stagecoach:GetNearestCreature( 10, 9916334 )
			badNPC:DespawnOrUnsummon(0)
			badNPC = stagecoach:GetNearestCreature( 10, entry_cabbie )
			badNPC:DespawnOrUnsummon(0)
			local x,y,z = stagecoach:GetLocation()
			guardsStagecoach = stagecoach:SpawnCreature( entry_stagecoach_guardsBranch, x, y, z, 3.1, 2, 300000 ) -- Деспавн через 5 минут
			stagecoach:DespawnOrUnsummon(0)
			local logOnRoad = guardsStagecoach:GetNearestGameObject( 50, entry_log )
			local cabbie = guardsStagecoach:GetNearestCreature( 10, entry_cabbie )
			if logOnRoad then
				cabbie:SendUnitSay( "Быстрее, убери бревно с дороги!", 0 )
			else
				cabbie:SendUnitSay( "Запрыгивай ко мне! Мы должны срочно доложить об этом в гарнизон!", 0 )
				guardsStagecoach:MoveWaypoint()
			end
			--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
				local Log_file = io.open("StagecoachLog.txt", "a")
				Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] Дилижанс защищён.\n")
				Log_file:close()
			--	--
		end
	end
end
RegisterCreatureEvent( entry_bandit, 4, Battle_WinCondition ) -- CREATURE_EVENT_ON_DIED
RegisterCreatureEvent( entry_banditLeader, 4, Battle_WinCondition ) -- CREATURE_EVENT_ON_DIED

local function STAGECOACH_RideBanditsBranch( event, creature, type, id )
	--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
		local x,y,z = creature:GetLocation()
		x,y,z = string.format("%.1f", x), string.format("%.1f", y), string.format("%.1f", z)
		local Log_file = io.open("StagecoachLog.txt", "a")
		Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] .go " ..x.." "..y.." "..z.." "..creature:GetMapId().." | Waypoint: "..id.."\n")
		Log_file:close()
	--	--
	if id == 9 then
		for i = 1, #savedPlayers do
			local player = GetPlayerByName(savedPlayers[i])
			if player then
				player:CompleteQuest( quest_id2 )
				--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
					local Log_file = io.open("StagecoachLog.txt", "a")
					Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] "..player:GetName().." Выполнил задание у бандитов.\n")
					Log_file:close()
				--	--
			end
		end
		creature:MoveStop()
		creature:SetRooted(true)
		creature:DespawnOrUnsummon(4000)
	end
end
RegisterCreatureEvent( entry_stagecoach_banditsBranch, 6, STAGECOACH_RideBanditsBranch ) -- CREATURE_EVENT_ON_REACH_WP

local function CAPTAIN_Gossip( event, player, creature, sender, intid )
	local stagecoach = creature:GetNearestCreature( 25, entry_stagecoach )
	local captain = creature:GetNearestCreature( 25, entry_captain )
	if event == 1 then
		player:GossipClearMenu()
		if stagecoach and player:HasQuest(quest_id) then
			player:GossipSetText( "Каждые несколько часов здесь отходит дилижанс с важным грузом.\n\nЕму, кстати, уже пора.", 28102001 )
			player:GossipMenuAddItem( 0, "<Начать задание.>", 1, 1, false, "Вы уверены что хотите начать?\nЭто задание не выполнить в одиночку - не забудьте найти себе хорошую компанию.")
		elseif not stagecoach and player:HasQuest(quest_id) then
			player:GossipSetText( "Каждые несколько часов здесь отходит дилижанс с важным грузом.\n\nЕсли хочешь помочь - дождись следующей повозки.", 28102001 )
		else
			player:GossipSetText( "Каждые несколько часов здесь отходит дилижанс с важным грузом.\n\nЕсли хочешь помочь - дождись следующей повозки и запишись у меня в список добровольцев.", 28102001 )
		end
		player:GossipAddQuests( creature )
		player:GossipSendMenu( 28102001, creature )
	else
		if stagecoach and not stagecoach:GetData("Active") then
			creature:SendUnitSay( "Дилижанс отправляется! Не отставайте от него и будьте ответственны в пути.", 0 )
			player:GossipComplete()
			stagecoach:SetRooted(false)
			stagecoach:MoveWaypoint()
			stagecoach:SetData( "Active", true )
			local players = creature:GetPlayersInRange(30)
			if players then
				for i = 1, #players do
					if players[i]:HasQuest(quest_id) then
						players[i]:SendAreaTriggerMessage("Дилижанс отправляется. Сопроводите его!")
						players[i]:SetData( "HasStagecoachRideQuest", true )
						--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
							local Log_file = io.open("StagecoachLog.txt", "a")
							Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] "..players[i]:GetName().." начал сопровождение.\n")
							Log_file:close()
						--	--
					end
				end
			end
		end
	end
end
RegisterCreatureGossipEvent( entry_captain, 1, CAPTAIN_Gossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( entry_captain, 2, CAPTAIN_Gossip ) -- GOSSIP_EVENT_ON_SELECT

local function STAGECOACH_OnSpawn( event, creature )
	creature:SetData( "Active", false )
	local guard = creature:GetNearestCreature( 25, entry_captain )
	if guard then
		guard:SendUnitSay( "Новая повозка прибыла! Всем храбрецам - готовсь. Поговорите со мной, когда будете готовы.", 0 )
		--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
			local x,y,z = creature:GetLocation()
			x,y,z = string.format("%.1f", x), string.format("%.1f", y), string.format("%.1f", z)
			local Log_file = io.open("StagecoachLog.txt", "a")
			Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] .go " ..x.." "..y.." "..z.." "..creature:GetMapId().." | Дилижанс заспавнился.\n")
			if creature:GetData("Active") then
				Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] .go " ..x.." "..y.." "..z.." "..creature:GetMapId().." | Дилижанс заспавнился в активном состоянии.\n")
			end
			Log_file:close()
		--	--
	end
end
RegisterCreatureEvent( entry_stagecoach, 5, STAGECOACH_OnSpawn ) -- CREATURE_EVENT_ON_SPAWN

local function CAPTAIN_WhenPlayerTakenQuest( event, player, creature, quest )
	player:SendBroadcastMessage("Поговорите с повозчиком, когда будете готовы начать поездку.")
	--	--	ВРЕМЕННОЕ ЛОГИРОВАНИЕ ПРОИСХОДЯЩЕГО
		local Log_file = io.open("StagecoachLog.txt", "a")
		Log_file:write("Time: ["..os.date("%d.%m %H:%M:%S").."] "..player:GetName().." взял стартовый квест.\n")
		Log_file:close()
	--	--
end
RegisterCreatureEvent( entry_captain, 31, CAPTAIN_WhenPlayerTakenQuest ) -- CREATURE_EVENT_ON_QUEST_ACCEPT
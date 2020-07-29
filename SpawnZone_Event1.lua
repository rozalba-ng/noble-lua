--[[	ВРЕМЕННЫЙ ИВЕНТ НА ЛУННОЙ ПОЛЯНЕ - КВЕСТ С NPC-ГНОМОМ	]]--

-- Таблица с прогрессом квеста
local questProgress = {}

-- ID гнома:
local GNOME_ENTRY = 9925038
local gnome_guid
local summonedCreatures = {}

-- ID ветролёта:
local HELICOPTER_ENTRY = 9925037
-- Таймеры до событий при полёте на ветролёте: (Робот и генератор обнаружены, инструменты обнаружены, игрок прилетел)
local helicopter_timer = { 12, 31, 55 }
-- Маршрут ветролёта - Сгенерировано через .taxi txt
local helicopter_path_table = { { 1, 7892.9, -2577.9, 490.5 }, { 1, 7865.3, -2549.4, 493.3 }, { 1, 7831.7, -2503.1, 543.3 }, { 1, 7799.4, -2419.4, 535.8 }, { 1, 7842.8, -2258.9, 545.5 }, { 1, 7824.3, -2185.4, 549.3 }, { 1, 7803.4, -2132.6, 534.0 }, { 1, 7763.8, -2112.8, 520.3 }, { 1, 7710.3, -2127.3, 512.8 }, { 1, 7637.1, -2184.2, 512.0 }, { 1, 7587.8, -2224.3, 509.7 }, { 1, 7518.1, -2262.1, 518.3 }, { 1, 7482.7, -2288.9, 526.3 }, { 1, 7463.1, -2367.9, 537.2 }, { 1, 7463.4, -2454.7, 526.7 }, { 1, 7473.0, -2562.4, 525.1 }, { 1, 7483.5, -2613.1, 535.8 }, { 1, 7541.9, -2685.1, 521.0 }, { 1, 7660.5, -2710.2, 508.7 }, { 1, 7767.7, -2669.2, 507.5 }, { 1, 7841.1, -2638.5, 503.6 }, { 1, 7864.4, -2611.8, 498.0 }, { 1, 7880.7, -2590.9, 493.9 }, { 1, 7892.4, -2580.0, 491.6 }, }
local helicopter_path = AddTaxiPath(helicopter_path_table, 24653, 24653)

-- ID робота:
local ROBOT_ENTRY = 9925040
local robot_timer = 16 -- Кол-во секунд дающееся на доставку робота к генератору (А пишет, что 15. Мы обманули игроков ради положительных эмоций)
-- Позиция перед гномом (Сдача робота владельцу)
local robot_position = { 7892.4, -2579.5, 487.2 }
-- ID генератора:
local GENERATOR_ENTRY = 5047777
local generator_spell = 64768 -- Молнии, блеск вокруг робота.

-- ID сундука с инструментами (Госсип или просто юзабельная гошка):
local TOOLS_ENTRY = 5047776

-- Количество стадий квеста (Сохраняются у игрока):
local QUEST_MAX_STAGE = 3
-- Лотерейный билет
local reward = 2113737

-- Текст всех реплик:
local text = {
	hello = {
		chat = "Эй! Я часто вижу тебя здесь. Не найдётся ли у тебя свободной минутки?",
		system = "|cffffcc00Найдите гнома|r и |cffffcc00взаимодействуйте с ним|r, если хотите помочь ему.",
		},
	continue = "Привет! Ну, как там с нашим дельцем?", -- Если игрок забил болт на квест.
	briefing = {
		"\nЯ знал, что ты не оставишь хорошего парня в злых руках судьбы. Не волнуйся, моё поручение не займёт много времени. Видишь ли, моя сумка порвалась и я потерял несколько важных мне вещей. В том числе и очки! А без них я ни капельки не вижу. Ты же не оставишь меня в беде, верно?",
		"\nИ так, если отбросить самое ненужное...\n|cffffcc00 1.|r Мне нужен мой сундучок с инструментами. Я думаю, что мои очки лежат там.\n|cffffcc00 2.|r Не обойтись и без помогатора 202020! Негодник разрядился и не отвечает на команды пульта.\n|cffffcc00 3.|r Мини-генератор! Помогатор не зарядится без него.\n|cffffcc00 4.|r В целом сам генератор мне не нужен, он устарел и слишком громоздкий. Заряди возле него помогатора и возвращайся ко мне!\nДа.. Не пугайся трудностей. Мой ветролёт снабжён датчиком - я прокачу тебя и ты быстро поймёшь, где искать эти предметы!",
		"А ты из смельчаков, да? Круто! Садись в ветролёт, когда будешь готов.",
		},
	preparation_flying = { -- Болтовня перед полётом
		"Мягкое сиденье, да? Ничего не трогай, пожалуйста! Машиной управляю я - через пульт!",
		"Так... Подожди, я плохо вижу без очков. А тут много кнопок!",
		"Ой! Извини, сейчас я найду нужный рычажок.",
		"Вот, кажется он. Приятного полёта!",
		},
	helicopter_flying = {
		"Радар подаёт первый сигнал! Кажется |cffffcc00инструменты гнома|r около |cffffcc00рынка ездовых животных|r.",
		"Радар подаёт два сигнала подряд! Видимо |cffffcc00робот|r затерялся |cffffcc00в лесу|r и |cffffcc00генератор|r находится рядом с ним.",
		"Добро пожаловать обратно! Ты уж прости, но парашют не предусмотрен - искать вещи придётся пешком. Я буду ждать тебя здесь!",
		},
	item_search = {
		"Хочешь прокатиться на ветролёте ещё раз? Прыгай в седло!\n",
		"Не забудь зарядить робота у генератора и привести его ко мне.\n",
		"И верни мне, пожалуйста, мои инструменты.",
		},
	robot = {
		gossip = "11010000 10100010 11010000 10110101 11010001 10000000 11010000 10111100 11010000 10111000 11010000 10111101 11010000 10110000 11010001 10000010 11010000 10111110 11010001 10000000 100000 101101 100000 11010000 10111100 11010000 10111110 11010000 10111001 100000 11010000 10111010 11010001 10000011 11010000 10111100 11010000 10111000 11010001 10000000|r\n<Кажется заряд робота вот-вот иссякнет. Он несёт какую-то неразбериху.>\n...\n<Вы уже нашли аккумулятор?>",
		run = "Робот быстро разряжается!\nПриведите его к генератору за |cffffcc0015|r секунд!",
		click = { -- Количество фраз можно безопасно изменять
			"Gjnjhjgbvcz!",
			"Rfrjq ctqxfc rjl&",
			"[{} ] _. [{} ]",
			"...",
			"111 _ 0 6 44 999 _ 222 666 77 _ 111 _ 6 5 _ 6 44 333 666 77 111 9 555 1",
			},
		fail = "|cffff6060Робот разряжается и исчезает!|r\nМожет быть он вернулся на своё старое место?",
		chat = "Я функционирую, следовательно, я существую.",
		charged = "Робот заряжен!\nТеперь вы можете отвести его к гному.",
		},
	tools = "Сундучок с инструментами найден.\nТеперь вы можете отнести его к гному.",
	final = {
		robot = { -- Робот
			"Помогатор, ты вернулся!", -- Гном
			"...", -- Робот
			"Где же ты пропадал?", -- Гном
			},
		tools = {-- Инструменты
			"Мои инструменты..",
			"Ты творишь чудеса, юный сыщик!",
			},
		reward = { -- Всё найдено
			"Я благодарен тебе за помощь!",
			"Сейчас я разберу свой бардак и отправлю тебе пару интересных штук...",
			"Не забудь проверить почтовый ящик, надеюсь ты не разочаруешься.",
			},
		mail = {
			subject = "Награда за помощь.",
			text = "Привет, друг! Надеюсь, что ты не успел соскучиться по мне.\nДумаю что эти вещички пригодятся в твоих странствиях. Не уверен насчёт карточки, но она выглядит древней. У меня таких полный сундук. Без понятия, откуда они там взялись.\nНо ты мог бы попробовать собирать их! За всякие добрые дела.\nНе скучай!\n\n    Твой Сэмми.",
			},
		gossip = "Как поживаешь?" ,
		}
	}

--[[	ObjectData

SpawnZoneEvent_1_Stage		- Стадия квеста от 0 до 3. 
0 - не начат. 1 - начат и можно летать на вертолёте. 2 - полет совершен и можно собирать вещи. 3 - квест завершен.

SpawnZoneEvent_1_Dialogue	- Пройденная страница диалога при общении с гномом через госсип
SpawnZoneEvent_1_Start		- Спам сообщение гнома в чат отправлено
SpawnZoneEvent_1_Continue	- Аналогично для предложения продолжить

SpawnZoneEvent_1_RobotRun	- Робот начал бежать с игроком
SpawnZoneEvent_1_RobotDelivered		- Робот доставлен

SpawnZoneEvent_1_Preparation		- Стадия подготовки к полету на вертолете

Charged						- Робот заряжен у генератора

SpawnZoneEvent_1_Tools_Found		- Игрок несет инструменты
SpawnZoneEvent_1_Tools_Delivered	- Игрок сдал инструменты

SpawnZoneEvent_1_GnomeMonologue		- Гном сейчас принимает робота/инструменты и не может принять другой предмет. (Чтобы не говорил сразу 2 диалога)
SpawnZoneEvent_1_Robot		- Стадия монолога при получении робота
SpawnZoneEvent_1_Tools		- Аналогично для инструментов

]]

local function UpdateQuestStage( self, stage )
	local accountID = self:GetAccountId()
	questProgress[accountID] = stage
	self:SetData( "SpawnZoneEvent_1_Stage", stage )
	local Q = WorldDBQuery("SELECT account FROM birthday_quest WHERE account = "..accountID)
	if Q then
		WorldDBQuery("UPDATE birthday_quest SET quest_stage = '"..stage.."' WHERE account = "..accountID)
	else
		WorldDBQuery("INSERT INTO birthday_quest ( account, quest_stage ) VALUES ('"..accountID.."','"..stage.."')")
	end
end

--[[	ОБЩЕНИЕ С ГНОМОМ	]]--

local function GOSSIP_Gnome(event, player, creature, sender, intid, code)
	if ( event == 1 ) then -- При клике на гнома
		if not player:GetData("SpawnZoneEvent_1_Stage") or player:GetData("SpawnZoneEvent_1_Stage") == 1 then
			player:GossipClearMenu()
			player:GossipMenuAddItem( 7, "У меня как раз есть свободная минутка!", 1, 1 )
			player:GossipMenuAddItem( 0, "Я вернусь позже.", 1, 2 )
			player:GossipSetText( text.briefing[1], 2020001 )
			player:GossipSendMenu( 2020001, creature )
			player:SetData("SpawnZoneEvent_1_Dialogue",1)
		elseif player:GetData("SpawnZoneEvent_1_Stage") == 2 then -- Игрок торчит поиск предметов
			player:GossipClearMenu()
			local gossipText = text.item_search[1]
			if not player:GetData("SpawnZoneEvent_1_RobotDelivered") then -- Игрок ещё не привёл робота
				gossipText = ( gossipText..(text.item_search[2]) )
			end
			if not player:GetData("SpawnZoneEvent_1_Tools_Delivered") then -- Игрок ещё не принес инструменты
				gossipText = ( gossipText..(text.item_search[3]) )
			end
			player:GossipSetText( gossipText, 2020003 )
			player:GossipSendMenu( 2020003, creature )
		elseif player:GetData("SpawnZoneEvent_1_Stage") == 3 then
			player:GossipClearMenu()
			player:GossipSetText( text.final.gossip, 2020005 )
			player:GossipSendMenu( 2020005, creature )
		end
	elseif ( event == 2 ) then -- При выборе пункта меню
		if not player:GetData("SpawnZoneEvent_1_Stage") or player:GetData("SpawnZoneEvent_1_Stage") == 1 then
			-- 1 страница
			if player:GetData("SpawnZoneEvent_1_Dialogue") == 1 then
				if intid == 1 then
					player:GossipMenuAddItem( 5, "<Кивнуть при упоминании ветролёта.>", 1, 1 )
					player:GossipMenuAddItem( 0, "<Задумчиво отойти в сторонку.>", 1, 2 )
					player:GossipSetText( text.briefing[2], 2020002 )
					player:GossipSendMenu( 2020002, creature )
					player:SetData("SpawnZoneEvent_1_Dialogue",2)
				else
					player:GossipComplete()
				end
			-- 2 страница
			elseif player:GetData("SpawnZoneEvent_1_Dialogue") == 2 then
				if intid == 1 then
					player:GossipComplete()
					UpdateQuestStage(player,1)
					creature:SendChatMessageToPlayer( 12, 0, text.briefing[3], player )
				else
					player:GossipComplete()
				end
			end
		end
	end
end
RegisterCreatureGossipEvent( GNOME_ENTRY, 1, GOSSIP_Gnome )
RegisterCreatureGossipEvent( GNOME_ENTRY, 2, GOSSIP_Gnome )

local function AIUPD_GnomeHello(event, creature)
	if (os.time()%3) == 0 then
		gnome_guid = saveCreature(creature)
		local NearPlayers = creature:GetPlayersInRange(14) -- 14 - Дистанция.
		for _,player in pairs(NearPlayers) do
			if not player:GetData("SpawnZoneEvent_1_Stage") and not player:GetData("SpawnZoneEvent_1_Start") then
				creature:SendChatMessageToPlayer( 12, 0, text.hello.chat, player )
				player:SendBroadcastMessage(text.hello.system)
				player:SendAreaTriggerMessage(text.hello.system)
				player:SetData("SpawnZoneEvent_1_Start",true)
			elseif player:GetData("SpawnZoneEvent_1_Stage") and not player:GetData("SpawnZoneEvent_1_Continue") and not player:GetData("SpawnZoneEvent_1_Start") then
				if player:GetData("SpawnZoneEvent_1_Stage") < QUEST_MAX_STAGE then
					creature:SendChatMessageToPlayer( 12, 0, text.continue, player )
					player:SetData("SpawnZoneEvent_1_Continue",true)
				end
			end
			if player:GetData("SpawnZoneEvent_1_Stage") == 2 then -- Сдача робота и инструментов
				if player:GetData("SpawnZoneEvent_1_RobotRun") and not player:GetData("SpawnZoneEvent_1_GnomeMonologue") then -- Робот
					local robot = loadCreature(summonedCreatures[player:GetName()])
					if robot and robot:GetData("Charged") then
						player:SetData("SpawnZoneEvent_1_RobotRun",false)
						player:SetData("SpawnZoneEvent_1_GnomeMonologue",true)
						timedFunction(GNOME_FinalDialogue,2,player:GetName(),"robot")
						robot:MoveTo( 2020200, robot_position[1], robot_position[2], robot_position[3] )
					end
				elseif player:GetData("SpawnZoneEvent_1_Tools_Found") and not player:GetData("SpawnZoneEvent_1_GnomeMonologue") then -- Инструменты
					player:SetData("SpawnZoneEvent_1_Tools_Found",false)
					player:SetData("SpawnZoneEvent_1_GnomeMonologue",true)
					timedFunction(GNOME_FinalDialogue,1,player:GetName(),"tools")
				elseif player:GetData("SpawnZoneEvent_1_Tools_Delivered") and player:GetData("SpawnZoneEvent_1_RobotDelivered") and not player:GetData("SpawnZoneEvent_1_GnomeMonologue") then -- Все цели выполнены
					player:SetData("SpawnZoneEvent_1_GnomeMonologue",true)
					timedFunction(GNOME_FinalDialogue,2,player:GetName(),"reward")
				end
			end
		end
	end
end
RegisterCreatureEvent( GNOME_ENTRY, 7 , AIUPD_GnomeHello )

function GNOME_FinalDialogue(playerName,typeVar)
	local gnome = loadCreature(gnome_guid)
	local player = GetPlayerByName(playerName)
	if player and gnome then
		if typeVar == "robot" then
			local robot = loadCreature(summonedCreatures[player:GetName()])
			local stage = player:GetData("SpawnZoneEvent_1_Robot")
			if not stage then
				gnome:SendChatMessageToPlayer( 12, 0, text.final.robot[1], player )
				player:SetData("SpawnZoneEvent_1_Robot",2)
			elseif stage == 2 then
				robot:SendChatMessageToPlayer( 12, 0, text.final.robot[2], player )
				player:SetData("SpawnZoneEvent_1_Robot",3)
			elseif stage == 3 then
				gnome:SendChatMessageToPlayer( 12, 0, text.final.robot[3], player )
				player:SetData("SpawnZoneEvent_1_Robot",4)
			else
				robot:SendChatMessageToPlayer( 12, 0, text.final.robot[2], player )
				player:SetData("SpawnZoneEvent_1_Robot",nil)
				robot:DespawnOrUnsummon(2000)
				player:SetData("SpawnZoneEvent_1_RobotDelivered",true)
				player:SetData("SpawnZoneEvent_1_GnomeMonologue",false)
				return
			end
		elseif typeVar == "tools" then
			local stage = player:GetData("SpawnZoneEvent_1_Tools")
			if not stage then
				gnome:SendChatMessageToPlayer( 12, 0, text.final.tools[1], player )
				player:SetData("SpawnZoneEvent_1_Tools",2)
			else
				gnome:SendChatMessageToPlayer( 12, 0, text.final.tools[2], player )
				player:SetData("SpawnZoneEvent_1_Tools_Delivered",true)
				player:SetData("SpawnZoneEvent_1_GnomeMonologue",false)
				player:SetData("SpawnZoneEvent_1_Tools",nil)
				return
			end
		elseif typeVar == "reward" then
			local stage = player:GetData("SpawnZoneEvent_1_Reward")
			if not stage then
				gnome:SendChatMessageToPlayer( 12, 0, text.final.reward[1], player )
				player:SetData("SpawnZoneEvent_1_Reward",2)
			elseif stage == 2 then
				gnome:SendChatMessageToPlayer( 12, 0, text.final.reward[2], player )
				player:SetData("SpawnZoneEvent_1_Reward",3)
			else
				gnome:SendChatMessageToPlayer( 12, 0, text.final.reward[3], player )
				player:SetData("SpawnZoneEvent_1_Reward",nil)
				-- Отправка письма с наградой:
				SendMail( (text.final.mail.subject), (text.final.mail.text), player:GetGUIDLow(), 0, 41, 0, 0, 0, reward, 2 )
				UpdateQuestStage(player,3)
				player:SetData("SpawnZoneEvent_1_GnomeMonologue",false)
				return
			end
		end
		timedFunction(GNOME_FinalDialogue,3.5,playerName,typeVar)
	end
end

--[[	ВЕТРОЛЁТ	]]--
local function GOSSIP_Helicopter(event, player, creature)
	if player:GetData("SpawnZoneEvent_1_Stage") and player:GetData("SpawnZoneEvent_1_Stage") < QUEST_MAX_STAGE then
		if not player:IsMounted() then
			local x, y, z, o = creature:GetLocation() -- Координаты ветролёта
			player:SetRooted(true)
			player:MoveJump( x, y, z, 15, 5 )
			player:Mount(22719)
			gnome = loadCreature(gnome_guid)
			gnome:SendChatMessageToPlayer( 12, 0, text.preparation_flying[1], player )
			timedFunction(PreparationFlying_Helicopter,3,player:GetName())
		else
			player:SendBroadcastMessage("|cffFF8040"..creature:GetName().." недовольно тарахтит. Покиньте текущий транспорт!")
		end
	end
end
RegisterCreatureGossipEvent( HELICOPTER_ENTRY, 1, GOSSIP_Helicopter )
	
function PreparationFlying_Helicopter(playerName)
	local player = GetPlayerByName(playerName)
	local gnome = loadCreature(gnome_guid)
	if player and gnome then
		local stage = player:GetData("SpawnZoneEvent_1_Preparation")
		if not stage or stage == 4 then
			player:SetData("SpawnZoneEvent_1_Preparation",2)
			gnome:SendChatMessageToPlayer( 12, 0, text.preparation_flying[2], player )
		elseif stage == 2 then
			player:SetData("SpawnZoneEvent_1_Preparation",3)
			player:SendBroadcastMessage("Ловкое действие "..gnome:GetName().." против "..player:GetName().." |cff71C671удачно|r.\n(26+"..math.random(3,8).." |cff71C671>=|r "..player:GetRoleStat(5).."+"..math.random(3,8)..")")
			gnome:SendChatMessageToPlayer( 12, 0, text.preparation_flying[3], player )
		else
			player:SetData("SpawnZoneEvent_1_Preparation",4)
			gnome:SendChatMessageToPlayer( 12, 0, text.preparation_flying[4], player )
			player:SetRooted(false)
			player:StartTaxi(helicopter_path)
			timedFunction(HELICOPTER_EVENT2,helicopter_timer[1],playerName)
			timedFunction(HELICOPTER_EVENT1,helicopter_timer[2],playerName)
			timedFunction(HELICOPTER_EVENT3,helicopter_timer[3],playerName)
			return
		end
		timedFunction(PreparationFlying_Helicopter,5,playerName)
	end
end

function HELICOPTER_EVENT1(playerName)
	local player = GetPlayerByName(playerName)
	if player then
		player:SendBroadcastMessage(text.helicopter_flying[1])
		player:SendAreaTriggerMessage(text.helicopter_flying[1])
	end
end

function HELICOPTER_EVENT2(playerName)
	local player = GetPlayerByName(playerName)
	if player then
		player:SendBroadcastMessage(text.helicopter_flying[2])
		player:SendAreaTriggerMessage(text.helicopter_flying[2])
	end
end

function HELICOPTER_EVENT3(playerName)
	local player = GetPlayerByName(playerName)
	local gnome = loadCreature(gnome_guid)
	if player and gnome then
		gnome:SendChatMessageToPlayer( 12, 0, text.helicopter_flying[3], player )
		UpdateQuestStage(player,2)
	end
end

--[[	РОБОТ	]]--
local function GOSSIP_Robot(event, player, creature, sender, intid, code)
	if ( event == 1 ) then -- При клике на робота
		if player:GetData("SpawnZoneEvent_1_Stage") == 2 then
			if not player:GetData("SpawnZoneEvent_1_RobotRun") and not player:GetData("SpawnZoneEvent_1_RobotDelivered") then
				player:GossipClearMenu()
				player:GossipMenuAddItem( 5, "<Вести робота к генератору.>", 1, 1 )
				player:GossipMenuAddItem( 0, "Я ещё вернусь, друг.", 1, 2 )
				player:GossipSetText( ("|cff"..math.random(100000,0xFFFFFF)..(text.robot.gossip)), 2020004 )
				player:GossipSendMenu( 2020004, creature )
			elseif not player:GetData("SpawnZoneEvent_1_RobotDelivered") and player:GetData("SpawnZoneEvent_1_RobotRun") then
				local randomNum = math.random(1,#text.robot.click)
				creature:SendChatMessageToPlayer( 12, 0, text.robot.click[randomNum], player )
			end
		end
	elseif ( event == 2 ) then -- При выборе пункта меню
		if intid == 1 then
			player:GossipComplete()
			player:SendBroadcastMessage(text.robot.run)
			player:SendAreaTriggerMessage(text.robot.run)
			player:SetData("SpawnZoneEvent_1_RobotRun",true)
			local x,y,z,o = creature:GetLocation()
			-- ЕСЛИ NPC ПРОПАДАЕТ РАНЬШЕ ВРЕМЕНИ:
			local robot = player:SpawnCreature( ROBOT_ENTRY, x, y, z, o, 3, (robot_timer*1100) ) -- <- МЕНЯТЬ ЗДЕСЬ (1070 дефолт)
			robot:MoveFollow( player, -2 )
			local playerName = player:GetName()
			summonedCreatures[playerName] = saveCreature(robot)
			timedFunction(ROBOT_EVENT,robot_timer,playerName)
		elseif intid == 2 then
			player:GossipComplete()
		end
	end
end
RegisterCreatureGossipEvent( ROBOT_ENTRY, 1, GOSSIP_Robot )
RegisterCreatureGossipEvent( ROBOT_ENTRY, 2, GOSSIP_Robot )
	
function ROBOT_EVENT(playerName)
	local player = GetPlayerByName(playerName)
	local robot = loadCreature(summonedCreatures[playerName])
	if player and robot then
		if not robot:GetData("Charged") then
			player:SendAreaTriggerMessage(text.robot.fail)
			player:SendBroadcastMessage(text.robot.fail)
			player:SetData("SpawnZoneEvent_1_RobotRun",false)
		end
	end
end

function ROBOT_EVENT2(playerName)
	local player = GetPlayerByName(playerName)
	local robot = loadCreature(summonedCreatures[playerName])
	if player and robot then
		robot:CastSpell( robot, generator_spell, false )
	end
end

function ROBOT_EVENT3(playerName)
	local player = GetPlayerByName(playerName)
	local robot = loadCreature(summonedCreatures[playerName])
	if player and robot then
		robot:SendChatMessageToPlayer( 12, 0, text.robot.chat, player )
		player:SendAreaTriggerMessage(text.robot.charged)
		player:SendBroadcastMessage(text.robot.charged)
		robot:MoveFollow( player, -2 )
	end
end

local function AIUPD_Generator(event, go, diff)
	if (os.time()%2) == 0 then
		local NearPlayers = go:GetPlayersInRange(5) -- 5 - Дистанция.
		for _,player in pairs(NearPlayers) do
			if player:GetData("SpawnZoneEvent_1_Stage") == 2 then
				if player:GetData("SpawnZoneEvent_1_RobotRun") then
					local robot = loadCreature(summonedCreatures[player:GetName()])
					if robot then
				
						if robot:GetDistance(go) <= 5 and not robot:GetData("Charged") then
							local x, y, z, o = go:GetLocation()
							-- Избавляемся от старого робота на встречу светлому будущему.
							robot:MoveTo( 2020100, x, y, z, true )
							robot:DespawnOrUnsummon(500)
							-- Позиция робота рядом с аккумулятором.asdas
							local robot = player:SpawnCreature( ROBOT_ENTRY, x+1, y+1, z+1, o, 8 )
							robot:SetData("Charged",true)
							local playerName = player:GetName()
							summonedCreatures[playerName] = saveCreature(robot)
							timedFunction(ROBOT_EVENT2,2,playerName)
							timedFunction(ROBOT_EVENT3,8,playerName)
						end
					end
				end
			end
		end
	end
end
RegisterGameObjectEvent( GENERATOR_ENTRY, 1, AIUPD_Generator )
	
--[[	СУНДУЧОК С ИНСТРУМЕНТАМИ	]]--

local function ONCLICK_Chest(event, player, object)
	if player:GetData("SpawnZoneEvent_1_Stage") == 2 then
		if not player:GetData("SpawnZoneEvent_1_Tools_Found") and not player:GetData("SpawnZoneEvent_1_Tools_Delivered") then
			player:SetData("SpawnZoneEvent_1_Tools_Found", true)
			player:SendAreaTriggerMessage(text.tools)
			player:SendBroadcastMessage(text.tools)
		end
	end
end
RegisterGameObjectGossipEvent( TOOLS_ENTRY, 1, ONCLICK_Chest )
	
--[[	ВСЕ БАГИ - ОТ РУК ИГРОКА	]]--

local function DeleteRobot(event, player)
	if player:GetData("SpawnZoneEvent_1_RobotRun") then -- Если игрок ведёт робота.
		player:SetData("SpawnZoneEvent_1_RobotRun",false)
		local playerName = player:GetName()
		if summonedCreatures[playerName] then
			local robot = loadCreature(summonedCreatures[playerName])
			robot:DespawnOrUnsummon(500)
		end
	end
end
RegisterPlayerEvent( 4, DeleteRobot ) -- Logout
RegisterPlayerEvent( 28, DeleteRobot ) -- Map change

--[[	ЗАГРУЗА ПРОГРЕССА КВЕСТА ИЗ БД	]]--

local QuestQ = WorldDBQuery("SELECT account,quest_stage FROM birthday_quest")
if QuestQ then
	for i = 1, QuestQ:GetRowCount() do
		local account, stage = QuestQ:GetUInt32(0), QuestQ:GetUInt8(1)
		questProgress[account] = stage
		QuestQ:NextRow()
	end
	QuestQ = nil
	-- Если игроки присутствуют в игре во время перезагрузки Элуны
	local players = GetPlayersInWorld()
	for i = 1,#players do
		if questProgress[players[i]:GetAccountId()] then
			players[i]:SetData( "SpawnZoneEvent_1_Stage", questProgress[players[i]:GetAccountId()] )
		end
	end
end

--[[	ВЕШАЕМ СТАДИЮ КВЕСТА НА ИГРОКА ПРИ ЕГО ВХОДЕ В МИР	]]--

local function PlayerLogin(event,player)
	if questProgress[player:GetAccountId()] then
		player:SetData( "SpawnZoneEvent_1_Stage", questProgress[player:GetAccountId()] )
	end
end
RegisterPlayerEvent( 3, PlayerLogin )
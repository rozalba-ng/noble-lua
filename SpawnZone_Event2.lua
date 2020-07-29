--[[	ВРЕМЕННЫЙ ИВЕНТ НА ЛУННОЙ ПОЛЯНЕ - ВОПРОС-ОТВЕТ	]]--

-- Игроки прошедшие викторину:
local quizCompleted = {}

-- Таблица с очками (Добавляются после правильного ответа):
local quizScore = {}

-- ID NPC задающего вопросы:
local quizLead = 9925042

-- ID награды
local reward = 2113737

-- Таблица с вопросами и ответами:
local puzzle = {
	{	--[1]
		question = "Как назывался самый первый сюжет от команды на проекте?",
		answers = {
			"О, Андорал мой, Андорал!",
			"Дивный новый Андорал",
			"Все дороги ведут в Андорал",
			"Чёрный взор",
		},
		correctAnswer = 3,
	},
	{	--[2]
		question = 'В каком году стартанула "Большая игра"?',
		answers = {
			"2018",
			"2017",
			"2016",
			"2015",
		},
		correctAnswer = 2,
	},
	{	--[3]
		question = "Сколько полигонов было отыграно за время существования проекта?",
		answers = {
			"5",
			"7",
			"8",
			"6",
		},
		correctAnswer = 2,
	},
	{	--[4]
		question = "Что в старой версии правил проекта обозначал легендарный 2.б.2?",
		answers = {
			"Оскорбление, клевета, «троллинг», провокация беспорядков в игре и на сайте, разжигание ссор, травля, лжесвидетельство",
			"Использование ненормативной лексики в общих чатах проекта",
			"Намеренное введение в заблуждение членов команды во время разбора конфликтных ситуаций",
			"Оскорбление, клевета,  намеренное введение в заблуждение членов команды проекта, травля, лжесвидетельство",
		},
		correctAnswer = 1,
	},
	{	--[5]
		question = "Какой ингредиент требуется для крафта, но его никак нельзя скрафтить?",
		answers = {
			"Доска",
			"Алый краситель",
			"Гайка",
			"Рулон ткани",
		},
		correctAnswer = 3,
	},
	{	--[6]
		question = "Сколько месяцев длился 10й год ОТП?",
		answers = {
			"12",
			"38",
			"9",
			"41",
		},
		correctAnswer = 4,
	},
}

-- Текст реплик:
local text = {
	hello = "Привет, ты любишь викторины? А призы? Чудесно! Я задам тебе несколько вопросов и награжу, если ты ответишь правильно.\n\nНачинаем?",
	start = "Давай!",
	final = "На этом всё! Сейчас я обдумаю твои ответы... А ты пока беги к ближайшему почтовому ящику, твои результаты вот-вот окажутся там.",
	completed = "Прости, но викторину можно пройти только один раз. Таковы правила!",
}

local function Quiz(event, player, creature, sender, intid)
	local accountID = player:GetAccountId()
	if event == 1 then -- При клике на NPC.
		if not player:GetData("SpawnZoneEvent_2_Completed") then
			quizScore[accountID] = 0
			player:GossipSetText( text.hello, 10072001 )
			player:GossipMenuAddItem( 0, text.start, 0, 1 )
			player:SetData("SpawnZoneEvent_2_Question",0)
		else player:GossipSetText( text.completed, 10072001 ) end
	else -- Нажатие кнопки ответа.
		if sender ~= 0 then
			if puzzle[sender].correctAnswer == intid then
				if not quizScore[accountID] then quizScore[accountID] = 0 end
				quizScore[accountID] = quizScore[accountID] + 1
			end
		end
		local questionNumber = tonumber(player:GetData("SpawnZoneEvent_2_Question")) + 1
		if questionNumber > #puzzle then -- Игрок ответил на все вопросы.
			creature:SendChatMessageToPlayer( 12, 0, text.final, player )
			player:GossipComplete()
			if quizScore[accountID] <= 1 then
				SendMail( "Результаты викторины", (quizScore[accountID].." вопросов из "..#puzzle..".\nПускай вы не знаток истории сервера, но зато точно активный игрок!"), player:GetGUIDLow(), 0, 41, 0, 0, 0 )
			elseif quizScore[accountID] == #puzzle then
				SendMail( "Результаты викторины", (quizScore[accountID].." вопросов из "..#puzzle..".\nХорошим результатом можно гордиться!"), player:GetGUIDLow(), 0, 41, 0, 0, 0, reward, math.floor(quizScore[accountID]/2) )
			else
				SendMail( "Результаты викторины", (quizScore[accountID].." вопросов из "..#puzzle), player:GetGUIDLow(), 0, 41, 0, 0, 0, reward, math.floor(quizScore[accountID]/2) )
			end
			player:SetData("SpawnZoneEvent_2_Completed", true)
			
			quizCompleted[accountID] = 1
			
			local Q = WorldDBQuery("SELECT account FROM birthday_quest WHERE account = "..accountID)
			if Q then
				WorldDBQuery("UPDATE birthday_quest SET quiz_stage = '1' WHERE account = "..accountID)
			else
				WorldDBQuery("INSERT INTO birthday_quest ( account, quiz_stage ) VALUES ('"..accountID.."','1')")
			end
			
			return
		end
		player:SetData("SpawnZoneEvent_2_Question",questionNumber)
		player:GossipSetText( puzzle[questionNumber].question, 10072001 ) -- Вывод вопроса
		for i = 1,4 do -- Добавление вариантов ответа
			player:GossipMenuAddItem( 0, puzzle[questionNumber].answers[i], questionNumber, i )
		end
	end
	player:GossipSendMenu( 10072001, creature )
end
RegisterCreatureGossipEvent( quizLead, 1, Quiz ) -- On Hello
RegisterCreatureGossipEvent( quizLead, 2, Quiz ) -- On Select

--[[	ЗАГРУЗА ПРОГРЕССА ВИКТОРИНЫ ИЗ БД	]]--

local QuizQ = WorldDBQuery("SELECT account,quiz_stage FROM birthday_quest")
if QuizQ then
	for i = 1, QuizQ:GetRowCount() do
		local account, stage = QuizQ:GetInt32(0), QuizQ:GetInt32(1)
		quizCompleted[account] = stage
		QuizQ:NextRow()
	end
	QuizQ = nil
	-- Если игроки присутствуют в игре во время перезагрузки Элуны
	local players = GetPlayersInWorld()
	if players then
		for i = 1,#players do
			if quizCompleted[( players[i]:GetAccountId() )] and quizCompleted[ players[i]:GetAccountId() ] > 0 then
				players[i]:SetData("SpawnZoneEvent_2_Completed", true)
			end	
		end
	end
end

--[[	ВЕШАЕМ СТАДИЮ ВИКТОРИНЫ НА ИГРОКА ПРИ ЕГО ВХОДЕ В МИР	]]--

local function PlayerLogin(event,player)
	if quizCompleted[( player:GetAccountId() )] and quizCompleted[ player:GetAccountId() ] > 0 then
		player:SetData("SpawnZoneEvent_2_Completed", true)
	end
end
RegisterPlayerEvent( 3, PlayerLogin )
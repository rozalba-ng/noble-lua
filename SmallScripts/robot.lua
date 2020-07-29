local ROBOT_ID = 9921262
local assistId1 = 9911053
local assistId2 = 9910788


local lastTimeCheck = {}
local robotState = 0

local robotPhrases = { "Инициализация проверки данных...", "Обработка данных: \"Кости судьбы\"... Успешно.","Обработка данных: \"Пальто\"... Успешно.",
						"Обработка данных: \"Дилижансы\"... Успешно.","Ошибка обработки массива \"Корабли\"... Критическая ошибка.","Режим экономии энергии активирован..."}

local assist1 = {"Когда-нибудь он заработает вновь.","Тело эльфа ему никогда не шло...","Эй, хватит!","Испачкаешь!","Проект на стадии тестировки, отстань!","Где у него кнопка, где у него кнопка... Знать бы где он сам!","Не трогай, он не исправен! То есть нет... Так и должно быть, это часть функционала!", "Если этот истукан его еще раз тыкнет, Хестия, клянусь всеми шестернями Азерота, я его стукну!", "А может его просто... Перезапустить?"}

local assist2 = {"Как жаль, что починиться этот робот может лишь своими силами.","Руки свои! Это высокоточный механизм!","Я бы не стала этого делать, если бы дорожила своими пальцами.","Зачем трогаешь? Это наш робот!","А ты чего тут ручками тыкаешь, а?!","У него обед, не видишь?","Он дымит! Дыми-и-и-т!","Да на его вычислительных мощностях весь Гномреган держался! А ты в него так небрежно тычешь пальцем. Прояви уважение к кибер-старику!","Эй, сломаешь!","Бесполезно... Из этого режима он еще не скоро выйдет.","Вытащить бы резервную память да на благие цели пустить!","Информации в нем - мое почтение!","Да почему он опять не работает?! Вроде же поменяли аккумулятор!","Он вроде бы реагирует на запросы, но как-то крайне медленно. Иногда и вовсе не принимает сигнал. Приемо-передающее устройство барахлит." }

local groupPhrases = {	{"Ну, он хотя бы не взорвался!","Как в прошлый раз..."},
						{"Кажется это потому что я забыл удалить ту функцию в перфокарте \"Привет_мир.луа\"", "Зато дописал еще три, да?!"}, 
						{"Сколько он еще будет вот... Так?","Хронометр показывает что еще ориентирочно десять минут!"}
						}

local groupPhraseId = 0
						
local assistCooldown = 0
local robotGlobalCooldown = 0


local function NextPhrase(eventid, delay, repeats, worldobject)
	worldobject:SendUnitSay(groupPhrases[groupPhraseId][2],0)
end

local function TriggerAssists(state,cr)
	local a1 = cr:GetNearestCreature(40,assistId1)
	local a2 = cr:GetNearestCreature(50,assistId2)
	if state == 1 or state == 2 or state == 3then
		local phid = math.random(1,#assist1)
		a1:SendUnitSay(assist1[phid],0)
	
	elseif state == 5 or state == 4 or state == 6then
		local phid = math.random(1,#assist2)
		a2:SendUnitSay(assist2[phid],0)
	
	
	elseif state == 7 then
		groupPhraseId = math.random(1,#groupPhrases)
		a1:SendUnitSay(groupPhrases[groupPhraseId][1],0)
		a2:RegisterEvent(NextPhrase,4*1000,1)
	end




end

		
local function OnGossip(event, player, object,cr)
	if os.time() - robotGlobalCooldown > 600 then	
		if robotState  == 0 then
			robotState = 1
			object:CastSpell(object,550026)
			object:SetStandState(0)
			object:EmoteState(1)
		end
	else
		if os.time() - assistCooldown > 15 then
			assistCooldown = os.time()
			local state = math.random(1,7)
			TriggerAssists(state,object)
		end
	end
end

local function OnAI(event, creature, diff)
	if robotState > 0 and ( not lastTimeCheck[creature:GetName()] or (  os.time() - lastTimeCheck[creature:GetName()]  ) > 3 )  then
		lastTimeCheck[creature:GetName()] = os.time()
		
		creature:SetStandState(0)
		creature:EmoteState(1)
		creature:SendUnitSay(robotPhrases[robotState],0)
		robotState = robotState + 1
		if robotState > #robotPhrases then
			robotState = 0
			robotGlobalCooldown = os.time()
		end
	elseif robotState == 0 then
		creature:SetStandState(7)
		
	end
end




RegisterCreatureGossipEvent(ROBOT_ID,1,OnGossip)

RegisterCreatureEvent( ROBOT_ID, 7, OnAI ) 
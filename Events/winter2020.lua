
local SQL_databaseCreation = [[
CREATE TABLE IF NOT EXISTS `Winter2020` (
	`account` INT(10) UNSIGNED NOT NULL,
	`character_guid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`behavior` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	`companion` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	`item` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	`issued` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	`quest_stage` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`account`),
	UNIQUE INDEX `character_guid` (`character_guid`)
)
COMMENT='Used for winter2020.lua'
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
;
]]
WorldDBQuery( SQL_databaseCreation )

local entry_owl = 9929871

local phrases = {
	[1] = {
		[1] = "хорошо",
		[2] = "плохо",
		[3] = "так же, как и в прошлом",
	},
	[2] = {
		[1] = "Зимосовушку",
		[2] = "Плюшика",
		[3] = "ВЛАСТЬ НАД МИРОМ",
	},
	[3] = {
		[1] = "Навсегда замёрзшая монетка",
		[2] = "Пакет горячего какао",
		[3] = "Тикающий подарок",
	},
}

--[[	ГОССИП "НАПИСАНИЯ" ПИСЬМА	]]--

local function Gossip_Owl( event, player, creature, sender, intid )
	if event == 1 then
	--	Отображение меню
		if not ( player:GetTotalPlayedTime() > 14400 ) then
		--	Игрок наиграл менее 4 часов на персонаже.
			player:TalkingHead( creature, "Дедушка Зима ещё не знает тебя." )
		else
			local Q = WorldDBQuery( "SELECT account FROM Winter2020 WHERE account = "..player:GetAccountId() )
			if Q then
			--	Игрок уже отправлял письмо.
				player:TalkingHead( creature, "Дедушка Зима уже получил твое письмо, "..player:GetName().."." )
			else
				local text = "<Белоснежная сова выглядит весьма уставшей.>\n\nХочешь попросить что-то у Дедушки Зимы?\nЯ могу доставить ему твоё письмо, "..player:GetName().."."
				player:GossipMenuAddItem( 0, "Я хочу написать письмо Дедушке Зиме!", 0, 0 )
				player:GossipSetText( text, 30122001 )
				player:GossipSendMenu( 30122001, creature )
			end
		end
	else
	--	Выбор варианта
		if sender == 0 then
		--	Игрок начинает писать письмо.
			player:SetData( "Winter2020", {0,0,0} )
			local text = "<В ваших руках оказывается пустой лист бумаги...>\n\nДорогой Дедушка Зима! В этом году я вёл себя..."
			player:GossipMenuAddItem( 0, "..."..phrases[1][1].."...", 1, 1 )
			player:GossipMenuAddItem( 0, "..."..phrases[1][2].."...", 1, 2 )
			player:GossipMenuAddItem( 0, "..."..phrases[1][3].."...", 1, 3 )
			player:GossipSetText( text, 30122002 )
			player:GossipSendMenu( 30122002, creature )
		else
			local T = player:GetData("Winter2020")
			T[sender] = intid
			player:SetData( "Winter2020", T )
			local text
			if sender == 1 then
				text = "\n\nДорогой Дедушка Зима! В этом году я вёл себя |cff360009"..phrases[1][ T[1] ].."|r, честное слово, и поэтому я хочу попросить у тебя..."
				player:GossipMenuAddItem( 0, "..."..phrases[2][1].."...", 2, 1 )
				player:GossipMenuAddItem( 0, "..."..phrases[2][2].."...", 2, 2 )
				player:GossipMenuAddItem( 0, "..."..phrases[2][3].."...", 2, 3 )
			elseif sender == 2 then
				text = "\n\nДорогой Дедушка Зима! В этом году я вёл себя |cff360009"..phrases[1][ T[1] ].."|r, честное слово, и поэтому я хочу попросить у тебя |cff360009"..phrases[2][ T[2] ].."|r, рисовочку..."
				player:GossipMenuAddItem( 0, "..."..phrases[3][1].."...", 3, 1 )
				player:GossipMenuAddItem( 0, "..."..phrases[3][2].."...", 3, 2 )
				player:GossipMenuAddItem( 0, "..."..phrases[3][3].."...", 3, 3 )
			elseif sender == 3 then
				text = "\n\nДорогой Дедушка Зима! В этом году я вёл себя |cff360009"..phrases[1][ T[1] ].."|r, честное слово, и поэтому я хочу попросить у тебя |cff360009"..phrases[2][ T[2] ].."|r, рисовочку \"|cff360009"..phrases[3][ T[3] ].."|r\" и маленького надувного пони.\n\nС любовью, "..player:GetName()
				player:GossipMenuAddItem( 0, "<Отправить письмо.>", 4, 1, false, "Только один из ваших персонажей может отправить письмо Дедушке Зиме. Вы уверены, что хотите отправить именно это письмо?" )
			else
				WorldDBQuery("REPLACE INTO Winter2020 ( account, character_guid, behavior, companion, item ) values ("..player:GetAccountId()..", "..player:GetGUIDLow()..", "..T[1]..","..T[2]..","..T[3]..")")
				player:TalkingHead( creature, "Можешь считать, что твоё письмо уже доставлено." )
				return
			end
			player:GossipSetText( text, 30122003 )
			player:GossipSendMenu( 30122003, creature )
		end
	end
end
RegisterCreatureGossipEvent( entry_owl, 1, Gossip_Owl ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( entry_owl, 2, Gossip_Owl ) -- GOSSIP_EVENT_ON_SELECT

--[[	ГОССИП ЗИМНИХ ПИТОМЦЕВ	]]--

local function Gossip_WinterPet( event, player, creature )
	if event == 1 then
		local text = "<Дедушка Зима прислал вам это маленькое существо.>"
		if ( not player:GetData("WinterPet2020") ) or (  ( os.time() - player:GetData("WinterPet2020") ) > 60  ) then
			player:GossipMenuAddItem( 0, "<Использовать безобидную зимнюю магию.>", 1, 1 )
		else
			text = text.."\n\n<Зимняя магия перезаряжается.>"
		end
		player:GossipSetText( text, 30122004 )
		player:GossipSendMenu( 30122004, creature )
	else
		player:GossipComplete()
		player:SetData( "WinterPet2020", os.time() )
		local x,y,z = player:GetLocation()
		player:MoveJump( x, y, z+1, 0.15, 13 )
		player:AddAura( 56137, player )
	end
end
local creatures = { 1000200, 1000201, 1000202 }
for i = 1, #creatures do
	RegisterCreatureGossipEvent( creatures[i], 1, Gossip_WinterPet ) -- GOSSIP_EVENT_ON_HELLO
	RegisterCreatureGossipEvent( creatures[i], 2, Gossip_WinterPet ) -- GOSSIP_EVENT_ON_SELECT
end

--[[	СУПЕРСЕКРЕТНЫЙ КВЕСТ	]]--

local entry_ice = 5049499
local entry_trampoline = 5049500
local entry_cacao = 5049501
local entry_gnome = 9929896
local entry_hammer = 5049502
local entry_gift = 5049503
local entry_acostar = 9921754
--	|cff80d2ff

local function GetQuestStage( player )
	local Q = WorldDBQuery( "SELECT quest_stage FROM Winter2020 WHERE account = "..player:GetAccountId() )
	if Q then
		return Q:GetUInt8(0)
	end
	return 0
end

local function UPQuestStage( player )
	local stage = GetQuestStage(player)
	WorldDBQuery( "REPLACE INTO Winter2020 ( account, quest_stage ) VALUES ( "..player:GetAccountId()..", "..(stage+1).." )" )
end

local function Stage1( _, _, player )
	local stage = GetQuestStage(player)
	if player:GetGMRank() == 1 then
		return
	end
	if stage == 0 then
	--	Игрок начинает квест.
		player:SendBroadcastMessage("|cff80d2ff\"Это что, сосулька? Откуда она здесь? Сбить бы её, да вот только чем..\"")
		UPQuestStage(player) --> 1
	elseif stage == 2 then
	--	Игрок пришел с молотком.
		player:SendBroadcastMessage("|cff80d2ffСосулька не поддаётся, но круто звенит, когда вы ударяете по ней.")
		UPQuestStage(player) --> 3
	elseif stage == 3 then
	--	Игрок дубасит сосульку.
		player:SendBroadcastMessage("|cff80d2ffВы довольно ударяете по сосульке ещё несколько раз.")
		UPQuestStage(player) --> 4
	elseif stage == 4 then
	--	Игрок дубасит сосульку 2.
		player:SendBroadcastMessage("|cff80d2ffКажется она начала звенеть громче.")
		UPQuestStage(player) --> 5
	elseif stage == 5 then
	--	Игрок дубасит сосульку 3.
		player:SendBroadcastMessage("|cff80d2ff...")
		UPQuestStage(player) --> 6
	elseif stage == 6 then
	--	Игрок дубасит сосульку 4.
		player:SendBroadcastMessage("|cff80d2ffКажется звон исходит из стоящего рядом портала. В вашей голове возникают два слова: \n\"|cff8880ffСтарый мир|r\".")
		UPQuestStage(player) --> 7
	else
	--	Игрок тут чисто по приколу.
		player:SendBroadcastMessage("|cff80d2ffСосулька всё ещё здесь.")
	end
end
RegisterGameObjectEvent( entry_ice, 14, Stage1 ) -- GAMEOBJECT_EVENT_ON_USE

local function Stage2( _, _, player )
	local stage = GetQuestStage(player)
	if stage == 1 then
	--	Игрок нашёл молоток.
		player:SendBroadcastMessage("|cff80d2ff\"Молоток выглядит крепким. Может теперь стукнуть им по сосульке?\"")
		UPQuestStage(player) --> 2
	elseif stage == 2 then
	--	Игрок уже с молотком.
		player:SendBroadcastMessage("|cff80d2ffВы уже взяли молоток. Теперь надо найти то, что можно хорошо стукнуть.")
	else
	--	Игрок тут чисто по приколу.
		player:SendBroadcastMessage("|cff80d2ff\"Воровать чужие молотки - не самая лучшая идея.\"")
	end
end
RegisterGameObjectEvent( entry_hammer, 14, Stage2 ) -- GAMEOBJECT_EVENT_ON_USE

local function Stage3( _, object, player )
	math.randomseed( os.time()+player:GetAccountId() )
	local x,y,z = object:GetLocation()
	x = x + math.random(-1,1)
	y = y + math.random(-1,1)
	z = z + 1.4
	player:MoveJump( x, y, z, 0.2, 40 )
	local creature = player:GetNearestCreature( 60, entry_gnome )
	if creature then
		local stage = GetQuestStage(player)
		if stage == 7 then
		--	Игрок только пришёл.
			player:TalkingHead( creature, "Эй! Эй, ты!.." )
			UPQuestStage(player) --> 8
		elseif stage == 8 then
		--	Игрок прыгает 1.
			player:TalkingHead( creature, "...Послушай, кажется я застрял тут надолго!.." )
			UPQuestStage(player) --> 9
		elseif stage == 9 then
		--	Игрок прыгает 2.
			player:TalkingHead( creature, "...Поэтому ты можешь помочь мне, если хочешь!.." )
			UPQuestStage(player) --> 10
		elseif stage == 10 then
		--	Игрок прыгает 3.
			player:TalkingHead( creature, "...И даже помочь Дедушке Зиме! Мы потеряли некоторые подарки.." )
			UPQuestStage(player) --> 11
		elseif stage == 11 then
			player:TalkingHead( creature, "...Первый подарок находится на Стоянке беженцев.." )
			UPQuestStage(player) --> 12
		elseif stage == 12 then
			player:TalkingHead( creature, "...ищи его в таверне! Он отведёт тебя к остальным!" )
			UPQuestStage(player) --> 13
		end
	end
end
RegisterGameObjectEvent( entry_trampoline, 14, Stage3 ) -- GAMEOBJECT_EVENT_ON_USE

local function Stage4( _, _, player )
	local stage = GetQuestStage(player)
	if stage == 13 then
	--	Игрок только пришёл.
		player:SendBroadcastMessage("|cff80d2ffВокруг мрачно, будто вы снова попали в Гилнеас.")
		UPQuestStage(player) --> 14
	elseif stage == 14 then
	--	Игрок снова нажимает на какао.
		player:SendBroadcastMessage("|cff80d2ff\"Это какао - единственное, что походит на подарок к Зимнему Покрову. Я возьму его.\"")
		UPQuestStage(player) --> 15
	else
	--	Игрок тут чисто по приколу.
		player:SendBroadcastMessage("|cff80d2ff...")
	end
end
RegisterGameObjectEvent( entry_cacao, 14, Stage4 ) -- GAMEOBJECT_EVENT_ON_USE

local function Stage6( _,_,_, player )
	if GetQuestStage(player) == 17 then
		player:SendBroadcastMessage("|cff80d2ff\"Ну и что делать дальше? А главное - кто украл эти подарки и зачем разбросал их по миру?\"\n|cff80d2ff...\n|cff80d2ff\"Может задание не работает? Мне нужно найти Акостара на лунной поляне.\"")
		UPQuestStage(player) --> 18
	end
end

local function Stage5( _, _, player )
	local stage = GetQuestStage(player)
	if stage == 15 then
	--	Игрок только пришёл.
		player:SendBroadcastMessage("|cff80d2ff\"Подарок тикает, а значит внутри бомба или часы, но наверное всё же бомба..\"")
		UPQuestStage(player) --> 16
	elseif stage == 16 then
	--	Игрок снова нажимает на какао.
		player:SendBroadcastMessage("|cff80d2ffВы забираете подарок.")
		UPQuestStage(player) --> 17
		player:RegisterEvent( Stage6, 300000, 1 )
	else
	--	Игрок тут чисто по приколу.
		player:SendBroadcastMessage("|cff80d2ffПодарок тикает.")
	end
end
RegisterGameObjectEvent( entry_gift, 14, Stage5 ) -- GAMEOBJECT_EVENT_ON_USE

local taxi = { { 1, 7872.4, -2482.8, 488.1 }, { 1, 7853.8, -2470.5, 492.3 }, { 1, 7827.3, -2460.0, 496.4 }, { 1, 7723.8, -2488.6, 499.9 }, { 1, 7638.7, -2668.7, 543.2 }, { 1, 7556.0, -2889.8, 574.0 }, { 1, 7574.4, -2986.3, 600.2 }, { 1, 7695.3, -3060.7, 631.8 }, { 1, 7746.3, -3087.8, 636.9 }, { 1, 7780.2, -3147.5, 651.6 }, { 1, 7789.8, -3186.5, 632.0 }, { 1, 7789.8, -3190.5, 625.7 }, }
taxi = AddTaxiPath( taxi, 36966, 36966 )

local function Stage7( event, player, creature, sender, intid, code )
	if event == 1 then
		local text = "Что я здесь делаю? Прячусь, конечно!"
		if ( GetQuestStage(player) >= 18 and GetQuestStage(player) <= 20 ) then
			text = text.."\n\nА вам что нужно? Тоже задание проходите? Очень сложное, говорите? Ничего с этим не поделаешь.\n\nЯ могу перенести вас на следующий этап, конечно, но разве у вас есть\n\n-> секретный код? <-\n\nИ не вздумайте спрашивать его у меня в дискорде! Нет, я серьёзно. Не надо.."
			player:GossipMenuAddItem( 0, "<Назвать код на ушко.>", 1, 1, true )
		else
			text = text.."\n\nНо раз уж меня нашли - поздравляю с Новым годом. Всего вам хорошего. Чтобы здоровье не шалило, деньги были в карманах и мордашка не унывала."
		end
		player:GossipSetText( text, 31122001 )
		player:GossipSendMenu( 31122001, creature )
	else
		if code then
			if code == "7819" then
				if GetQuestStage(player) == 18 then
					player:TalkingHead( creature, "Добро пожаловать в следующий этап!" )
					UPQuestStage(player) --> 19
				end
				player:StartTaxi(taxi)
			else
				creature:AddAura( 21847, player )
				creature:SendChatMessageToPlayer( 12, 0, Roulette( "Не-а.", "Не то!", "Безуспешная попытка.", "Не верно.", "Нет.", "Попробуй ещё раз.", "Ух... Не то." ), player )
				player:GossipComplete()
			end
		else
			player:GossipComplete()
		end
	end
end
RegisterCreatureGossipEvent( entry_acostar, 1, Stage7 ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( entry_acostar, 2, Stage7 ) -- GOSSIP_EVENT_ON_SELECT

--[[	ВХОД ИГРОКА В МИР	]]--

local items = {
	[1] = {
		"Дорогой друг! Я с радостью слежу за твоими успехами и желаю тебе дальнейших процветаний! Пускай эти подарки принесут тебе праздничное настроение.\n\n  Дедушка Зима.",
		"Дорогой друг! Я вижу, кое-кто в этом году вел себя не самым лучшим образом, чем сильно огорчил мое старческое сердце. По правде сказать, сначала я хотел положить в твой подарок большой кусок угля, но в последний момент передумал. Этот год был непростым, так что каждый заслужил немного новогоднего настроения. Счастливого зимнего покрова!",
		"Дорогой друг! Я рад, что ты стойко движешься к своим целям и не сворачиваешь с пути! Пускай эти подарки принесут тебе праздничное настроение.\n\n  Дедушка Зима.",
	},
	[2] = {
		1000100,
		1000101,
		1000102,
	},
	[3] = {
		5057393,
		5057394,
		5057392,
	},
}

local function OnLogin_Player( _, player )
	local Q = WorldDBQuery( "SELECT behavior, companion, item FROM Winter2020 WHERE character_guid = "..player:GetGUIDLow().." AND issued = 0" )
	if Q then
		local text = Q:GetUInt8(0)
		local companion = Q:GetUInt8(1)
		local item = Q:GetUInt8(2)
		SendMail( "Посылка от Дедушки Зимы.", items[1][text], player:GetGUIDLow(), 0, 65, 20, 0, 0, items[2][companion], 1, items[3][item], 1, 600158, 1 )
		WorldDBQuery( "UPDATE Winter2020 SET issued = 1 WHERE account = "..player:GetAccountId() )
		-- --
		if GetQuestStage(player) == 17 then
			player:RegisterEvent( Stage6, 600000, 1 )
		end
	end
end
RegisterPlayerEvent( 3, OnLogin_Player ) -- PLAYER_EVENT_ON_LOGIN

--[[	ОГРАНИЧЕНИЕ СТРОИТЕЛЬСТВА	]]--

local function AntiGOB(event, player, item, target)
	local x,y = player:GetX(), player:GetY()
	if ( player:GetMapId() == 1 ) and ( x > 7436 and x < 8003 ) and ( y < -3215 and y > -3354 ) then
        player:SendBroadcastMessage("|cff80d2ff\"Тут и так полная неразбериха. Не думаю, что установить несколько ГОшек здесь - хорошая идея.\n")
        return false
    end
end

local function RegisterEvent_AntiGOB()
	local Q = WorldDBQuery("SELECT entry FROM item_template WHERE entry > 500000 and entry < 600000")
	for i = 1, Q:GetRowCount() do
		local entry = Q:GetInt32(0)
		RegisterItemEvent( entry, 2, AntiGOB )
		Q:NextRow()
	end
end
RegisterServerEvent( 33, RegisterEvent_AntiGOB ) -- ELUNA_EVENT_ON_LUA_STATE_OPEN
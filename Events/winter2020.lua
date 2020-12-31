
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
	end
end
RegisterPlayerEvent( 3, OnLogin_Player ) -- PLAYER_EVENT_ON_LOGIN

--[[	СУПЕРСЕКРЕТНЫЙ КВЕСТ	]]--

local entry_ice = 5049499
local entry_trampoline = 5049500
local entry_cacao = 5049501
local entry_gnome = 9929896
local entry_hammer = 5049502
--	|cff3da9e3

local function GetQuestStage( player )
	local Q = WorldDBQuery( "SELECT quest_stage FROM Winter2020 WHERE account = "..player:GetAccountId() )
	if Q then
		return Q:GetUInt8(0)
	end
	return 0
end

local function UPQuestStage( player )
	local stage = GetQuestStage(player)
	WorldDBQuery( "REPLACE INTO Winter2020 ( account, quest_stage ) VALUES ( "..player:GetAccountId()..", "..(stage-1).." )" )
end

local function Stage1( _, _, player )
	local stage = GetQuestStage(player)
	if stage == 0 then
	--	Игрок начинает квест.
		player:SendBroadcastMessage("|cff3da9e3\"Это что, сосулька? Откуда она здесь? Сбить бы её, да вот только чем..\"")
		UPQuestStage(player) --> 1
	elseif stage == 2 then
	--	Игрок пришел с молотком.
		player:SendBroadcastMessage("|cff3da9e3Сосулька не поддаётся, но круто звенит, когда вы ударяете по ней.")
		UPQuestStage(player) --> 3
	elseif stage == 3 then
	--	Игрок дубасит сосульку.
		player:SendBroadcastMessage("|cff3da9e3Вы довольно ударяете по сосульке ещё несколько раз.")
		UPQuestStage(player) --> 4
	elseif stage == 4 then
	--	Игрок дубасит сосульку 2.
		player:SendBroadcastMessage("|cff3da9e3Кажется она начала звенеть громче.")
		UPQuestStage(player) --> 5
	elseif stage == 5 then
	--	Игрок дубасит сосульку 3.
		player:SendBroadcastMessage("|cff3da9e3...")
		UPQuestStage(player) --> 6
	elseif stage == 6 then
	--	Игрок дубасит сосульку 4.
		player:SendBroadcastMessage("|cff3da9e3Кажется звон исходит из стоящего рядом портала. В вашей голове возникают два слова: \n\"Старый мир\".")
		UPQuestStage(player) --> 7
	else
	--	Игрок тут чисто по приколу.
		player:SendBroadcastMessage("|cff3da9e3Сосулька всё ещё здесь.")
	end
end
RegisterGameObjectEvent( entry_ice, 14, Stage1 ) -- GAMEOBJECT_EVENT_ON_USE

local function Stage2( _, _, player )
	local stage = GetQuestStage(player)
	if stage == 1 then
	--	Игрок нашёл молоток.
		player:SendBroadcastMessage("|cff3da9e3\"Молоток выглядит крепким. Может теперь стукнуть им по сосульке?\"")
		UPQuestStage(player) --> 2
	elseif stage == 2 then
	--	Игрок уже с молотком.
		player:SendBroadcastMessage("|cff3da9e3Вы уже взяли молоток. Теперь надо найти то что можно хорошо стукнуть.")
	else
	--	Игрок тут чисто по приколу.
		player:SendBroadcastMessage("|cff3da9e3\"Воровать чужие молотки - не самая лучшая идея.\"")
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
	local creature = player:GetNearestCreature( 40, entry_gnome )
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
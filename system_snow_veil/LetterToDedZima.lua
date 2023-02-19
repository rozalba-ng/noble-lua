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

local entry_owl = 988018

local phrases = {
	[1] = {
		[1] = "хорошо",
		[2] = "плохо",
		[3] = "так же, как и в прошлом",
		[4] = "хотелось бы лучше, но как есть",
		[5] = "ну, по крайней мере я очень старался",
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
		[4] = "Нетающую снежинку",
		[5] = "Снежное мороженое",
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
			local Q2 = WorldDBQuery( "SELECT account FROM Winter2022 WHERE account = "..player:GetAccountId() )
			if Q then
			--	Игрок уже отправлял письмо.
				player:TalkingHead( creature, "Дедушка Зима уже получил твое письмо, "..player:GetName().."." )
			elseif Q2 then
				player:TalkingHead( creature, "Дедушка Зима всё понимает, что тебе хотелось угодить злостному Анрилчу, но именно поэтому ты всё равно наказан, "..player:GetName()..", и останешься без подарка на этот Зимний Покров." )
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
			player:GossipMenuAddItem( 0, "..."..phrases[1][4].."...", 1, 4 )
			player:GossipMenuAddItem( 0, "..."..phrases[1][5].."...", 1, 5 )
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
				player:GossipMenuAddItem( 0, "..."..phrases[3][4].."...", 3, 4 )
				player:GossipMenuAddItem( 0, "..."..phrases[3][5].."...", 3, 5 )
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

--[[	ВХОД ИГРОКА В МИР	]]--

local items = {
	[1] = {
		"Дорогой друг! Я с радостью слежу за твоими успехами и желаю тебе дальнейших процветаний! Пускай эти подарки принесут тебе праздничное настроение.\n\n  Дедушка Зима.",
		"Дорогой друг! Я вижу, кое-кто в этом году вел себя не самым лучшим образом, чем сильно огорчил мое старческое сердце. По правде сказать, сначала я хотел положить в твой подарок большой кусок угля, но в последний момент передумал. Этот год был непростым, так что каждый заслужил немного новогоднего настроения. Счастливого зимнего покрова!",
		"Дорогой друг! Я рад, что ты стойко движешься к своим целям и не сворачиваешь с пути! Пускай эти подарки принесут тебе праздничное настроение.\n\n  Дедушка Зима.",
		"Дорогой друг! Моё сердце радуется, что ты стремишься быть лучше, чем в прошлом году. И знаешь, над чем нужно поработать. Помни, не всё получается сразу, на ухабистом жизненном пути не всё всегда идёт так, как нам хочется. Но главное - нести свет в своём сердце.",
		"Дорогой друг! Я уверен, что с твоим усердием в следующем году всё наверняка получится. Главное - идти в новый с чистым сердцем. А я верю, что у тебя оно именно такое. Счастливого Зимнего покрова!",
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
		5102430,
		5102431,
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
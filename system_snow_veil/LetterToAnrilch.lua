local SQL_databaseCreation = [[
CREATE TABLE IF NOT EXISTS `Winter2022` (
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
COMMENT='Used for LetterToAnrilch.lua'
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
;
]]
WorldDBQuery( SQL_databaseCreation )

local entry_owl = 988017

local phrases = {
	[1] = {
		[1] = "разбивал ёлочные игрушки",
		[2] = "воровал у детей подарки",
		[3] = "оторвал снеговику нос",
		[4] = "избил трёх гномов-помощников",
		[5] = "порвал все носки над камином",
	},
	[2] = {
		[1] = "Снеголиса",
		[2] = "Волкоснега",
		[3] = "МАНАБОМБУ",
	},
	[3] = {
		[1] = "заледеневшую карту сокровищ",
		[2] = "кружечку кока-О",
		[3] = "не-праздничный колпак",
		[4] = "анти-ёлку",
		[5] = "совсем не подарок",
	},
}

--[[	ГОССИП "НАПИСАНИЯ" ПИСЬМА	]]--

local function Gossip_Owl( event, player, creature, sender, intid )
	if event == 1 then
	--	Отображение меню
		if not ( player:GetTotalPlayedTime() > 14400 ) then
		--	Игрок наиграл менее 4 часов на персонаже.
			player:TalkingHead( creature, "Анрилч ещё не знает ничего про тебя!" )
		else
			local Q = WorldDBQuery( "SELECT account FROM Winter2022 WHERE account = "..player:GetAccountId() )
			local Q2 = WorldDBQuery( "SELECT account FROM Winter2020 WHERE account = "..player:GetAccountId() )
			if Q then
			--	Игрок уже отправлял письмо.
				player:TalkingHead( creature, "Анрилч уже получил твое письмо, "..player:GetName().."." )
			elseif Q2 then
				player:TalkingHead( creature, "Какой кошмар, ты отправил письмо Дедушке Зиме? И не надейся получить от Анрилча подарки!" )
			else
				local text = "<Фиолетовая сова выглядит весьма довольной.>\n\nХочешь попросить что-то у Анрилча?\nЯ могу доставить ему твоё письмо, "..player:GetName().."."
				player:GossipMenuAddItem( 0, "Я хочу написать письмо Анрилчу!", 0, 0 )
				player:GossipSetText( text, 30122001 )
				player:GossipSendMenu( 30122001, creature )
			end
		end
	else
	--	Выбор варианта
		if sender == 0 then
		--	Игрок начинает писать письмо.
			player:SetData( "Winter2022", {0,0,0} )
			text = "<В ваших руках оказывается пустой, страшно помятый, лист бумаги... Вы где его хранили-то вообще?>\n\nМногоуважаемый Анрилч! Я знаю, как туго приходится тебе в этот праздник... Я старался изо всех сил, чтобы расстроить Зимний покров, а именно..."
				player:GossipMenuAddItem( 0, "..."..phrases[1][1].."...", 1, 1 )
				player:GossipMenuAddItem( 0, "..."..phrases[1][2].."...", 1, 2 )
				player:GossipMenuAddItem( 0, "..."..phrases[1][3].."...", 1, 3 )
				player:GossipMenuAddItem( 0, "..."..phrases[1][4].."...", 1, 4 )
				player:GossipMenuAddItem( 0, "..."..phrases[1][5].."...", 1, 5 )
			player:GossipSetText( text, 30122002 )
			player:GossipSendMenu( 30122002, creature )
		else
			local T = player:GetData("Winter2022")
			T[sender] = intid
			player:SetData( "Winter2022", T )
			local text
			if sender == 1 then
				text = "\n\nМногоуважаемый Анрилч! Я знаю, как туго приходится тебе в этот праздник... Я старался изо всех сил, чтобы расстроить Зимний покров, а именно - |cff360009"..phrases[1][ T[1] ].."|r, и всё, чтобы поддержать твой гениальный замысел и утереть нос этому напыщенному Дедушке Зиме, а потому я думаю, что я заслужил..." 
				player:GossipMenuAddItem( 0, "..."..phrases[2][1].."...", 2, 1 )
				player:GossipMenuAddItem( 0, "..."..phrases[2][2].."...", 2, 2 )
				player:GossipMenuAddItem( 0, "..."..phrases[2][3].."...", 2, 3 )
			elseif sender == 2 then
				text = "\n\nМногоуважаемый Анрилч! Я знаю, как туго приходится тебе в этот праздник... Я старался изо всех сил, чтобы расстроить Зимний покров, а именно - |cff360009"..phrases[1][ T[1] ].."|r, и всё чтобы поддержать твой гениальный замысел и утереть нос этому напыщенному Дедушке Зиме, а потому я думаю что я заслужил |cff360009"..phrases[2][ T[2] ].."|r, рисовку, чтобы все ощутили мою безграничную мощь..."
				player:GossipMenuAddItem( 0, "..."..phrases[3][1].."...", 3, 1 )
				player:GossipMenuAddItem( 0, "..."..phrases[3][2].."...", 3, 2 )
				player:GossipMenuAddItem( 0, "..."..phrases[3][3].."...", 3, 3 )
				player:GossipMenuAddItem( 0, "..."..phrases[3][4].."...", 3, 4 )
				player:GossipMenuAddItem( 0, "..."..phrases[3][5].."...", 3, 5 )
			elseif sender == 3 then
				text = "\n\nМногоуважаемый Анрилч! Я знаю, как туго приходится тебе в этот праздник... Я старался изо всех сил, чтобы расстроить Зимний покров, а именно - |cff360009"..phrases[1][ T[1] ].."|r, и всё чтобы поддержать твой гениальный замысел и утереть нос этому напыщенному Дедушке Зиме, а потому я думаю что я заслужил |cff360009"..phrases[2][ T[2] ].."|r, рисовку, чтобы все ощутили мою безграничную мощь. Например, |cff360009"..phrases[3][ T[3] ].."|r.. и маленького надувного тюлева.\n\nС уважением, "..player:GetName()
				player:GossipMenuAddItem( 0, "<Отправить письмо.>", 4, 1, false, "Только один из ваших персонажей может отправить письмо Анрилчу. Вы уверены, что хотите отправить именно это письмо?" )
			else
				WorldDBQuery("REPLACE INTO Winter2022 ( account, character_guid, behavior, companion, item ) values ("..player:GetAccountId()..", "..player:GetGUIDLow()..", "..T[1]..","..T[2]..","..T[3]..")")
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
		"Здарова, негодяй! Ха-ха, так им, этим проклятым разноцветным стекляшкам! Ты не представляешь, дружбан, сколько маленьких гномреганских и кезанских детей тратят бессонные ночи, чтобы изготовить для всего Азерота эти проклятые игрушки. И что?! Ты думаешь, им за это платят?! Как бы не так! Так что вот твоя заслуженная награда.",
		"Здарова, проныра! Да, так их, этих остолопов! Они наверняка весь год вели себя просто отвратительно, ленились и не вскопали ни одной грядки! А этот слюнтяй всё равно подарит им подарки! Так они никогда ничему не научатся! Вот, в этом подарке наверняка должно быть то, что ты хочешь. Забирай, он твой!",
		"Здарова, жулик! Главное, что ты не оторвал нос моему Гиговику. Но ты бы и не смог, ха-ха! Здорово, что тебе удалось подпортить этим идиотам их идиотский праздник. Вот, это тебе за труды. Надеюсь на твою помощь в следующем году, дружище!",
		"Здарова! Избил? Прям взаправду? Ну и силёнок то у тебя... Надеюсь, эти болваны усвоят урок и в следующий раз Зимний Покров уж точно не состоится. Великие дела начинаются с малого, даже если малое - это избиение глупых коротышек в праздничных колпаках. Вот, держи свою награду. Она заслужена!",
		"Здарова, хитрец! И правильно! Ты знаешь, сколько пожаров ежегодно случается из-за этих тупых носков? Какой идиот вообще придумал вешать носки над камином?! Отличная работа, з которую вполне можно наградить. Открывай скорее. Уверен, ты порадуешься!",
	},
	[2] = {
		1000142,
		1000143, 
		1000144,
	},
	[3] = {
		5102432,
		5102433,
		5102434,
		5102435,
		5102436,
	},
}

local function OnLogin_Player( _, player )
	local Q = WorldDBQuery( "SELECT behavior, companion, item FROM Winter2022 WHERE character_guid = "..player:GetGUIDLow().." AND issued = 0" )
	if Q then
		local text = Q:GetUInt8(0)
		local companion = Q:GetUInt8(1)
		local item = Q:GetUInt8(2)
		SendMail( "Посылка от Анрилча.", items[1][text], player:GetGUIDLow(), 0, 65, 20, 0, 0, items[2][companion], 1, items[3][item], 1, 600158, 1 )
		WorldDBQuery( "UPDATE Winter2022 SET issued = 1 WHERE account = "..player:GetAccountId() )
		-- --
		if GetQuestStage(player) == 17 then
			player:RegisterEvent( Stage6, 600000, 1 )
		end
	end
end
RegisterPlayerEvent( 3, OnLogin_Player ) -- PLAYER_EVENT_ON_LOGIN
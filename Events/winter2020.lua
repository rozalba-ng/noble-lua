
local SQL_databaseCreation = [[
CREATE TABLE IF NOT EXISTS `Winter2020` (
	`account` INT(10) UNSIGNED NOT NULL,
	`character` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`behavior` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	`companion` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	`item` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	`issued` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`account`)
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
				WorldDBQuery("REPLACE INTO Winter2020 ( account, character, behavior, companion, item ) values ("..player:GetAccountId()..", "..player:GetGUIDLow()..", "..T[1]..","..T[2]..","..T[3]..")")
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
		player:GossipSetText( text, 30122004 )
		if ( not player:GetData("WinterPet2020") ) or (  ( os.time() - player:GetData("WinterPet2020") ) > 60  ) then
			player:GossipMenuAddItem( 0, "<Использовать безобидную зимнюю магию.>", 1, 1 )
		end
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
	local Q = WorldDBQuery( "SELECT behavior, companion, item FROM Winter2020 WHERE character = "..player:GetGUIDLow().." AND issued = 0" )
	if Q then
		local text = Q:GetUInt8(0)
		local companion = Q:GetUInt8(1)
		local item = Q:GetUInt8(2)
		SendMail( "Посылка от Дедушки Зимы.", items[1][text], player:GetGUIDLow(), 0, 65, 20, 0, 0, items[2][companion], 1, items[3][item], 1, 600158, 1 )
		WorldDBQuery( "UPDATE winter2020 SET issued = 1 WHERE account = "..player:GetAccountId() )
	end
end
RegisterPlayerEvent( 3, OnLogin_Player ) -- PLAYER_EVENT_ON_LOGIN
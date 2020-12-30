
local SQL_databaseCreation = [[
CREATE TABLE IF NOT EXISTS `Winter2020` (
	`account` INT(10) UNSIGNED NOT NULL,
	`behavior` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	`companion` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	`item` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
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
			player:TalkingHead( creature, "Дедушка Зима тебя не знает." )
		else
			local Q = WorldDBQuery( "SELECT account FROM Winter2020 WHERE account = "..player:GetAccountId() )
			if Q then
			--	Игрок уже отправлял письмо.
				player:TalkingHead( creature, "Ты уже отправлял письмо Дедушке Зиме, "..player:GetName().."." )
			else
				local text = "<Белоснежная сова выглядит весьма уставшей.>\n\nХочешь попросить что-то у Дедушки Зимы?\nЯ могу доставить ему твоё письмо, "..player:GetName().."."
				player:GossipMenuAddItem( 0, "Здравствуйте! Вставить текст.", 0, 0 )
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
				text = "<Сова подозрительно смотрит на написанное вами...>\n\nДорогой Дедушка Зима! В этом году я вёл себя |cff360009"..phrases[1][ T[1] ].."|r. Честное слово. И поэтому я хочу попросить у тебя..."
				player:GossipMenuAddItem( 0, "..."..phrases[2][1].."...", 2, 1 )
				player:GossipMenuAddItem( 0, "..."..phrases[2][2].."...", 2, 2 )
				player:GossipMenuAddItem( 0, "..."..phrases[2][3].."...", 2, 3 )
			elseif sender == 2 then
				text = "<Кажется Сова немного поседела...>\n\nДорогой Дедушка Зима! В этом году я вёл себя |cff360009"..phrases[1][ T[1] ].."|r. Честное слово. И поэтому я хочу попросить у тебя |cff360009"..phrases[2][ T[2] ].."|r, рисовочку..."
				player:GossipMenuAddItem( 0, "..."..phrases[3][1].."...", 3, 1 )
				player:GossipMenuAddItem( 0, "..."..phrases[3][2].."...", 3, 2 )
				player:GossipMenuAddItem( 0, "..."..phrases[3][3].."...", 3, 3 )
			elseif sender == 3 then
				text = "<Вы заканчиваете своё письмо. Сова готова отнести его.>\n\nДорогой Дедушка Зима! В этом году я вёл себя |cff360009"..phrases[1][ T[1] ].."|r. Честное слово. И поэтому я хочу попросить у тебя |cff360009"..phrases[2][ T[2] ].."|r, рисовочку \"|cff360009"..phrases[3][ T[3] ].."|r\" и маленького надувного пони.\n\nС любовью, "..player:GetName()
				player:GossipMenuAddItem( 0, "<Отправить письмо.>", 4, 1, false, "Только один из ваших персонажей может отправить письмо Дедушке Зиме. Вы уверены, что хотите отправить именно это письмо?" )
			else
				WorldDBQuery("REPLACE INTO Winter2020 ( account, behavior, companion, item ) values ("..player:GetAccountId()..","..T[1]..","..T[2]..","..T[3]..")")
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
local creatures = { 1000197, 1000196, 1000198 }
for i = 1, #creatures do
	RegisterCreatureGossipEvent( creatures[i], 1, Gossip_WinterPet ) -- GOSSIP_EVENT_ON_HELLO
	RegisterCreatureGossipEvent( creatures[i], 2, Gossip_WinterPet ) -- GOSSIP_EVENT_ON_SELECT
end
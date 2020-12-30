
local aura_wind = 40321
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

local function Gossip_Owl( event, player, creature, sender, intid )
	if event == 1 then
	--	Отображение меню
		local text = "<Белоснежная сова выглядит весьма устало.>\nХочешь попросить что-то у Дедушки Зимы?\n<Кажется она заметила вас.>\nЯ могу отнести ему твоё письмо, "..player:GetName().."."
		player:GossipMenuAddItem( 0, "Здравствуйте! Вставить текст.", 0, 0 )
		player:GossipSetText( text, 30122001 )
		player:GossipSendMenu( 30122001, creature )
	else
	--	Выбор варианта
		if sender == 0 then
		--	Игрок начинает писать письмо.
			player:SetData( "Winter2020", {0,0,0} )
			local text = "<В ваших руках оказывается пустой лист бумаги...>\n Дорогой Дедушка Зима! В этом году я вёл себя..."
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
				text = "<Сова подозрительно смотрит на написанное вами...>\n Дорогой Дедушка Зима! В этом году я вёл себя |cff360009"..phrases[1][ T[1] ].."|r. Честное слово. И поэтому я хочу попросить у тебя..."
				player:GossipMenuAddItem( 0, "..."..phrases[2][1].."...", 2, 1 )
				player:GossipMenuAddItem( 0, "..."..phrases[2][2].."...", 2, 2 )
				player:GossipMenuAddItem( 0, "..."..phrases[2][3].."...", 2, 3 )
			elseif sender == 2 then
				text = "<Кажется Сова немного поседела...>\n Дорогой Дедушка Зима! В этом году я вёл себя |cff360009"..phrases[1][ T[1] ].."|r. Честное слово. И поэтому я хочу попросить у тебя |cff360009"..phrases[2][ T[2] ].."|r, рисовочку..."
				player:GossipMenuAddItem( 0, "..."..phrases[3][1].."...", 3, 1 )
				player:GossipMenuAddItem( 0, "..."..phrases[3][2].."...", 3, 2 )
				player:GossipMenuAddItem( 0, "..."..phrases[3][3].."...", 3, 3 )
			elseif sender == 3 then
				text = "<Вы заканчиваете своё письмо. Сова готова отнести его.>\n Дорогой Дедушка Зима! В этом году я вёл себя |cff360009"..phrases[1][ T[1] ].."|r. Честное слово. И поэтому я хочу попросить у тебя |cff360009"..phrases[2][ T[2] ].."|r, рисовочку |cff360009"..phrases[3][ T[3] ].."|r и маленького надувного пони.\n\nС любовью, "..player:GetName()
				player:GossipMenuAddItem( 0, "<Отправить письмо.>", 4, 1, false, "Только один из ваших персонажей может отправить письмо Дедушке Зиме.\nВы уверены, что хотите отправить именно это письмо?" )
			else
				player:TalkingHead( creature, "Тут какой-то текст." )
				return
			end
			player:GossipSetText( text, 30122003 )
			player:GossipSendMenu( 30122003, creature )
		end
	end
end
RegisterCreatureGossipEvent( entry_owl, 1, Gossip_Owl ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( entry_owl, 2, Gossip_Owl ) -- GOSSIP_EVENT_ON_SELECT
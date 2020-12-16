local AIO = AIO or require("AIO")
local MyHandlers = AIO.AddHandlers("SocialClassSelection", {})

--	Уголок настроек
local entry_creature = 9929463
local entry_quest = 110031
local aura = {
	91055, -- Дворянин
	91056, -- Духовенство
	91057, -- Магократия
	91058, -- Вольный житель
	91062, -- Аноним
}

function MyHandlers.ShowMenu( player )
	AIO.Handle(player, "SocialClassSelection","Storm_ShowMenu")
end

function MyHandlers.SelectClass( player, class )
    local creature = player:GetNearestCreature( 15, entry_creature )
	if creature and tonumber(class) then
		class = math.floor( tonumber(class) )
		if class > 0 and class < 5 then
			CharDBQuery("REPLACE INTO character_citycraft_config ( character_guid, city_class ) values ("..player:GetGUIDLow()..", "..aura[class]..")")
			player:AddAura( aura[class], player )
			player:CompleteQuest( entry_quest )
			player:TalkingHead( creature, "А ты умеешь выбирать жизненные пути, да? Рад знакомству." )
		end
	end
end

local function Creature_Gossip( event, player, creature, sender, intid )
	if event == 1 then
	--	Вывод госсипа
		local text
		player:GossipAddQuests( creature )
		if player:HasAura(91055) then
		--	Обращение к дворянину
			text = "Рад видеть вас, "..player:GetName().."! Чем я могу вам помочь?"
		elseif player:HasAura(91056) then
		--	Обращение к священнику
			text = "Да хранит вас Свет! Чем могу быть полезен?"
		elseif player:HasAura(91057) then
		--	Обращение к магу
			text = "Ваше чародейство! Чем могу быть полезен?"
		elseif player:HasAura(91058) then
		--	Обращение к вольному жителю
			text = "Доброго пути, друг! Тебе что-то подсказать?"
		elseif player:HasAura(91062) then
		--	Если игрок скрыл свою роль
			text = "Знакомое лицо, не иначе. Мы раньше не встречались?"
		else
		--	Игрок ещё не выбрал класс.
			text = "Новая персона в наших краях? Ну, и как мне тебя звать-величать?"
			if player:HasQuest( entry_quest ) then
				player:GossipMenuAddItem( 0, "<Представиться.>", 1, 1 )
			end
		end
		player:GossipSetText( text, 13122001 )
		player:GossipSendMenu( 13122001, creature )
	elseif player:HasQuest( entry_quest ) then
	--	Выбор варианта
		player:GossipComplete()
		MyHandlers.ShowMenu( player )
	end
end
RegisterCreatureGossipEvent( entry_creature, 1, Creature_Gossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( entry_creature, 2, Creature_Gossip ) -- GOSSIP_EVENT_ON_SELECT
local AIO = AIO or require("AIO")
local MyHandlers = AIO.AddHandlers("SocialClassSelection", {})

--	Уголок настроек
local entry_creature = 9929463
local entry_quest = 110031

local aura = {
	91055, -- Дворянство
	91056, -- Духовенство
	91057, -- Магократия
	91058, -- Вольные жители
	91062, -- Аноним
}
local quests = {
--	Квесты-костыли обозначающие, какую из ролей выбрал игрок.
	[91055] = 110061, -- Дворянство
	[91056] = 110057, -- Духовенство
	[91057] = 110059, -- Магократия
	[91058] = 110063, -- Вольные жители
}

local entry_quest_law = 110053
local entry_quest_thief = 110052

function MyHandlers.ShowMenu( player )
	AIO.Handle(player, "SocialClassSelection","Storm_ShowMenu")
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
		player:GossipMenuAddItem( 0, "<Сменить социальный класс.>", 1, 2, false)
		player:GossipSetText( text, 13122001 )
		player:GossipSendMenu( 13122001, creature )
	elseif event == 3 then
	--	Вывод госсипа при смене социальной роли
		local text = "Обратите внимание - фракция Теней Штормграда доступна только для Вольных Жителей.\n\n|cff360009Если вы не хотите менять фракцию - выберите ту, в которой находитесь сейчас.\n\n|rВыберите доступную для данного социального класса фракцию:"
		player:GossipMenuAddItem( 0, "Королевство Штормград", 2, 1, false, "Это ваш окончательный выбор." )
		if player:GetData("ChangingSocialRole_Selected") == 91058 then
		--	Игрок выбрал Вольного Жителя
			player:GossipMenuAddItem( 0, "Тени Штормграда", 2, 2, false, "Это ваш окончательный выбор." )
		end
		player:GossipMenuAddItem( 0, "Я хочу выбрать другой социальный класс.", 2, 3 )
		player:GossipSetText( text, 16122002 )
		player:GossipSendMenu( 16122002, creature )
	else
	--	Выбор варианта
		if sender == 1 then
		--	Выбор роли
			player:SetData( "ChangingSocialRole", true )
			player:GossipComplete()
			MyHandlers.ShowMenu( player )
		else
		--	Перевыбор роли
			if player:GetData("ChangingSocialRole") and intid ~= 3 then
			--	Настройка выполненных квестов
				local role = player:GetData("ChangingSocialRole_Selected")
				if intid == 1 then
				--	Королевство Штормград
					player:RemoveQuest( entry_quest_thief )
					player:RemoveQuest( entry_quest_law )
					player:AddQuest( entry_quest_law )
					player:CompleteQuest( entry_quest_law )
					player:RewardQuest( entry_quest_law )
				elseif ( ( intid == 2 ) and ( role == 91058 ) ) then
					player:RemoveQuest( entry_quest_thief )
					player:RemoveQuest( entry_quest_law )
					player:AddQuest( entry_quest_thief )
					player:CompleteQuest( entry_quest_thief )
					player:RewardQuest( entry_quest_thief )
				end
				for _, v in pairs(quests) do
					player:RemoveQuest(v)
				end
				player:AddQuest( quests[ role ] )
				player:CompleteQuest( quests[ role ] )
				player:RewardQuest( quests[ role ] )
			--	Махинации с аурами
				for i = 1, #aura do
					player:RemoveAura( aura[i] )
				end
				player:AddAura( player:GetData("ChangingSocialRole_Selected"), player )
			--	Обновление записи в базе данных
				CharDBQuery("REPLACE INTO character_citycraft_config ( character_guid, city_class, allow_role_change ) values ("..player:GetGUIDLow()..", "..tonumber(role)..", 1)")
			--	Подчищаем кеш, выводим уведомление.
				player:SetData( "ChangingSocialRole", nil )
				player:SetData( "ChangingSocialRole_Selected", nil )
				player:TalkingHead( creature, "Все имеют право на второй шанс." )
				player:SendBroadcastMessage( "Вы изменили свой социальный класс.")
			--	Обновление фазы для корректного отображения иконок квестов
				player:SetPhaseMask(524288)
				player:SetPhaseMask(1)

			else
			--	Выбор другой социальной роли.
				player:GossipComplete()
				MyHandlers.ShowMenu( player )
			end
		end
	end
end
RegisterCreatureGossipEvent( entry_creature, 1, Creature_Gossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( entry_creature, 2, Creature_Gossip ) -- GOSSIP_EVENT_ON_SELECT

function MyHandlers.SelectClass( player, class )
    local creature = player:GetNearestCreature( 15, entry_creature )
	if creature and tonumber(class) then
		class = math.floor( tonumber(class) )
		if class > 0 and class < 5 then
			if player:HasQuest( entry_quest ) then
				CharDBQuery("REPLACE INTO character_citycraft_config ( character_guid, city_class ) values ("..player:GetGUIDLow()..", "..aura[class]..")")
				player:AddAura( aura[class], player )
				player:CompleteQuest( entry_quest )
				player:RewardQuest( entry_quest )

				player:AddQuest( quests[ aura[class] ] )
				player:CompleteQuest( quests[ aura[class] ] )
				player:RewardQuest( quests[ aura[class] ] )

				player:TalkingHead( creature, "А ты умеешь выбирать жизненные пути, да? Рад знакомству." )
			elseif player:GetData("ChangingSocialRole") then
				player:SetData( "ChangingSocialRole_Selected", aura[class] )
				Creature_Gossip( 3, player, creature )
			end
		end
	end
end
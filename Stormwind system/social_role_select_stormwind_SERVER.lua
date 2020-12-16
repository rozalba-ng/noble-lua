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
		local Q = CharDBQuery( "SELECT allow_role_change FROM character_citycraft_config WHERE character_guid = "..player:GetGUIDLow() )
		if Q then
		--	Если игрок уже смешарик
			if Q:GetUInt8(0) > 0 then
				player:GossipMenuAddItem( 0, "<Сменить социальный класс.>", 1, 2, false, "ВСЯ РЕПУТАЦИЯ БУДЕТ ПОТЕРЯНА.\nВы не сможете бесплатно сменить социальный класс ещё раз." )
			end
		end
		player:GossipSetText( text, 13122001 )
		player:GossipSendMenu( 13122001, creature )
	elseif event == 3 then
	--	Вывод госсипа при смене социальной роли
		local text = "Обратите внимание - фракция Теней Штормграда доступна только для Вольных Жителей.\n\n|cff360009Вся накопленная репутация будет потеряна.\n\nВы не сможете бесплатно сменить социальный класс ещё раз.\n\n|rВыберите фракцию:"
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
			if intid == 2 then
				player:SetData( "ChangingSocialRole", true )
			end
			player:GossipComplete()
			MyHandlers.ShowMenu( player )
		else
		--	Перевыбор роли
			if player:GetData("ChangingSocialRole") and intid ~= 3 then
			--	Последняя проверка, определение оставшихся смен роли (Если игрок имел > 1)
				local Q = CharDBQuery( "SELECT allow_role_change FROM character_citycraft_config WHERE character_guid = "..player:GetGUIDLow() )
				if Q then
					local allow_role_change = Q:GetUInt8(0)
					if allow_role_change > 0 then
						allow_role_change = allow_role_change - 1
					--	Отбирание репутационных жетонов
					--[[
						if player:HasItem( 2114371, 1, true ) then
							player:RemoveItem( 2114371, player:GetItemCount( 2114371, true ) )
						end						
						if player:HasItem( 2114372, 1, true ) then
							player:RemoveItem( 2114372, player:GetItemCount( 2114372, true ) )
						end
					]]
					--	Настройка выполненных квестов
						if intid == 1 then
						--	Королевство Штормград
							player:RemoveQuest( entry_quest_thief )
							player:RemoveQuest( entry_quest_law )
							player:AddQuest( entry_quest_law )
							player:CompleteQuest( entry_quest_law )
							player:RewardQuest( entry_quest_law )
						elseif ( ( intid == 2 ) and ( player:GetData("ChangingSocialRole_Selected") == 91058 ) ) then
						--	Тени Штормграда
							player:RemoveQuest( entry_quest_thief )
							player:RemoveQuest( entry_quest_law )
							player:AddQuest( entry_quest_thief )
							player:CompleteQuest( entry_quest_thief )
							player:RewardQuest( entry_quest_thief )
						end
					--	Установка нулевой репутации
						player:SetReputation( thiefs_faction, 0 )
						player:SetReputation( law_faction, 0 )
					--	Махинации с аурами
						for i = 1, #aura do
							player:RemoveAura( aura[i] )
						end
						player:AddAura( player:GetData("ChangingSocialRole_Selected"), player )
					--	Обновление записи в базе данных
						CharDBQuery("REPLACE INTO character_citycraft_config ( character_guid, city_class, allow_role_change ) values ("..player:GetGUIDLow()..", "..tonumber(player:GetData("ChangingSocialRole_Selected"))..", "..allow_role_change..")")
					--	Подчищаем кеш, выводим уведомление.
						player:SetData( "ChangingSocialRole", nil )
						player:SetData( "ChangingSocialRole_Selected", nil )
						player:TalkingHead( creature, "Все имеют право на второй шанс." )
						player:SendBroadcastMessage( "Вы изменили свой социальный класс. Осталось смен роли на персонаже: "..allow_role_change )
					end
				end
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
				player:TalkingHead( creature, "А ты умеешь выбирать жизненные пути, да? Рад знакомству." )
			elseif player:GetData("ChangingSocialRole") then
				player:SetData( "ChangingSocialRole_Selected", aura[class] )
				Creature_Gossip( 3, player, creature )
			end
		end
	end
end
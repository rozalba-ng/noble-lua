--	КОМАНДА ДЛЯ СОЗДАНИЯ НАГРАДНЫХ ПРЕДМЕТОВ-РЕЦЕПТОВ ПОЗВОЛЯЮЩИХ СОЗДАВАТЬ ДРУГИЕ ПРЕДМЕТЫ ИЗ УКАЗАННЫХ РЕСУРСОВ
--	Использование .craftitems
--	Команда доступна только 2+ ГМ

local spell_placeholder = 30433 -- Спелл для прикрепления к предметам-рецептам.
local default_spell_cooldown = 2500 -- Перезарядка спелла
local crafts = {	-- Профессии которые могут требоваться для использования рецепта.
--	>30 элементов в списке требуют функционала перелистывания страничек.
--	{ ID из SkillLine.dbc, Название },
	{ 0, "Без профессии" },
	{ 129, "Первая помощь" },
	{ 164, "Кузнечное дело" },
	{ 165, "Кожевничество" },
	{ 171, "Алхимия" },
	{ 182, "Травничество" },
	{ 185, "Кулинария" },
	{ 186, "Горное дело" },
	{ 197, "Портняжное дело" },
	{ 202, "Инженерное дело" },
	{ 333, "Наложение чар" },
	{ 356, "Рыбная ловля" },
	{ 393, "Снятие шкур" },
	{ 755, "Ювелирное дело" },
	{ 773, "Начертание" },
	{ 830, "Плотничество" },
	{ 831, "Гончарное дело" },
}

local smallfolk = require 'smallfolk'

local SQL_databaseCreation = [[
CREATE TABLE IF NOT EXISTS `craftable_items` (
	`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	`trigger_item_entry` INT(10) UNSIGNED NOT NULL,
	`resources` TEXT NOT NULL,
	`result` TEXT NOT NULL,
	`account` INT(10) UNSIGNED NULL DEFAULT NULL,
	INDEX `id` (`id`)
)
COMMENT='Used for craftItems.lua'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]
WorldDBQuery( SQL_databaseCreation )

local CraftItems_Table = {} -- Для создания рецептов
local CraftItems_LoadedTable = {} -- Для использования созданных рецептов

--[[	ИСПОЛЬЗОВАНИЕ РЕЦЕПТА	]]--

local function CraftItems_OnItemUse( event, player, item, target )
	local entry = item:GetEntry()
	if CraftItems_LoadedTable[entry] then
		for i = 1, #CraftItems_LoadedTable[entry].resources do
			if not player:HasItem( CraftItems_LoadedTable[entry].resources[i][1], CraftItems_LoadedTable[entry].resources[i][2] ) then
				player:SendNotification("Вам нужно иметь "..CraftItems_LoadedTable[entry].resources[i][2].." ["..CraftItems_LoadedTable[entry].resources[i][3].."]")
				player:PlayDirectSound( 12889, player )
				return false
			end
		end
		for i = 1, #CraftItems_LoadedTable[entry].resources do
			player:RemoveItem( CraftItems_LoadedTable[entry].resources[i][1], CraftItems_LoadedTable[entry].resources[i][2] )
		end
		for i = 1, #CraftItems_LoadedTable[entry].result do
			player:AddItem( CraftItems_LoadedTable[entry].result[i][1], CraftItems_LoadedTable[entry].result[i][2] )
			player:PlayDirectSound( 12867, player )
			if not player:HasItem( CraftItems_LoadedTable[entry].result[i][1] ) then
				SendMail( "Потерянный предмет.", "Этот предмет не влез в ваши сумки при использовании ["..item:GetName().."].", player:GetGUIDLow(), 0, 61, 1500, 0, 0, CraftItems_LoadedTable[entry].result[i][1], CraftItems_LoadedTable[entry].result[i][2] )
				player:SendBroadcastMessage("|cffFF4500[!!]|r Один из созданных предметов не влез в ваши сумки и был отправлен по почте.\nПерезайдите в игру для отображения письма.")
			end
		end
	else player:SendNotification("Произошла ошибка. Свяжитесь с администрацией.") end
end

--[[	СОЗДАНИЕ ПРЕДМЕТА	]]--

local function CraftItems_Menu( event, player, command, sender, intid, code, menu_id )
	local accountID = player:GetAccountId()
	if ( event == 42 and ( command == "craftitems" or command == "craftsystem" ) and player:GetGMRank() > 1 ) or event == 1 then -- PLAYER_EVENT_ON_COMMAND, Обновление gossip меню
		if event == 42 or sender == 0 then
			CraftItems_Table[accountID] = {}
			player:GossipClearMenu()
			player:GossipSetText( "Выберите опцию:", 23092002 )
			player:GossipMenuAddItem( 4, "Новый рецепт", 1, 1 )
			player:GossipMenuAddItem( 0, "Удалить рецепт", 1, 2, true, "Укажите ID (entry) предмета вызывающего крафт." )
			player:GossipSendMenu( 23092002, player, 23092001 )
		end
	elseif event == 2 then -- GOSSIP_EVENT_ON_SELECT
		if sender == 1 then -- Стартовое меню
			if intid == 1 then -- Создание предмета
				-- Установка актуального текста
				local text = "Все предметы для рецепта должны быть уже созданы."
				if CraftItems_Table[accountID].trigger_item then
					text = text.."\n\n- "..CraftItems_Table[accountID].trigger_item.name.." -"
				end
				if CraftItems_Table[accountID].ingredients and #CraftItems_Table[accountID].ingredients > 0 then
					text = text.."\n\nИнгридиенты:"
					for i = 1, #CraftItems_Table[accountID].ingredients do
						text = text.."\n"..i..". "..CraftItems_Table[accountID].ingredients[i].name.." x"..CraftItems_Table[accountID].ingredients[i].amount
					end
				end
				if CraftItems_Table[accountID].reward and ( CraftItems_Table[accountID].reward[1] or CraftItems_Table[accountID].reward.name ) then
					if CraftItems_Table[accountID].reward.name then
						text = text.."\n\nНаграда за крафт:\n- "..CraftItems_Table[accountID].reward.name.." x"..CraftItems_Table[accountID].reward.amount
					else
						text = text.."\n\nНаграды за крафт:"
						for i = 1, #CraftItems_Table[accountID].reward do
							text = text.."\n"..i..". "..CraftItems_Table[accountID].reward[i].name.." x"..CraftItems_Table[accountID].reward[i].amount
						end
					end
				end
				player:GossipSetText( text, 23092003 )
				-- Установка актуальных кнопок
				player:GossipMenuAddItem( 4, "Указать ID предмета-рецепта", 2, 1, true )
				player:GossipMenuAddItem( 4, "Добавить ингридиент", 2, 2, true, "Укажите ID ингридиента и его кол-во через пробел." )
				if CraftItems_Table[accountID].ingredients and #CraftItems_Table[accountID].ingredients > 0 then
					player:GossipMenuAddItem( 4, "Удалить ингридиент", 2, 3, true, "Укажите номер ингридиента из списка в меню." )
				end
				player:GossipMenuAddItem( 4, "Указать ID наград(ы) за крафт", 2, 4, true, "Укажите ID награды и её кол-во через пробел. Если вам нужно несколько наград - разделяйте их точкой с запятой.\nENTRY AMOUNT ; ENTRY AMOUNT" )
				-- Проверка на добавленные пункты.
				if CraftItems_Table[accountID].trigger_item and ( CraftItems_Table[accountID].ingredients and #CraftItems_Table[accountID].ingredients > 0 ) and CraftItems_Table[accountID].reward then
					player:GossipMenuAddItem( 6, "Указать требуемый навык профессии", 2, 5 )
					player:GossipMenuAddItem( 6, "Указать время перезарядки", 2, 6, true, "Укажите время перезарядки в секундах." )
					player:GossipMenuAddItem( 1, "Завершить создание рецепта", 2, 7 )
				end
				player:GossipMenuAddItem( 0, "Вернуться назад |cffa60702(ОТМЕНА)", 2, 6 )
				player:GossipSendMenu( 23092003, player, 23092001 )
			elseif intid == 2 then -- Удаление предмета
				if code and tonumber(code) and tonumber(code) > 0 then
					code = tonumber(code)
					local itemQ = WorldDBQuery( 'SELECT Flags FROM item_template WHERE entry = '..code )
					if itemQ then
						local itemQ2 = WorldDBQuery( 'SELECT id FROM craftable_items WHERE trigger_item_entry = '..code )
						if itemQ2 then
							local Flags = itemQ:GetUInt32(0)
							if FindFlag( Flags, 64 ) then Flags = Flags - 64 end
							WorldDBQuery( 'UPDATE item_template SET Flags = '..Flags..', spellid_1 = 0, spellcooldown_1 = 0 WHERE entry = '..code )
							local id = itemQ2:GetUInt32(0)
							WorldDBQuery( 'DELETE FROM craftable_items WHERE id = '..id )
							ClearItemEvents( code )
							CraftItems_LoadedTable[code] = nil
							player:SendBroadcastMessage("Рецепт с ID |cff00FF7F"..id.."|r удалён.\nДля завершения удаления рецепта перезагрузите базу предметов ( .reload all_item_template ) и при необходимости удалите папку Cache.")
						else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Рецепт не найден.") CraftItems_Menu( 1, player, _, 0 ) end
					else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Предмет не найден.") CraftItems_Menu( 1, player, _, 0 ) end
				else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Вы должны указать ID (entry) предмета.") CraftItems_Menu( 1, player, _, 0 ) end
			end
		elseif sender == 2 then -- Создание нового предмета
			if intid == 1 then -- Указание ENTRY юзабельного предмета
				if code and tonumber(code) and tonumber(code) > 0 then
					code = tonumber(code)
					local itemQ = WorldDBQuery( 'SELECT name FROM item_template WHERE entry = '..code )
					if itemQ then
						itemQ2 = WorldDBQuery( 'SELECT id FROM craftable_items WHERE trigger_item_entry = '..code )
						if not itemQ2 then
							CraftItems_Table[accountID].trigger_item = {}
							CraftItems_Table[accountID].trigger_item.entry = code
							CraftItems_Table[accountID].trigger_item.name = itemQ:GetString(0)
							player:SendAreaTriggerMessage("Вы указали предмет с ID |cff00FF7F"..code.."|r.")
							CraftItems_Menu( 2, player, _, 1, 1 )
						else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Рецепт с этим предметом уже создан.") CraftItems_Menu( 2, player, _, 1, 1 ) end
					else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Предмет не найден.") CraftItems_Menu( 2, player, _, 1, 1 ) end
				else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Вы должны указать ID (entry) предмета.") CraftItems_Menu( 2, player, _, 1, 1 ) end
			elseif intid == 2 then -- Добавление ингридиента
				if code then
					local entry, amount
					if string.find( code, " " ) then -- Кол-во указано
						code = string.split( code, " " )
						if code[1] and tonumber(code[1]) and tonumber(code[1]) > 0 then
							entry = tonumber(code[1])
							if code[2] and tonumber(code[2]) and tonumber(code[2]) > 0 then
								amount = tonumber(code[2])
							elseif not code[2] then amount = 1
							else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Вы должны указать кол-во ингридиента.") CraftItems_Menu( 2, player, _, 1, 1 ) end
						else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Вы должны указать ID (entry) предмета.") CraftItems_Menu( 2, player, _, 1, 1 ) end
					elseif tonumber(code) and tonumber(code) > 0 then -- Кол-во не указано
						entry = tonumber(code)
						amount = 1
					else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Вы должны указать ID (entry) предмета.") CraftItems_Menu( 2, player, _, 1, 1 ) end
					local itemQ = WorldDBQuery( 'SELECT name FROM item_template WHERE entry = '..entry )
					if itemQ then
						if not CraftItems_Table[accountID].ingredients then
							CraftItems_Table[accountID].ingredients = {}
						else
							for i = 1, #CraftItems_Table[accountID].ingredients do
								if CraftItems_Table[accountID].ingredients[i].entry == entry then
									player:SendAreaTriggerMessage("|cffFF4500[!!]|r Ингридиент уже добавлен и будет перезаписан.")
									table.remove( CraftItems_Table[accountID].ingredients, i )
									break
								end
							end
						end
						table.insert( CraftItems_Table[accountID].ingredients, { entry = entry, amount = amount, name = itemQ:GetString(0) } )
						player:SendAreaTriggerMessage("Вы указали ингридиент с ID |cff00FF7F"..entry.."|r.")
						CraftItems_Menu( 2, player, _, 1, 1 )
					else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Предмет не найден.") CraftItems_Menu( 2, player, _, 1, 1 ) end
				else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Вы должны указать ID (entry) предмета.") CraftItems_Menu( 2, player, _, 1, 1 ) end
			elseif intid == 3 then -- Удаление ингридиента
				if code and tonumber(code) and tonumber(code) > 0 and tonumber(code) <= #CraftItems_Table[accountID].ingredients then
					table.remove( CraftItems_Table[accountID].ingredients, code )
					player:SendAreaTriggerMessage("Вы удалили ингридиент.")
					CraftItems_Menu( 2, player, _, 1, 1 )
				else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Вы должны указать порядковый номер ингридиента из списка.") CraftItems_Menu( 2, player, _, 1, 1 ) end
			elseif intid == 4 then -- Финальная награда
				CraftItems_Table[accountID].reward = {}
				if string.find( code, ";" ) then -- Несколько наград
					code = string.split( code, ";" )
					for i = 1, #code do
						local entry, amount
						if string.find( code[i], " " ) then
							code[i] = string.split( code[i], " " )
							entry = code[i][1]
							amount = code[i][2] or 1 -- Какой-то багфикс.
						else
							entry = code[i]
							amount = 1
						end
						if tonumber(entry) and tonumber(amount) and tonumber(entry) > 0 and tonumber(amount) > 0 then
							entry = tonumber(entry)
							amount = tonumber(amount)
							local itemQ = WorldDBQuery( 'SELECT name FROM item_template WHERE entry = '..entry )
							if itemQ then
								table.insert( CraftItems_Table[accountID].reward, { entry = entry, amount = amount, name = itemQ:GetString(0) } )
							else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Один из указанных предметов не найден.") CraftItems_Menu( 2, player, _, 1, 1 ) CraftItems_Table[accountID].reward = nil return end
						else player:SendAreaTriggerMessage("|cffFF4500[!!]|r При указании одной из наград была допущена ошибка.") CraftItems_Menu( 2, player, _, 1, 1 ) CraftItems_Table[accountID].reward = nil return end
					end
				else -- Одна награда
					if string.find( code, " " ) then
						code = string.split( code, " " )
						if tonumber(code[1]) and tonumber(code[2]) and tonumber(code[1]) > 0 and tonumber(code[2]) > 0 then
							CraftItems_Table[accountID].reward.entry = tonumber(code[1])
							CraftItems_Table[accountID].reward.amount = tonumber(code[2])
						else player:SendAreaTriggerMessage("|cffFF4500[!!]|r При указании награды была допущена ошибка.") CraftItems_Menu( 2, player, _, 1, 1 ) CraftItems_Table[accountID].reward = nil return end
					else -- Кол-во не указано.
						CraftItems_Table[accountID].reward.amount = 1
						if tonumber(code) and tonumber(code) > 0 then
							CraftItems_Table[accountID].reward.entry = code
						else player:SendAreaTriggerMessage("|cffFF4500[!!]|r При указании награды была допущена ошибка.") CraftItems_Menu( 2, player, _, 1, 1 ) CraftItems_Table[accountID].reward = nil return end
					end
					local itemQ = WorldDBQuery( 'SELECT name FROM item_template WHERE entry = '..( CraftItems_Table[accountID].reward.entry ) )
					if itemQ then
						CraftItems_Table[accountID].reward.name = itemQ:GetString(0)
					else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Указанный предмет не найден.") CraftItems_Menu( 2, player, _, 1, 1 ) CraftItems_Table[accountID].reward = nil return end
				end
				player:SendAreaTriggerMessage("Вы указали награду за крафт.")
				CraftItems_Menu( 2, player, _, 1, 1 )
			elseif intid == 5 then -- Выбор требуемой профессии
				if #crafts > 30 then -- >30 вызывает краш сервера
					player:SendBroadcastMessage("|cffFF4500[!!]|r Произошла ОЧЕНЬ критическая ошибка:\nДлина списка доступных профессий превышает 30 элементов.")
					CraftItems_Menu( 2, player, _, 1, 1 )
					return
				end
				player:GossipSetText( "Выберите одну профессию:", 02102001 )
				player:GossipMenuAddItem( 4, crafts[1][2], 3, 1 ) -- Без профессии
				for i = 2, #crafts do
					player:GossipMenuAddItem( 0, crafts[i][2], 3, i, true, "Укажите требуемый уровень навыка." )
				end
				player:GossipSendMenu( 02102001, player, 23092001 )
			elseif intid == 6 then -- Указание времени перезарядки
				if code and tonumber(code) and tonumber(code) >= 0 then
					code = tonumber(code)
					CraftItems_Table[accountID].reload = code * 1000
					player:SendAreaTriggerMessage("Время перезарядки в |cff00FF7F"..code.."|rс указано.")
					CraftItems_Menu( 2, player, _, 1, 1 )
				else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Вы указали некорректное время.") CraftItems_Menu( 2, player, _, 1, 1 ) end
			elseif intid == 7 then -- Завершение создания предмета
				-- ПРИВЯЗЫВАЕМ СПЕЛЛ-ПЛЕЙСХОЛДЕР К ПРЕДМЕТУ, СТАВИМ КУЛДАУН И НУЖНЫЕ ФЛАГИ ДЛЯ ИСПОЛЬЗОВАНИЯ СПЕЛЛА
				local itemQ = WorldDBQuery( 'SELECT Flags, spellid_1 FROM item_template WHERE entry = '..( CraftItems_Table[accountID].trigger_item.entry ) )
				if itemQ then
					local Flags = itemQ:GetUInt32(0)
					if not FindFlag( Flags, 64 ) then Flags = Flags + 64 end
					
					local spellid_1 = itemQ:GetInt32(1)
					if not spellid_1 or spellid_1 == 0 then spellid_1 = spell_placeholder end
					
					local spellcooldown_1 = CraftItems_Table[accountID].reload or default_spell_cooldown
					
					if not CraftItems_Table[accountID].requiredSkill then CraftItems_Table[accountID].requiredSkill = { 0, 0 } end
					
					WorldDBQuery( 'UPDATE item_template SET Flags = '..Flags..', RequiredSkill = '..CraftItems_Table[accountID].requiredSkill[1]..', RequiredSkillRank = '..CraftItems_Table[accountID].requiredSkill[2]..', spellid_1 = '..spellid_1..', spellcooldown_1 = '..spellcooldown_1..' WHERE entry = '..( CraftItems_Table[accountID].trigger_item.entry ) )
					local entry = CraftItems_Table[accountID].trigger_item.entry
					CraftItems_LoadedTable[entry] = {}
					-- ДЕЛАЕМ ЗАПИСЬ В ТАБЛИЦУ ПОД ПРЕДМЕТЫ-РЕЦЕПТЫ
					local resources = {}
					for i = 1, #CraftItems_Table[accountID].ingredients do
						table.insert( resources, { CraftItems_Table[accountID].ingredients[i].entry, CraftItems_Table[accountID].ingredients[i].amount, CraftItems_Table[accountID].ingredients[i].name } )
					end
					CraftItems_LoadedTable[entry].resources = resources
					resources = smallfolk.dumps( resources )
					local result = {}
					if CraftItems_Table[accountID].reward.name then
						result = {
							{
							CraftItems_Table[accountID].reward.entry,
							CraftItems_Table[accountID].reward.amount,
							},
						}
					else
						for i = 1, #CraftItems_Table[accountID].reward do
							table.insert( result, { CraftItems_Table[accountID].reward[i].entry, CraftItems_Table[accountID].reward[i].amount } )
						end
					end
					CraftItems_LoadedTable[entry].result = result
					result = smallfolk.dumps( result )
					WorldDBQuery( [[INSERT INTO craftable_items ( trigger_item_entry, resources, result, account ) values (]]..entry..[[,']]..resources..[[',']]..result..[[',]]..accountID..[[)]] )
					RegisterItemEvent( entry, 2, CraftItems_OnItemUse ) -- ITEM_EVENT_ON_USE
					
					player:SendBroadcastMessage("Рецепт создан.\nENTRY предмета-рецепта: |cff00FF7F"..CraftItems_Table[accountID].trigger_item.entry.."\n|cffFF4500[!!]|rДля завершения создания рецептов перезагрузите базу предметов ( .reload all_item_template ) и при необходимости удалите папку Cache.")
					CraftItems_Menu( 1, player, _, 0 )
				else player:SendBroadcastMessage("|cffFF4500[!!]|r Произошла серьёзная ошибка. Свяжитесь с отделом разработки!") return end -- Предмет успел пропасть из БД?
			elseif intid == 6 then -- Вернуться назад
				CraftItems_Menu( 1, player, _, 0 )
			end
		elseif sender == 3 then -- Выбор профессии
			if intid == 1 then
				CraftItems_Table[accountID].requiredSkill = { 0, 0 }
				player:SendAreaTriggerMessage("Рецепт не требует наличия профессии.")
			else
				if code and tonumber(code) and tonumber(code) > 0 then
					CraftItems_Table[accountID].requiredSkill = {
						crafts[intid][1],	-- ID профессии
						tonumber(code),		-- Уровень профессии
					}
					player:SendAreaTriggerMessage( "Рецепт требует |cff00FF7F"..crafts[intid][2].."|r [|cff00FF7F"..code.."|r]." )
				else player:SendAreaTriggerMessage("|cffFF4500[!!]|r Вы указали некорректный уровень навыка.") CraftItems_Menu( 2, player, _, 2, 5 ) return end
			end
			CraftItems_Menu( 2, player, _, 1, 1 )
		end
	end
end
RegisterPlayerEvent( 42, CraftItems_Menu ) -- PLAYER_EVENT_ON_COMMAND
RegisterPlayerGossipEvent( 23092001, 2, CraftItems_Menu ) -- GOSSIP_EVENT_ON_SELECT

--[[	ЗАГРУЗКА ПРЕДМЕТОВ	]]--

local function CraftItems_Loading( event )
	print("Loading the database for craftItems.lua")
	local craftQ = WorldDBQuery( 'SELECT trigger_item_entry, resources, result FROM craftable_items' )
	if craftQ then
		for i = 1, craftQ:GetRowCount() do
			local trigger_item_entry = craftQ:GetUInt32(0)
			local resources = craftQ:GetString(1)
			local result = craftQ:GetString(2)
			
			RegisterItemEvent( trigger_item_entry, 2, CraftItems_OnItemUse ) -- ITEM_EVENT_ON_USE
			resources = smallfolk.loads( resources )
			result = smallfolk.loads( result )
			CraftItems_LoadedTable[trigger_item_entry] = {
				resources = resources,
				result = result,
			}
			
			craftQ:NextRow()
		end
	end
	print("Database for craftItems.lua loaded.")
end
RegisterServerEvent( 33, CraftItems_Loading ) -- ELUNA_EVENT_ON_LUA_STATE_OPEN ( Когда все скрипты загрузились )

--[[
	╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═
	╩═╦═╩═╦═╩═╦▄████▄═╦▄████▄═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦
	╦═╩═╦═╩═╦═╩██▀▀██═╩██▀▀██═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦
	╩═╦═╩═╦═╩═╦██──██═╦██──██═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═
	╦═╩═╦═╩═╦═╩██──██═╩██──██═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═
	╩═╦═╩═╦═╩═╦██──██═╦██──██═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦
	╦═╩═╦═╩═╦═╩██──██═╩██──██═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═
	╩═╦═╩═╦═╩═▄██──██████──██▄╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═
	╦═╩═╦═╩═▄███▀──────────▀███▄╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦╔════════════════════════════════════════╗═╦═╩═╦═╩═╦
	╩═╦═╩═╦██▀────────────────▀██═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩║╔═╗░╔═╦═╦╗░░░░░░╔══╗░░░░░░░░░░░░░░░░░╔═╗║═╩═╦═╩═╦═╩═
	╦═╩═╦═███─────██─────██────███╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦║║╬╠╦╣═╣═╬╬═╗╔═╦╗╚╗╗╠═╦═╦═╦═╦╗╔═╦═╦═╦╦╣═╣║═╦═╩═╦═╩═╦
	╩═╦═╩═██──────██─────██─────██╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩║║╗╣║╠═╠═║║╬╚╣║║║╔╩╝║╩╬╗║╔╣╩╣╚╣╬║╬║╩╣╔╬═║║═╩═╦═╩═╦═╩
	╦═╩═╦═██─██▄██▄─────────────██╩▄▄▄╩═█▄╩═▄▄▄═╦═╩═╦═╩═╦═╩═╦═╩═╦║╚╩╩═╩═╩═╩╩══╩╩═╝╚══╩═╝╚═╝╚═╩═╩═╣╔╩═╩╝╚═╝║═╦═╩═╦═╩═╦
	╩═╦═╩═██─██████─────────────██╦═▀▀▀▄██▄▀▀▀╦═╩═╦═╩═╦═╩═╦═╩═╦═╩╚═══════════════════════════════╚╝═══════╝═╩═╦═╩═╦═
	╦═╩═╦▄███████▀───▒▒▒────────██╩═╦═█▒▒▒▒█╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦
	╩═╦▄█████▀─────────────────▄██╦═╩███████╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩
	╦═▐█████▄▄───────────────▄▄██═╩═▄███▒▒▒█╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═
	╩═▐████▀▀█████▄▄▄▄▄▄▄█████▀▀╩═╦▄████▒▒██╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩
	╦═▐█████▄▄▄██▀▀▀▀▀▀▀▀▀██▄▄▄▄████████▒▒██╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═
	╩═╦▀████████████▄▄▄██████████████▀╦█▒▒▒█╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩
	╦═╩═╦▀████████████████████████▀═╦═╩█▒▒▒█╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦═╩═╦
]]
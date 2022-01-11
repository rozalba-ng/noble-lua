--	СКРИПТЫ ХЭЛЛУИНОВСКИХ ИВЕНТОВ 2020 ГОДА
local entry_vlad = 9928200
--		Улетающие вороны
local entry_crow = 110001
--		Разбегающиеся тараканы (исп.в Квесте)
local entry_cockroach = 110002
local quest_cockroach = 110024
--		Тыква на лунной поляне
local entry_pumpkin = 9928199
local quest_pumpkin = 110019
--		Задание с оборотнями
local entry_werewolf = 9928219
local entry_attackedPumpkin = 9928229
--		Задание с поиском книги рецептов
local entry_book = 5049130
local quest_book = 110021
--		Задание с призраками
local entry_cauldron = 5049154
local quest_cauldron = 110028
--		Ежедневное задание с убийством скелетов на кладбище
local entry_skeleton = 9928230
local entry_skeleton2 = 9928231
--		Ежедневное задание с полётом на метле
local entry_broom = 9928270
local entry_gameobject_broom = 5049153
local quest_broom = 110026
local entry_eye = 9928271
local spell_eye = 51695
local item_eye = 2114448
--		Необязательное задание с убийством паука
local entry_spider = 9928232
--		Тыквенный Бог (Воскрешает и телепортирует на карту)
local entry_pumpkinGod = 110003

--		Фразы при входе в игру
local welcome_messages = {
	"По вашей коже пробегают мурашки...",
	"Вы чувствуете приближение чего-то великого...",
	"В вашей голове возникает образ не-вампира Владика.",
	"Вы боитесь, что Владик может оказаться вампиром.",
	"Страхвилль манит вас...",
	"Мимо вас пролетает летучая мышь. Вы вспоминаете Владика.",
	'"На колени перед Тыквенным богом, смертный!" - звучит в вашей голове.',
	"Ночью вам приснилась большая тыква наполненная тараканами. Ужас.",
	"Вы думаете о том, что в Страхвилле должны быть секретные задания. Но их пока что нет.",
	"В Страхвилле все знают ваше имя, но что если представиться наоборот?",
	"Над Страхвиллем почти зашло блеклое солнце... С тех пор прошли уже тысячи лет.",
	"Постучите по тыкве, если хотите проверить степень её спелости.",
	"Полёты на метле - весело. Так думает Владик.",
	"Иногда в воздухе пролетают оранжевые глаза. Интересно, куда они летят?",
}
--		Полёт на карту
local taxiTable = { { 1, 7887.3, -2581.1, 489.5 }, { 1, 7889.7, -2578.0, 493.3 }, { 1, 7897.8, -2574.0, 502.8 }, { 1, 7897.7, -2560.3, 511.6 }, { 1, 7886.3, -2562.5, 517.4 }, { 1, 7894.8, -2569.7, 522.2 }, { 1, 7900.0, -2569.2, 525.0 }, { 1, 7901.1, -2564.0, 528.9 }, { 1, 7896.5, -2560.5, 535.8 }, { 1, 7891.4, -2562.1, 543.0 }, { 9001, 102.1, -33.0, 24.1 }, { 9001, 113.5, -1.5, 7.8 }, { 9001, 115.8, 20.7, 4.2 }, { 9001, 107.8, 50.2, 8.5 }, { 9001, 96.2, 43.0, 12.8 }, { 9001, 97.6, 32.7, 16.5 }, { 9001, 97.4, 22.2, 25.9 }, { 9001, 96.2, 20.0, 28.3 }, { 9001, 97.6, 18.8, 29.6 }, { 9001, 106.9, 11.8, 28.7 }, { 9001, 122.7, 4.5, 27.3 }, { 9001, 139.4, 7.7, 26.1 }, { 9001, 150.9, 22.1, 24.8 }, { 9001, 160.1, 50.5, 11.8 }, { 9001, 172.2, 84.8, 6.7 }, { 9001, 166.5, 109.2, 4.2 }, { 9001, 130.2, 132.8, 5.2 }, { 9001, 100.8, 128.1, 7.9 }, { 9001, 83.6, 112.2, 10.4 }, { 9001, 74.1, 87.2, 11.5 }, { 9001, 67.1, 64.9, 12.2 }, { 9001, 64.8, 54.1, 11.5 }, }
local taxi = AddTaxiPath( taxiTable, 16701, 16701 )

local SQL_databaseCreation = [[
CREATE TABLE IF NOT EXISTS `Halloween2020` (
	`player_guid` INT(10) UNSIGNED NOT NULL,
	`quest_stage` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`player_guid`)
)
COMMENT='Used for halloween2020.lua'
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
;
]]
WorldDBQuery( SQL_databaseCreation )

--[[	ОГРАНИЧЕНИЕ СТАРТОВОЙ ЗОНЫ	]]--

local allowed_area_sphere = {
	x = 55.3,
	y = 43.5,
	z = 9,
	radius = 55,
}
local function AllowedArea_StartQuest( _,_,_, player )
	if player:GetMapId() == 9001 and player:GetData("Halloween2020Stage") == 0 then
		player:RegisterEvent( AllowedArea_StartQuest, 5000, 1 )
		if player:GetDistance( allowed_area_sphere.x, allowed_area_sphere.y, allowed_area_sphere.z ) > allowed_area_sphere.radius then
			if not player:GetData("StartQuest_Warning") then
				player:SendAreaTriggerMessage("|cffff7588Вернитесь обратно, а иначе не-вампир Владик вернёт вас сам!")
				player:SetData( "StartQuest_Warning", true )
			else
				player:SetData( "StartQuest_Warning", false )
				player:Teleport( 9001, 52.4, 39, 11, 0.8 )
				player:CastSpell( player, 39568 )
			end
		else
			player:SetData( "StartQuest_Warning", false )
		end
	end
end

--[[	УЛЕТАЮЩИЕ ВОРОНЫ	]]--

local function OnSpawn_ScaredCrow( event, creature )
	creature:SetData( "Fear", false )
end
RegisterCreatureEvent( entry_eye, 5, OnSpawn_ScaredCrow )

local function Ambient_ScaredCrow( _,_,_, player )
	if player:GetMapId() == 9001 then
		player:RegisterEvent( Ambient_ScaredCrow, 2000, 1 )
		if not player:IsGM() then
			local creature = player:GetNearestCreature( 6, entry_crow )
			if creature and not creature:GetData("Fear") then
				local x, y, z = creature:GetLocation()
				x, y, z = math.random(-10,10) + x, math.random(-10,10) + y, 12 + z
				creature:SetByteValue( 6+68, 0, 0 )
				creature:SetDisableGravity( true )
				creature:MoveTo( 02102001, x, y, z )
				creature:SetData( "Fear", true )
				creature:DespawnOrUnsummon( 3000 )
			end
		end
	end
end

--[[	ХРУСТЯЩИЕ ТАРАКАНЫ	]]--

--	Поимка таракана
local function Gossip_ScaredCockroach( event, player, creature )
	if player:HasQuest(quest_cockroach) then
		player:Kill( creature )
		player:Emote( 60 )
		creature:DespawnOrUnsummon( 1500 )
		local amount = player:GetData("Cockroach")
		if not amount then amount = 0 end
		amount = amount + 1
		player:SetData( "Cockroach", amount )
		if amount == 24 then
			player:SendAreaTriggerMessage("|cffff7588Мерзкие таракашки раздавлены!")
			player:CompleteQuest(quest_cockroach)
			player:RewardQuest(quest_cockroach)
		else
			player:SendAreaTriggerMessage( "|cffff7588Таракан хрустит. Осталось раздавить: "..(24 - amount) )
		end
	else
		player:SendBroadcastMessage("|cffff7588Не-вампир Владик не одобрил бы этого. Кто знает, может эти тараканы - его лучшие друзья?")
	end
end
RegisterCreatureGossipEvent( entry_cockroach, 1, Gossip_ScaredCockroach )

local function Quest_ScaredCockroach( event, player, creature, quest )
	if quest == quest_cockroach then
		player:SetData( "Cockroach", 0 )
	end
end
RegisterCreatureEvent( entry_vlad, 31, Quest_ScaredCockroach ) -- CREATURE_EVENT_ON_QUEST_ACCEPT

--[[	ТЫКВА НА ЛУННОЙ ПОЛЯНЕ	]]--

local function Gossip_Pumpkin( event, player, creature, sender, intid )
	if event == 1 then
	--	Первое открытие госсипа
		player:GossipClearMenu()
		player:GossipSetText( "Страхвиль в опасности!", 29102001 )
		player:GossipAddQuests(creature)
		if player:HasQuest(quest_pumpkin) or player:GetData("Halloween2020") then
			player:GossipMenuAddItem( 0, "<Отправиться в Страхвилль.>", 1, 1 )
		end
		player:GossipSendMenu( 29102001, creature )
	else
	--	Выбор варианта
		player:StartTaxi(taxi)
	end
end
RegisterCreatureGossipEvent( entry_pumpkin, 1, Gossip_Pumpkin ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( entry_pumpkin, 2, Gossip_Pumpkin ) -- GOSSIP_EVENT_ON_SELECT

local function PlayerData( event, player )
	if event == 28 and player:GetMapId() == 9001 and player:HasQuest(quest_pumpkin) then
	--	Первый вход на карту
		local guid = tostring( player:GetGUID() )
		WorldDBQuery("REPLACE INTO Halloween2020 (player_guid) VALUES ("..guid..")")
		player:SetData( "Halloween2020", true )
		player:SetData( "Halloween2020Stage", 0 )
		player:SetData( "HalloweenMap", true )
		player:SetPhaseMask(2)
	end
	if event == 3 then
	--	Заход в игру
		local guid = tostring( player:GetGUID() )
		local playerQ = WorldDBQuery( "SELECT quest_stage FROM Halloween2020 WHERE player_guid = '"..guid.."'" )
		if playerQ then
			player:SetData( "Halloween2020", true )
			local stage = playerQ:GetUInt8(0)
			player:SetData( "Halloween2020Stage", stage )
			if player:GetMapId() == 9001 then
				PlayerData( 28, player ) -- Переход к установке флага и соотв.фазы
			end
			player:SendBroadcastMessage( "|cffff7588"..welcome_messages[math.random(1,#welcome_messages)] )
		end
	else
	--	Смена карты
		if player:GetMapId() == 9001 then
			local stage = player:GetData("Halloween2020Stage")
			if stage == 0 then
				player:SetPhaseMask(2)
				if not player:GetData("StartQuestArea") then
					player:SetData( "StartQuestArea", true )
					player:RegisterEvent( AllowedArea_StartQuest, 15000, 1 )
				end
			elseif stage == 1 then
				player:SetPhaseMask(1)
			elseif stage == 2 then
				player:SetPhaseMask(5)
			end
			player:SetData( "HalloweenMap", true )
			if not player:GetData("CrowTrigger") then
				player:SetData( "CrowTrigger", true )
				player:RegisterEvent( Ambient_ScaredCrow, 5000, 1 )
			end
		elseif player:GetData("HalloweenMap") then
			player:SetData( "HalloweenMap", false )
			player:SetData( "StartQuestArea", false )
			player:SetData( "CrowTrigger", false )
			player:SetPhaseMask(1)
		end
	end
end
RegisterPlayerEvent( 3, PlayerData ) -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent( 28, PlayerData ) -- PLAYER_EVENT_ON_MAP_CHANGE

--[[	ОБОРОТНИ	]]--

werewolfs_table = {}

local function OnCombat_Werewolf( event, creature, target )
	creature:SetRooted(false)
	creature:EmoteState(0)
end
RegisterCreatureEvent( entry_werewolf, 1, OnCombat_Werewolf ) -- CREATURE_EVENT_ON_ENTER_COMBAT

local function Killer_Werewolf(eventId)
	local creature = loadCreature( werewolfs_table[eventId] )
	if not creature:IsInCombat() then
		creature:SetRooted(true)
		local pumpkin = creature:GetNearestCreature( 15, entry_attackedPumpkin )
		if pumpkin then
			creature:SetFacingToObject(pumpkin)
			creature:EmoteState(36)
		end
	end
end

local function OnReachHome_Werewolf( event, creature )
	math.randomseed( os.time() + creature:GetGUIDLow() )
	local id = math.random( 1, #jumpPoints )
	creature:MoveJump( jumpPoints[id].x, jumpPoints[id].y, jumpPoints[id].z, math.random(15,18), math.random(20,25) )
	local eventId = CreateLuaEvent( Killer_Werewolf, 4000, 1 )
	werewolfs_table[eventId] = saveCreature(creature)
end
RegisterCreatureEvent( entry_werewolf, 24, OnReachHome_Werewolf ) -- CREATURE_EVENT_ON_REACH_HOME

local function OnSpawn_Werewolf( event, creature )
	math.randomseed( os.time() + creature:GetGUIDLow() )
	if math.random(1,100) >= 90 then
		if math.random(1,2) == 2 then
			creature:SendUnitEmote("Оборотень взбирается на холм и яростно рычит!")
		else
			creature:SendUnitEmote("Оборотень клацает зубами.")
		end
	end
	local pumpkins = creature:GetNearObjects( 40, 0, entry_attackedPumpkin )
	local pumpkin = pumpkins[math.random(1,#pumpkins)]
	local x, y, z = pumpkin:GetLocation()
	local xOfs = math.random(-2,2)
	if xOfs == 0 then xOfs = 1 end
	local yOfs = math.random(-2,2)
	if yOfs == 0 then yOfs = 1 end
	creature:MoveJump( x+xOfs, y+yOfs, z, math.random(15,18), math.random(20,25) )
	local eventId = CreateLuaEvent( Killer_Werewolf, 4000, 1 )
	werewolfs_table[eventId] = saveCreature(creature)
end
RegisterCreatureEvent( entry_werewolf, 5, OnSpawn_Werewolf ) -- CREATURE_EVENT_ON_SPAWN

--[[	ПОИСК КНИГИ РЕЦЕПТОВ	]]--

local function OnRead_Book( event, objectORplayer, player )
	if event == 14 then
		player:GossipClearMenu()
		player:GossipSetText( "<Древний фолиант с рецептами не-вампира Владика.>\n...\n<В книге присутствуют страшные картинки. Лучше бы вы и правда не смотрели дальше первой страницы.>", 30102001 )
		if player:HasQuest(quest_book) then
			player:GossipMenuAddItem( 0, "<Забрать книгу.>", 1, 1 )
		end
		player:GossipSendMenu( 30102001, player, 30102002 )
	else
		objectORplayer:SetData( "Halloween2020Stage", 1 )
		objectORplayer:SetPhaseMask(1)
		local guid = tostring( objectORplayer:GetGUID() )
		WorldDBQuery("UPDATE Halloween2020 SET quest_stage = 1 WHERE player_guid = '"..guid.."'")
		objectORplayer:CompleteQuest(quest_book)
		objectORplayer:GossipComplete()
	end
end
RegisterGameObjectEvent( entry_book, 14, OnRead_Book ) -- GAMEOBJECT_EVENT_ON_USE
RegisterPlayerGossipEvent( 30102002, 2, OnRead_Book ) -- GOSSIP_EVENT_ON_SELECT

--[[	БУНТУЮЩИЕ СКЕЛЕТЫ	]]--

local skeleton_phrases = {
	"Вы правда верите в то, что Владик не вампир?",
	"Я пляшу уже целый век!",
	"Мои суставы этого не выдержат.",
	"Я всего-то хотел отдохнуть!",
	"Господин заставляет плясать нас круглые сутки, а сам даже таракана раздавить не может.",
	"Это не может продолжаться вечно, слышишь?!",
}

local function OnDamageTaken_Skeleton( event, creature, target )
	math.randomseed( os.time() + creature:GetGUIDLow() )
	if math.random(1,100) >= 50 then
		creature:SendUnitSay( skeleton_phrases[ math.random(1,#skeleton_phrases) ], 0)
	end
end
RegisterCreatureEvent( entry_skeleton, 1, OnDamageTaken_Skeleton ) -- CREATURE_EVENT_ON_ENTER_COMBAT
RegisterCreatureEvent( entry_skeleton2, 1, OnDamageTaken_Skeleton ) -- CREATURE_EVENT_ON_ENTER_COMBAT

--[[	ДЯДЯ ШНЮК ПАЖИЛОЙ ПАВУЧОК	]]--

local spider_phrases = {
    "Да когда уже этот проклятый кровосос уймётся?!",
    "Отстаньте, я на самоизоляции!",
    "Этот не-вампир вообще слышал о том, что такое социальная дистанция?",
    "Проваливай из моего склепа, двуногий болван!",
    "Пошел вон!",
    "Да когда это уже закончится?!",
}

local function OnDamageTaken_Spider( event, creature )
	math.randomseed( os.time() + creature:GetGUIDLow() )
	creature:SendUnitSay( spider_phrases[ math.random(1,#spider_phrases) ], 0)
end
RegisterCreatureEvent( entry_spider, 1, OnDamageTaken_Spider ) -- CREATURE_EVENT_ON_ENTER_COMBAT

--[[	ТЕХНИЧЕСКИЕ ОГРАНИЧЕНИЯ ДЕЯТЕЛЬНОСТИ ИГРОКОВ	]]--

--	Ангти ГМ-ка

local function AntiGM( event, player )
	if player:GetGMRank() == 1 and player:GetMapId() == 9001 then
		if not player:GetAccountId() == 8828 then -- Если НЕ игровая поддержка
			player:SendBroadcastMessage("|cffff7588Увы, не-вампир Владик не позвал вас на свою крутую вечеринку..\n|cffff7588Попробуйте зайти с игрового аккаунта.")
			player:Teleport( 1, 7796, -2574, 489, 0 )
			player:SetPhaseMask(1)
		end
	end
end
RegisterPlayerEvent( 28, AntiGM ) -- PLAYER_EVENT_ON_MAP_CHANGE

--	Анти гошки

local function AntiGOB(event, player, item, target)
	if player:GetMapId() == 9001 then
        player:SendBroadcastMessage("|cffff7588Вы не можете строить здесь. Не-вампир Владик этого не оценит.")
        return false;
    end
end

local function RegisterEvent_AntiGOB()
	local Q = WorldDBQuery("SELECT entry FROM item_template WHERE entry > 500000 and entry < 600000")
	for i = 1, Q:GetRowCount() do
		local entry = Q:GetInt32(0)
		RegisterItemEvent( entry, 2, AntiGOB )
		Q:NextRow()
	end
end
RegisterServerEvent( 33, RegisterEvent_AntiGOB ) -- ELUNA_EVENT_ON_LUA_STATE_OPEN

--[[	ВОСКРЕШАЮЩИЙ ИГРОКОВ ТЫКВЕННЫЙ БОГ	]]--

local function Gossip_PumpkinGod( event, player, creature, sender, intid )
	if event == 1 then
	--	Первый вывод текста.
		player:GossipClearMenu()
		if player:GetData("Halloween2020") then
			player:GossipSetText( "Неуклюжий смертный снова мёртв? Я могу воскресить его и вернуть в Страхвилл.", 30102001 )
			player:GossipMenuAddItem( 0, "<Отправиться в Страхвилл.>", 1, 1 )
		else
			player:GossipSetText( "Тыквенный Бог не знает твоего имени.", 30102001 )
		end
		player:GossipSendMenu( 30102001, creature )
	else
	--	Выбор варианта.
		if sender == 1 then
			player:GossipComplete()
			player:Teleport( 9001, 277.3, 182.3, 6.5, 3.1 )
			player:ResurrectPlayer(25)
		end
	end
end
RegisterCreatureGossipEvent( entry_pumpkinGod, 1, Gossip_PumpkinGod ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( entry_pumpkinGod, 2, Gossip_PumpkinGod ) -- GOSSIP_EVENT_ON_SELECT

--[[	ПОЛЁТ НА МЕТЛЕ	]]--

local allowed_areas = {
	{
		x = { 46.5, 415 },
		y = { -33, 223.6 },
		z = { -1, 68 },
	},
	{
		x = { 200, 415 },
		y = { -66, 223.6 },
		z = { -1, 68 },
	},
}
local function AllowedArea_BroomFly( _,_,_, player )
    if player:IsOnVehicle() then
		player:RegisterEvent( AllowedArea_BroomFly, 5000, 1 )
		local x, y, z = player:GetLocation()
		for i = 1, #allowed_areas do
			if x > allowed_areas[i].x[1] and x < allowed_areas[i].x[2] then
				if y > allowed_areas[i].y[1] and y < allowed_areas[i].y[2] then
					if z > allowed_areas[i].z[1] and z < allowed_areas[i].z[2] then
						if player:GetData("BroomFly_Warning") then player:SetData( "BroomFly_Warning", false ) end
						return
					end
				end
			end
		end
		if not player:GetData("BroomFly_Warning") then
			player:SendAreaTriggerMessage("|cffff7588Вернитесь обратно, а иначе не-вампир Владик вернёт вас сам!")
			player:SetData( "BroomFly_Warning", true )
		else
			local broom = player:GetNearestCreature(entry_broom)
			broom:DespawnOrUnsummon(1000)
			player:SetData( "BroomFly_Warning", false )
			player:SetData( "Broom", nil )
			player:Teleport( 9001, 389, 146.8, 38, 0 )
			player:CastSpell( player, 39568 )
		end
	end
end

local function OnSpawn_Eye( event, creature )
	creature:SetData( "Killed", false )
end
RegisterCreatureEvent( entry_eye, 5, OnSpawn_Eye )

local function Trigger_Eye( _,_,_, player )
	if player:IsOnVehicle() and not player:HasItem( item_eye, 10 ) and player:HasQuest(quest_broom) then
		player:RegisterEvent( Trigger_Eye, 1000, 1 )
		local eye = player:GetNearestCreature( 4, entry_eye )
		if eye and not eye:GetData("Killed") then
			eye:SetData( "Killed", true )
			eye:CastSpell( eye, spell_eye )
			eye:DespawnOrUnsummon(1000)
			player:AddItem( item_eye )
		end
	end
end

local function WhenPlayerMountedOnBroom( event, player, spell )
	if spell:GetEntry() == 43671 and player:GetMapId() == 9001 then -- Управление техникой
		player:RegisterEvent( AllowedArea_BroomFly, 1000, 1 )
		player:RegisterEvent( Trigger_Eye, 1000, 1 )
	end
end
RegisterPlayerEvent( 5, WhenPlayerMountedOnBroom ) -- PLAYER_EVENT_ON_SPELL_CAST

local function SpawnBroom( _,_, player )
	if player:HasQuest(quest_broom) and ( not player:GetData("Broom") or (os.time() - player:GetData("Broom")) > 180  ) then
		local x,y,z,o = player:GetLocation()
		local broom = player:SpawnCreature( entry_broom, x,y,z,o, 3, 180000 )
		broom:SetSpeed( 6, 5 )
		player:SetData( "Broom", os.time() )
		player:CastSpell( broom, 43671 )
	else
		local vlad = player:GetNearestCreature( 25, entry_vlad )
		if vlad then
			vlad:SendChatMessageToPlayer( 12, 0, "Ай-яй-яй, это не для вас.", player )
		end
	end
end
RegisterGameObjectEvent( entry_gameobject_broom, 14, SpawnBroom ) -- GAMEOBJECT_EVENT_ON_USE

local function OnQuestAbandon_Eye( event, player, questId )
	if questId == quest_cockroach then
		player:SetData( "Cockroach", 0 )
	elseif questId == quest_broom then
		player:SetData( "KilledEyes", 0 )
	end
	player:RemoveQuest(questId)
end
RegisterPlayerEvent( 38, OnQuestAbandon_Eye ) -- PLAYER_EVENT_ON_QUEST_ABANDON

--[[	ПРИЗРАКИ	]]--

local function OnQuestFinished_Cauldron( event, player, object, quest )
	if quest:GetId() == quest_cauldron then
		player:SetData( "Halloween2020Stage", 2 )
		player:SetPhaseMask(5)
		local guid = tostring( player:GetGUID() )
		WorldDBQuery("UPDATE Halloween2020 SET quest_stage = 2 WHERE player_guid = '"..guid.."'")
		player:SendBroadcastMessage("|cffff7588Вы чувствуете на себе уставшие взгляды...")
	end
end
RegisterGameObjectEvent( entry_cauldron, 5, OnQuestFinished_Cauldron ) -- GAMEOBJECT_EVENT_ON_QUEST_REWARD

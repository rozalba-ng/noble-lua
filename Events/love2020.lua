local SQL_databaseCreation = [[
CREATE TABLE IF NOT EXISTS `love2020` (
	`account` INT(10) UNSIGNED NOT NULL,
	`valentine` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`text` TEXT NOT NULL COLLATE 'latin1_swedish_ci',
	`lamp` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`account`)
)
COMMENT='Used for events/love2020.lua'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]
CharDBQuery( SQL_databaseCreation )

local event = {
	entry = {
		item = 5057535,
		creature = 9931186,
		creature_gossip = 9931188,
		firework = 44940,
		aura = 62002,
		aura_frog = 62537,
		trader = 9931187,
	},
	text = {
		"Не желаете приобрести прошлогодние открытки? Новая коллекция!",
		"С праздником! Покупать будете?",
		"Романтика, значит? Я продаю отличные подарки для таких себе вторых половинок.",
		"Вы любите своего партнёра, а я люблю деньги. Всё сходится!",
		"Купите букетик.",
		"А-апчхи! Кто подсказал ей брызнуть в меня духами?! ... Покупать будете?",
		"Купите что-нибудь, прошу!",
		"Мой девиз - \"Лучшие побрякушки для бездельников и лучше безделушки для побрякушек\".",
	},
	text2 = {
		"Вы когда-нибудь пробовали целовать лягушек? А жаб?",
		"Я ищу здесь свою любовь но, похоже, что все подходят ко мне только за подарками.",
		"Я слышал о некой Зергуше... Вы её не видели?",
		"Я всё разгадал: Мор влюблена в Владикавкуся, Розальба в сервер, Неко в Санта, Адель в Кункуна, а Акостар, Эзил, Харуша, Элнир и Снежок в... Ну, вы поняли. Они просто любят своё дело.",
		"Вы наверное кого-то любите, да?",
		"Не стесняйтесь признаваться в любви. Даже если объект обожания красив...",
		"Вам давали почитать стихи написанные влюблёнными? Нет? Я мог бы дать вам почитать свои, но забыл их сегодня дома.",
		"Кто-то облил КунКуна розовой краской. Мне кажется ему это нравится...",
		"Любовная лихорадка сносит всем голову, а Адель отмечает свой день рождения. Вы, кстати, не забыли её поздавить?",
	},
}

--[[	ЗАПУСК ФОНАРИКОВ	]]--

function event.FlyingLamp( _,_,_, creature )
	if math.random(1,4) == 1 then -- 25% шанс
		creature:CastSpell( creature, event.entry.firework, true )
	end
	creature:SetScale( creature:GetScale()+0.2 )
	local x,y,z = creature:GetLocation()
	creature:MoveJump( x+math.random(-4,4), y+math.random(-4,4), z+math.random(1,2), 0.2, 3 )
end

function event.OnSpawnLamp( _,_,_, creature )
	local x,y,z = creature:GetLocation()
	creature:MoveJump( x, y, z+4, 0.4, 1 )
	creature:RegisterEvent( event.FlyingLamp, 15000, 26 )
end

function event.OnUseLamp( _, player, item, target )
	player:CastSpell( player, 6245, true )----
	local x,y,z,o = player:GetLocation()
	local creature
	creature = player:SpawnCreature( event.entry.creature, x+math.random(-1,1), y+math.random(-1,1), z+1.2, o, 3, 420000 ) -- TEMPSUMMON_TIMED_DESPAWN
	creature:RegisterEvent( event.OnSpawnLamp, 3000, 1 )
	creature:SetDisableGravity(true)
	local guid = player:GetGUIDLow()
	creature:SetOwnerGUID( guid )
	creature:SetCreatorGUID( guid )
	player:RemoveItem( item, 1 )
	player:PlayDirectSound( 12901, player )
	return true
end
RegisterItemEvent( event.entry.item, 2, event.OnUseLamp ) -- ITEM_EVENT_ON_USE

--[[	ОТПРАВЛЕНИЕ ПОЦЕЛУЙЧИКОВ	]]--

event.kisses = {}

function event.OnKiss( _, player, emote )
	if emote == 58 then
		local target = player:GetSelection()
		if target and ( player ~= target ) then
			if not target:HasAura( event.entry.aura ) then
				local name = player:GetName()
				if not event.kisses[name] then
					event.kisses[name] = 1
				else
					event.kisses[name] = event.kisses[name] + 1
					if event.kisses[name] >= math.random(10,20) then
						event.kisses[name] = 0
						local x,y,z,o = player:GetLocation()
						local creature = player:SpawnCreature( event.entry.trader, x+0.2, y+0.2, z+0.2, o, 3, 40000 )
						creature:SendUnitSay( event.text[math.random(1,#event.text)], 0 )
						creature:MoveFollow( player )
						creature:SetDisableGravity(true)
						local guid = player:GetGUIDLow()
						creature:SetOwnerGUID( guid )
						creature:SetCreatorGUID( guid )
					end
				end
				target:AddAura( event.entry.aura, target )
			end
			if target:ToCreature() and ( (target:GetEntry() == 9925361) or (target:GetEntry() == 9925362) ) then
				player:AddAura( event.entry.aura_frog, player )
			end
		end
	end
end
RegisterPlayerEvent( 24, event.OnKiss ) -- PLAYER_EVENT_ON_TEXT_EMOTE

--[[	АНОНИМНЫЕ ВАЛЕНТИНКИ, ОТПРАВКА ФОНАРИКОВ	]]--

function event.Gossip( e, player, creature, sender, intid, code )
	if e == 1 then
		local text = event.text2[math.random(1,#event.text2)]
		text = text.."\n\nХотите отправить валентинку или праздничный фонарик?"
		local Q = CharDBQuery("SELECT valentine, lamp FROM love2020 WHERE account = "..player:GetAccountId())
		if Q then
			local valentine = Q:GetUInt32(0)
			local lamp = Q:UInt8(1)
			if valentine == 0 then
				text = text.."\nХорошие новости - вы можете отправить анонимную валентинку."
				player:GossipMenuAddItem( 0, "<Отправить анонимную валентинку.>", 1, 1 )
			end
			if lamp < 2 then
				text = text.."\nФонарики любят все. Хотите отправить фонарик?"
				if lamp == 0 then
					player:GossipMenuAddItem( 0, "<Анонимно отправить фонарик.>", 1, 2, true, "Введите имя получателя.\nВы можете отправить ещё 2 фонарика." )
				else
					player:GossipMenuAddItem( 0, "<Анонимно отправить фонарик.>", 1, 2, true, "Введите имя получателя.\nВы можете отправить ещё 1 фонарик." )
				end
			end
		else
			text = text.."\nВы можете отправить по фонарику двум дорогим вам людям и одну анонимную валентинку. Не пишите туда гадостей, прошу!"
			player:GossipMenuAddItem( 0, "<Отправить анонимную валентинку.>", 1, 1 )
			player:GossipMenuAddItem( 0, "<Анонимно отправить фонарик.>", 1, 2, true, "Введите имя получателя.\nВы можете отправить ещё 2 фонарика." )
		end
		player:GossipSetText( text, 14022101 )
		player:GossipSendMenu( 14022101, creature )
	else
		if sender == 1 then
			if intid == 1 then
			else
				if code and ( code ~= " " ) then
					if code ~= player:GetName() then
						local Q = CharDBQuery("SELECT lamp FROM love2020 WHERE account = "..player:GetAccountId())
						local lamp = Q:GetUInt8()
						if lamp < 2 then
							local Q2 = CharDBQuery("SELECT account, guid FROM characters WHERE name = '"..tostring(code).."'")
							if Q2 then
								local account = Q:GetInt32(0)
								if account ~= player:GetAccountId() then
									lamp = lamp + 1
									CharDBQuery("REPLACE INTO love2020 ( account, lamp ) VALUES ( "..player:GetAccountId()..", "..lamp.." )")
									local guid = Q:GetInt32(1)
									SendMail( "Любовная лихорадка", "Кто-то решил отправить вам этот чудесный фонарик.", guid, 0, 64, 20, 0, 0, event.entry.item, 1 )
									player:SendAreaTriggerMessage("Подарок отправлен!")
									player:GossipComplete()
								else
									player:SendNotification("Вы не можете отправить подарок себе.")
									player:GossipComplete()
								end
							else
								player:SendNotification("Получатель не найден.")
								player:GossipComplete()
							end
						end
					else
						player:SendNotification("Вы не можете отправить подарок себе.")
						player:GossipComplete()
					end
				else
					player:SendNotification("Вы не указали имя получателя.")
					player:GossipComplete()
				end
			end
		else
			if intid == 1 then
			else
			end
		end
	end
end
RegisterCreatureGossipEvent( event.entry.creature_gossip, 1, event.Gossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( event.entry.creature_gossip, 2, event.Gossip ) -- GOSSIP_EVENT_ON_SELECT
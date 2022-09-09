-- Таблица с сохранёнными NPC
local savedNpc = {}
--test
local aura_whitelist = { 12, 44 }
--[[	ВИД ТАБЛИЦЫ
savedNpc = {
	entry = {
		guid = {
			animation = 1
			size = 1
			mount = 0
			...
		}
		guid = {
		...
		}
	}
	entry = {
	...
	}
}
]]
-- В БД хранятся:
-- entry, guid, animation, size, mount, byte1, byte2, auras, gm_account_id

--[[	ДЕЙСТВИЯ ПРИ ПРОГРУЗКЕ NPC	]]--

function savedNpcUpdate(event, creature)
	local entry, guid = creature:GetEntry(), creature:GetDBTableGUIDLow()
	if savedNpc[entry] and savedNpc[entry][guid] then
		creature:EmoteState(savedNpc[entry][guid].animation) -- Анимация
		creature:SetScale(savedNpc[entry][guid].size) -- Размер
		if savedNpc[entry][guid].mount ~= 0 then 
			creature:Mount(savedNpc[entry][guid].mount) -- Маунт
		end
		creature:SetByteValue(6+68,0,( savedNpc[entry][guid].byte1 )) -- Byte1 (Сидит/Лежит/Умер)
		creature:SetByteValue(6+116,0,( savedNpc[entry][guid].byte2 )) -- Byte2 (Оружие)
		if type(savedNpc[entry][guid].auras) == "table" then -- Ауры
			for i = 1,#savedNpc[entry][guid].auras do
				if not creature:HasAura( savedNpc[entry][guid].auras[i] ) then
					creature:AddAura( savedNpc[entry][guid].auras[i] ,creature)
				end
			end
		else
			if savedNpc[entry][guid].auras then
				if not creature:HasAura( savedNpc[entry][guid].auras ) then
					creature:AddAura( savedNpc[entry][guid].auras ,creature)
				end
			end
		end
	end
end

--[[	ЗАГРУЗКА СОХРАНЁННЫХ NPC	]]--

local savedNpcQ = WorldDBQuery("SELECT entry,guid,animation,size,mount,byte1,byte2,auras FROM saved_npc")
if savedNpcQ then
	for i = 1, savedNpcQ:GetRowCount() do
		local entry = savedNpcQ:GetInt32(0)
		if not savedNpc[entry] then
			savedNpc[entry] = {}
			RegisterCreatureEvent(entry,36,savedNpcUpdate)
		end
		if savedNpcQ:GetString(7) then -- У NPC есть ауры?
			local auras = savedNpcQ:GetString(7)
			if(string.find(auras, " ")) then
				local aurasT = string.split(auras, " ")
			else aurasT = tonumber(auras) end -- Если аура только одна
		end
		local guid = savedNpcQ:GetInt32(1)
		savedNpc[entry][guid] = {
			animation = savedNpcQ:GetUInt16(2),
			size = savedNpcQ:GetUInt8(3),
			mount = savedNpcQ:GetInt32(4),
			byte1 = savedNpcQ:GetUInt8(5),
			byte2 = savedNpcQ:GetUInt8(6),
			auras = aurasT,
		}
		savedNpcQ:NextRow()
	end
end

--[[	СОХРАНЕНИЕ NPC	]]--
-- Entry, Guid, Анимация, Размер, Маунт, Байт 1, Байт 2, Ауры, ID аккаунта ГМа
	
function savedNpcSAVE(event, player, command)
	if ( (command == "savenpc" or command == "npcsave") and player:GetGMRank() > 0 ) then
		local PlayerTarget = player:GetSelection()
		if PlayerTarget then
			if PlayerTarget:ToCreature() then
				local entry, guid = PlayerTarget:GetEntry(), PlayerTarget:GetDBTableGUIDLow()
				if not savedNpc[entry] then savedNpc[entry] = {} end
				if not savedNpc[entry][guid] then savedNpc[entry][guid] = {} end
				-- Анимация
				savedNpc[entry][guid].animation = PlayerTarget:GetByteValue(6+77,0)
				-- Размер
				savedNpc[entry][guid].size = PlayerTarget:GetScale()
				-- Маунт
				if PlayerTarget:IsMounted() then
					savedNpc[entry][guid].mount = PlayerTarget:GetMountId()
				else
					savedNpc[entry][guid].mount = 0
				end
				-- Байт 1 (Сидит/Лежит/Умер)
				savedNpc[entry][guid].byte1 = PlayerTarget:GetByteValue(6+68,0)
				-- Байт 2 (Оружие)
				savedNpc[entry][guid].byte2 = PlayerTarget:GetByteValue(6+116,0)
				-- Ауры
				savedNpc[entry][guid].auras = {}
				local aurasForDB = ""
				for k,v in pairs(aura_whitelist) do
					if PlayerTarget:HasAura(v) then
						table.insert(savedNpc[entry][guid]["auras"],v)
						aurasForDB = v.." "..aurasForDB
					end
				end
				if aurasForDB == "" then -- Если аур нет
					savedNpc[entry][guid].auras = 0
					aurasForDB = "0"
				end
				-- ID аккаунта ГМа
				local gm_account_id = player:GetAccountId()
				-- Сохранение инфы в БД
				local NPCAlreadySavedQ = WorldDBQuery('SELECT guid FROM saved_npc WHERE entry = '..entry..' AND guid = '..guid)
				if NPCAlreadySavedQ then
					WorldDBQuery('UPDATE saved_npc SET animation = '..savedNpc[entry][guid]["animation"]..',size = '..savedNpc[entry][guid]["size"]..',mount = '..savedNpc[entry][guid]["mount"]..',byte1 = '..savedNpc[entry][guid]["byte1"]..',byte2 = '..savedNpc[entry][guid]["byte2"]..',auras = "'..aurasForDB..'",gm_account_id = '..gm_account_id..' WHERE guid = '..guid)
					player:SendBroadcastMessage("Сохранённый NPC обновлён.")
				else
					WorldDBQuery('INSERT INTO saved_npc (entry, guid, animation, size, mount, byte1, byte2, auras, gm_account_id) VALUES ('..entry..','..guid..','..savedNpc[entry][guid]["animation"]..','..savedNpc[entry][guid]["size"]..','..savedNpc[entry][guid]["mount"]..','..savedNpc[entry][guid]["byte1"]..','..savedNpc[entry][guid]["byte2"]..',"'..aurasForDB..'",'..gm_account_id..')')
					RegisterCreatureEvent(entry,36,savedNpcUpdate)
					player:SendBroadcastMessage("NPC сохранён.")
				end
			else player:SendBroadcastMessage("|cffFF4500[!!]|r Возьмите NPC в таргет.") end
		else player:SendBroadcastMessage("|cffFF4500[!!]|r Возьмите NPC в таргет.") end
	end
	
--[[	ОТМЕНА СОХРАНЕНИЯ МАСТЕРОМ	]]--
	
	if ( (command == "unsavenpc" or command == "npcunsave") and player:GetGMRank() > 0 ) then
		local PlayerTarget = player:GetSelection()
		if PlayerTarget and PlayerTarget:ToCreature() then
			local entry, guid = PlayerTarget:GetEntry(), PlayerTarget:GetDBTableGUIDLow()
			if savedNpc[entry] and savedNpc[entry][guid] then
				savedNpc[entry][guid] = nil
				WorldDBQuery('DELETE FROM saved_npc WHERE guid = '..guid)
				player:SendBroadcastMessage("NPC перестал сохраняться.")
			else player:SendBroadcastMessage("|cffFF4500[!!]|r Данный NPC ещё не сохранён.") end
		else player:SendBroadcastMessage("|cffFF4500[!!]|r Возьмите NPC в таргет.") end
	end
end
RegisterPlayerEvent( 42, savedNpcSAVE )

--[[	ЧИСТКА УДАЛЁННЫХ NPC	]]--

local function ForgetSavedNPC(event, creature)
	local entry, guid = creature:GetEntry(), creature:GetDBTableGUIDLow()
	if savedNpc[entry] and savedNpc[entry][guid] then
		WorldDBQuery("DELETE FROM saved_npc WHERE guid = "..guid)
	end
end
RegisterServerEvent( 31, ForgetSavedNPC )

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
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
]]
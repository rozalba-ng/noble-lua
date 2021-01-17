
	local AIO = AIO or require("AIO")
local BM_Handlers = AIO.AddHandlers("BM_Handlers", {})

local EVENT_ON_CAST = 5;



 TURN_AURA = 88037
 IS_IN_BATTLE_AURA = 88057
 LEAVER_AURA = 88058
 HP_AURA =  88059
 WOUND_AURA = 88010
 DOUBLE_ATTACK_AURA = 88076
 DEAD_AURA = 45801


local TIMER_FOR_TURN = 90
local TIMER_FOR_PREPARATION = 60
--Cостояния персонажа
local PState_DEAD = 0
local PState_LIVE = 1
local PState_SKIP = 2
---

--Состояния боя
local BState_INVITE = 0
local BState_PREPARING = 1
local BState_STARTED = 2
local BState_PAUSED = 3
local BState_CLOSED = 4
local BState_CANCELED = 5
local BState_ESCAPING = 6 
---

local hpBuffAuraList = {	{id = 88044, bonus = 1},
							{id = 88039, bonus = 1},
							{id = 88045, bonus = 1},
							{id = 88071, bonus = 1},
							{id = 88072, bonus = 1},
							{id = 88046, bonus = 2},
							{id = 88047, bonus = 2},
							{id = 88048, bonus = 2},
							{id = 88049	, bonus = 2},
							{id = 88074, bonus = 2},
							{id = 88073, bonus = 2}
						}


function tcontain(table,key)
	for i = 1, #table do
		if table[i] == key then
			return i
		end
	end
	return false
end

function findPlayer(table,key)
	for i = 1, #table do
		if table[i].name == key then
			return i
		end
	end
	return false
end
function round(n)
	    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
	end

local battleList = {}

--[[local battleTemplate = {	initor = "", 			--|Заготовка объекта боя
							victim = "", 				--|
							players = {},				--|
							playersCanEnter = {},		--|
							livePlayers = 0,			--|
							battleState = BState_INVITE	--|
							}
]]
							
--[[local playerInfoTemplate = { 	name = "", 						--|Заготовка данных персонажа
								state = PState_LIVE, 				--|
								hp = 0, 							--|
								flaglist = {["offline"] = false}} 	--|
]]
local battleInitiations = {}
local battlesExpect = {}

listPlayersInBattle = {}

local listPlayersInBattleTemplate = {battleId = 0}

local function createBattleData()
	local battleTemplate = {	battleId = 0,
								initorName = "", 				--|Заготовка объекта боя
								victimName = "", 				--|
								players = {},					--|
								playersCanEnter = {},			--|
								livePlayers = 0,				--|
								escapeResistors = {},			--|
								state = BState_INVITE,			--|
								lastTimerId = 0,				--|
								timeOfBattlePrep = 0,			--|
								diedPlayers = {},				--|
								winnerPlayers = {},
								runAwayPlayers = {},				--|
								rpMessage = "",					--|
								oocMessage = ""					--|
							}

	return battleTemplate
end

local function createPlayerData(player)
	local hpCount = 3
	for i = 1, #hpBuffAuraList do
		if player:HasAura(hpBuffAuraList[i].id) then
			hpCount = hpCount + hpBuffAuraList[i].bonus
		end
	end
	local playerData = { 	name = player:GetName(),
							state = PState_LIVE,
							hp = hpCount,
							maxHp = hpCount,
							startDist = 0,
							initiateRoll = 0,
							flaglist = 	{	offline = false,
											skipLastTurn = false,
											alreadyRunned = false
										}
						}
	return playerData
end

local function openBattleSession(initor,victim, rpMessage, oocMessage)
	local battle = createBattleData()
	battle.initorName = initor:GetName()
	battle.victimName = victim:GetName()
	battle.rpMessage = rpMessage
	battle.oocMessage = oocMessage
	table.insert(battleList,battle)
	local id = #battleList
	battle.battleId = id
	battle.players = { createPlayerData(GetPlayerByName(battle.initorName)),createPlayerData(GetPlayerByName(battle.victimName))}
	listPlayersInBattle[initor:GetName()] = { battleId = 0 }
	listPlayersInBattle[initor:GetName()].battleId = battle.battleId
	listPlayersInBattle[victim:GetName()] = { battleId = 0 }
	listPlayersInBattle[victim:GetName()].battleId = battle.battleId
	return battle
end
local function client_UpdatePlayersFrame(battle)
	for i = 1, #battle.players do
		local playerName = battle.players[i].name
		local player = GetPlayerByName(playerName)
		if player then
			AIO.Handle(player,"BM_Handlers","UpdatePlayersFrame",battle)
		end
	end
end

function GetPlayerBattleId(player)
	return listPlayersInBattle[player:GetName()].battleId
end

function GetPlayerBattleTurn(player)
	local aura = player:GetAura(TURN_AURA)
	return aura:GetStackAmount()
end


local function preparePlayerToBattle(player,battle)
	listPlayersInBattle[player:GetName()] = { battleId = 0 }
	listPlayersInBattle[player:GetName()].battleId = battle.battleId
	player:AddAura(IS_IN_BATTLE_AURA,player)
	local turnAura = player:AddAura(TURN_AURA,player)
	local turn = 0
	for i = 1, #battle.players do
		if battle.players[i].name == player:GetName() then
			turn = i
		end
	end
	turnAura:SetStackAmount(turn)
	local hpAura = player:AddAura(HP_AURA,player)
	hpAura:SetStackAmount(battle.players[turn].hp)
end
local function isInSameBattle(player,target)
	if player:HasAura(IS_IN_BATTLE_AURA) then
		if target:HasAura(IS_IN_BATTLE_AURA) then
			if GetPlayerBattleId(player) == GetPlayerBattleId(target) then
				return true
			end
		end
	else
		return false
	end

end


local function addPlayerInBattle(player,battle,dist)
	local playerData = createPlayerData(player)
	playerData.startDist = dist
	if battle.state == BState_PREPARING then  
		table.insert(battle.players,playerData)
		SayToBattle(cGreen.."Игрок "..cWhite..player:GetName().." присоединился к бою!",battle)
	elseif battle.state == BState_STARTED then 
		table.insert(battle.players,playerData)
		preparePlayerToBattle(player,battle)
		battle.livePlayers = battle.livePlayers + 1
		SayToBattle(cGreen.."Игрок "..cWhite..player:GetName().." присоединился к бою!",battle)
	end
	client_UpdatePlayersFrame(battle)
end


function randomizeTable(tab)
	local places = {}
	local newTab = {}
	for i = 1, #tab do
		table.insert(places,i)
	end
	while #places > 0 do
		local randomPlace = table.remove(places,math.random(#places))
		newTab[randomPlace] = table.remove(tab)
	end
	return newTab
end

local battleTimerList = {}

local function BattleTimer(eventId, delay, repeats) 
	local battle = battleTimerList[eventId]
	if battle and battle.state ~= BState_ESCAPING and battle.state ~= BState_CLOSED then
		battle.players[1].flaglist.skipLastTurn = true
		nextTurnBattle(battle.battleId)
	end
end

local function updateTimerFrame(battle,seconds)
	for i = 1, #battle.players do
		local playerName = battle.players[i].name
		local player = GetPlayerByName(playerName)
		if player then
			AIO.Handle(player,"BM_Handlers","SetTimer",seconds)
			
		end
	end
	client_UpdatePlayersFrame(battle)
end

local function SetTurnTimer(battle,seconds)
	battleTimerList[battle.lastTimerId] = nil
	local timerId = CreateLuaEvent(BattleTimer,seconds*1000,1)
	battleTimerList[timerId] = battle
	battle.lastTimerId = timerId
	updateTimerFrame(battle,seconds)
end

function startBattle(battle)
	battle.state = BState_STARTED
	local sortTable = {pair = {}, lowDist = {}, midDist = {}, highDist = {}}
	local newQuery = {}
	for i = 1, #battle.players do
		if i == 1 or i == 2 then
			table.insert(sortTable.pair, battle.players[i])
		elseif battle.players[i].startDist < 13.2 then
			table.insert(sortTable.lowDist, battle.players[i])
		elseif battle.players[i].startDist >= 13.2 and battle.players[i].startDist < 26.4 then
			table.insert(sortTable.midDist, battle.players[i])
		elseif battle.players[i].startDist >= 26.4 then
			table.insert(sortTable.highDist, battle.players[i])
		end
	end
	for k,v in pairs (randomizeTable(sortTable.pair)) do table.insert(newQuery,v) end
	for k,v in pairs (randomizeTable(sortTable.lowDist)) do table.insert(newQuery,v) end
	for k,v in pairs (randomizeTable(sortTable.midDist)) do table.insert(newQuery,v) end
	for k,v in pairs (randomizeTable(sortTable.highDist)) do table.insert(newQuery,v) end
	battle.players = newQuery
	SayToBattle(cGreen.."Начало битвы!"..cR.." Количество игроков - "..cGreen..#battle.players..cR,battle)
	local playerListText = ""
	for i = 1, #battle.players do
		local player = GetPlayerByName(battle.players[i].name)
		player:SetRooted(true)
		preparePlayerToBattle(player,battle)
		playerListText = playerListText.."|Hplayer:"..battle.players[i].name.."|h"..cWhite.."["..battle.players[i].name.."]|r|h"
		if i < #battle.players then
			playerListText = playerListText..", "
		else
			playerListText = playerListText..". "
		end
	end
	battle.livePlayers = #battle.players
	client_UpdatePlayersFrame(battle)
	SayToBattle("Участники: "..playerListText,battle)
	SetTurnTimer(battle,TIMER_FOR_TURN)
end
function endBattle(battle)
	for i = 1, #battle.players do
		
		local playerName = battle.players[i].name
		local player = GetPlayerByName(playerName)
		listPlayersInBattle[playerName] = nil
		if player then
			--[[if battle.players[i].state == PState_DEAD and not player:HasAura(WOUND_AURA) then
				player:AddAura(WOUND_AURA, player)
			elseif battle.players[i].state == PState_DEAD  and player:HasAura(WOUND_AURA) then
				local woundAura = player:GetAura(WOUND_AURA)
				woundAura:SetStackAmount(woundAura:GetStackAmount()+1)
			end]]
			player:RemoveAura(HP_AURA)
			player:RemoveAura(TURN_AURA)
			player:RemoveAura(IS_IN_BATTLE_AURA)
			local deadAura = player:GetAura(DEAD_AURA)
			player:EmoteState( 0 )
			if deadAura then
				player:RemoveAura(DEAD_AURA)
				player:SetStandState(8)
				
				
			end
			player:RemoveAura(DEAD_AURA)
			player:SetRooted(false)
			AIO.Handle(player,"BM_Handlers","EndBattle")
		end
	end
	SayToBattle("Бой завершен.",battle)
	local winnerList = ""
	for i = 1, #battle.players do
		if battle.players[i].state == PState_LIVE then
			winnerList = winnerList.." |Hplayer:"..battle.players[i].name.."|h"..cGreen.."["..battle.players[i].name.."]|r|h"
		end
	end
	local diedList = ""
	for i = 1, #battle.diedPlayers do
		diedList = diedList.." |Hplayer:"..battle.diedPlayers[i].."|h"..cRed.."["..battle.diedPlayers[i].."]|r|h"
	end
	local runAwayList = ""
	for i = 1, #battle.runAwayPlayers do
		runAwayList = runAwayList.." |Hplayer:"..battle.runAwayPlayers[i].."|h"..cWhite.."["..battle.runAwayPlayers[i].."]|r|h"
	end
	
	if #battle.diedPlayers > 0 then
		SayToBattle("Поверженные: "..diedList,battle)
	end
	if #battle.runAwayPlayers > 0 then
		SayToBattle("Сбежали: "..runAwayList,battle)
	end
	SayToBattle("Победители: "..winnerList,battle)
	
	local clearWinnerList = ""
	for i = 1, #battle.players do
		if battle.players[i].state == PState_LIVE then
			clearWinnerList = clearWinnerList.." "..battle.players[i].name
		end
	end
	local clearDiedList = ""
	for i = 1, #battle.diedPlayers do
		clearDiedList = clearDiedList.." "..battle.diedPlayers[i]
	end
	local clearRunAwayList = ""
	for i = 1, #battle.runAwayPlayers do
		clearRunAwayList = clearRunAwayList.." "..battle.runAwayPlayers[i]
	end
	
	WorldDBExecute("INSERT INTO `world`.`BattleSystem_results` (`winnerList`, `leaverList`, `loserList`, `rpReason`, `oocReason`) VALUES ('"..clearWinnerList.."', '"..clearRunAwayList.."', '"..clearDiedList.."', '"..battle.rpMessage.."', '"..battle.oocMessage.."');")
	battle.state = BState_CLOSED
end
local function killPlayerInBattle(battle,player)
	
	for i = 1, #battle.players do
		if battle.players[i].name == player:GetName() then
			battle.players[i].hp = 0
			battle.players[i].state = PState_DEAD
			player:RemoveAura(HP_AURA)
			player:AddAura(DEAD_AURA,player)
			player:RemoveAura(TURN_AURA)
			battle.livePlayers = battle.livePlayers - 1
			SayToBattle(player:GetName().." теряет все свои очки здоровья и выбывает из битвы!",battle)
			table.insert(battle.diedPlayers,player:GetName())
		end
	end
end


function updateStatePlayers(battleId)
	local turn = 1
	local battle = battleList[battleId]
	for i = 1, #battle.players do
		local player = GetPlayerByName(battle.players[i].name)
		if player then 
			player:SetRooted(true)
			local healthAura = player:GetAura(HP_AURA)
			listPlayersInBattle[player:GetName()] = {}
			listPlayersInBattle[player:GetName()] = { battleId = battle.battleId }
			if healthAura ~= nil then
				battle.players[i].hp = healthAura:GetStackAmount()
				local turnAura = player:GetAura(TURN_AURA)
				turnAura:SetStackAmount(turn)
				turn = turn + 1
			end
		end
	end
	client_UpdatePlayersFrame(battle)
end



function nextTurnBattle(battleId)
	local battle = battleList[battleId]
	battle.players[1].flaglist.alreadyRunned = false
	local allPlayerIsSkipping = true
	for i = 1, #battle.players do
		if battle.players[i].flaglist.skipLastTurn == false and battle.players[i].flaglist.offline == false and battle.players[i].state ~= PState_DEAD then
			allPlayerIsSkipping = false
		end
	end
	
	if battle.state == BState_CLOSED then
		return false
	end
	if battle.livePlayers == 1 or #battle.players == 1 or allPlayerIsSkipping then
		endBattle(battle)
		return false
	end
	if battle and (battle.state ~= BState_CLOSED or battle.state ~= BState_ESCAPING) or battle.state ~= BState_CANCELED then
		local firstPlayer = battle.players[1]
		table.insert(battle.players,firstPlayer)
		table.remove(battle.players,1)
		while battle.players[1].state == PState_DEAD or battle.players[1].flaglist.offline == true do
			firstPlayer = battle.players[1]
			table.remove(battle.players,1)
			table.insert(battle.players,firstPlayer)
		end
	end
	SetTurnTimer(battle,TIMER_FOR_TURN)
	updateStatePlayers(battleId)
	local firstPlayer = GetPlayerByName(battle.players[1].name)
	firstPlayer:SendNotification("Ваш ход!")
	firstPlayer:PlayDirectSound(8462,firstPlayer)
	client_UpdatePlayersFrame(battle)
end
function SayToBattle(text,battle)
	if battle ~= nil then
		if battle.players ~= nil then
			for i = 1, #battle.players do
				local player = GetPlayerByName(battle.players[i].name)
				if player then
					player:SendBroadcastMessage(text)
				end
			end
		end
	end
end
function handlePlayerRoll(success,rollType, player,target,isPotionReroll,isCrit)
	if (not player:HasAura(IS_IN_BATTLE_AURA) and target:HasAura(IS_IN_BATTLE_AURA)) or (player:HasAura(IS_IN_BATTLE_AURA) and not target:HasAura(IS_IN_BATTLE_AURA)) then
		player:SendBroadcastMessage("Вы не можете атаковать цель, которая находится не в вашем бою.")
		return false
	end

	if (isInSameBattle(player,target) or (player:GetName() == target:GetName() and rollType == 6 and player:HasAura(IS_IN_BATTLE_AURA))) and  not isPotionReroll then
		if GetPlayerBattleTurn(player) == 1 then
			if  player:GetSelection() == player and rollType ~= 6 then
				player:SendBroadcastMessage("Вы не можете совершить атаку на самого себя.")
				return false
			end
			local battleId = listPlayersInBattle[player:GetName()].battleId
			local battle = battleList[battleId]
			if target:HasAura(HP_AURA) then
				if success and rollType ~= 6 then
					if player:HasAura(DOUBLE_ATTACK_AURA) and isCrit then
						local hpAura = target:GetAura(HP_AURA)
						SayToBattle(cWhite..player:GetName()..cR.." снимает "..cWhite..target:GetName().." "..cRed.."2 очка здоровья."..cR.." Эффект бонуса \"Стремительность\"",battle)
						if hpAura:GetStackAmount() < 3 then
							killPlayerInBattle(battle,target)
						else
							hpAura:SetStackAmount(hpAura:GetStackAmount() - 2)
						end
					
					else
						local hpAura = target:GetAura(HP_AURA)
						SayToBattle(cWhite..player:GetName()..cR.." снимает "..cWhite..target:GetName().." "..cRed.."1 очко здоровья."..cR,battle)
						if hpAura:GetStackAmount() < 2 then
							killPlayerInBattle(battle,target)
						else
							hpAura:SetStackAmount(hpAura:GetStackAmount() - 1)
						end
					end
					
				elseif rollType == 6 then
					local hpAura = target:GetAura(HP_AURA)
					local curHp = hpAura:GetStackAmount()
					local pid = findPlayer(battle.players,target:GetName())
					local maxHp = battle.players[pid].maxHp
					if curHp < maxHp then
						if success then
							if target:GetName() == player:GetName() then
								SayToBattle(cWhite..player:GetName()..cR.." восстанавливает сам себе "..cGreen.."1 очко здоровья."..cR,battle)
							else
								SayToBattle(cWhite..player:GetName()..cR.." восстанавливает "..cWhite..target:GetName().." "..cGreen.."1 очко здоровья."..cR,battle)
							end
							hpAura:SetStackAmount(curHp + 1)
						end
					else
						player:SendBroadcastMessage("У игрока уже максимальное количество здоровья. Попробуйте что-нибудь другое.")
						return false
					end
				
				end
				battle.players[1].flaglist.skipLastTurn = false
				nextTurnBattle(battleId)
				return true
			else
				player:SendBroadcastMessage("Цель уже выбыла из битвы")
				return false
			end
			
		else
			player:SendBroadcastMessage("Ваша атака не засчитывается как боевая, так как сейчас не ваш ход!")
			return false
		end
	else
		return true
	
	end
	
end



function UpdateClientDataTable(player,battleId)
	if player then
		AIO.Handle(player,"BM_Handlers","UpdatePlayerTable",battleList[battleId].players)
	end
end

local timedBattleStart = {}
	
local function TimerToStartBattle(timerId, delay, repeats, playerObject)
	player = playerObject:ToPlayer()
	local battle = timedBattleStart[timerId]
	startBattle(battle)	
end


local function initiateBattle(player, target)
	battleInitiations[player:GetName()] =  target:GetName()
	
end


local function startBattlePreparation(battle)
	battle.state = BState_PREPARING
	local playersCanEnter = { 	{name = battle.initorName, dist = 0},
								{name = battle.victimName, dist = 0}
							}
	local initor = GetPlayerByName(battle.initorName)
	local victim = GetPlayerByName(battle.victimName)
	local playersAround = initor:GetPlayersInRange(40)
	for i = 1, #playersAround do
		if playersAround[i]:GetName() ~= battle.victimName and playersAround[i]:GetName() ~= battle.initorName then
			table.insert(playersCanEnter, {name = playersAround[i]:GetName(), dist = initor:GetDistance(playersAround[i]) })
		end
	end
	
	battle.playersCanEnter = playersCanEnter
	initor:SetRooted(true)
	initor:EmoteState( 45 )
	victim:EmoteState( 45 )
	victim:SetRooted(true)
	initor:SendBroadcastMessage(cRed.."Вы напали на "..cGreen..battle.victimName..cRed.."!"..cR.." В течение минуты к бою могут подключиться другие игроки.")
	victim:SendBroadcastMessage(cRed.."На вас напал "..cGreen..battle.initorName..cRed.."!"..cR.." В течение минуты к бою могут подключиться другие игроки.")
	initor:TextEmote(battle.rpMessage)
	for i = 3, #battle.playersCanEnter do
		local player = GetPlayerByName(battle.playersCanEnter[i].name)
		if not player:HasAura(IS_IN_BATTLE_AURA) then
			player:SendBroadcastMessage(cGreen..battle.initorName..cR.." нападает на "..cGreen..battle.victimName..cR.."! |HEnterBattle:"..battle.battleId.."|h[Подключиться к бою!]|h") 
		end
	end	
	timerId = initor:RegisterEvent(TimerToStartBattle,TIMER_FOR_PREPARATION*1000,1)
	timedBattleStart[timerId] = battle
	client_UpdatePlayersFrame(battle)
	battle.timeOfBattlePrep = os.clock()
	updateTimerFrame(battle,TIMER_FOR_PREPARATION)
end

function sendInviteToBattle(battle,player,oocMessage,rpMessage)
	AIO.Handle(player,"BM_Handlers","OpenInviteFrame",battle.initorName,oocMessage,rpMessage)
end


function BM_Handlers.SendInitiateData(player, rpMessage, oocMessage)
	local targetName = battleInitiations[player:GetName()]
	local target = GetPlayerByName(targetName)
	if target then
		if not player:HasAura(IS_IN_BATTLE_AURA) and not listPlayersInBattle[targetName] and not listPlayersInBattle[player:GetName()] then
			if not target:HasAura(IS_IN_BATTLE_AURA) then
				if player:IsOnVehicle() then
					player:SendBroadcastMessage("Сначала необходимо спешиться")
					return false
				end
				local battle = openBattleSession(player,target,rpMessage,oocMessage)
				sendInviteToBattle(battle,target,oocMessage,rpMessage)
				player:SendBroadcastMessage(targetName.." отправлен вызов на бой.")
				--startBattlePreparation(battle)
			else
				player:SendBroadcastMessage("Игрок уже находится в другой битве.")

			end
		else
			player:SendBroadcastMessage("Вы уже находитесь в другой битве.")

		end
		
	else
		player:SendBroadcastMessage("Необходимо выбрать в цель "..cWhite.." игрока.|r")
	end
end

local function LetEscape(battle)
	
	AIO.Handle(GetPlayerByName(battle.players[1].name),"BM_Handlers","EndBattle")
	
	local playerName = battle.players[1].name
	local player = GetPlayerByName(playerName)
	listPlayersInBattle[playerName] = nil
	player:RemoveAura(HP_AURA)
	player:AddAura(LEAVER_AURA,player)
	player:RemoveAura(TURN_AURA)
	player:RemoveAura(IS_IN_BATTLE_AURA)
	player:SetRooted(false)
	player:EmoteState(0)
	table.remove(battle.players,1)
	battle.state = BState_STARTED
	battle.escapeResistors = {}
	battle.livePlayers = battle.livePlayers - 1
	table.insert(battle.runAwayPlayers,playerName) 
	nextTurnBattle(battle.battleId)
end

local function InterruptEscape(battle)
	battle.state = BState_STARTED
	battle.escapeResistors = {}
	nextTurnBattle(battle.battleId)
end


local function EscapeTimer(eventId, delay, repeats) 
	local battle = battleTimerList[eventId]
	if battle.state == BState_ESCAPING then
		if #battle.escapeResistors == 0 then
			SayToBattle("Игроку "..battle.players[1].name.." никто не мешает и он успешно сбегает с поле боя!",battle)
			LetEscape(battle)
		else
			local escapeRoll = math.random(1,12)
			local playerListText = ""
			local resistPoints = #battle.escapeResistors
			for i = 1, #battle.escapeResistors do
				playerListText = playerListText.."|Hplayer:"..battle.escapeResistors[i].."|h"..cWhite.."["..battle.escapeResistors[i].."]|r|h"
			end
			local isSuccess = false
			local color = ""
			if resistPoints > 5 then
				resistPoints = 5
			end
			if escapeRoll >= 6 + resistPoints then
				isSuccess = true
				color = cGreen
			else
				isSuccess = false
				color = cRed
			end
			SayToBattle("Порог побега: 6 + "..#battle.escapeResistors.." (Сопротивление - "..playerListText..") = "..resistPoints + 6 ..". Результат броска на побег - "..color..escapeRoll,battle)
			if isSuccess then
				SayToBattle(battle.players[1].name.." успешно сбегает с поля боя!",battle)
				LetEscape(battle)
			else
				SayToBattle(battle.players[1].name.." проваливает попытку побега!",battle)
				InterruptEscape(battle)
			end
		end
	end
end

function BM_Handlers.PlayerSkipping(player)
	local battle = battleList[listPlayersInBattle[player:GetName()].battleId]
	if battle.players[1].name == player:GetName() and battle.state == BState_STARTED then
		battle.players[1].flaglist.skipLastTurn = true
		SayToBattle(player:GetName().." пропускает ход.",battle)
		nextTurnBattle(battle.battleId)
	end
end

local function SetEscapeTimer(battle,seconds)
	local timerId = CreateLuaEvent(EscapeTimer,seconds*1000,1)
	battleTimerList[timerId] = battle
	updateTimerFrame(battle,seconds)
end

function BM_Handlers.TryToEscape(player)
	local battle = battleList[listPlayersInBattle[player:GetName()].battleId]
	if battle.players[1].name == player:GetName() and battle.state == BState_STARTED then
		battle.state = BState_ESCAPING
		SayToBattle(player:GetName().." пытается бежать с поля боя!",battle)
		SetEscapeTimer(battle, TIMER_FOR_TURN/2)
		client_UpdatePlayersFrame(battle)
		return false
	end
	player:SendBroadcastMessage("Попытку побега необходимо совершать в свой ход.")
end
function BM_Handlers.InterruptToEscape(player)	
	local battle = battleList[listPlayersInBattle[player:GetName()].battleId]
	local pid = findPlayer(battle.players,player:GetName())
	if not tcontain(battle.escapeResistors, player:GetName()) and battle.state == BState_ESCAPING and battle.players[1].name ~= player:GetName() and battle.players[pid].state ~= PState_DEAD then
		table.insert(battle.escapeResistors,player:GetName())
		SayToBattle(player:GetName().." пытается помешать побегу.",battle)
		client_UpdatePlayersFrame(battle)
	end
end
function BM_Handlers.PlayerAcceptInvite(player)
	local battle = battleList[listPlayersInBattle[player:GetName()].battleId]
	local newOccMessage = ""
	local oocMessage = battle.oocMessage
	
	local newRpMessage = ""
	local rpMessage = battle.rpMessage
	local target = GetPlayerByName(battle.initorName)
	if player:IsOnVehicle() or target:IsOnVehicle() then
		player:SendBroadcastMessage("Все участники боя должны быть спешаны со скакуна.")
		target:SendBroadcastMessage("Все участники боя должны быть спешаны со скакуна.")
		endBattle(battle)
		return false
	end
	local max_char = 1500
	for S in string.gmatch(oocMessage, "[^\"\'\\]") do
			if string.len(newOccMessage) < max_char then
				newOccMessage = (newOccMessage..S)
			else
				player:SendBroadcastMessage("Возникла ошибка")
				target:SendBroadcastMessage("Возникла ошибка")
				endBattle(battle)
				break
			end
		end
		
	for S in string.gmatch(rpMessage, "[^\"\'\\]") do
			if string.len(newRpMessage) < max_char then
				newRpMessage = (newRpMessage..S)
			else
				player:SendBroadcastMessage("Возникла ошибка")
				target:SendBroadcastMessage("Возникла ошибка")
				endBattle(battle)
				break
			end
		end
	WorldDBExecute("INSERT INTO `world`.`BattleSystem_initiations` (`initiatorName`, `targetName`, `oocReason`, `rpReason`, `accepted`) VALUES ('"..battle.initorName.."', '"..battle.victimName.."', '"..newOccMessage.."', '"..newRpMessage.."', '1');")
	startBattlePreparation(battle)
end

function BM_Handlers.PlayerDesclineInvite(player)
	local battle = battleList[listPlayersInBattle[player:GetName()].battleId]
	local initor = GetPlayerByName(battle.initorName)
	initor:SendBroadcastMessage(player:GetName().." отклоняет вызов боя.")
	local newOccMessage = ""
	local oocMessage = battle.oocMessage
	
	local newRpMessage = ""
	local rpMessage = battle.rpMessage
	
	local max_char = 1500
	for S in string.gmatch(oocMessage, "[^\"\'\\]") do
			if string.len(newOccMessage) < max_char then
				newOccMessage = (newOccMessage..S)
			else
				SayToBattle("Возникла ошибка",battle)
				endBattle(battle)
				break
			end
		end
		
	for S in string.gmatch(rpMessage, "[^\"\'\\]") do
			if string.len(newRpMessage) < max_char then
				newRpMessage = (newRpMessage..S)
			else
				SayToBattle("Возникла ошибка",battle)
				endBattle(battle)
				break
			end
		end
	WorldDBExecute("INSERT INTO `world`.`BattleSystem_initiations` (`initiatorName`, `targetName`, `oocReason`, `rpReason`, `accepted`) VALUES ('"..battle.initorName.."', '"..battle.victimName.."', '"..newOccMessage.."', '"..newRpMessage.."', '0');")
	listPlayersInBattle[battle.initorName] = nil
	listPlayersInBattle[battle.victimName] = nil
	battleInitiations[battle.initorName] = nil
	battle = nil
end
function BM_Handlers.StartBattle(player,targetName)
	local targetSel = player:GetSelection()
	if player:HasAura(LEAVER_AURA) then
		player:SendBroadcastMessage("Вы недавно сбежали из боя и не можете организовать новый, пока на вас наложен эффект \"Сбежавший\"")
		return false
	end
	if player:IsOnVehicle() then
		player:SendBroadcastMessage("Сначала необходимо спешиться")
		return false
	end
	if targetSel == nil then
		player:SendBroadcastMessage("Необходимо выбрать в цель "..cWhite.."игрока.|r")
		return false
	end
	local target = targetSel:ToPlayer()
	if target and target:GetName() ~= player:GetName() and not listPlayersInBattle[targetName] and not listPlayersInBattle[player:GetName()] then
		if not player:HasAura(IS_IN_BATTLE_AURA) then
			if not target:HasAura(IS_IN_BATTLE_AURA) then
				if target:HasAura(LEAVER_AURA) then
					player:SendBroadcastMessage("Игрок только что сбежал из боя.")
					return false
				end
				initiateBattle(player, target)
				AIO.Handle(player,"BM_Handlers","OpenInitFrame",target:GetName())
			else
				player:SendBroadcastMessage("Игрок уже находится в другой битве.")

			end
		else
			player:SendBroadcastMessage("Вы уже находитесь в другой битве.")

		end
		
	else
		player:SendBroadcastMessage("Необходимо выбрать в цель "..cWhite.."игрока.|r")
	end
end

function BM_Handlers.CastRoll(player,roll)
	local targetSel = player:GetSelection()
	if targetSel == nil then
		player:SendBroadcastMessage("Необходимо выбрать в цель "..cWhite.."игрока.|r")
		return false
	end
	local target = targetSel:ToPlayer()
	if  target and isInSameBattle(player,target) then
		local spellId
		if roll == 1 then spellId = 88005
		elseif roll == 2 then spellId = 88006
		elseif roll == 3 then spellId = 88007
		elseif roll == 4 then spellId = 88008
		end
		player:CastSpell(target,spellId,true)
		player:ResetSpellCooldown(spellId,true)
	
	end
end
function BM_Handlers.EnterInBattle(player, value)
	local battleId = tonumber(value) 
	local battle = battleList[battleId]
	if not player:HasAura(IS_IN_BATTLE_AURA) and not listPlayersInBattle[player:GetName()] and battle then
		for i = 1, #battle.players do
			if battle.players[i].name == player:GetName() then
				player:SendBroadcastMessage("Вы уже находитесь в бою.")
				return false
			end
		end
		for i = 1, #battle.playersCanEnter do
			if battle.playersCanEnter[i].name == player:GetName()  then
				if not player:HasAura(LEAVER_AURA) then
					if not player:IsOnVehicle() then
						addPlayerInBattle(player,battle,battle.playersCanEnter[i].dist)
						player:SetRooted(true)
						player:EmoteState( 45 )
						AIO.Handle(GetPlayerByName(battle.players[1].name),"BM_Handlers","CallToSendTime",player:GetName())
						return true
					else
						player:SendBroadcastMessage("Сначала необходимо спешиться.")
					end
				else
					player:SendBroadcastMessage("Вы недавно сбежали из боя и не можете присоединиться, пока на вас наложен эффект \"Сбежавший\"")
				
				end
			end
		end
		
	else
		player:SendBroadcastMessage("Вы уже находитесь в бою.")
	
	end
end

local reRootPlayerList = {}

function reRoot(eventId, delay, repeats) 
	local playerName = reRootPlayerList[eventId]
	local player = GetPlayerByName(playerName)
	if listPlayersInBattle[playerName] then
		player:SetRooted(true)
	end
end
function BM_Handlers.StartRunning(player)
	local bid = listPlayersInBattle[player:GetName()].battleId
	local battle = battleList[bid]
	if battle.players[1].name == player:GetName() and battle.players[1].flaglist.alreadyRunned == false then
		player:SetRooted(false)
		battle.players[1].flaglist.alreadyRunned = true
		local id = CreateLuaEvent(reRoot,3*1000,1)
		reRootPlayerList[id] = player:GetName()
	end
end
function BM_Handlers.TechnicalLeave(player)
	local bid = listPlayersInBattle[player:GetName()].battleId
	local battle = battleList[bid]
	
	local playerName = player:GetName()
	local pid = findPlayer(battle.players,player:GetName())
	SayToBattle(playerName.." покидает бой по неролевой причине. В случае нарушения правил сервера обратитесь к игровому мастеру.",battle)
	AIO.Handle(player,"BM_Handlers","EndBattle")
	player:EmoteState( 0)
	player:RemoveAura(HP_AURA)
	player:RemoveAura(TURN_AURA)
	player:RemoveAura(IS_IN_BATTLE_AURA)
	player:RemoveAura(DEAD_AURA)	
	player:SetRooted(false)
	table.remove(battle.players,pid)
	battle.state = BState_STARTED
	battle.escapeResistors = {}
	battle.livePlayers = battle.livePlayers - 1
	table.insert(battle.runAwayPlayers,playerName) 
	listPlayersInBattle[playerName] = nil
	nextTurnBattle(battle.battleId)
	
	WorldDBExecute("INSERT INTO `world`.`BattleSystem_techleaves` (`playerName`) VALUES ('"..player:GetName().."');")
	
end
function BM_Handlers.SendTime(player, secs, targetName)
	AIO.Handle(GetPlayerByName(targetName),"BM_Handlers","SetTimer",secs)
end

local function OnPlayerCommandWithArg(event, player, code)
    if code == "techleave" then
		if listPlayersInBattle[player:GetName()] then
			AIO.Handle(player,"BM_Handlers","TechLeaveFrameOpen")
		else
			player:SendBroadcastMessage("Вы не находитесь в бою.")
		end
	end
	
end

local function OnPlayerLogin(event, player)
	if listPlayersInBattle[player:GetName()] then
		local battleId = GetPlayerBattleId(player)
		local battle = battleList[battleId]
		for i = 1, #battle.players do
			if battle.players[i].name == player:GetName() then
				battle.players[i].flaglist.offline = false
			end
		end
		AIO.Handle(player,"BM_Handlers","StartBattle")
		updateStatePlayers(battleId)
	else
		player:RemoveAura(HP_AURA)
		player:RemoveAura(TURN_AURA)
		player:RemoveAura(DEAD_AURA)
		player:SetRooted(false)
		player:RemoveAura(IS_IN_BATTLE_AURA)
	end
end



local function castEvent(event, player, spell, skipCheck)
	local spellId = spell:GetEntry();
	if listPlayersInBattle[player:GetName()] then
		local bid = listPlayersInBattle[player:GetName()].battleId
		local battle = battleList[bid]
		if (spellId == 88041) and not battle then
			local itemLink = GetItemLink(600054,8)
				player:SendBroadcastMessage(player:GetName().." использует "..itemLink.." и |cFF79ed21 восполняет одно потерянное очко здоровья!|r")
			local nearPlayers = player:GetPlayersInRange( 40, 0, 0 )
			for index, nearPlayer in pairs(nearPlayers) do
				nearPlayer:SendBroadcastMessage(player:GetName().." использует "..itemLink.." и |cFF79ed21 восполняет одно потерянное очко здоровья!|r")
			end
			player:RemoveAura(88041)
		elseif (spellId == 88041) and battle then
			local pid = findPlayer(battle.players,player:GetName())
			local hpAura = player:GetAura(HP_AURA)
			local hpCount = hpAura:GetStackAmount()
			if hpCount < battle.players[pid].maxHp then
				local itemLink = GetItemLink(600054,8)
				player:SendBroadcastMessage(player:GetName().." использует "..itemLink.." и |cFF79ed21 восполняет одно потерянное в бою очко здоровья!|r")
				local nearPlayers = player:GetPlayersInRange( 40, 0, 0 )
				for index, nearPlayer in pairs(nearPlayers) do
					nearPlayer:SendBroadcastMessage(player:GetName().." использует "..itemLink.." и |cFF79ed21 восполняет одно потерянное в бою очко здоровья!|r")
				end
				hpAura:SetStackAmount(hpCount+1)
				player:RemoveAura(88041)
				updateStatePlayers(battle.battleId)
			else
				player:SendBroadcastMessage("У вас максимальное количество здоровья.")
				player:AddItem(600054,1)
				player:RemoveAura(88041)
			end
		elseif spellId ==84022 or spellId == 43671 then
			if listPlayersInBattle[player:GetName()] then
				local target = spell:GetTarget()
				target:DespawnOrUnsummon()
			end
		end
	end
end


local function OnPlayerLogout(event, player)
	if listPlayersInBattle[player:GetName()] then
		local battleId = GetPlayerBattleId(player)
		local battle = battleList[battleId]
		for i = 1, #battle.players do
			if battle.players[i].name == player:GetName() then
				battle.players[i].flaglist.offline = true
			end
		end
		updateStatePlayers(battleId)
	end
end

RegisterPlayerEvent(EVENT_ON_CAST, castEvent);
RegisterPlayerEvent(3, OnPlayerLogin)
RegisterPlayerEvent(4, OnPlayerLogout)
RegisterPlayerEvent(42, OnPlayerCommandWithArg)
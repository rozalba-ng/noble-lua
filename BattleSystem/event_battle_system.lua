EBS_TURN_AURA = 88037
EBS_HP_AURA = 88038
EBS_WOUND_AURA = 88010
EBS_WEAK_AURA = 88012
DEATH_SOLDER_AURA = 88053
EBS_ARMOR_AURA = 88050
EBS_ENERGY_AURA = 88060
EBS_PHYSICS_DEF_AURA = 102050 
EBS_MAGIC_DEF_AURA = 102051
-- Новые ауры
EBS_FOCUS_AURA = 95009
-- Конец новых аур

EBS_Auras = {	{	id = 88061,
					name = "Усталость",},
				{	id = 88062,
					name = "Контроль",},
				{	id = 88063,
					name = "Усилиение",},
				{	id = 88064,
					name = "Периодический урон",}
			}

-- Новые статы
EBS_AuraStats = {	{	id = 95001,
						name = "Физическая сила",},
					{	id = 95002,
						name = "Мастерство",},
					{	id = 95003,
						name = "Учёность",},
					{	id = 95004,
						name = "Мудрость",},
					{	id = 95005,
						name = "Атака",},
					{	id = 95006,
						name = "Защита",},
					{	id = 95007,
						name = "Дальний бой",},
					{	id = 95008,
						name = "Магия",},
					{	id = 95010,
						name = "Живучесть",},
					{	id = 95011,
						name = "Мана",},
					{	id = 95018,
						name = "Мощь",},
					{	id = 95023,
						name = "Незаметность",},
					{	id = 95048,
						name = "Удача",}				
				}

-- Новые дебаффы
EBS_AuraDebuffs = {	{	id = 95019,
						name = "Холод",},
					{	id = 95020,
						name = "Жар",},
					{	id = 95024,
						name = "Сон",},
					{	id = 95025,
						name = "Оглушение",},
					{	id = 95026,
						name = "Обездвиживание",},
					{	id = 95027,
						name = "Замешательство",},
					{	id = 95031,
						name = "Безумие",},
					{	id = 95033,
						name = "Разрушение брони",},
					{	id = 95034,
						name = "Уязвимость к магии",},
					{	id = 95035,
						name = "Уязвимость к природе",},
					{	id = 95036,
						name = "Уязвимость ко Тьме",},
					{	id = 95037,
						name = "Уязвимость к Скверне",},
					{	id = 95038,
						name = "Уязвимость к огню",},
					{	id = 95039,
						name = "Уязвимость к ветру",},
					{	id = 95040,
						name = "Уязвимость к земле",},
					{	id = 95041,
						name = "Уязвимость к воде",},
					{	id = 95042,
						name = "Уязвимость ко льду",},
					{	id = 95043,
						name = "Уязвимость к крови",},
					{	id = 95044,
						name = "Уязвимость к молнии",},
					{	id = 95047,
						name = "Буян",},
					{	id = 95054,
						name = "Антимагия",}
				}
				
-- Новые баффы
EBS_AuraBuffs = {	{	id = 95012,
						name = "Усиление (скорость)",},
					{	id = 95013,
						name = "Усиление (атака)",},
					{	id = 95014,
						name = "Усиление (защита)",},
					{	id = 95015,
						name = "Усиление (дальний бой)",},
					{	id = 95016,
						name = "Усиление (точность)",},
					{	id = 95028,
						name = "Абсолютная неуязвимость",},
					{	id = 95029,
						name = "Неуязвимость (магия)",},
					{	id = 95030,
						name = "Неуязвимость (физич.)",},
					{	id = 95032,
						name = "Исступление",}
				}

-- Новые травмы
EBS_AuraHarm = {	{	id = 95021,
						name = "Лёгкая рана",},
					{	id = 95022,
						name = "Тяжёлая рана",},
					{	id = 95049,
						name = "Перелом руки",},
					{	id = 95050,
						name = "Перелом ноги",},
					{	id = 95051,
						name = "Перелом челюсти",},
					{	id = 95052,
						name = "Кровопотеря",},
					{	id = 95053,
						name = "Немота",}
				}

-- Новые действия
EBS_AuraActions = {	{	id = 95017,
						name = "Действие",},
					{	id = 95045,
						name = "Нейтрализация",},
					{	id = 95046,
						name = "Провокация",},
					{	id = 95055,
						name = "Подкрепление",},
					{	id = 95056,
						name = "Метка охотника",}
				}
-- Конец новых ауров

EBS = {}
EBS.OpenBattles = {}
local redColor = "|cFFf7382a"
local greenColor = "|cFF5fdb2e"
local red = "|cffff0000"
local blue = "|cff00ccff"
local gray = "|cffbbbbbb"
local white = "|cffffffff"
local green = "|cff71C671"
local choco = "|cffCD661D"
local cyan = "|cff00ffff"
local sexpink = "|cffC67171"
local sexblue = "|cff00E5EE"
local sexhotpink = "|cffFF6EB4"
local purple = "|cffDA70D6"
local greenyellow = "|cffADFF2F"

local function OpenBattle(playerMaster)
	local masterName = playerMaster:GetName()
	if EBS.OpenBattles[masterName] then
		playerMaster:SendBroadcastMessage("Боевая сессия уже открыта.")
		return false
	end
	EBS.OpenBattles[masterName] = {}
	if EBS.OpenBattles[masterName] then
		playerMaster:SendBroadcastMessage("Боевая сессия открыта успешно.")
	end
end
local function CloseBattle(playerMaster)
	local masterName = playerMaster:GetName()
	if EBS.OpenBattles[masterName] then
		EBS.OpenBattles[masterName] = nil
		playerMaster:SendBroadcastMessage("Боевая сессия успешно закрыта.")
	else
		playerMaster:SendBroadcastMessage("За вами не закрепленна боевая сессия или сессия была не начата.")
	end
end


local function AddPlayerToBattle(playerMaster,player, hpCount)
	local masterName = playerMaster:GetName()
	local playerName = player:GetName()
	if EBS.OpenBattles[masterName] then
		EBS.OpenBattles[masterName].players = {}
		EBS.OpenBattles[masterName].players[playerName] = {}
		EBS.OpenBattles[masterName].players[playerName].hp = hpCount
		EBS.OpenBattles[masterName].players[playerName].turn = #EBS.OpenBattles[masterName].players
		local turnAura = player:AddAura(EBS_TURN_AURA,player)
		turnAura:SetStackAmount(EBS.OpenBattles[masterName].players[playerName].turn)
		local hpAura = player:AddAura(EBS_HP_AURA,player)
		hpAura:SetStackAmount(hpCount)
		player:SendBroadcastMessage("Вы были добавлены бой под ведением игрока "..masterName..".\n  Количество ваших очков здоровья - "..EBS.OpenBattles[masterName].players[playerName].hp.."\n  Ваша очередность хода - "..EBS.OpenBattles[masterName].players[playerName].turn)
	else
	
	end
end

local function OnPlayerCommandWithArg(event, player, code)
    if(string.find(code, " "))then
        local arguments = {}
        local arguments = string.split(code, " ")
        if (arguments[1] == "setarmor" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if tonumber(value) == 0 then
					if not GM_target:ToPlayer() then
						setNpcStats(GM_target, ROLE_STAT_ARMOR, 0);
					end
					GM_target:RemoveAura(EBS_ARMOR_AURA)
					return false
				end
				if GM_target:HasAura(EBS_ARMOR_AURA) then
					local armorAura = GM_target:GetAura(EBS_ARMOR_AURA)
					armorAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..greenColor..value.." очков брони")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..greenColor..value.." очков брони")
					end
					
				else
					local armorAura = GM_target:AddAura(EBS_ARMOR_AURA,GM_target)
					armorAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..greenColor..value.." очков брони")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..greenColor..value.." очков брони")
					end
					
				end
				if not GM_target:ToPlayer() then
					setNpcStats(GM_target, ROLE_STAT_ARMOR, value);
				end
			end
		elseif (arguments[1] == "addarmor" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if GM_target:HasAura(EBS_ARMOR_AURA) then
					local armorAura = GM_target:GetAura(EBS_ARMOR_AURA)
					local stackAmount = armorAura:GetStackAmount()
					armorAura:SetStackAmount(stackAmount + value)
					if not GM_target:ToPlayer() then
						setNpcStats(GM_target, ROLE_STAT_ARMOR, stackAmount + value);
					end
					player:SendBroadcastMessage(GM_target:GetName().." добавлено "..greenColor..value.."|r очков брони!")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам добавлено "..greenColor..value.." очков брони!")	
					end
					
				else
					player:SendBroadcastMessage("Существо не имеет ауры")
				end
			end
		elseif (arguments[1] == "removearmor" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if GM_target:HasAura(EBS_ARMOR_AURA) then
					local armorAura = GM_target:GetAura(EBS_ARMOR_AURA)
					local stackAmount = armorAura:GetStackAmount()
					if stackAmount - value  < 1 then
						if not GM_target:ToPlayer() then
							setNpcStats(GM_target, ROLE_STAT_ARMOR, 0);
						end
						GM_target:RemoveAura(EBS_ARMOR_AURA)
						return false
					end
					armorAura:SetStackAmount(stackAmount - value)
					if not GM_target:ToPlayer() then
						setNpcStats(GM_target, ROLE_STAT_ARMOR, stackAmount - value);
					end
					player:SendBroadcastMessage(GM_target:GetName().." потерял "..greenColor..value.."|r очков брони!")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вы потеряли "..greenColor..value.." очков брони!")	
					end
					
				else
					player:SendBroadcastMessage("Существо не имеет ауры")
				end
				
			end
		elseif (arguments[1] == "setpharmor" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if tonumber(value) == 0 then
					GM_target:RemoveAura(EBS_PHYSICS_DEF_AURA)
					return false
				end
				if GM_target:HasAura(EBS_PHYSICS_DEF_AURA) then
					local armorAura = GM_target:GetAura(EBS_PHYSICS_DEF_AURA)
					armorAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..greenColor..value.." очков физической защиты")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..greenColor..value.." физической защиты")
					end
					
				else
					local armorAura = GM_target:AddAura(EBS_PHYSICS_DEF_AURA,GM_target)
					armorAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..greenColor..value.." физической защиты")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..greenColor..value.." физической защиты")
					end
					
				end
			end
		elseif (arguments[1] == "addpharmor" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if GM_target:HasAura(EBS_PHYSICS_DEF_AURA) then
					local armorAura = GM_target:GetAura(EBS_PHYSICS_DEF_AURA)
					local stackAmount = armorAura:GetStackAmount()
					armorAura:SetStackAmount(stackAmount + value)
					player:SendBroadcastMessage(GM_target:GetName().." добавлено "..greenColor..value.."|r физической брони!")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам добавлено "..greenColor..value.." физической брони!")	
					end
					
				else
					player:SendBroadcastMessage("Существо не имеет ауры")
				end
			end
		elseif (arguments[1] == "removepharmor" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if GM_target:HasAura(EBS_PHYSICS_DEF_AURA) then
					local armorAura = GM_target:GetAura(EBS_PHYSICS_DEF_AURA)
					local stackAmount = armorAura:GetStackAmount()
					if stackAmount - value  < 1 then
						GM_target:RemoveAura(EBS_PHYSICS_DEF_AURA)
						return false
					end
					armorAura:SetStackAmount(stackAmount - value)
					player:SendBroadcastMessage(GM_target:GetName().." потерял "..greenColor..value.."|r физической брони!")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вы потеряли "..greenColor..value.." физической брони!")	
					end
					
				else
					player:SendBroadcastMessage("Существо не имеет ауры")
				end
				
			end
		elseif (arguments[1] == "setmagarmor" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if tonumber(value) == 0 then
					GM_target:RemoveAura(EBS_MAGIC_DEF_AURA)
					return false
				end
				if GM_target:HasAura(EBS_MAGIC_DEF_AURA) then
					local armorAura = GM_target:GetAura(EBS_MAGIC_DEF_AURA)
					armorAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..greenColor..value.." очков магической защиты")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..greenColor..value.." магической защиты")
					end
					
				else
					local armorAura = GM_target:AddAura(EBS_MAGIC_DEF_AURA,GM_target)
					armorAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..greenColor..value.." магической защиты")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..greenColor..value.." магической защиты")
					end
					
				end
			end
		elseif (arguments[1] == "addmagarmor" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if GM_target:HasAura(EBS_MAGIC_DEF_AURA) then
					local armorAura = GM_target:GetAura(EBS_MAGIC_DEF_AURA)
					local stackAmount = armorAura:GetStackAmount()
					armorAura:SetStackAmount(stackAmount + value)
					player:SendBroadcastMessage(GM_target:GetName().." добавлено "..greenColor..value.."|r магической брони!")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам добавлено "..greenColor..value.." магической брони!")	
					end
					
				else
					player:SendBroadcastMessage("Существо не имеет ауры")
				end
			end
		elseif (arguments[1] == "removemagarmor" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if GM_target:HasAura(EBS_MAGIC_DEF_AURA) then
					local armorAura = GM_target:GetAura(EBS_MAGIC_DEF_AURA)
					local stackAmount = armorAura:GetStackAmount()
					if stackAmount - value  < 1 then
						GM_target:RemoveAura(EBS_MAGIC_DEF_AURA)
						return false
					end
					armorAura:SetStackAmount(stackAmount - value)
					player:SendBroadcastMessage(GM_target:GetName().." потерял "..greenColor..value.."|r магической брони!")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вы потеряли "..greenColor..value.." магической брони!")	
					end
					
				else
					player:SendBroadcastMessage("Существо не имеет ауры")
				end
				
			end
		 elseif (arguments[1] == "sethp" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if not GM_target:ToPlayer() then
					setNpcStats(GM_target, ROLE_STAT_HEALTH, tonumber(value));
				end
				if tonumber(value) == 0 then
					GM_target:RemoveAura(EBS_HP_AURA)
					return false
				end
				if GM_target:HasAura(EBS_HP_AURA) then
					local hpAura = GM_target:GetAura(EBS_HP_AURA)
					hpAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..greenColor..value.." очков здоровья")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..greenColor..value.." очков здоровья")
					end
					
				else
					local hpAura = GM_target:AddAura(EBS_HP_AURA,GM_target)
					hpAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..greenColor..value.." очков здоровья")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..greenColor..value.." очков здоровья")
					end
					
				end
			end
		elseif (arguments[1] == "setwound" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			
			if player:GetGMRank() > 0 then
				if tonumber(value) == 0 then
					GM_target:RemoveAura(EBS_WOUND_AURA)
					return false
				end
				if GM_target:HasAura(EBS_WOUND_AURA) then
					local hpAura = GM_target:GetAura(EBS_WOUND_AURA)
					hpAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..greenColor..value.." очков ран")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..greenColor..value.." очков ран")
					end
					
				else
					local hpAura = GM_target:AddAura(EBS_WOUND_AURA,GM_target)
					hpAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..greenColor..value.." очков ран")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..greenColor..value.." очков ран")
					end
					
				end
			end
		elseif (arguments[1] == "damhp" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if GM_target:HasAura(EBS_HP_AURA) then
					local hpAura = GM_target:GetAura(EBS_HP_AURA)
					local stackAmount = hpAura:GetStackAmount()
					if (stackAmount-value) < 1 then
						if not GM_target:ToPlayer() then
							setNpcStats(GM_target, ROLE_STAT_HEALTH, 0);
						end
						GM_target:RemoveAura(EBS_HP_AURA)
						GM_target:AddAura(DEATH_SOLDER_AURA,GM_target)
						player:SendBroadcastMessage(GM_target:GetName().." получил "..redColor.."урон|r в "..value.." очков!")
						if GM_target:ToPlayer() then
							GM_target:SendBroadcastMessage("Вы получили "..redColor.."урон|r в "..value.." очка!")
							GM_target:SendBroadcastMessage(redColor.."Количество ваших очков здоровья опустилость до нуля... Вы не способны продолжать бой.")
						end
						return false
					end
					hpAura:SetStackAmount(stackAmount - value)
					if not GM_target:ToPlayer() then
						setNpcStats(GM_target, ROLE_STAT_HEALTH, stackAmount - value);
					end
					player:SendBroadcastMessage(GM_target:GetName().." получил "..redColor.."урон|r в "..value.." очков!")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вы получили "..redColor.."урон|r в "..value.." очков!")
					end
					
				else
					player:SendBroadcastMessage("Существо не имеет ауры")
				end
			end
		elseif (arguments[1] == "addhp" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if GM_target:HasAura(EBS_HP_AURA) then
					local hpAura = GM_target:GetAura(EBS_HP_AURA)
					local stackAmount = hpAura:GetStackAmount()
					hpAura:SetStackAmount(stackAmount + value)
					if not GM_target:ToPlayer() then
						setNpcStats(GM_target, ROLE_STAT_HEALTH, stackAmount + value);
					end
					player:SendBroadcastMessage(GM_target:GetName().." добавлено "..greenColor..value.."|r очков здоровья!")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам добавлено "..greenColor..value.." очков здоровья!")	
					end
					
				else
					player:SendBroadcastMessage("Существо не имеет ауры")
				end
			end
-- Добавить фокус
		elseif (arguments[1] == "setfocus" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if tonumber(value) == 0 then
					GM_target:RemoveAura(EBS_FOCUS_AURA)
					return false
				end
				if GM_target:HasAura(EBS_FOCUS_AURA) then
					local focusAura = GM_target:GetAura(EBS_FOCUS_AURA)
					focusAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..greenColor..value.." очков фокуса")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..greenColor..value.." очков фокуса")
					end
					
				else
					local focusAura = GM_target:AddAura(EBS_FOCUS_AURA,GM_target)
					focusAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..greenColor..value.." очков фокуса")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..greenColor..value.." очков фокуса")
					end
					
				end
			end
		elseif (arguments[1] == "addfocus" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if GM_target:HasAura(EBS_FOCUS_AURA) then
					local focusAura = GM_target:GetAura(EBS_FOCUS_AURA)
					local stackAmount = focusAura:GetStackAmount()
					focusAura:SetStackAmount(stackAmount + value)
					player:SendBroadcastMessage(GM_target:GetName().." добавлено "..greenColor..value.."|r очков фокуса!")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам добавлено "..greenColor..value.." очков фокуса!")	
					end
					
				else
					player:SendBroadcastMessage("Существо не имеет ауры")
				end
			end
		elseif (arguments[1] == "removefocus" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if GM_target:HasAura(EBS_FOCUS_AURA) then
					local focusAura = GM_target:GetAura(EBS_FOCUS_AURA)
					local stackAmount = focusAura:GetStackAmount()
					if stackAmount - value  < 1 then
						GM_target:RemoveAura(EBS_FOCUS_AURA)
						return false
					end
					focusAura:SetStackAmount(stackAmount - value)
					player:SendBroadcastMessage(GM_target:GetName().." потерял "..greenColor..value.."|r очков фокуса!")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вы потеряли "..greenColor..value.." очков фокуса!")	
					end
					
				else
					player:SendBroadcastMessage("Существо не имеет ауры")
				end
			end
-- Конец добавления фокуса
		elseif (arguments[1] == "seten" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if tonumber(value) == 0 then
					GM_target:RemoveAura(EBS_HP_AURA)
					return false
				end
				if GM_target:HasAura(EBS_ENERGY_AURA) then
					local energyAura = GM_target:GetAura(EBS_ENERGY_AURA)
					energyAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..blue..value.." очков энергии")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..blue..value.." очков энергии")
					end
					
				else
					local energyAura = GM_target:AddAura(EBS_ENERGY_AURA,GM_target)
					energyAura:SetStackAmount(value)
					player:SendBroadcastMessage(GM_target:GetName().." установлено "..blue..value.." очков энергии")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам установлено "..blue..value.." очков энергии")
					end
					
				end
				
			end
		elseif (arguments[1] == "adden" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if GM_target:HasAura(EBS_ENERGY_AURA) then
					local energyAura = GM_target:GetAura(EBS_ENERGY_AURA)
					local stackAmount = energyAura:GetStackAmount()
					energyAura:SetStackAmount(stackAmount + value)
					player:SendBroadcastMessage(GM_target:GetName().." добавлено "..blue..value.."|r очков энергии!")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вам добавлено "..blue..value.." очков энергии!")	
					end
					
				else
					player:SendBroadcastMessage("Существо не имеет ауры")
				end
			end
		elseif (arguments[1] == "damen" and #arguments == 2 ) then
			local value = arguments[2]
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader) then
			
				if GM_target:HasAura(EBS_ENERGY_AURA) then
					local energyAura = GM_target:GetAura(EBS_ENERGY_AURA)
					local stackAmount = energyAura:GetStackAmount()
					if (stackAmount-value) < 1 then
						GM_target:RemoveAura(EBS_ENERGY_AURA)
						player:SendBroadcastMessage(GM_target:GetName().." теряет "..blue..value.."|r энергии!")
						if GM_target:ToPlayer() then
							GM_target:SendBroadcastMessage("Вы тратите "..blue..value.."|r энергии!")
							GM_target:SendBroadcastMessage("У "..player:GetName().." кончились очки "..blue.."энергии|r")
						end
						
						player:SendBroadcastMessage("У вас кончились очки "..blue.."энергии|r")
						
						return false
					end
					energyAura:SetStackAmount(stackAmount - value)
					player:SendBroadcastMessage(GM_target:GetName().." теряет "..blue..value.."|r энергии!")
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("Вы тратите "..blue..value.."|r энергии!")
					end
					
					
				else
					player:SendBroadcastMessage("Существо не имеет ауры")
					
					
				end
			end
		elseif (arguments[1] == "setstatus" and #arguments == 3 ) then
			local value = arguments[3]
			local statusId = tonumber(arguments[2])
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if tonumber(value) == 0 then
					GM_target:RemoveAura(EBS_Auras[statusId].id)
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("С вас снят эффект "..purple.."\""..EBS_Auras[statusId].name.."\"")
					end
					
					player:SendBroadcastMessage("С "..player:GetName().." снят эффект "..purple.."\""..EBS_Auras[statusId].name.."\"")
					return false
				end
				if GM_target:HasAura(EBS_Auras[statusId].id) then
					local aura = GM_target:GetAura(EBS_Auras[statusId].id)
					aura:SetStackAmount(value)
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("На вас установлен эффект "..purple.."\""..EBS_Auras[statusId].name.."\"|r мощностью "..redColor..value.."|r")
					end
					
					player:SendBroadcastMessage("На "..player:GetName().." установлен эффект "..purple.."\""..EBS_Auras[statusId].name.."\"|r мощностью "..redColor..value.."|r")
				else
					local energyAura = GM_target:AddAura(EBS_Auras[statusId].id,GM_target)
					energyAura:SetStackAmount(value)
					
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("На вас наложен эффект "..purple.."\""..EBS_Auras[statusId].name.."\"|r мощностью "..redColor..value.."|r")
					end
					
					player:SendBroadcastMessage("На "..player:GetName().." наложен эффект "..purple.."\""..EBS_Auras[statusId].name.."\"|r мощностью "..redColor..value.."|r")
				end
			end
		elseif (arguments[1] == "removestatus" and #arguments == 2 ) then
			local statusId = tonumber(arguments[2])
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				GM_target:RemoveAura(EBS_Auras[statusId].id)
				if GM_target:ToPlayer() then
					GM_target:SendBroadcastMessage("С вас снят эффект "..purple.."\""..EBS_Auras[statusId].name.."\"")
				end
					
				
				player:SendBroadcastMessage("С "..player:GetName().." снят эффект "..purple.."\""..EBS_Auras[statusId].name.."\"")
			end
-- Добавить новые статы
		elseif (arguments[1] == "setaurastats" and #arguments == 3 ) then
			local value = arguments[3]
			local aurastatsId = tonumber(arguments[2])
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if tonumber(value) == 0 then
					GM_target:RemoveAura(EBS_AuraStats[aurastatsId].id)
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("С вас снят эффект "..purple.."\""..EBS_AuraStats[aurastatsId].name.."\"")
					end
					
					player:SendBroadcastMessage("С "..player:GetName().." снят эффект "..purple.."\""..EBS_AuraStats[aurastatsId].name.."\"")
					return false
				end
				if GM_target:HasAura(EBS_AuraStats[aurastatsId].id) then
					local aura = GM_target:GetAura(EBS_AuraStats[aurastatsId].id)
					aura:SetStackAmount(value)
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("На вас установлен эффект "..purple.."\""..EBS_AuraStats[aurastatsId].name.."\"|r мощностью "..redColor..value.."|r")
					end
					
					player:SendBroadcastMessage("На "..player:GetName().." установлен эффект "..purple.."\""..EBS_AuraStats[aurastatsId].name.."\"|r мощностью "..redColor..value.."|r")
				else
					local energyAura = GM_target:AddAura(EBS_AuraStats[aurastatsId].id,GM_target)
					energyAura:SetStackAmount(value)
					
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("На вас наложен эффект "..purple.."\""..EBS_AuraStats[aurastatsId].name.."\"|r мощностью "..redColor..value.."|r")
					end
					
					player:SendBroadcastMessage("На "..player:GetName().." наложен эффект "..purple.."\""..EBS_AuraStats[aurastatsId].name.."\"|r мощностью "..redColor..value.."|r")
				end
			end
		elseif (arguments[1] == "removeaurastats" and #arguments == 2 ) then
			local aurastatsId = tonumber(arguments[2])
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				GM_target:RemoveAura(EBS_AuraStats[aurastatsId].id)
				if GM_target:ToPlayer() then
					GM_target:SendBroadcastMessage("С вас снят эффект "..purple.."\""..EBS_AuraStats[aurastatsId].name.."\"")
				end
				player:SendBroadcastMessage("С "..player:GetName().." снят эффект "..purple.."\""..EBS_AuraStats[aurastatsId].name.."\"")
			end
-- Конец добавления новых статов

-- Добавить новые дебаффы
		elseif (arguments[1] == "setdebuff" and #arguments == 3 ) then
			local value = arguments[3]
			local auradebuffId = tonumber(arguments[2])
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if tonumber(value) == 0 then
					GM_target:RemoveAura(EBS_AuraDebuffs[auradebuffId].id)
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("С вас снят эффект "..purple.."\""..EBS_AuraDebuffs[auradebuffId].name.."\"")
					end
					
					player:SendBroadcastMessage("С "..player:GetName().." снят эффект "..purple.."\""..EBS_AuraDebuffs[auradebuffId].name.."\"")
					return false
				end
				if GM_target:HasAura(EBS_AuraDebuffs[auradebuffId].id) then
					local aura = GM_target:GetAura(EBS_AuraDebuffs[auradebuffId].id)
					aura:SetStackAmount(value)
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("На вас установлен эффект "..purple.."\""..EBS_AuraDebuffs[auradebuffId].name.."\"|r мощностью "..redColor..value.."|r")
					end
					
					player:SendBroadcastMessage("На "..player:GetName().." установлен эффект "..purple.."\""..EBS_AuraDebuffs[auradebuffId].name.."\"|r мощностью "..redColor..value.."|r")
				else
					local energyAura = GM_target:AddAura(EBS_AuraDebuffs[auradebuffId].id,GM_target)
					energyAura:SetStackAmount(value)
					
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("На вас наложен эффект "..purple.."\""..EBS_AuraDebuffs[auradebuffId].name.."\"|r мощностью "..redColor..value.."|r")
					end
					
					player:SendBroadcastMessage("На "..player:GetName().." наложен эффект "..purple.."\""..EBS_AuraDebuffs[auradebuffId].name.."\"|r мощностью "..redColor..value.."|r")
				end
			end
		elseif (arguments[1] == "removedebuff" and #arguments == 2 ) then
			local auradebuffId = tonumber(arguments[2])
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				GM_target:RemoveAura(EBS_AuraDebuffs[auradebuffId].id)
				if GM_target:ToPlayer() then
					GM_target:SendBroadcastMessage("С вас снят эффект "..purple.."\""..EBS_AuraDebuffs[auradebuffId].name.."\"")
				end
				player:SendBroadcastMessage("С "..player:GetName().." снят эффект "..purple.."\""..EBS_AuraDebuffs[auradebuffId].name.."\"")
			end
-- Конец добавления новых дебаффов

-- Добавить новые баффы
		elseif (arguments[1] == "setbuff" and #arguments == 3 ) then
			local value = arguments[3]
			local aurabuffId = tonumber(arguments[2])
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if tonumber(value) == 0 then
					GM_target:RemoveAura(EBS_AuraBuffs[aurabuffId].id)
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("С вас снят эффект "..purple.."\""..EBS_AuraBuffs[aurabuffId].name.."\"")
					end
					
					player:SendBroadcastMessage("С "..player:GetName().." снят эффект "..purple.."\""..EBS_AuraBuffs[aurabuffId].name.."\"")
					return false
				end
				if GM_target:HasAura(EBS_AuraBuffs[aurabuffId].id) then
					local aura = GM_target:GetAura(EBS_AuraBuffs[aurabuffId].id)
					aura:SetStackAmount(value)
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("На вас установлен эффект "..purple.."\""..EBS_AuraBuffs[aurabuffId].name.."\"|r мощностью "..redColor..value.."|r")
					end
					
					player:SendBroadcastMessage("На "..player:GetName().." установлен эффект "..purple.."\""..EBS_AuraBuffs[aurabuffId].name.."\"|r мощностью "..redColor..value.."|r")
				else
					local energyAura = GM_target:AddAura(EBS_AuraBuffs[aurabuffId].id,GM_target)
					energyAura:SetStackAmount(value)
					
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("На вас наложен эффект "..purple.."\""..EBS_AuraBuffs[aurabuffId].name.."\"|r мощностью "..redColor..value.."|r")
					end
					
					player:SendBroadcastMessage("На "..player:GetName().." наложен эффект "..purple.."\""..EBS_AuraBuffs[aurabuffId].name.."\"|r мощностью "..redColor..value.."|r")
				end
			end
		elseif (arguments[1] == "removebuff" and #arguments == 2 ) then
			local aurabuffId = tonumber(arguments[2])
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				GM_target:RemoveAura(EBS_AuraBuffs[aurabuffId].id)
				if GM_target:ToPlayer() then
					GM_target:SendBroadcastMessage("С вас снят эффект "..purple.."\""..EBS_AuraBuffs[aurabuffId].name.."\"")
				end
				player:SendBroadcastMessage("С "..player:GetName().." снят эффект "..purple.."\""..EBS_AuraBuffs[aurabuffId].name.."\"")
			end
-- Конец добавления новых баффов

-- Добавить новые раны
		elseif (arguments[1] == "setharm" and #arguments == 3 ) then
			local value = arguments[3]
			local auraharmId = tonumber(arguments[2])
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if tonumber(value) == 0 then
					GM_target:RemoveAura(EBS_AuraHarm[auraharmId].id)
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("С вас снят эффект "..purple.."\""..EBS_AuraHarm[auraharmId].name.."\"")
					end
					
					player:SendBroadcastMessage("С "..player:GetName().." снят эффект "..purple.."\""..EBS_AuraHarm[auraharmId].name.."\"")
					return false
				end
				if GM_target:HasAura(EBS_AuraHarm[auraharmId].id) then
					local aura = GM_target:GetAura(EBS_AuraHarm[auraharmId].id)
					aura:SetStackAmount(value)
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("На вас установлен эффект "..purple.."\""..EBS_AuraHarm[auraharmId].name.."\"|r мощностью "..redColor..value.."|r")
					end
					
					player:SendBroadcastMessage("На "..player:GetName().." установлен эффект "..purple.."\""..EBS_AuraHarm[auraharmId].name.."\"|r мощностью "..redColor..value.."|r")
				else
					local energyAura = GM_target:AddAura(EBS_AuraHarm[auraharmId].id,GM_target)
					energyAura:SetStackAmount(value)
					
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("На вас наложен эффект "..purple.."\""..EBS_AuraHarm[auraharmId].name.."\"|r мощностью "..redColor..value.."|r")
					end
					
					player:SendBroadcastMessage("На "..player:GetName().." наложен эффект "..purple.."\""..EBS_AuraHarm[auraharmId].name.."\"|r мощностью "..redColor..value.."|r")
				end
			end
		elseif (arguments[1] == "removeharm" and #arguments == 2 ) then
			local auraharmId = tonumber(arguments[2])
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				GM_target:RemoveAura(EBS_AuraHarm[auraharmId].id)
				if GM_target:ToPlayer() then
					GM_target:SendBroadcastMessage("С вас снят эффект "..purple.."\""..EBS_AuraHarm[auraharmId].name.."\"")
				end
				player:SendBroadcastMessage("С "..player:GetName().." снят эффект "..purple.."\""..EBS_AuraHarm[auraharmId].name.."\"")
			end
-- Конец добавления новых ран

-- Добавить новые действия
		elseif (arguments[1] == "setactions" and #arguments == 3 ) then
			local value = arguments[3]
			local auraactionsId = tonumber(arguments[2])
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				if tonumber(value) == 0 then
					GM_target:RemoveAura(EBS_AuraActions[auraactionsId].id)
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("С вас снят эффект "..purple.."\""..EBS_AuraActions[auraactionsId].name.."\"")
					end
					
					player:SendBroadcastMessage("С "..player:GetName().." снят эффект "..purple.."\""..EBS_AuraActions[auraactionsId].name.."\"")
					return false
				end
				if GM_target:HasAura(EBS_AuraActions[auraactionsId].id) then
					local aura = GM_target:GetAura(EBS_AuraActions[auraactionsId].id)
					aura:SetStackAmount(value)
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("На вас установлен эффект "..purple.."\""..EBS_AuraActions[auraactionsId].name.."\"|r мощностью "..redColor..value.."|r")
					end
					
					player:SendBroadcastMessage("На "..player:GetName().." установлен эффект "..purple.."\""..EBS_AuraActions[auraactionsId].name.."\"|r мощностью "..redColor..value.."|r")
				else
					local energyAura = GM_target:AddAura(EBS_AuraActions[auraactionsId].id,GM_target)
					energyAura:SetStackAmount(value)
					
					if GM_target:ToPlayer() then
						GM_target:SendBroadcastMessage("На вас наложен эффект "..purple.."\""..EBS_AuraActions[auraactionsId].name.."\"|r мощностью "..redColor..value.."|r")
					end
					
					player:SendBroadcastMessage("На "..player:GetName().." наложен эффект "..purple.."\""..EBS_AuraActions[auraactionsId].name.."\"|r мощностью "..redColor..value.."|r")
				end
			end
		elseif (arguments[1] == "removeactions" and #arguments == 2 ) then
			local auraactionsId = tonumber(arguments[2])
			local GM_target = player:GetSelectedUnit()
			local targetCreature = GM_target:ToCreature()
			local targetPlayer = GM_target:ToPlayer()
			local IsInSameRaidWith
			if targetPlayer then
				IsInSameRaidWith = player:IsInSameRaidWith(targetPlayer)
			end
			local playerGroup = player:GetGroup()
			local isLeader
			if playerGroup then
				isLeader = playerGroup:IsLeader(player:GetGUID())
			end
			
			if player:GetGMRank() > 0 or (player:GetDmLevel() > 0 and targetCreature and targetCreature:GetOwner() == player) or (player:GetDmLevel() > 0 and IsInSameRaidWith and isLeader)then
				GM_target:RemoveAura(EBS_AuraActions[auraactionsId].id)
				if GM_target:ToPlayer() then
					GM_target:SendBroadcastMessage("С вас снят эффект "..purple.."\""..EBS_AuraActions[auraactionsId].name.."\"")
				end
				player:SendBroadcastMessage("С "..player:GetName().." снят эффект "..purple.."\""..EBS_AuraActions[auraactionsId].name.."\"")
			end
-- Конец добавления новых действий

		end
		
		
	--[[elseif code == "ebsopen" then
		if player:GetGMRank() > 0 then
			OpenBattle(player)
		end
	elseif code == "ebsclose" then
		if player:GetGMRank() > 0 then
			CloseBattle(player)
		end
	elseif code == "ebsaddplayer" then
		if player:GetGMRank() > 0 then
			local GM_target = player:GetSelectedUnit();
			AddPlayerToBattle(player,GM_target, 3)
		end ]]--
	elseif code == "wakeup" then
		if player:GetGMRank() > 0 then
			local GM_target = player:GetSelectedUnit()
			GM_target:RemoveAura(DEATH_SOLDER_AURA)
			GM_target:RemoveAura(EBS_HP_AURA)
			GM_target:RemoveAura(EBS_ARMOR_AURA)
			GM_target:RemoveAura(EBS_ENERGY_AURA)
			GM_target:RemoveAura(EBS_FOCUS_AURA)

			if not GM_target:ToPlayer() then
				setNpcStats(GM_target, ROLE_STAT_HEALTH, 0)
				setNpcStats(GM_target, ROLE_STAT_ARMOR, 0)
			end

			for i = 1, #EBS_Auras do
				GM_target:RemoveAura(EBS_Auras[i].id)
			end
		else
			player:RemoveAura(DEATH_SOLDER_AURA)
			player:RemoveAura(EBS_HP_AURA)
			player:RemoveAura(EBS_ARMOR_AURA)
			player:RemoveAura(EBS_ENERGY_AURA)
			for i = 1, #EBS_Auras do
				player:RemoveAura(EBS_Auras[i].id)
			end
		end
	end
end

RegisterPlayerEvent(42, OnPlayerCommandWithArg)
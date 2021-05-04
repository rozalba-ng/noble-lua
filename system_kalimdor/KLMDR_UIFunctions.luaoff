
local lastTimeChangeFrac = {}

KAL_HonorIdItem = 1111000
KAL_HonorCost = 25
KALIMDOR_MID = 2105
KAL_UnitCost = 140

KAL_unitList = {}
KAL_unitListOnFrac = { [1] = 9921543, [2] = 9921541, [3] = 9921542 }

local AST_ID = 146
function LoadFractions()
	LoadFractions = {}
	local q = WorldDBQuery("SELECT id,name, res_count FROM kalimdor_fractions ")
	if q then
		for i = 1, q:GetRowCount() do
			table.insert(KAL_fractionList, { id = q:GetInt32(0), name = q:GetString(1),res = q:GetInt32(2)})
			
			q:NextRow()
		end
	end
end

function LoadPlayerInfo()
	local q = WorldDBQuery("SELECT * FROM kalimdor_players ")
	if q then
		for i = 1, q:GetRowCount() do
			KAL_playerInfo[q:GetString(0)] = { fid = q:GetInt32(1), perm = q:GetInt32(2) }
			q:NextRow()
		end

	end
end

function GetPlayerFraction(playerName)
	if KAL_playerInfo[playerName] then
		local fid = KAL_playerInfo[playerName].fid
		return fid
	end
end
function GetPlayerPerm(playerName)
	if KAL_playerInfo[playerName] then
		local perm = KAL_playerInfo[playerName].perm
		return perm
	end
end
LoadPlayerInfo()

LoadFractions()

function SayToFraction(fid,text)
	for i, player in pairs(GetPlayersInWorld(2)) do
		--if player:GetMapId() == KALIMDOR_MID then
			local plFid = GetPlayerFraction(player:GetName())
			if plFid then
				if plFid == fid then
					player:SendBroadcastMessage(text)
				end
			end
		--end
	end
end


local function OnPlayerCommandWithArg(event, player, code)
    if code == "buy unit" then
		if GetPlayerFraction(player:GetName()) then
			local perm = GetPlayerPerm(player:GetName())
			if perm == 1 then
				SendGossip("[Калимдор] Покупка юнита",player)
			else
				player:SendBroadcastMessage("Вы не обладаете правом распоряжения ресурсами")
			end
		else
			player:SendBroadcastMessage("Вы не находитесь во фракции")
		end
		
	elseif code == "choose fraction" then
		if not lastTimeChangeFrac[player:GetName()] or (os.time()- lastTimeChangeFrac[player:GetName()]) > 3600 then
			SendGossip("[Калимдор] Выбор фракции",player)
		else
			player:SendBroadcastMessage("Вы уже меняли фракцию в течении часа.")
		end
	elseif code == "kchange res" then
		if (player:GetAccountId() == AST_ID or player:GetGMRank() > 1 ) then
			SendGossip("[Калимдор] Изменить ресурсы",player)
		end
	elseif code == "addrules" then
		if (player:GetAccountId() == AST_ID or player:GetGMRank() > 1 ) then
			SendGossip("[Калимдор] Дать права",player)
		end
	elseif code == "removerules" then
		if (player:GetAccountId() == AST_ID or player:GetGMRank() > 1 ) then
			SendGossip("[Калимдор] Убрать права",player)
		end
	elseif code == "rescount" then
		if GetPlayerFraction(player:GetName()) then
			local perm = GetPlayerPerm(player:GetName())
			if perm == 1 then
				local q = WorldDBQuery("SELECT id,name, res_count FROM kalimdor_fractions WHERE id = "..GetPlayerFraction(player:GetName()))
				player:SendBroadcastMessage("Количество ресурсов вашей фракции - "..q:GetInt32(2))
			else
				player:SendBroadcastMessage("Вы не обладаете правом распоряжения ресурсами")
			end
		else
			player:SendBroadcastMessage("Вы не находитесь во фракции")
		end
	elseif code == "buy honor" then
		if GetPlayerFraction(player:GetName()) then
			local perm = GetPlayerPerm(player:GetName())
			if perm == 1 then
				SendGossip("[Калимдор] Покупка хонора",player)
			else
				player:SendBroadcastMessage("Вы не обладаете правом распоряжения ресурсами")
			end
		else
			player:SendBroadcastMessage("Вы не находитесь во фракции")
		end
	
	end
end


local function BuyUnit(player,buttonName,gossipName,data)
	if GetPlayerFraction(player:GetName()) then
		local perm = GetPlayerPerm(player:GetName())
		if perm == 1 then
			local nearestPoint = player:GetNearestCreature(KAL_POINT_RADIUS,KAL_CP_Entry)
			if nearestPoint then
				local pointData = GetPointData(nearestPoint)
				if pointData then
					if pointData.owner_id == GetPlayerFraction(player:GetName()) then
						local x, y, z, o = player:GetLocation();
						local pid = player:GetGUIDLow();
						local map = player:GetMapId();
						if GetResources(GetPlayerFraction(player:GetName())) >= KAL_UnitCost then
							PerformIngameSpawn( 1, KAL_unitListOnFrac[GetPlayerFraction(player:GetName())], map, 0, x, y, z, o, true, pid, 0, 1)
							AddResources(GetPlayerFraction(player:GetName()),KAL_UnitCost*-1,100)
							local q = WorldDBQuery("SELECT id,name, res_count FROM kalimdor_fractions WHERE id = "..GetPlayerFraction(player:GetName()))
							player:SendBroadcastMessage("Количество ресурсов вашей фракции - "..q:GetInt32(2))
						else
							player:SendBroadcastMessage("У вашей фракции недостаточно ресурсов для покупки юнита. Необходимо - "..KAL_UnitCost)
						end
					else
						player:SendBroadcastMessage("Вы сначала должны захватить точку, чтобы располагать на ней свои войска")
					end
				end
			else
				player:SendBroadcastMessage("Рядом нет ваших точек")
			end
		else
			player:SendBroadcastMessage("Вы не обладаете правом распоряжения ресурсами")
		end
	else
		player:SendBroadcastMessage("Вы не находитесь во фракции")
	end
	
end
local function BuyHonor(player,buttonName,gossipName,data)
	if GetPlayerFraction(player:GetName()) then
		local perm = GetPlayerPerm(player:GetName())
		if perm == 1 then
			if GetResources(GetPlayerFraction(player:GetName())) >= KAL_HonorCost then
				local suc = player:AddItem(KAL_HonorIdItem,1)
				if suc then
					AddResources(GetPlayerFraction(player:GetName()),KAL_HonorCost*-1,100)
					local q = WorldDBQuery("SELECT id,name, res_count FROM kalimdor_fractions WHERE id = "..GetPlayerFraction(player:GetName()))
					player:SendBroadcastMessage("Количество ресурсов вашей фракции - "..q:GetInt32(2))
				else
					player:SendBroadcastMessage("Недостаточно места в инвентаре")
				end
			else
				player:SendBroadcastMessage("У вашей фракции недостаточно ресурсов для покупки юнита. Необходимо - "..KAL_HonorCost)
			end
		else
			player:SendBroadcastMessage("Вы не обладаете правом распоряжения ресурсами")
		end
	else
		player:SendBroadcastMessage("Вы не находитесь во фракции")
	end
	
end
local function EnterInFrac(player,fracName,gossipName,data)
	local fracId = 0
	for i = 1, #KAL_fractionList do
		if KAL_fractionList[i].name == fracName then
			fracId = KAL_fractionList[i].id
			player:SendBroadcastMessage("Вы присоединяетесь к фракции \""..fracName.."\"")
			WorldDBExecute("INSERT INTO kalimdor_players (player_name, fraction_id, permission) VALUES('"..player:GetName().."',"..fracId..", 0) ON DUPLICATE KEY UPDATE fraction_id="..fracId..", permission=0")
			KAL_playerInfo[player:GetName()] = { fid = fracId, perm = 0 }
			
			lastTimeChangeFrac[player:GetName()] = os.time()
			return true
		end
	end
end
local function ChangeRes(player,fracName,gossipName,data)
	local fracId = 0
	for i = 1, #KAL_fractionList do
		if KAL_fractionList[i].name == fracName then
			fracId = KAL_fractionList[i].id
			player:SendBroadcastMessage("Количество ресурсов фракции \""..fracName.."\" изменено на "..data)
			AddResources(fracId,tonumber(data),100)
			local q = WorldDBQuery("SELECT id,name, res_count FROM kalimdor_fractions WHERE id = "..fracId)
			player:SendBroadcastMessage("Количество ресурсов "..q:GetString(1).." - "..q:GetInt32(2))
			return true
		end
	end
end
local function AddPerm(player,label,gossipName,data)
	WorldDBExecute("UPDATE kalimdor_players SET `permission`='1' WHERE  `player_name`='"..data.."'")
	player:SendBroadcastMessage("Права на фракцию выданы "..data)
	KAL_playerInfo[data].perm = 1
end
local function RemovePerm(player,label,gossipName,data)
	WorldDBExecute("UPDATE kalimdor_players SET `permission`='0' WHERE  `player_name`='"..data.."'")
	player:SendBroadcastMessage("Права на фракцию убраны у "..data)
	KAL_playerInfo[data].perm = 0
end

NewGossip("[Калимдор] Покупка юнита")
AddButtonToGossip("[Калимдор] Покупка юнита","Купить юнита",1,false,"Вы потратите ресурсы",BuyUnit)

NewGossip("[Калимдор] Покупка хонора")
AddButtonToGossip("[Калимдор] Покупка хонора","Купить "..GetItemLink(KAL_HonorIdItem),1,false,nil,BuyHonor,false)


NewGossip("[Калимдор] Выбор фракции")
for i = 1, #KAL_fractionList do
	AddButtonToGossip("[Калимдор] Выбор фракции",KAL_fractionList[i].name,1,false,"Вы действительно хотите присоединиться к фракции \""..KAL_fractionList[i].name.."\"?",EnterInFrac,true)
end
NewGossip("[Калимдор] Изменить ресурсы")
for i = 1, #KAL_fractionList do
	AddButtonToGossip("[Калимдор] Изменить ресурсы",KAL_fractionList[i].name,1,true,"Вы действительно хотите изменить количество ресурсов \""..KAL_fractionList[i].name.."?",ChangeRes,false)
end
NewGossip("[Калимдор] Дать права")
AddButtonToGossip("[Калимдор] Дать права","Ввести ник игрока на выдачу прав",1,true,"Вы действительно хотите выдать права этому игроку? Игрок будет иметь доступ к распоряжению ресурсами фракции.\nВажно: Игрок должен состоять в этой фракции.",AddPerm,false)

NewGossip("[Калимдор] Убрать права")
AddButtonToGossip("[Калимдор] Убрать права","Ввести ник на отбирание прав",1,true,nil,RemovePerm,false)


RegisterPlayerEvent(42, OnPlayerCommandWithArg)
local GENDER_MALE = 1
local GENDER_FEM = 2
local GENDER_NET = 3

local resTypes = {
	metall = 1,
	wood = 2
	}
	
local itemTypes = { shortSword = 1, longSword = 2, halberd = 3 }

local function createResKit(n_resType,n_resCount, n_part, n_gender)
	local resKit = { resType = n_resType, count = n_resCount, part = n_part, gender = n_gender}
	return resKit
end

local resNames = {	[resTypes.metall] = "Металл", [resTypes.wood] = "Древесина"	}

local resSubTypes = {
	[resTypes.metall] = {
		bronze = 1,
		steel = 2,
		silver = 3},
	[resTypes.wood] = {
		oak = 1,
		pine = 2,
		birch = 3}
	}
local madeofNames = {
	[GENDER_MALE] = "сделан",
	[GENDER_FEM] = "сделана",
	[GENDER_NET] = "сделано"
	}
local resSubNames = {
	[resTypes.metall] = {
		[resSubTypes[resTypes.metall].bronze] = {name = "Бронза",madeof = "из бронзы"},
		[resSubTypes[resTypes.metall].steel] = {name = "Сталь",madeof = "из стали"},
		[resSubTypes[resTypes.metall].silver] = {name = "Серебро",madeof = "из серебра"}},
	[resTypes.wood] = {
		[resSubTypes[resTypes.wood].oak] = {name = "Дуб", madeof = "из дуба"},
		[resSubTypes[resTypes.wood].pine] = {name = "Сосна", madeof = "из сосны"},
		[resSubTypes[resTypes.wood].birch] = {name = "Береза",madeof = "из березы"}}
	}

local itemRes = { 
	[itemTypes.shortSword] = { createResKit(resTypes.metall,2,"Недлинный клинок",GENDER_MALE), createResKit(resTypes.wood,2,"Рукоять",GENDER_FEM) },
	[itemTypes.longSword] = { createResKit(resTypes.metall,3,"Длинное острие",GENDER_NET), createResKit(resTypes.wood,5,"Рукоять",GENDER_FEM)},
	[itemTypes.halberd] = { createResKit(resTypes.metall,4,"Наконечник",GENDER_MALE), createResKit(resTypes.wood,7,"Древко",GENDER_NET) }
	}
local itemNames = {
	[itemTypes.shortSword] = { name = "Короткий меч", gender = GENDER_MALE },
	[itemTypes.longSword] = { name = "Длинный меч", gender = GENDER_MALE },
	[itemTypes.halberd] = { name = "Алебарда", gender = GENDER_FEM }
	}

	
local function OnPlayerCommandWithArg(event, player, code)
    if player:GetAccountId() == 2899 then
		if(string.find(code, " "))then
			local arguments = {}
			local arguments = string.split(code, " ")
			if (arguments[1] == "ittest" and #arguments == 4 ) then
				itemId = tonumber(arguments[2])
				matId1 = tonumber(arguments[3])
				matId2 = tonumber(arguments[4])
				player:SendBroadcastMessage("Перед вами "..itemNames[itemId].name..".\n"..itemRes[itemId][1].part.." "..madeofNames[itemRes[itemId][1].gender].." "..resSubNames[1][matId1].madeof..". "..itemRes[itemId][2].part.." "..madeofNames[itemRes[itemId][2].gender].." "..resSubNames[2][matId2].madeof..".")
				return false
			end
		end
	end
end
RegisterPlayerEvent(42, OnPlayerCommandWithArg)
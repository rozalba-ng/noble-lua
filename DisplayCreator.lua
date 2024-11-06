local transmogSlots = {0,2,3,4,5,6,7,8,9,14,18}
local max_char = 255

local function getPlayerTransmog(player)
	local idList = {};
	for slot = 1, #transmogSlots do
		local transmogrified = player:GetItemByPos(255, transmogSlots[slot])
		if transmogrified then
			local fentry = GetFakeEntry(transmogrified);
			local itemEntry = transmogrified:GetEntry()
			if (fentry) then
				itemEntry = fentry
			end
			table.insert(idList,itemEntry)
		else
			table.insert(idList,0)
		end
	end
	return idList
end

local function extractName(arguments)
	local name = ""
	for i = 2, #arguments do
		for S in string.gmatch(arguments[i], "[^\"\'\\]") do
			if string.len(name) < max_char then
				name = (name..S)
			end
		end
		if string.len(name) < max_char then
				name = (name.." ")
		end
	end
	return name
end

-- As model is chosen on a client side, we cannot get which one is there.
-- But if allowSeveralModels is true, we will just use the first non-zero.
function GetModelCreature(entry, allowSeveralModels)
	local creatureQ = WorldDBQuery(string.format(
		[[
			SELECT modelid1, modelid2, modelid3, modelid4 
			FROM world.creature_template 
			WHERE entry = %d
		]], entry))
	print(creatureQ:GetInt32(0), creatureQ:GetInt64(0), creatureQ:GetString(0))
	local row = creatureQ:GetRow()
	print(row.modelid1)
	local modelId = {creatureQ:GetInt32(0), creatureQ:GetInt32(1), creatureQ:GetInt32(2), creatureQ:GetInt32(3)}
	local singleModel = 0
	for _, model in ipairs(models) do
		model = math.abs(model)
        if model ~= 0 then
            if allowSeveralModels then
                return model
            elseif singleModel ~= 0 and singleModel ~= model then
                return nil
            end
            singleModel = model
        end
    end
	return singleModel
end

local function extractName(arguments)
	local name = ""
	for i = 2, #arguments do
		for S in string.gmatch(arguments[i], "[^\"\'\\]") do
			if string.len(name) < max_char then
				name = (name..S)
			end
		end
		if string.len(name) < max_char then
				name = (name.." ")
		end
	end
	return name
end

-- These commands are only applicable for GMs.
local function OnPlayerCommandWithArg(event, player, code)
	if player:GetGMRank() == 0 then
		return false
	end
    if(string.find(code, " "))then
        local arguments = {}
        local arguments = string.split(code, " ")
        if (arguments[1] == "createdisp" and #arguments > 1 ) then
			local idList = getPlayerTransmog(player);
			local custQ = CharDBQuery('SELECT race, gender, skin, face, hairStyle, hairColor, facialStyle FROM characters where guid = ' .. player:GetGUIDLow());
			local name = extractName(arguments);
			WorldDBQuery("INSERT INTO `world`.`creature_template_outfits` (`race`, `gender`, `skin`, `face`, `hair`, `haircolor`, `facialhair`, `head`, `shoulders`, `body`, `chest`, `waist`, `legs`, `feet`, `wrists`, `hands`, `back`, `tabard`, `user_id`, `updated_by`, `comment`) VALUES ('"..custQ:GetUInt32(0).."', '"..custQ:GetUInt32(1).."', '"..custQ:GetUInt32(2).."', '"..custQ:GetUInt32(3).."', '"..custQ:GetUInt32(4).."', '"..custQ:GetUInt32(5).."', '"..custQ:GetUInt32(6).."', '"..idList[1].."', '"..idList[2].."', '"..idList[3].."', '"..idList[4].."', '"..idList[5].."', '"..idList[6].."', '"..idList[7].."', '"..idList[8].."', '"..idList[9].."', '"..idList[10].."', '"..idList[11].."', '0', '0', '"..name.."');")
			local lastidQ = WorldDBQuery("SELECT entry FROM creature_template_outfits ORDER BY entry DESC LIMIT 1;")
			ReloadNPCOutfits()
			--ReloadCreatureOutfitByEntry(lastidQ:GetUInt32(0))
			player:SendBroadcastMessage("Облик "..name.."создан и готов к использованию! ID -"..lastidQ:GetUInt32(0))
		elseif (arguments[1] == "createtargetdisp" and #arguments > 1 ) then
			local target = player:GetSelection()
			local targetPlayer = target:ToPlayer()
			local idList = getPlayerTransmog(targetPlayer)
			local custQ = CharDBQuery('SELECT race,gender,skin, face, hairStyle, hairColor, facialStyle FROM characters where guid = ' .. targetPlayer:GetGUIDLow());
			local name = extractName(arguments);
			WorldDBQuery("INSERT INTO `world`.`creature_template_outfits` (`race`, `gender`, `skin`, `face`, `hair`, `haircolor`, `facialhair`, `head`, `shoulders`, `body`, `chest`, `waist`, `legs`, `feet`, `wrists`, `hands`, `back`, `tabard`, `user_id`, `updated_by`, `comment`) VALUES ('"..custQ:GetUInt32(0).."', '"..custQ:GetUInt32(1).."', '"..custQ:GetUInt32(2).."', '"..custQ:GetUInt32(3).."', '"..custQ:GetUInt32(4).."', '"..custQ:GetUInt32(5).."', '"..custQ:GetUInt32(6).."', '"..idList[1].."', '"..idList[2].."', '"..idList[3].."', '"..idList[4].."', '"..idList[5].."', '"..idList[6].."', '"..idList[7].."', '"..idList[8].."', '"..idList[9].."', '"..idList[10].."', '"..idList[11].."', '0', '0', '"..name.."');")
			local lastidQ = WorldDBQuery("SELECT entry FROM creature_template_outfits ORDER BY entry DESC LIMIT 1;")
			ReloadNPCOutfits()
			--ReloadCreatureOutfitByEntry(lastidQ:GetUInt32(0))
			player:SendBroadcastMessage("Облик "..name.."создан по подобию игрока "..targetPlayer:GetName().." и готов к использованию! ID -"..lastidQ:GetUInt32(0))
            return false;
		end
	elseif (code == "reloadoutfits") then
		ReloadNPCOutfits()
		local gms = GetPlayersInWorld(2)
		for i = 1, #gms do
			if gms[i]:GetGMRank() > 0 then
				gms[i]:SendBroadcastMessage("Перезагрузка обликов. Инициирована - "..player:GetName().." ("..player:GetAccountName()..")")
			end
		end
	elseif (code == "reloadoutfit") then
		local outfitId = tonumber(arguments[2])
		if outfitId == 0 then
			player:SendBroadcastMessage("Вы указали неверный id.")
			return false
		end
		--ReloadCreatureOutfitByEntry(outfitId)
	elseif (code == "changenpctransmog") then
		local target = player:GetSelection()
		if target:ToPlayer() then
			player:SendBroadcastMessage("Можно переодевать только неписей!")
			return false
		end
		local creatureId = target:GetGUIDLow()
		local templateId = target:GetEntry()
		local modelId = GetModelCreature(templateId, false)
		if not modelId then
			player:SendBroadcastMessage("Можно переодевать только неписей с единственной моделькой.")
			return false
		end

		local appearenceQuery = WorldDBQuery("SELECT race, gender, skin, face, hair, hairColor, facialhair"..
		"FROM world.creature_template_outfits"..
		"WHERE entry=".. modelId
		)
		local npc = {
			race = appearenceQuery:GetUInt32(0),
			gender = appearenceQuery:GetUInt32(1),
			skin = appearenceQuery:GetUInt32(2),
			face = appearenceQuery:GetUInt32(3),
			hair = appearenceQuery:GetUInt32(4),
			hairColor = appearenceQuery:GetUInt32(5),
			facialHair = appearenceQuery:GetUInt32(6)
		}

		local transmogList = getPlayerTransmog(player);
		local checkOutfitQuery = string.format([[
			SELECT entry FROM world.creature_template_outfits
			WHERE race = %d AND gender = %d AND skin = %d AND face = %d AND hair = %d AND hairColor = %d AND facialHair = %d
			AND head = %d AND shoulders = %d AND body = %d AND chest = %d AND waist = %d AND legs = %d AND feet = %d
			AND wrists = %d AND hands = %d AND back = %d AND tabard = %d
		]],
			npc.race, npc.gender, npc.skin, npc.face, npc.hair, npc.hairColor, npc.facialHair,
			transmogList[1], transmogList[2], transmogList[3], transmogList[4], transmogList[5],
			transmogList[6], transmogList[7], transmogList[8], transmogList[9], transmogList[10], transmogList[11]
    	)

    	local outfitResult = WorldDBQuery(checkOutfitQuery)

		local dispId = nil
		if outfitResult then
			dispId = outfitResult:GetUInt32(0)
		else
			local insertQuery = string.format([[
				INSERT INTO world.creature_template_outfits (race, gender, skin, face, hair, hairColor, facialHair,
				head, shoulders, body, chest, waist, legs, feet, wrists, hands, back, tabard, user_id, updated_by, comment)
				VALUES (%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, 0, 0, 'NPC change equipment')
			]],
				npc.race, npc.gender, npc.skin, npc.face, npc.hair, npc.hairColor, npc.facialHair,
				transmogList[1], transmogList[2], transmogList[3], transmogList[4], transmogList[5],
				transmogList[6], transmogList[7], transmogList[8], transmogList[9], transmogList[10], transmogList[11]
			)
			WorldDBQuery(insertQuery)
			local dispQuery = WorldDBQuery("SELECT entry FROM creature_template_outfits ORDER BY entry DESC LIMIT 1;")
			dispId = dispQuery:GetUInt32(0)
			ReloadNPCOutfits()
			--ReloadCreatureOutfitByEntry(dispId)
		end
		local updateCreatureTemplateQuery = WorldDBQuery("UPDATE world.creature_template"..
		"SET modelid1 = ".. -dispId .. ", modelid2 = 0, modelid3 = 0, modelid4 = 0"..
		"WHERE entry = " .. templateId)
		-- ReloadCreatureOutfitByEntry()
		-- ReloadCreatureTemplateByEntry(templateId)
		-- ReloadCreatureByEntry(creatureId)
	end
end

RegisterPlayerEvent(42, OnPlayerCommandWithArg)

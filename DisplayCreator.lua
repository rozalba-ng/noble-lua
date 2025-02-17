local transmogSlots = {0,2,3,4,5,6,7,8,9,14,18}
local max_char = 255
local function OnPlayerCommandWithArg(event, player, code)
    if(string.find(code, " "))then
        local arguments = {}
        local arguments = string.split(code, " ")
        if (arguments[1] == "createdisp" and #arguments > 1 ) then
			if player:GetGMRank() > 0 then
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
				local custQ = CharDBQuery('SELECT race,gender,skin, face, hairStyle, hairColor, facialStyle FROM characters where guid = ' .. player:GetGUIDLow() );	
				local name = "";
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

				WorldDBQuery("INSERT INTO `world`.`creature_template_outfits` (`race`, `gender`, `skin`, `face`, `hair`, `haircolor`, `facialhair`, `head`, `shoulders`, `body`, `chest`, `waist`, `legs`, `feet`, `wrists`, `hands`, `back`, `tabard`, `user_id`, `updated_by`, `comment`) VALUES ('"..custQ:GetUInt32(0).."', '"..custQ:GetUInt32(1).."', '"..custQ:GetUInt32(2).."', '"..custQ:GetUInt32(3).."', '"..custQ:GetUInt32(4).."', '"..custQ:GetUInt32(5).."', '"..custQ:GetUInt32(6).."', '"..idList[1].."', '"..idList[2].."', '"..idList[3].."', '"..idList[4].."', '"..idList[5].."', '"..idList[6].."', '"..idList[7].."', '"..idList[8].."', '"..idList[9].."', '"..idList[10].."', '"..idList[11].."', '0', '0', '"..name.."');")
				local lastidQ = WorldDBQuery("SELECT entry FROM creature_template_outfits ORDER BY entry DESC LIMIT 1;")
				
				
				ReloadNPCOutfits()
				player:SendBroadcastMessage("Облик "..name.."создан и готов к использованию! ID -"..lastidQ:GetUInt32(0))
			end
		
		
            return false;
		elseif (arguments[1] == "createtargetdisp" and #arguments > 1 ) then
			if player:GetGMRank() > 0 then
				local idList = {};
				local target = player:GetSelection()
				local targetPlayer = target:ToPlayer()
				if targetPlayer then
					for slot = 1, #transmogSlots do
						local transmogrified = targetPlayer:GetItemByPos(255, transmogSlots[slot])
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
					local custQ = CharDBQuery('SELECT race,gender,skin, face, hairStyle, hairColor, facialStyle FROM characters where guid = ' .. targetPlayer:GetGUIDLow() );	
					local name = "";
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

					WorldDBQuery("INSERT INTO `world`.`creature_template_outfits` (`race`, `gender`, `skin`, `face`, `hair`, `haircolor`, `facialhair`, `head`, `shoulders`, `body`, `chest`, `waist`, `legs`, `feet`, `wrists`, `hands`, `back`, `tabard`, `user_id`, `updated_by`, `comment`) VALUES ('"..custQ:GetUInt32(0).."', '"..custQ:GetUInt32(1).."', '"..custQ:GetUInt32(2).."', '"..custQ:GetUInt32(3).."', '"..custQ:GetUInt32(4).."', '"..custQ:GetUInt32(5).."', '"..custQ:GetUInt32(6).."', '"..idList[1].."', '"..idList[2].."', '"..idList[3].."', '"..idList[4].."', '"..idList[5].."', '"..idList[6].."', '"..idList[7].."', '"..idList[8].."', '"..idList[9].."', '"..idList[10].."', '"..idList[11].."', '0', '0', '"..name.."');")
					local lastidQ = WorldDBQuery("SELECT entry FROM creature_template_outfits ORDER BY entry DESC LIMIT 1;")
					
					
					ReloadNPCOutfits()
					player:SendBroadcastMessage("Облик "..name.."создан по подобию игрока "..targetPlayer:GetName().." и готов к использованию! ID -"..lastidQ:GetUInt32(0))
				end
			end
		
		
            return false;
		
		end
	elseif (code == "reloadoutfits") then
		if player:GetGMRank() > 0 then
			ReloadNPCOutfits()
			local gms = GetPlayersInWorld(2)
			for i = 1, #gms do
				if gms[i]:GetGMRank() > 0 then
					gms[i]:SendBroadcastMessage("Перезагрузка обликов. Инициирована - "..player:GetName().." ("..player:GetAccountName()..")")
				end
			end
		end
    end
end

RegisterPlayerEvent(42, OnPlayerCommandWithArg)
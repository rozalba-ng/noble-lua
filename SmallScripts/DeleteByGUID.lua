local function OnCommand(player,guid)
	if(player:GetGMRank() > 0 or player:GetDmLevel() > 0)then
		if tonumber(guid) == nil then
			player:Print("Гуид НПС должен быть числом")
			return false
		elseif #guid > 10 then
			player:Print("Длинна Гуида НПС не должна быть более 10 цифр")
			return false
		end
		local q_entry = WorldDBQuery("SELECT id,map FROM creature WHERE guid = "..guid)
		if not q_entry then
			player:Print("НПС с таким Гуидом не было обнаружено")
			return false
		end
		local entry = q_entry:GetInt32(0)
		local mapid = q_entry:GetInt32(1)
		local creature = GetCreature(guid,entry,mapid)
		if creature == nil then
			player:Print("Данное существо либо не найдено в базе, либо не прогруженно в игровом мире. Попробуйте подойти к НПС, чтобы тот мог появится.")
			return false
		end
		if player:GetDmLevel() > 0 and player:GetGMRank() == 0 then
			if(creature:GetOwner() ~= player)then
				player:Print("Данный НПС вам не принадлежит")
				return false
			end
		end
		creature:Delete()
		player:Print("НПС успешно удален")
	else
		player:Print("У вас нет доступа к этой команде.")
	end
end
RegisterCommand("guiddelnpc",OnCommand)
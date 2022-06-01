local NPCToDelete = {}
local GOToDelete = {}



function OnCommand(player,guid)
	if(player:GetGMRank() > 0)then
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
		creature:Delete()
	else
		player:Print("У вас нет доступа к этой команде.")
	end
end
RegisterCommand("guiddelnpc",OnCommand)
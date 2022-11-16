--[[Каждые 5 минут проверяет челочисленный]]
local dublon = 301396;
local whiteRes = 301393;
local greenRes = 301394;

local function sendShopLetters()
	if SocialTime() then
		return false
	end

	local bonusQuery = CharDBQuery("SELECT * from doors_owners where bonus > 0");
	if (bonusQuery ~= nil) then
		local rowCount = bonusQuery:GetRowCount();	
		local entry;
		for var=1,rowCount,1 do
			local ownerData = bonusQuery:GetRow();
			local door_guid = ownerData['door_guid'];
			local amount = math.floor(ownerData['bonus']);
			local playerId = ownerData['ownerID'];
			
			if (playerId ~= 0 and amount > 0) then
				SendMail('Банк', 'Добрый день! Извольте получить доход от предприятия ' .. door_guid .. '. С уважением, ваш банк.', playerId, 36, 61, 20, 0, 0, dublon, amount);
				CharDBQuery('UPDATE doors_owners set bonus = bonus - ' .. amount .. ' where door_guid = ' .. door_guid);
			end
			bonusQuery:NextRow();
		end
	end	
end
CreateLuaEvent(sendShopLetters, 600000, 0);

local function sendOnlineLetters()
	if SocialTime() then
		return false
	end

	local bonusQuery = CharDBQuery("SELECT * from character_daily_log where standart_gift > 0 and standart_gift_done = 0");
	if (bonusQuery ~= nil) then
		local rowCount = bonusQuery:GetRowCount();
		local entry;
		for var=1,rowCount,1 do
			local ownerData = bonusQuery:GetRow();
			local standart_amount = ownerData['standart_gift'];
			local playerId = ownerData['character_guid'];
			local id = ownerData['id'];

			if (playerId ~= 0 and standart_amount > 0) then
				SendMail('Noblegarden - серебро', 'Ежедневный бонус за вашу активность на должности', playerId, 36, 61, 20, standart_amount); -- серебро
				CharDBQuery('UPDATE character_daily_log set standart_gift_done = 1 where id = ' .. id);
			end

			bonusQuery:NextRow();
		end
	end
end
CreateLuaEvent(sendOnlineLetters, 600000, 0);

local function sendResWhiteLetters()
	if SocialTime() then
		return false
	end

	local bonusQuery = CharDBQuery("SELECT * from character_daily_log where bonus_gift > 0 and bonus_gift_done = 0");
	if (bonusQuery ~= nil) then
		local rowCount = bonusQuery:GetRowCount();
		local entry;
		for var=1,rowCount,1 do
			local ownerData = bonusQuery:GetRow();
			local standart_amount = ownerData['bonus_gift'];
			local playerId = ownerData['character_guid'];
			local id = ownerData['id'];

			if (playerId ~= 0 and standart_amount > 0) then
				SendMail('Noblegarden - ресурсы', 'Поощрение за вчерашнюю ролевую активность', playerId, 36, 61, 20, 0, 0, whiteRes, standart_amount); -- обычные ресурсы
				CharDBQuery('UPDATE character_daily_log set bonus_gift_done = 1 where id = ' .. id);
			end

			bonusQuery:NextRow();
		end
	end
end
CreateLuaEvent(sendResWhiteLetters, 650000, 0);

local function sendResGreenLetters()
	if SocialTime() then
		return false
	end

	local bonusQuery = CharDBQuery("SELECT * from character_daily_log where random_gif > 0 and random_gift_done = 0");
	if (bonusQuery ~= nil) then
		local rowCount = bonusQuery:GetRowCount();
		local entry;
		for var=1,rowCount,1 do
			local ownerData = bonusQuery:GetRow();
			local standart_amount = ownerData['random_gif'];
			local playerId = ownerData['character_guid'];
			local id = ownerData['id'];

			if (playerId ~= 0 and standart_amount > 0) then
				SendMail('Noblegarden - необычные ресурсы', 'Вчера вы проявили небывалую активность и заслужили бонус!', playerId, 36, 61, 20, 0, 0, greenRes, standart_amount); -- необычные ресурсы
				CharDBQuery('UPDATE character_daily_log set random_gift_done = 1 where id = ' .. id);
			end

			bonusQuery:NextRow();
		end
	end
end
CreateLuaEvent(sendResGreenLetters, 620000, 0);

local function sendWeeklyLetters()
	if SocialTime() then
		return false
	end

	local bonusQuery = CharDBQuery("SELECT * from character_weekly_log where (rep_gift_amount > 0 and rep_gift_done = 0) or (crowns_gift_amount > 0 and crowns_gift_done = 0)");
	if (bonusQuery ~= nil) then
		local rowCount = bonusQuery:GetRowCount();
		local entry;
		for var=1,rowCount,1 do
			local ownerData = bonusQuery:GetRow();
			local crowns_amount = ownerData['crowns_gift_amount'];
			local playerId = ownerData['character_guid'];
			local id = ownerData['id'];

			if (playerId ~= 0 and crowns_amount > 0 and tonumber(ownerData['log_type']) == 1) then
				SendMail('Noblegarden - валюта', 'Еженедельное жалованье за вашу должность!', playerId, 36, 61, 20, 0, 0, dublon, crowns_amount);
				CharDBQuery('UPDATE character_weekly_log set crowns_gift_done = 1 where id = ' .. id);
--			elseif (playerId ~= 0 and crowns_amount > 0 and tonumber(ownerData['log_type']) == 2) then
--				SendMail('Noblegarden - серебро', 'Ежедневный бонус за вашу активность на должности', playerId, 36, 61, 20, crowns_amount); -- серебро
--				CharDBQuery('UPDATE character_weekly_log set crowns_gift_done = 1 where id = ' .. id);
			end

			if (playerId ~= 0 and crowns_amount > 0) then

			end
			bonusQuery:NextRow();
		end
	end
end
CreateLuaEvent(sendWeeklyLetters, 600000, 0);
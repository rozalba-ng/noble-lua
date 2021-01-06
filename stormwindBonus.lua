--[[Каждые 5 минут проверяет челочисленный]]

local function sendShopLetters()
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
				SendMail('Банк Штормграда', 'Добрый день! Извольте получить ваш базовый доход от лавки ' .. door_guid .. '. С уважением, городской банк Штормграда.', playerId, 36, 61, 20, 0, 0, 600057, amount);
				CharDBQuery('UPDATE doors_owners set bonus = bonus - ' .. amount .. ' where door_guid = ' .. door_guid);
			end
			bonusQuery:NextRow();
		end
	end	
end

CreateLuaEvent(sendShopLetters, 200000, 0);

local function sendOnlineLetters()
	local bonusQuery = CharDBQuery("SELECT * from character_daily_log where (standart_gift > 0 and standart_gift_done = 0) or (public_gift > 0 and public_gift_done = 0)");
	if (bonusQuery ~= nil) then
		local rowCount = bonusQuery:GetRowCount();
		local entry;
		for var=1,rowCount,1 do
			local ownerData = bonusQuery:GetRow();
			local standart_amount = ownerData['standart_gift'];
			local public_amount = ownerData['public_gift'];
			local playerId = ownerData['character_guid'];
			local id = ownerData['id'];
			local activity = math.floor(ownerData['stormwind_primetime_total']/(60));

			local factionQuery = CharDBQuery("SELECT faction from character_reputation where faction in (1163, 1162) and guid = " .. playerId .. " order by standing DESC limit 1");

			if (factionQuery ~= nil) then
				local factionRow = factionQuery:GetRow();
				local faction = factionRow['faction'];

				local standart_item = 600245;
				local public_item = 600248;

				if (faction == law_faction) then
					standart_item = 600239;
					public_item = 600243;
				end

				if (playerId ~= 0 and standart_amount > 0) then
					SendMail('Noblegarden', 'Добрый день! Ваша активность на территории Штормграда в праймтайм за прошлые сутки: ' .. activity .. ' минут. Накопленный бонус репутации: ' .. standart_amount .. ' малых жетонов. Приятной игры!', playerId, 36, 61, 20, 0, 0, standart_item, standart_amount);
					CharDBQuery('UPDATE character_daily_log set standart_gift_done = 1 where id = ' .. id);
				end

				if (playerId ~= 0 and public_amount > 0) then
					SendMail('Noblegarden', 'Добрый день! Вчера вы проявили необычайную активность на полигоне Штормград, и потому вам полагается дополнительная награда! Спасибо за вашу активность!', playerId, 36, 61, 20, 0, 0, public_item, public_amount);
					CharDBQuery('UPDATE character_daily_log set public_gift_done = 1 where id = ' .. id);
				end
			end;

			bonusQuery:NextRow();
		end
	end
end

CreateLuaEvent(sendOnlineLetters, 200000, 0);

local function sendWeeklyLetters()
	local bonusQuery = CharDBQuery("SELECT * from character_weekly_log where (rep_gift_amount > 0 and rep_gift_done = 0) or (crowns_gift_amount > 0 and crowns_gift_done = 0)");
	if (bonusQuery ~= nil) then
		local rowCount = bonusQuery:GetRowCount();
		local entry;
		for var=1,rowCount,1 do
			local ownerData = bonusQuery:GetRow();
			local rep_amount = ownerData['rep_gift_amount'];
			local crowns_amount = ownerData['crowns_gift_amount'];
			local playerId = ownerData['character_guid'];
			local id = ownerData['id'];

			local factionQuery = CharDBQuery("SELECT faction from character_reputation where faction in (1163, 1162) and guid = " .. playerId .. " order by standing DESC limit 1");

			if (factionQuery ~= nil) then
				local factionRow = factionQuery:GetRow();
				local faction = factionRow['faction'];

				local rep_item = 2114372;
				local veksel_item = 600157;

				if (faction == law_faction) then
					rep_item = 2114371;
				end

				local text_rep = 'Еженедельный гильдейский бонус репутации';
				local text_crowns = 'Еженедельный гильдейский бонус валюты';
				if (tonumber(ownerData['log_type']) == 2) then
					text_rep = 'Поздравляем с попаданием в топ недельного рейтинга личной активности! Важи жетоны репутации прилагаются!';
					text_crowns = 'Поздравляем с попаданием в топ недельного рейтинга личной активности! Ваши Королевские Вексели прилагаются!';
				end

				if (playerId ~= 0 and rep_amount > 0 and playerId == 41063) then
					SendMail('Noblegarden - репутация', text_rep, playerId, 36, 61, 20, 0, 0, rep_item, rep_amount);
					CharDBQuery('UPDATE character_weekly_log set rep_gift_done = 1 where id = ' .. id);
				end

				if (playerId ~= 0 and crowns_amount > 0 and playerId == 41063) then
					SendMail('Noblegarden - валюта', text_crowns, playerId, 36, 61, 20, 0, 0, veksel_item, crowns_amount);
					CharDBQuery('UPDATE character_weekly_log set crowns_gift_done = 1 where id = ' .. id);
				end
			end;

			bonusQuery:NextRow();
		end
	end
end

CreateLuaEvent(sendWeeklyLetters, 200000, 0);
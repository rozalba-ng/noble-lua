--[[Каждые 5 минут проверяет список голосов с ммотоп и рассылает письма с подарками]]
local function sendVoteLetters()
	if SocialTime() then
		return false
	end

	--local votesQuery = CharDBQuery('SELECT id, account, `character` FROM vote_statistics where sended = 0');
	local votesQuery = CharDBQuery("SELECT a.id, a.account, a.`character` from vote_statistics a where a.sended = 0 and (a.amount > 1 OR (NOT EXISTS (select b.* from vote_statistics b where b.`date` like concat(substr(a.`date`, 1, 10),'%') and b.sended = 1 and b.amount = 1 and b.account = a.account) AND NOT EXISTS (select count(c.account) as cnt from vote_statistics c where c.`date` like concat(substr(a.`date`, 1, 10),'%') and c.sended = 0 and c.amount = 1 and c.account = a.account having cnt>1)))");
	--local votesDateQuery = CharDBQuery('SELECT id, account, `character` FROM vote_statistics where sended = 1 and amount = 1 and `date` like "'..os.date("%d.%m.%Y",os.time()+7200)..'%");
	--PrintError("SELECT id, account, `character` FROM vote_statistics where sended = 1 and amount = 1 and `date` like '"..os.date("%d.%m.%Y",os.time()+7200).."%'");
	if (votesQuery ~= nil) then
		local rowCount = votesQuery:GetRowCount();	
		local entry;
		for var=1,rowCount,1 do
			local voteId = votesQuery:GetString(0);
			local accountName = votesQuery:GetString(1);
			local characterName = votesQuery:GetString(2);
			local playerId = 0;		
			
			-- проверяем отправил ли пользователь имя персонажа
			local characterQuery = CharDBQuery('SELECT guid FROM characters where name = "' .. characterName .. '"');
			if (characterQuery ~= nil) then
				playerId = characterQuery:GetString(0);
			else
				-- если пользователь не отправил имя персонажа, то ищем отправленный аккаунт
				local accountQuery = AuthDBQuery('SELECT id FROM account where username = "' .. accountName .. '"');
				if (accountQuery ~= nil) then
					accountId = accountQuery:GetString(0);
					local charByNameQuery = CharDBQuery('SELECT guid FROM characters where account = "' .. accountId .. '" order by name ASC limit 1');
					-- если такой акаунт существует, берем первого персонажа отсортированного по имени
					if (charByNameQuery ~= nil) then
						playerId = charByNameQuery:GetString(0);
						local charByNameQuery = CharDBQuery('SELECT guid FROM characters where account = "' .. accountId .. '"');
					end
				end
			end
			
			if (playerId ~= 0) then
				SendMail('Thanks for voting us!', 'Hello! Thanks for voting us on MMOTOP, and here is your prize!', playerId, 36, 61, 20, 0, 0, 9363, 1);
				CharDBQuery('UPDATE vote_statistics set sended = 1 where id = ' .. voteId);
			end
			
			votesQuery:NextRow();
		end
	end	
end

CreateLuaEvent(sendVoteLetters, 600000, 0);
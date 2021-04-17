
-- баф печального отшельника
local otshelnik_aura = 91169
local karas_aura = 91174
local dolce_aura = 91172

--[[Every 30 minutes calculate activity ]]
local function sendTavernBonuses()
	local onlinePlayers = GetPlayersInWorld( 2 ); --[[ 2-neutral, both horde and aliance]]
	local otchelnik_bonus = 0;
	local karas_bonus = 0;
	local dolce_bonus = 0;
	local base_bonus = 0.5;
	for _, player in ipairs( onlinePlayers ) do
		if ( player:IsAFK() == false and player:GetPhaseMask() == 1) then
		--	Добавление репутации
			if SocialTime() then
				if (player:HasAura(otshelnik_aura)) then
					otchelnik_bonus = otchelnik_bonus + base_bonus;
				end
				if (player:HasAura(karas_aura)) then
					karas_bonus = karas_bonus + base_bonus;
				end
				if (player:HasAura(dolce_aura)) then
					dolce_bonus = dolce_bonus + base_bonus;
				end
			end
		end;
	end

	if (otchelnik_bonus > 1) then
		local otchelnik_bonus_ceil = math.ceil(otchelnik_bonus)
		SendMail('Otshelnik bonus!', 'Бонус за активность таверны "Печальный Отшельник" (квартал магов)', 25924, 36, 61, 20, 0, 0, 600057, otchelnik_bonus_ceil); -- мне на персонаж Райка для мониторинга
		SendMail('Otshelnik bonus!', 'Бонус за активность таверны "Печальный Отшельник" (квартал магов)', 31404, 36, 61, 20, 0, 0, 600057, otchelnik_bonus_ceil); -- 31404 персонаж Корс (Неко)
	end
	if (karas_bonus > 1) then
		local karas_bonus_ceil = math.ceil(karas_bonus)
		SendMail('Karas bonus', 'Бонус за активность таверны "Драный карась" (торговый квартал)', 25924, 36, 61, 20, 0, 0, 600057, karas_bonus_ceil); -- мне на персонаж Райка для мониторинга
		SendMail('Karas bonus', 'Бонус за активность таверны "Драный карась" (торговый квартал)', 8212, 36, 61, 20, 0, 0, 600057, karas_bonus_ceil); -- 8212 персонаж Хейвинд (Ферриан)
	end
	if (dolce_bonus > 0) then
		local dolce_bonus_ceil = math.ceil(dolce_bonus)
		SendMail('Karas bonus', 'Бонус за активность таверны "Драный карась" (торговый квартал)', 25924, 36, 61, 20, 0, 0, 600057, dolce_bonus_ceil); -- мне на персонаж Райка для мониторинга
		SendMail('Karas bonus', 'Бонус за активность клуба "Дольче Вита" (дворянский квартал)', 7269, 36, 61, 20, 0, 0, 600057, dolce_bonus_ceil); -- 8212 персонаж Диметра (Ирина)
	end
end
CreateLuaEvent( sendTavernBonuses, 1800000, 0 )
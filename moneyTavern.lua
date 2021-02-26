
-- баф печального отшельника
local otshelnik_aura = 91169

--[[Every 30 minutes calculate activity ]]
local function sendTavernBonuses()
	local onlinePlayers = GetPlayersInWorld( 2 ); --[[ 2-neutral, both horde and aliance]]
	local otchelnik_bonus = 0;
	local base_bonus = 0.5;
	for _, player in ipairs( onlinePlayers ) do
		if ( player:IsAFK() == false and player:GetPhaseMask() == 1) then
		--	Добавление репутации
			if SocialTime() then
				if (player:HasAura(otshelnik_aura)) then
					otchelnik_bonus = otchelnik_bonus + base_bonus;
				end
			end
		end;
	end

	if (otchelnik_bonus > 1) then
		local otchelnik_bonus_floor = math.floor(otchelnik_bonus)
		local otchelnik_bonus_ceil = math.ceil(otchelnik_bonus)
		SendMail('Otshelnik bonus!', 'Бонус за активность таверны "Печальный Отшельник" (квартал магов)', 25924, 36, 61, 20, 0, 0, 600057, otchelnik_bonus_floor);
		SendMail('Otshelnik bonus!', 'Бонус за активность таверны "Печальный Отшельник" (квартал магов)', 566, 36, 61, 20, 0, 0, 600057, otchelnik_bonus_ceil);
	end
end
CreateLuaEvent( sendTavernBonuses, 1800000, 0 )
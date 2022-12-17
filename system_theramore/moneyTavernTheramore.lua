-- бафы заведений
local aura_main_tavern   = 91320
local aura_granizon = 91323
local aura_amarosa  = 91322
local aura_ratusha  = 91321
local aura_garpia  = 91324
local aura_pirate = 91325

--[[Every 30 minutes calculate activity ]]
local function sendTavernBonusesTheramore()
	local onlinePlayers = GetPlayersInWorld( 2 ); --[[ 2-neutral, both horde and aliance]]
	local main_tavern_bonus = 0;
	local ratusha_bonus = 0;
	local garnizon_bonus = 0;
	local amarosa_bonus = 0;
	local garpia_bonus = 0;
	local pirate_bonus = 0;
	local base_bonus = 0.3;

	for _, player in ipairs( onlinePlayers ) do
		if ( player:IsAFK() == false and player:GetPhaseMask() == 1) then
		--	Добавление репутации
			if SocialTime() then
				if (player:HasAura(aura_main_tavern)) then
					main_tavern_bonus = main_tavern_bonus + base_bonus;
				end
				if (player:HasAura(aura_granizon)) then
					garnizon_bonus = garnizon_bonus + base_bonus;
				end
				if (player:HasAura(aura_amarosa)) then
					amarosa_bonus = amarosa_bonus + base_bonus;
				end
				if (player:HasAura(aura_ratusha)) then
					ratusha_bonus = ratusha_bonus + base_bonus;
				end
				if (player:HasAura(aura_garpia)) then
					garpia_bonus = garpia_bonus + base_bonus;
				end
				if (player:HasAura(aura_pirate)) then
					pirate_bonus = pirate_bonus + base_bonus;
				end
			end
		end;
	end --//

	if (main_tavern_bonus > 1) then
		local main_tavern_bonus_ceil = math.ceil(main_tavern_bonus)
		SendMail('Доход трактира!', 'Бонус за активность городского трактира', 82760, 36, 61, 20, 0, 0, 301396, main_tavern_bonus_ceil); -- 82760 персонаж Пакито (Самурайчик)
	end
	if (garnizon_bonus > 0) then
		local garnizon_bonus_ceil = math.ceil(garnizon_bonus)
		SendMail('Казна гарнизона', 'Бонус за активность гарнизона', 85977, 36, 61, 20, 0, 0, 301396, garnizon_bonus_ceil); -- 85977 персонаж Арчибальд  (Лорнсон)
	end
	if (amarosa_bonus > 0) then
		local amarosa_bonus_ceil = math.ceil(amarosa_bonus)
		SendMail('Доход Амароса', 'Бонус за активность клуба "Амароса"', 94604, 36, 61, 20, 0, 0, 301396, amarosa_bonus_ceil); -- 94604 персонаж Летиция (Флат)
	end
	if (ratusha_bonus > 0) then
		local ratusha_bonus_ceil = math.ceil(ratusha_bonus)
		SendMail('Казна ратуши', 'Бонус за активность ратуши', 98676, 36, 61, 20, 0, 0, 301396, ratusha_bonus_ceil); -- 98676 персонаж Джайна (Розальба)
	end
--	if (garpia_bonus > 0) then
--		local garpia_bonus_ceil = math.ceil(garpia_bonus)
--		SendMail('Доход Мертвой Гарпии', 'Бонус за активность Мертвой Гарпии', 2997, 36, 61, 20, 0, 0, 301396, garpia_bonus_ceil); -- 2997 персонаж Гук
--	end
	if (pirate_bonus > 0) then
		local pirate_bonus_ceil = math.ceil(pirate_bonus)
		SendMail('Дозод трактира', 'Бонус за активность трактира', 22059, 36, 61, 20, 0, 0, 301396, pirate_bonus_ceil); -- 22059 персонаж Оттар
	end
end
CreateLuaEvent( sendTavernBonusesTheramore, 1800000, 0 )

local playTime = { 12, 23 } -- С 13 по 00 (МСК) с учетом смещения серверного времени
local money = 600252

local function PayDay()
--	Функция выполняется раз в полчаса, всем игрокам отыгравшим час выдает мешок монет.
	
	local currentTime = tonumber( os.date("%H") )
	if not ( currentTime >= playTime[1] and currentTime <= playTime[2] ) then
		return
	end
	
--	Получение всех игроков в Кул-Тирасе
	local T = GetMapById(1643):GetPlayers(2)
	local T_secondaryMap = GetMapById(903):GetPlayers(2) -- Доп.карта с интерьерами
	for _, v in ipairs(T_secondaryMap) do 
		table.insert(T, v)
	end
	
	for _, player in ipairs(T) do
	--	Обработка каждого игрока
		if player:GetPhaseMask() == 1 then
			if ( player:GetZoneId() == 8717 ) or ( player:GetZoneId() == 8567 ) then
				if player:GetData("KT_HalfHour") then
				--	Игрок отыграл полчаса, выдаем награду
					if player:HasEmptySlot() then
						player:AddItem( money, 1 )
						player:SendBroadcastMessage("|cff629404[-X-] |cff8bad4cВы получаете мешочек монет за активную игру.")
					else
						SendMail( "Мешочек монет", "Мешочек монет не влез в ваши карманы и был выслан на почту.", player:GetGUIDLow(), 0, 41, 20, 0, 0, money, 1 )
						player:SendBroadcastMessage("|cff629404[-X-] |cff8bad4cМешочек монет не влез в ваши карманы и был выслан на почту.")
					end
					player:PlayDirectSound( 120, player )
					player:SetData( "KT_HalfHour", false )
				else
				--	Игрок только что отыграл полчаса с момента входа в игру ИЛИ выдачи последней награды
					player:SetData( "KT_HalfHour", true )
				end
			end
		end
	end
end
CreateLuaEvent( PayDay, 1800000, 0 )
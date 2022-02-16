--[[
ROLE_STAT_STRENGTH = 0;
ROLE_STAT_AGLILITY = 1;
ROLE_STAT_INTELLECT = 2;
ROLE_STAT_STAMINA = 3;
ROLE_STAT_VERSA = 4;
ROLE_STAT_WILL = 5;
ROLE_STAT_SPIRIT = 6;
ROLE_STAT_CHARISMA = 7;
ROLE_STAT_AVOID = 8;
ROLE_STAT_LUCK = 9;
ROLE_STAT_STEALTH = 10;
ROLE_STAT_INIT = 11;
ROLE_STAT_PERCEPT = 12;
]]
local AIO = AIO or require("AIO")
local GetCharStatInfo_Cooldown = 1
local ChangeCharStatInfo_Cooldown = 2
local ChangeCharHeight_Cooldown = 3
local CharacterStatsHandler = AIO.AddHandlers("CharacterStatsHandler", {})

local CHAR_CHANGE_COOLDOWN_MINUTES = 60*5

local function SendRolestatData(player)
	if player:GetLuaCooldown(GetCharStatInfo_Cooldown) ~= 0 then
		player:Print("Не так быстро.")
		return false
	end
	player:SetLuaCooldown(0.5,GetCharStatInfo_Cooldown)
	local guid = player:GetGUID()
	local q_pointStats = CharDBQuery("SELECT * FROM character_role_stats WHERE guid = "..tostring(guid))
	local p_data = {}
	if q_pointStats then
		local p_str = q_pointStats:GetInt32(1)
		local p_agl = q_pointStats:GetInt32(2)
		local p_int = q_pointStats:GetInt32(3)
		local p_stam = q_pointStats:GetInt32(4)
		local p_ver = q_pointStats:GetInt32(5)
		local p_will = q_pointStats:GetInt32(6)
		local p_spirit = q_pointStats:GetInt32(7)
		local p_charisma = q_pointStats:GetInt32(8)
		local p_avoid = q_pointStats:GetInt32(9)
		local p_luck = q_pointStats:GetInt32(10)
		local p_stealth = q_pointStats:GetInt32(11)
		local p_init = q_pointStats:GetInt32(12)
		local p_perc = q_pointStats:GetInt32(13)
		p_data = {p_str,p_agl,p_int,p_stam,p_ver,p_will,p_spirit,p_charisma,p_avoid,p_luck,p_stealth,p_init,p_perc}
	else
		p_data = {0,0,0,0,0,0,0,0,0,0,0,0,0}
	end
	
	
	local str = player:GetRoleStat(ROLE_STAT_STRENGTH)
	local agl = player:GetRoleStat(ROLE_STAT_AGLILITY)
	local int = player:GetRoleStat(ROLE_STAT_INTELLECT)
	local stam = player:GetRoleStat(ROLE_STAT_STAMINA)
	local ver = player:GetRoleStat(ROLE_STAT_VERSA)
	local will = player:GetRoleStat(ROLE_STAT_WILL)
	local spirit = player:GetRoleStat(ROLE_STAT_SPIRIT)
	local charisma = player:GetRoleStat(ROLE_STAT_CHARISMA)
	local avoid = player:GetRoleStat(ROLE_STAT_AVOID)
	local luck = player:GetRoleStat(ROLE_STAT_LUCK)
	local stealth = player:GetRoleStat(ROLE_STAT_STEALTH)
	local init = player:GetRoleStat(ROLE_STAT_INIT)
	local perc = player:GetRoleStat(ROLE_STAT_PERCEPT)
	local data = {str,agl,int,stam,ver,will,spirit,charisma,avoid,luck,stealth,init,perc}
	
	AIO.Handle(player,"CharacterStatsHandler","RecieveStats",data,p_data)
end

local function SendHeightData(player)
	if player:GetLuaCooldown(GetCharStatInfo_Cooldown) ~= 0 then
		player:Print("Не так быстро.")
		return false
	end
	player:SetLuaCooldown(0.5,GetCharStatInfo_Cooldown)
	local guid = player:GetGUID()
	local q_height = CharDBQuery("SELECT height FROM character_customs WHERE char_id = "..tostring(guid))
	local height = 1
	if q_height then
		height = q_height:GetString(0)
	end
	
	if tonumber(height) < 0.85 then
		height = 0.85
	end
	if tonumber(height) > 1.15 then
		height = 1.15	
	end
	AIO.Handle(player,"CharacterStatsHandler","RecieveHeight",height)
end
function CharacterStatsHandler.SendNewHeight(player,newHeight)

	if player:GetLuaCooldown(ChangeCharHeight_Cooldown) ~= 0 then
		player:Print("Вы можете изменять ваш рост не чаще чем раз в 5 секунд.")
		return false
	end
	player:SetLuaCooldown(5,ChangeCharHeight_Cooldown)
	if tonumber(newHeight) > 1.15 or tonumber(newHeight) < 0.85 then
		player:Print("Некорректное значение роста")
	end
	local guid = player:GetGUID()
	
	CharDBQuery("REPLACE INTO character_customs (char_id, height) VALUES ("..tostring(guid)..","..tostring(newHeight)..")")
	SendHeightData(player)
	player:SetScale(newHeight)
end

function CharacterStatsHandler.SendNewStats(player,newStats)

	if player:GetLuaCooldown(ChangeCharStatInfo_Cooldown) ~= 0 then
		player:Print("Вы можете обновлять ваши характеристики не чаще чем раз в 5 часов.")
		return false
	end
	player:SetLuaCooldown(1*60*CHAR_CHANGE_COOLDOWN_MINUTES,ChangeCharStatInfo_Cooldown)
	local mainSum = 0
	local socSum = 0
	for i,stat in ipairs(newStats) do --Валидация статов
		if tonumber(stat) == nil then
			player:Print("Значения характеристик некорректны.")
			return false
		end
		if i < 8 then
			if stat > 5 or stat < 0 then
				player:Print("Значения характеристик некорректны.")
				return false
			else
				mainSum = mainSum + stat
				if mainSum > 8 then
					player:Print("Значения характеристик некорректны.")
					return false
				end
			end
		else
			if stat > 8 or stat < 0 then
				player:Print("Значения характеристик некорректны.")
				return false
			else
				socSum = socSum + stat
				if socSum > 15 then
					player:Print("Значения характеристик некорректны.")
					return false
				end
			end
		end
	end
	local guid = player:GetGUID()
	local q_pointStats = CharDBQuery("SELECT * FROM character_role_stats WHERE guid = "..tostring(guid)) --Получение текущих очков сохраненных в базе
	local p_data = {}
	if q_pointStats then
		local p_str = q_pointStats:GetInt32(1)
		local p_agl = q_pointStats:GetInt32(2)
		local p_int = q_pointStats:GetInt32(3)
		local p_stam = q_pointStats:GetInt32(4)
		local p_ver = q_pointStats:GetInt32(5)
		local p_will = q_pointStats:GetInt32(6)
		local p_spirit = q_pointStats:GetInt32(7)
		local p_charisma = q_pointStats:GetInt32(8)
		local p_avoid = q_pointStats:GetInt32(9)
		local p_luck = q_pointStats:GetInt32(10)
		local p_stealth = q_pointStats:GetInt32(11)
		local p_init = q_pointStats:GetInt32(12)
		local p_perc = q_pointStats:GetInt32(13)
		p_data = {p_str,p_agl,p_int,p_stam,p_ver,p_will,p_spirit,p_charisma,p_avoid,p_luck,p_stealth,p_init,p_perc}
	else
		p_data = {0,0,0,0,0,0,0,0,0,0,0,0,0}
	end
	local guid = player:GetGUID()
	local values = tostring(guid)..","..table.concat(newStats, ",")
	
	for i,stat in ipairs(newStats) do
		local oldMainStat = p_data[i]
		local bonus = player:GetRoleStat(i-1) - oldMainStat
		local newValue = (stat+bonus)-player:GetRoleStat(i-1)
		if newValue > 0 then
			player:SetRoleStat(i-1,newValue,true)
		else
			player:SetRoleStat(i-1,-newValue,false)
		end
		
	end
	CharDBQuery("REPLACE INTO character_role_stats (guid, STR, AGI, INTEL, VIT, DEX, WILL, SPI, CHA, AVOID, LUCK, HID, INIT, PER) VALUES ("..values..")")
	SendRolestatData(player)
end


function CharacterStatsHandler.GetStats(player)
	SendRolestatData(player)
end

function CharacterStatsHandler.GetHeight(player)
	SendHeightData(player)
end
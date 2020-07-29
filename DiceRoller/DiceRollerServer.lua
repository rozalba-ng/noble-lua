
local AIO = AIO or require("AIO")

local DiceRoller = AIO.AddHandlers("DiceRollerHandlers", {})


local RollBuffer = {}
function DiceRoller.DiceRollerAddonRoll(player, mod1, mod2, mod3)
if tonumber(mod1) == nil or tonumber(mod2) == nil or tonumber(mod3) == nil then return end
if tonumber(mod1) > 9 then return end
RollBuffer.Summ = 0
RollBuffer.Curr = nil
RollBuffer.Random = nil
for i=1,tonumber(mod1) do
    RollBuffer.Random = math.random(mod2);
    if RollBuffer.Curr == nil then
        if (RollBuffer.Random * 100)/mod2 >= 90 or RollBuffer.Random == mod2 then
            RollBuffer.Curr = "|cFF4DB54D" .. RollBuffer.Random .. "|r"
        elseif (RollBuffer.Random * 100)/mod2 <= 10 or RollBuffer.Random == 1 then
            RollBuffer.Curr = "|cFFC43533" .. RollBuffer.Random .. "|r"
        else
            RollBuffer.Curr = RollBuffer.Random
        end
    else
        if (RollBuffer.Random * 100)/mod2 >= 90 or RollBuffer.Random == mod2 then
            RollBuffer.Curr = RollBuffer.Curr .. ", " .. "|cFF4DB54D" .. RollBuffer.Random .. "|r"
        elseif (RollBuffer.Random * 100)/mod2 <= 10 or RollBuffer.Random == 1 then
            RollBuffer.Curr = RollBuffer.Curr .. ", " .. "|cFFC43533" .. RollBuffer.Random .. "|r"
        else
            RollBuffer.Curr = RollBuffer.Curr .. ", " .. RollBuffer.Random
        end
    end
RollBuffer.Summ = RollBuffer.Summ + RollBuffer.Random
end

if player:IsInGroup() then
    local GroupRoll = player:GetGroup():GetMembers()
    local RowGroupRoll = #GroupRoll;
    for var=1,RowGroupRoll,1 do
        GroupRoll[var]:SendBroadcastMessage("|Hplayer:" .. player:GetName() .."|h|cffffffff[".. player:GetName() .."]|r|h выбрасывает " .. mod1 .. "d" .. mod2 .. " [" .. RollBuffer.Curr .. "] + " .. mod3 .. " = " .. RollBuffer.Summ + mod3)
    end
else
    player:SendBroadcastMessage("|Hplayer:" .. player:GetName() .."|h|cffffffff[".. player:GetName() .."]|r|h выбрасывает " .. mod1 .. "d" .. mod2 .. " [" .. RollBuffer.Curr .. "] + " .. mod3 .. " = " .. RollBuffer.Summ + mod3)
end
end






function DiceRoller.RaidRollerAddonRoll(player, mod1, mod2, mod3, mod4, name)
if tonumber(mod1) == nil or tonumber(mod2) == nil or tonumber(mod3) == nil or tonumber(mod4) == nil or name == nil then return end
if tonumber(mod1) > 9 then return end
if string.len(name) > 40 then return end
RollBuffer.Summ = 0
RollBuffer.Curr = nil
RollBuffer.Random = nil
for i=1,tonumber(mod1) do
    RollBuffer.Random = math.random(mod2);
    if RollBuffer.Curr == nil then
        if (RollBuffer.Random * 100)/mod2 >= 90 or RollBuffer.Random == mod2 then
            RollBuffer.Curr = "|cFF4DB54D" .. RollBuffer.Random .. "|r"
        elseif (RollBuffer.Random * 100)/mod2 <= 10 or RollBuffer.Random == 1 then
            RollBuffer.Curr = "|cFFC43533" .. RollBuffer.Random .. "|r"
        else
            RollBuffer.Curr = RollBuffer.Random
        end
    else
        if (RollBuffer.Random * 100)/mod2 >= 90 or RollBuffer.Random == mod2 then
            RollBuffer.Curr = RollBuffer.Curr .. ", " .. "|cFF4DB54D" .. RollBuffer.Random .. "|r"
        elseif (RollBuffer.Random * 100)/mod2 <= 10 or RollBuffer.Random == 1 then
            RollBuffer.Curr = RollBuffer.Curr .. ", " .. "|cFFC43533" .. RollBuffer.Random .. "|r"
        else
            RollBuffer.Curr = RollBuffer.Curr .. ", " .. RollBuffer.Random
        end
    end
RollBuffer.Summ = RollBuffer.Summ + RollBuffer.Random
end

if player:IsInGroup() then
    local GroupRoll = player:GetGroup():GetMembers()
    local RowGroupRoll = #GroupRoll;
    for var=1,RowGroupRoll,1 do
        GroupRoll[var]:SendBroadcastMessage("|Hplayer:" .. player:GetName() .."|h|cffffffff[".. player:GetName() .."]|r|h использует: |cffffffff[" .. name .. "]|r ".. mod1 .. "d" .. mod2 .. " [" .. RollBuffer.Curr .. "] + " .. mod3 .. " + " .. mod4 .. " = " .. RollBuffer.Summ + mod3 + mod4)
    end
else
    player:SendBroadcastMessage("|Hplayer:" .. player:GetName() .."|h|cffffffff[".. player:GetName() .."]|r|h использует: |cffffffff[" .. name .. "]|r ".. mod1 .. "d" .. mod2 .. " [" .. RollBuffer.Curr .. "] + " .. mod3 .. " + " .. mod4 .. " = " .. RollBuffer.Summ + mod3 + mod4)
end
end


function Roll_Split(R_pString, R_pPattern)
   local R_Table = {}
   local R_fpat = "(.-)" .. R_pPattern
   local R_last_end = 1
   local R_s, R_e, R_cap = R_pString:find(R_fpat, 1)
   while R_s do
      if R_s ~= 1 or R_cap ~= "" then
     table.insert(R_Table,R_cap)
      end
      R_last_end = R_e+1
      R_s, R_e, R_cap = R_pString:find(R_fpat, R_last_end)
   end
   if R_last_end <= #R_pString then
      R_cap = R_pString:sub(R_last_end)
      table.insert(R_Table, R_cap)
   end
   return R_Table
end

function string:split(sep)
    local sep, fields = sep or ",", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

local function OnPlayerCommand(event, player,command)
	if(string.find(command, " "))then
    local arguments = {}
    local arguments = string.split(command, " ")
        if (arguments[1] == "diceroll" and #arguments == 2 ) then
            RollCashList = Roll_Split(tostring(string.gsub(string.gsub(arguments[2], "d", "@"), "+", "@")),"@")
            if RollCashList then
                if tonumber(RollCashList[1]) == nil or tonumber(RollCashList[2]) == nil or tonumber(RollCashList[3]) == nil then
                    player:SendBroadcastMessage("Ошибка: Используйте конструкцию '1d20+0'.")
                    return
                else
                    DiceRoller.DiceRollerAddonRoll(player, tonumber(RollCashList[1]), tonumber(RollCashList[2]), tonumber(RollCashList[3]))
                end
            else
                player:SendBroadcastMessage("Ошибка: Используйте конструкцию '1d20+0'.")
                return
            end
        end
	end
	return false
end

RegisterPlayerEvent(42, OnPlayerCommand)
--[[function string:split(sep)
    local sep, fields = sep or ",", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end]] --// Не локальная, уже есть в одном из файлов

local function GeneratePseudoNick()
local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
local length = 12
local randomString = ''

math.randomseed(os.time())

charTable = {}
for c in chars:gmatch"." do
    table.insert(charTable, c)
end

for i = 1, length do
    randomString = randomString .. charTable[math.random(1, #charTable)]
end
    return randomString
end

local function DeleteCharacterName(event, player,command)
if(player:GetGMRank() > 1)then    
    local arguments = {}
    local arguments = string.split(command, " ")
    if (arguments[1] == "deletename" and #arguments == 2 ) then
        CharDBQuery("UPDATE `characters`.`characters` SET `at_login`=1 WHERE  `name`='".. tostring(arguments[2]) .."';");
        CharDBQuery("UPDATE `characters`.`characters` SET `name`='".. GeneratePseudoNick() .. "' WHERE  `name`='".. tostring(arguments[2]) .."';");
        player:SendBroadcastMessage("Ник персонажа: [" .. tostring(arguments[2]) .. "] удален.")
    end
end	

end
RegisterPlayerEvent(42, DeleteCharacterName)
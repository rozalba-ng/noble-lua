--[[
	Функция возвращает случайный из переданных в неё аргументов.
]]

function Roulette(...)
    local t = {...}
    math.randomseed( os.time() )
    return t[ math.random( 1, #t ) ]
end

--[[	НЕ РАБОТАЕТ ПОЧЕМУ-ТО
function WorldObject:UpdatePhaseMask()
	local phase = self:GetPhaseMask()
	if ( phase ~= 1073741824 ) then
		self:SetPhaseMask(1073741824)
		self:SetPhaseMask(phase)
	else
		self:SetPhaseMask(536870912)
		self:SetPhaseMask(1073741824)
	end
end
]]

function table.find( T, val )
    for key, data in pairs(T) do
        if ( data == val ) then
            return key
        end
    end
    return nil
end

function Player:HasEmptySlot()
	for slot = 23,38 do
		if not self:GetItemByPos( 255, slot ) then
			return true
		end
	end
	return false
end
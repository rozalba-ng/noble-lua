--[[
	Функция возвращает случайный из переданных в неё аргументов.
]]

function Roulette(...)
    local t = {...}
    math.randomseed( os.time() )
    return t[ math.random( 1, #t ) ]
end
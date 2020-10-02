
function ReadFlag( flag )
    local binary = {}
    repeat
        table.insert( binary, (flag%2) )
        flag = math.floor( flag/2 )
    until flag == 0
    local result = {}
    for i = 1,#binary do
        local number = binary[i] * ( 2^(i-1) )
        if number > 0 then
            table.insert( result, number )
        end
    end
    if #result > 0 then
        return result,table.concat( result, " " )
    else
        return false
    end
end

function FindFlag( self, flag )
    if type( self ) == "table" then
    	for _, val in pairs( self ) do
    		if val == flag then
    			return true
    		end
        end
		return false
	elseif type( self ) == "number" then
		local flags = ReadFlag( self )
		return FindFlag( flags, flag )
	else
		return nil
    end
end
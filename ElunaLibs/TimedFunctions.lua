local argsList = {}


function execFunc(timerId)
	local func = argsList[timerId].funcToExec
	func(unpack(argsList[timerId].args))
end

function timedFunction(func,secCount,...)
	local timerId = CreateLuaEvent(execFunc, secCount*1000,1)
	argsList[timerId] = {}
	argsList[timerId] = { funcToExec = func, args = {} }
	for i,v in ipairs(table.pack(...)) do
        table.insert(argsList[timerId].args,v)
    end
end


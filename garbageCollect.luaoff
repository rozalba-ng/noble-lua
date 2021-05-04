--	УДАЛЕНИЕ МУСОРА
--	Раз в 5 минут забывает переменные, на которые ничего не ссылается.
local function garbageCollect()
	print("Garbage collection..")
	collectgarbage()
end
CreateLuaEvent( garbageCollect, 300000, 0 )
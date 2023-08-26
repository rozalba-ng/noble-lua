local AIO = AIO or require("AIO")

local GET_ROPS = "SELECT id, char_id, title, nop FROM character_nops"
local GET_CHAR_ID = "SELECT guid FROM characters"

function TestRop()
	local results = queryDatabase(GET_ROPS)
	
	if results then
        for _, row in ipairs(results) do
            local id = row.id
            local char_id = row.char_id
            local title = row.title
            local nop = row.nop

            if nop == 2501 then
                print(string.format("id: %d, char_id: %d, title: %s, nop: %d", id, char_id, title, nop))
            end
        end
    else
        print("Ошибка")
    end
end
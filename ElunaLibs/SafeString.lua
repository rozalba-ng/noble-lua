
function string:Safe()
	local safe_text = ""
	for S in self:gmatch("[^\"\'\\]") do
		safe_text = safe_text..S
	end
	return safe_text
end
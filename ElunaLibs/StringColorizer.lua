
cRed = "|cffff0000"
cGreen = "|cff00ff00"
cBlue = "|cff0000ff"
cWhite = "|cffffffff"
cR = "|r"




colorTable = { 	["red"] = cRed,
				["green"] = cGreen,
				["blue"] = cBlue,
				["white"] = cWhite}
				
			
function string:color(colorName)
	return colorTable[colorName]..self.."|r"
end

function toColorString(data,colorName)
	return tostring(data):color(colorName)
end

local queryTable = {}
local textEvents = {}



local function InvokePrint(eventId, delay, repeats)
	
	local players = textEvents[eventId].players
	local text = textEvents[eventId].text
	for i, playerName in pairs(players) do
		print(playerName)
		local player = GetPlayerByName(playerName)
		if player then
			player:Print(text)
		end
	end
end

function QueryPrint(players)
	local query = {}
	query.texts = {}
	query.players = {}
	if players then
		for i,player in pairs(players) do
			table.insert(query.players, player:GetName())
			
		end
		
		function query:Add(text,delay)
			local textData = {}
			textData.text = text
			textData.delay = delay
			table.insert(self.texts, textData)
		end
		function query:Invoke()
			local startDelay = 0
			for i, textData in pairs(self.texts) do
				local delay = textData.delay
				local text = textData.text
				startDelay = startDelay + delay
				local eventId = CreateLuaEvent(InvokePrint,startDelay,1)
				
				textEvents[eventId] = {}
				textEvents[eventId].players = self.players
				textEvents[eventId].text = text
			end
		end
	end
	return query
end
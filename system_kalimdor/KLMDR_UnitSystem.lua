

local lastTimeCheck = {}


function TroopDied(event, creature, killer)
	creature:Delete()
end

function TroopAiUpdate(event, creature, diff)
	local playerList = creature:GetPlayersInRange(100)
	if not creature:GetVictim() then
		local crFid = KAL_unitList[creature:GetEntry()]
		if playerList then
			for i, player in pairs(playerList) do
				if KAL_playerInfo[player:GetName()] then
					local fid = KAL_playerIn	fo[player:GetName()].fid
					--print("crFid "..crFid.." fid "..fid)
					if crFid ~= fid then
						creature:Attack(player)
						--return true
					end
				end
			end
		end
	end
end

for i = 1, #KAL_unitListOnFrac do
	RegisterCreatureEvent( KAL_unitListOnFrac[i], 4, TroopDied )
	RegisterCreatureEvent( KAL_unitListOnFrac[i], 7, TroopAiUpdate ) 
	KAL_unitList[KAL_unitListOnFrac[i]] = i
end



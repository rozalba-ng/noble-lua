
PetControlAIO = PetControlAIO or {}

--[[
	������ �� ������� PetControlAIO ��� � ����� PetControl_Server.lua
]]

function PetControlAIO.PlayerCommands( _, player, command )
	if command == "pet" then -- ����� �������
		player:SendBroadcastMessage("|cffFF4500(!)|r ��� ������������� ���� ������ ����� ����� �������� � ����.\n|cff00FF7F.pet say [�����]|r - ������� �� ���� ��������.\n|cff00FF7F.pet emote [�����]|r - ��������� ������ �� ���� ��������.\n|cff00FF7F.pet stay|r - ������� ����� �� �����.\n|cff00FF7F.pet follow|r - ������� ������� �� ����.\n|cff00FF7F.pet play [ID] {������}|r - ������� ����������� ��������.\n���� �� ����� |cff00FF7F{������}|r ������� ����� �������� �������� ����� ����������� ����������.\n|cff00FF7F.pet pos [0, 1 ��� 3]|r - ������, ������ ��� ������.\n|cff00FF7F.pet tele|r - �������� �������� � ���������.")
	elseif string.find( command, " " ) then
		command = string.split( command, " " )
		if command[1] == "pet" then -- �������
			if command[2] == "say" then
				if command[3] then
					local text = ""
					for i = 3, #command do
						text = text..tostring(command[i]).." "
					end
					PetControlAIO.Say( player, text )
					return
				end
			----------
			elseif command[2] == "emote" then
				if command[3] then
					local text = ""
					for i = 3, #command do
						text = text..tostring(command[i]).." "
					end
					PetControlAIO.Emote( player, text )
					return
				end
			----------
			elseif command[2] == "stay" then
				PetControlAIO.Follow( player, 0 )
				return
			----------
			elseif command[2] == "follow" then
				PetControlAIO.Follow( player, 1 )
				return
			----------
			elseif command[2] == "play" then
				if command[3] and tonumber( command[3] ) then
					local creature = player:GetSelection()
					if creature and ( creature:GetOwner() == player ) and not ( creature:HasAura(91072) ) then
						if command[4] then
							creature:EmoteState( command[3] )
						else
							creature:Emote( command[3] )
						end
						return
					else player:SendNotification("�� �� ������ ��������� ���� ���������.") end
				end
			----------
			elseif command[2] == "pos" then
				if command[3] and tonumber( command[3] ) then
					PetControlAIO.Byte1( player, command[3] )
					return
				end
			----------
			elseif command[2] == "tele" then
				local creature = player:GetSelection()
				if creature and ( creature:GetOwner() == player ) and not ( creature:HasAura(91072) ) then
					local x,y,z,o = player:GetLocation()
					creature:NearTeleport(x,y,z,o)
					return
				else player:SendNotification("�� �� ������ ��������� ���� ���������.") end
			----------
			else
				player:SendBroadcastMessage("|cffFF4500[!!]|r �� �������� � ��������� �������.\n����������� |cff00FF7F.pet|r ��� ��������� ��������� ��� ������.")
			end
		end
	end
end
RegisterPlayerEvent( 42, PetControlAIO.PlayerCommands ) -- PLAYER_EVENT_ON_COMMAND
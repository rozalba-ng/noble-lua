
--	NPC ���������� ���� ���������� (���� ���� � ������� 25 �����)
local entry_npc = 123
--	NPC ��������� ���� � ������� (��� �������� �������)
local entry_bonus_npc = 123

--[[Every 15 minutes player recieve 10 copper. If pleyer is in guild, he auto-deposit 10 copper to guild, but resieve 5 additional copper]]
local function calculateMoney()
	local onlinePlayers = GetPlayersInWorld( 2 ); --[[ 2-neutral, both horde and aliance]]		
	for _, player in ipairs( onlinePlayers ) do	
		if ( player:IsAFK() == false ) then
		--	���������� �����
			player:ModifyMoney( 40 );
			local guild = player:GetGuild();
			if ( guild ~= nil ) then		
				player:ModifyMoney( -5 );
				guild:DepositBankMoney( player, 15 )
			end
		--	���������� ���������
			if SocialTime() then
				local f
				if player:GetQuestStatus( 110052 ) == 6 then
				--	����� �������� ����� �� ���������� � ���� ����������
					f = thiefs_faction
				elseif player:GetQuestStatus( 110053 ) == 6 then
				--	����� �������� ����� �� ���������� � ����������� ���������
					f = law_faction
				end
				if f and player:GetPhaseMask() == 1 then
				--	����� �������� ���� �� ������� � ��������� � 1 ����
					local zone, r = player:GetZoneId(), 0
					if zone == 1519 then
					--	����� � ����������
						r = 3
					elseif zone == 10237 or zone == 10214 or zone == 10197 or zone == 10160 or player:GetNearestCreature( 25, entry_npc ) then
					--	����� ������ �� ��������
						r = 2
					end
					if ActionTime() then
					--	���� ����� ����������� - ��� ��������� �����.
						r = r + 2
					end
					if player:GetNearestCreature( 30, entry_bonus_npc ) then
					--	���� ����� ���� ��� �������� �����
						r = r + 2
					end
					--	���������� ���������
					player:SetReputation( f, player:GetReputation( f ) + r )
				end
			end
		end;	  
	end
end
CreateLuaEvent(calculateMoney, 5000, 0);
--CreateLuaEvent(calculateMoney, 900000, 0);
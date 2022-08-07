function Player:Print(str)
	self:SendBroadcastMessage(str)
end
InterfaceExt = InterfaceExt or {}
local interfaceList = {}
local interfaceLastId = 0

function InterfaceExt.OnClose(player, ...)
	player:GossipComplete()
end

function RowObject(rowId,text,code,popup)
	local row = {icon = 0, msg = text, intid = rowId, code = code, popup = popup}
	function row:SetIcon(iconId)
		self.icon = iconId
	end
	return row
end

function Player:CreateInterface()
	local id = interfaceLastId + 1
	local interface = {}
	interface.connectedFunctions = {}
	interface.lastRowId = 1
	interface.rows = {}
	interface.player_name = self:GetName()
	function interface:AddRow(text, funcToCall, willClose, ...)		
		self.connectedFunctions[self.lastRowId] = {}
		self.connectedFunctions[self.lastRowId].func = funcToCall
		self.connectedFunctions[self.lastRowId].args =  table.pack(...)

		self.connectedFunctions[self.lastRowId].willClose = willClose
		local row = RowObject(self.lastRowId,text,false,nil)
		
		table.insert(self.rows,row)
		self.lastRowId = self.lastRowId + 1
		return row
	end
	function interface:AddAskRow(text, funcToCall, willClose, ...)		
		self.connectedFunctions[self.lastRowId] = {}
		self.connectedFunctions[self.lastRowId].func = funcToCall
		self.connectedFunctions[self.lastRowId].args =  table.pack(...)

		self.connectedFunctions[self.lastRowId].willClose = willClose
		local row = RowObject(self.lastRowId,text,true,nil)
		
		table.insert(self.rows,row)
		self.lastRowId = self.lastRowId + 1
		return row
	end
	function interface:AddClose(name)
		name = name or "Закрыть"
		self.connectedFunctions[self.lastRowId] = {}
		self.connectedFunctions[self.lastRowId].func = InterfaceExt.OnClose
		self.connectedFunctions[self.lastRowId].args =  arg or {}
		self.connectedFunctions[self.lastRowId].willClose = true
		local row = RowObject(self.lastRowId,name,false,nil)
		row:SetIcon(3)
		table.insert(self.rows,row)
		self.lastRowId = self.lastRowId + 1
		return row
	end
	function interface:AddPopupRow(text, funcToCall,popupText,willClose,...)
		self.connectedFunctions[self.lastRowId] = {}
		self.connectedFunctions[self.lastRowId].func = funcToCall
		self.connectedFunctions[self.lastRowId].args =  table.pack(...)
		self.connectedFunctions[self.lastRowId].willClose = willClose
		local row = RowObject(self.lastRowId,text,false,popupText)
		table.insert(self.rows,row)
		self.lastRowId = self.lastRowId + 1
		return row
	end
	
	function interface:Click(intid,object,code)
		local player = GetPlayerByName(self.player_name)
		local func = self.connectedFunctions[intid].func
		if code == nil then
			func(player,object,intid,unpack(self.connectedFunctions[intid].args))
		else
			func(player,object,intid,code,unpack(self.connectedFunctions[intid].args))
		end
		if self.connectedFunctions[intid].willClose then
			player:GossipComplete()
		end
	end
	function interface:Send(menuText,sender)
		local player = GetPlayerByName(self.player_name)
		player:GossipClearMenu()
		player:GossipSetText(menuText,909808707)
		for i,v in pairs(self.rows) do
			player:GossipMenuAddItem(v.icon,v.msg,1,v.intid,v.code, v.popup)
		end
		player:GossipSendMenu(909808707,sender)
	end
	interfaceList[self:GetName()] = interface
	return interface
end

function Player:CurrentInterface()
	return interfaceList[self:GetName()]
end

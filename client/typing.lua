addEventHandler("onClientCharacter", root, function(symbol)
	if self.state then else return end
	if not self.typing then return end
	if dxGetTextWidth(self.edit..""..symbol, 0.5, self.fonts["editbox"]) < radio.editWeight then
		self.edit = self.edit..""..symbol
		RadioGetResult(self.edit)
	end
end)

local backspaceTimer
local subTimer
addEventHandler("onClientKey", root, function(key, state)
	if self.state then else return end
	if not self.typing then return end
	if key == "backspace" then
		if state then
			self.edit = utf8.sub(self.edit, 1, utf8.len(self.edit) - 1)

			if isTimer(backspaceTimer) then
				killTimer(backspaceTimer)
			end
			if isTimer(subTimer) then
				killTimer(subTimer)
			end

			backspaceTimer = setTimer(function()
				if state then
					subTimer = setTimer(function()
						self.edit = utf8.sub(self.edit, 1, utf8.len(self.edit) - 1)
					end, 50, 0)
				else
					if isTimer(backspaceTimer) then
						killTimer(backspaceTimer)
					end
					if isTimer(subTimer) then
						killTimer(subTimer)
					end
				end
			end, 200, 1)
		else
			if isTimer(backspaceTimer) then
				killTimer(backspaceTimer)
			end
			if isTimer(subTimer) then
				killTimer(subTimer)
			end
		end
	end
end)
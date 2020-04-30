sx, sy = guiGetScreenSize()
px = sx/1920

function isCursor(posX, posY, width, height)
	if isCursorShowing() then
		local mouseX, mouseY = getCursorPosition()
		local clientW, clientH = guiGetScreenSize()
		local mouseX, mouseY = mouseX * clientW, mouseY * clientH
		if (mouseX > posX and mouseX < (posX + width) and mouseY > posY and mouseY < (posY + height)) then
			return true
		end
	end
	return false
end

function round(value)
	return math.ceil(value)
end
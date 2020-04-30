--Radio Search

function getItemData(item)
	local startPos = utf8.find(item, "{");
	local endPos = utf8.find(item, "}");
	if startPos and endPos then
		local musicTable = fromJSON(utf8.sub(item, startPos, endPos))
		return musicTable
	end
end

function downloadImageCallback(data, errnum, id)
	if data ~= "ERROR" then
		self.sendImage(id, data)
	else
		outputDebugString("Error getting track cover - code "..tostring(errnum), 2)
	end
end

function searchCallback(result, errnum)
	if result ~= "ERROR" then
		local sendTable = {};
		local start = utf8.find(result, '<ul class="tracks__list">')
		local text
		local endpos = 0
		local soundsCount = 0

		if start then
			text = utf8.sub(result, start)
			local musics = utf8.gmatch(text, 'class="tracks__item track mustoggler"')
			for k in musics do
				local start, endPosition = utf8.find(text, k, endpos)
				local _, endPositionB = utf8.find(text, "</li>", start)
				local currentSection = utf8.sub(text, start, endPositionB)

				endpos = endPosition
				soundsCount = soundsCount + 1
				table.insert(sendTable, getItemData(currentSection))
			end
		end
		if soundsCount > 0 then
			self.sendResult(sendTable)
			for k,v in ipairs(sendTable) do
				local id = utf8.sub(v.id, 10)
				fetchRemote("https://ruq.hotmo.org/"..v.img, downloadImageCallback, "", false, id)
			end
		end
	else
		outputDebugString("Error getting tracks list - code "..tostring(errnum), 2)
	end
end

function self.searchTracks(text)
	for k,v in ipairs(getRemoteRequests(getThisResource())) do
		abortRemoteRequest(v)
	end
	fetchRemote("https://ruq.hotmo.org/search?q="..utf8.gsub(text, " ", "+"), searchCallback, "", false)
end

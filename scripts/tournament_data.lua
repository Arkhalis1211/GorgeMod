--[[
	Fox: data'll look like this
	{
		{
			time = 0,
			time_played = 1000,
			score = 0,
			data = {}
			players = {
				["KU_HMMM"] = {
					name = "fox",
					steamid = "91283012893120",
					character = "wilson",
					data = {},
				}
			}
		}
	}
	
	
]]

TournamentData = {
	file = "gorge_tournament.txt",
	data = {},
}

function TournamentData:Save()
	local f
	local content
	
	if kleifileexists and kleifileexists(self.file) then
		-- f = io.open(self.file, "a") This doesn't work for some strange reason.....
		f = io.open(self.file)
		if f then
			content = f:read("*all")
			f:close()
		end
	end
	
	f = io.open(self.file, "w")
	
	if f then
		if content then
			f:write(content.."\n")
		end
	
		f:write(self:Get())
		f:close()
		print("[Gorge Tournament]: Saved game results to %s.", self.file)
	else
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("[Gorge Tournament]: Failed to write %s. Please, check your permissions for mod folder.", self.file)
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	end
end

function TournamentData:ClearData()
	self.data = {}
	self:Save()
end

function TournamentData:SaveData(data)
	self.data = data
	self:Save()
end

function TournamentData:Get()
	local saved = {}
	
	local function add(...)
		table.insert(saved, ...)
	end
	
	add("\n==========================================================")
	add(string.format("Game played on (%s) with score: %d. Game took: %s Outcome: %s\nShared stats:", self.data.time, self.data.score, self.data.time_played, (self.outcome and "Won" or "Lost")))
	for name, val in pairs(self.data.data) do
		add(string.format("\t%s: %s", tostring(name), tostring(val)))
	end
	add("Players:")
	for id, pdat in pairs(self.data.players) do
		add(string.format("\nName: %s, Userid: %s, Steam ID: %s, Character: %s\nStats:", tostring(pdat.name), id, tostring(pdat.netid), tostring(pdat.prefab or pdat.lobbycharacter)))
		for name, val in pairs(pdat.stats) do
			add(string.format("\t%s: %s", tostring(name), tostring(val)))
		end
	end
	
	return table.concat(saved, "\n")
end

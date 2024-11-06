--[[
	cook_large
	cook_all_stations +
	cook_silver +
	farm_sow_all +
	farm_fertilize +
	farm_till +
	gather_sap +
	gather_crab +
	gather_spice +
	gather_safe +
	quag_encore_all_stations_large +
]]

require("tournament_data")

local COIN_POINTS =
{
	[1] = { [1] = 1,   [1] = 1   },
	[2] = { [1] = 28,  [2] = 84  },
	[3] = { [1] = 98,  [2] = 294 },
	[4] = { [1] = 343, [2] = 343 }
}

local function AddAchievement(tbl, id)
	if id and not tbl[id] then
		tbl[id] = true
	end
end

local function RemoveAchievement(tbl, id)
	if id and tbl[id] then
		tbl[id] = nil
	end
end

local QuagmireAnalytics = Class(function(self, inst)
	self.inst = inst

	self.start_time = 0
	self.round_time = 0

	self.player_data = {}

	self.possible_stats = deepcopy(TUNING.GORGE.BEST_STATS)

	--UpdateStat(nil, "", 1)
	self.stats = {
		tributes_success = 0,
		tributes_salted = 0,
		tributes_silvered = 0,
		tributes_failed = 0,
		meals_burnt = 0,
		coins = {0, 0, 0, 0},
		meals_made = 0,
		logs = 0,
		points = 0,
	}
	
	self.tributes = {}

	self.achievementlist = EventAchievements:GetAchievementsCategoryList("quagmire", 1)

	inst:ListenForEvent("lobbyplayerspawndelay", function()
		self:InitPlayers()
		self.start_time = GetTime()
	end)

	inst:ListenForEvent("ms_gameend", function(w, win)
		self.round_time = self:GetGameTime()
		local outcome = self:GetMatchOutcome()
		self:UpdateAchievements(nil, {outcome = outcome}, true)
	end)

	inst:ListenForEvent("ms_quagmirerecipeappraised", function(w, data)
		if not data then
			return
		end

		-- For achievements
		if data.matched then
			self.stats.tributes_success = self.stats.tributes_success + 1
		else
			self.stats.tributes_failed = self.stats.tributes_failed + 1
		end

		for i, count in ipairs(data.coins) do
			self.stats.coins[i] = self.stats.coins[i] + count

			-- Accumulate points
			if i == 1 then
				self.stats.points = self.stats.points + count
			else
				if count == 1 then
					self.stats.points = self.stats.points + COIN_POINTS[i][1]
				elseif count > 1 then
					self.stats.points = self.stats.points + COIN_POINTS[i][2]
				end

				if count > 2 then
					print("[QuagmireAnalytics] Warning: got more then 2 coins:", i)
				end
			end
		end
		
		self.tributes[data.product] = (self.tributes[data.product] or 0) + 1

		self:UpdateAchievements("tributes", data)
		self:UpdateAchievement("quag_encore_meaty", nil, {ingredients = data.recipe.ingredients or {}})
		self:UpdateAchievement("quag_encore_veggie", nil, {ingredients = data.recipe.ingredients or {}})
	end)

	rawset(_G, "UpdateAchievement", function(...)
		self:UpdateAchievement(...)
	end)

	rawset(_G, "UpdateStat", function(...)
		self:UpdateStat(...)
	end)

	if CHEATS_ENABLED then
		rawset(_G, "DebugScratchpad", function(id)
			printwrap("" , self.player_data[id or TheNet:GetUserID()].scratchpad)
		end)
		
		rawset(_G, "DebugStats", function(id)
			printwrap("" , self.player_data[id or TheNet:GetUserID()].stats)
		end)
	end
end)

function QuagmireAnalytics:InitPlayers()
	self.shared_scratchpad = {}
	self.shared_achievements = {}

	self._seenplayers = {}
	for i, data in ipairs(TheNet:GetClientTable()) do
		if not TheNet:IsDedicated() or not data.performance then
			table.insert(self._seenplayers, data)
		end
	end

	for i, data in ipairs(TheNet:GetClientTable()) do
		if not TheNet:IsDedicated() or not data.performance then
			self.player_data[data.userid] = {
				netid = data.netid,
				name = data.name,
				lobbycharacter = data.lobbycharacter,
				prefab = data.prefab,
				userid = data.userid,
				colour = data.colour,

				portrait = data.vanity[1],

				stats = {
					tributes = 0,
					
					meals_made = 0,
					meals_burnt = 0,
					meals_saved = 0,
					buys = 0,
					
					crops_farmed = 0,
					crops_planted = 0,
					crops_picked = 0,
					crops_rotten = 0,

					logs = 0,
					herbs_picked = 0,

					stepcounter = 0,
				},
				achievements = {},
				scratchpad = {},
			}
		end
	end
end

function QuagmireAnalytics:AllAchievements(category, fn)
	for _, adata in ipairs(self.achievementlist) do
		if not category or category == adata.category then
			for _, data in ipairs(adata.data) do
				fn(data, adata)
			end
		end
	end	
end

function QuagmireAnalytics:UpdateAchievements(category, achievement_data, gameend)
	for id, user in pairs(self.player_data) do
		self:AllAchievements(category, function(data, category)
			achievement_data.analytics = self
			achievement_data.statstracker = self
			if gameend then
				if data.endofmatchfn then
					if data.endofmatchfn(user, achievement_data, user.scratchpad, self.shared_scratchpad) then
						-- table.insert(user.achievements, {desc = data.achievementid, val = 0})
						AddAchievement(user.achievements, data.achievementid)
					else
						RemoveAchievement(user.achievements, data.achievementid)
					end
				end
			elseif data.testfn then
				if data.testfn(user, achievement_data, user.scratchpad, self.shared_scratchpad) then
					-- table.insert(user.achievements, {desc = data.achievementid, val = 0})
					AddAchievement(user.achievements, data.achievementid)
				else
					RemoveAchievement(user.achievements, data.achievementid)
				end
			end
		end)
	end
end

-- Fox: We'll have to update shared manually since for some reason they're in wrong category 
function QuagmireAnalytics:UpdateAchievement(id, userid, data, shared)
	local achievement = EventAchievements:FindAchievementData("quagmire", 1, id)
	if not achievement then
		return
	end
	print("UpdateAchievement", id, data)
	if not data then
		data = {
			statstracker = self,
			analytics = self,
		}
	elseif type(data) == "table" then
		data.statstracker = self
		data.analytics = self
	end
	
	if userid then
		if achievement.testfn(self.player_data[userid], data, self.player_data[userid].scratchpad) then
			-- table.insert(self.player_data[userid].achievements, {desc = id, val = 0})
			AddAchievement(self.player_data[userid].achievements, id)
			print("AddAchievement", id)
		else
			RemoveAchievement(self.player_data[userid].achievements, id)
		end
		printwrap("self.player_data[userid].achievements", self.player_data[userid].achievements)
	elseif achievement.shared_progress_fn then
		if achievement.shared_progress_fn(data, self.shared_scratchpad) then
			-- table.insert(self.shared_achievements, {desc = id, val = 0})
			AddAchievement(self.shared_achievements, id)
		else
			RemoveAchievement(self.shared_achievements, id)
		end
	end
end

function QuagmireAnalytics:PushMatchResults()
	for id, data in pairs(self.player_data) do
		local ctable = TheNet:GetClientTableForUser(id)
		if ctable then
			data.prefab = ctable.prefab

			data.base = ctable.base_skin
			data.body = ctable.body_skin
			data.hand = ctable.hand_skin
			data.legs = ctable.legs_skin
			data.feet = ctable.feet_skin
		end
	end

	local field_order = {"userid", "netid", "character", "cardstat"}
	
	local player_stats = {}
	local field_order_established = false
	
	for userid, data in pairs(self.player_data) do
		local current_player_stats = {}
		table.insert(current_player_stats, userid)
		table.insert(current_player_stats, data.netid)
		table.insert(current_player_stats, data.prefab)
		table.insert(current_player_stats, self:GetBestStat(userid)[1] or "<nil>")
		
		for i, stat in ipairs(TUNING.GORGE.FIELDS_ORDER) do
			table.insert(current_player_stats, math.floor(data.stats[stat] or 0))
			if not field_order_established then
				table.insert(field_order, stat)
			end
		end
		field_order_established = true			
		table.insert(player_stats, current_player_stats)
	end
	
	TheFrontEnd.match_results.mvp_cards = self:GetMvpAwards()
	TheFrontEnd.match_results.wxp_data = self:GetAwardedWxp()
	TheFrontEnd.match_results.player_stats = {gametype = "ReGorgeItated-"..(Settings.gorge_game_mode or "default"), session = TheWorld.meta.session_identifier, data = player_stats, fields = field_order}
	TheFrontEnd.match_results.outcome = self:GetMatchOutcome()

	self:DumpGameResult()
end

function QuagmireAnalytics:GetMatchStat(name)
	return self.stats[name]
end

function QuagmireAnalytics:GetGaveDuplicateTributed()
	for food, count in pairs(self.tributes) do
		if count > 2 then
			return true
		end
	end
	return false
end

function QuagmireAnalytics:GetStatTotal(stat, id)
	if id then	
		if not self.player_data[id] then
			print("ERROR: no player in self.player_data! ", CalledFrom())
		end
		return self.player_data[id] and self.player_data[id].stats[stat] or 0
	else
		local total = 0
		
		for id, data in pairs(self.player_data) do
			total = total + (data.stats[stat] or 0)
		end
		
		return total
	end
end

function QuagmireAnalytics:GetAwardedWxp()
	local wxp_data = {}
	
	if CHEATS_ENABLED then
		printwrap("player", self.player_data[TheNet:GetUserID()].achievements)
		printwrap("shared", self.shared_achievements)
	end
	
	for id, data in pairs(self.player_data) do
		wxp_data[id] = {
			new_xp = 0,
			match_xp = 0,
			earned_boxes = 0,
			details = {}, -- Fox: Maybe it's better to deepcopy it?
		}
		for achievement, _ in pairs(data.achievements) do
			table.insert(wxp_data[id].details, {desc = achievement, val = 0})
		end
		for achievement, _ in pairs(self.shared_achievements) do
			table.insert(wxp_data[id].details, {desc = achievement, val = 0})
		end
	end
	
	
	if CHEATS_ENABLED then
		printwrap("wxp_data", wxp_data)
	end

	return wxp_data
end

function QuagmireAnalytics:UpdateStat(userid, stat, delta)
	if userid then
		if self.player_data[userid] and self.player_data[userid].stats[stat] then
			self.player_data[userid].stats[stat] = self.player_data[userid].stats[stat] + delta
		end
	elseif self.stats[stat] then
		self.stats[stat] = self.stats[stat] + delta
	end
end

function QuagmireAnalytics:GetBestStat(userid)
	if self.player_data[userid].beststat then
		return self.player_data[userid].beststat
	end

	if GetTableSize(self.possible_stats) == 0 then
		self.possible_stats = deepcopy(TUNING.GORGE.BEST_STATS)
	end

	local stats = self.player_data[userid].stats
	local stats_points = {}
	for stat, data in pairs(self.possible_stats) do
		stats_points[stat] = {
			tier = (data.next_tier and stats[stat] >= data.next_tier) and 2 or nil,
			value = stats[stat] * data.points,
		}
	end

	local best_stat = {}
	local best_value = 0

	for stat, data in pairs(stats_points) do
		if best_value < data.value then
			best_stat = {data.tier and stat .. data.tier or stat, stats[stat]}
			best_value = data.value
		end
	end
	
	self.player_data[userid].beststat = best_stat
	
	return best_stat
end

function QuagmireAnalytics:GetMvpAwards()
	local result = {}

	for id, data in pairs(self.player_data) do
		if TheNet:GetClientTableForUser(id) then
			local best_stat = self:GetBestStat(id)
			table.insert(result, {
				user = {
					base = data.base,
					body = data.body,
					hand = data.hand,
					legs = data.legs,
					feet = data.feet,
					portrait = data.portrait,

					lobbycharacter = data.lobbycharacter,
					prefab = data.prefab,

					name = data.name,
					userid = data.userid,
					colour = data.colour,
				},
				participation = not best_stat,
				beststat = best_stat or {},
			})
		end
	end
	
	return result
end

function QuagmireAnalytics:GetMatchOutcome()
	local outscore = nil
	if self.stats.points > 0 then
		-- Surg: must be integer (not float) else get crash game :)
		outscore = tonumber(string.format("%d", math.floor((self.stats.points * 1000) / self.round_time)))
	end

	return {
		won = self.inst.components.quagmire.gameresult,
		time = self.round_time,
		tributes_success = self.stats.tributes_success,
		tributes_failed = self.stats.tributes_failed,
		score = outscore,
	}
end

-- Fox: see lobbyscreen.lua:516
function QuagmireAnalytics:DumpGameResult()
	if not TheNet:IsDedicated() then
		return
	end
	
	local player_stats = Settings.match_results.player_stats or TheFrontEnd.match_results.player_stats
	if player_stats ~= nil and #player_stats.data > 0 then
		local str = "\nstats_type,".. tostring(player_stats.gametype)
		str = str .. "\nsession," .. tostring(player_stats.session)
		str = str .. "\nclient_date," .. os.date("%c")
		
		local outcome = Settings.match_results.outcome or TheFrontEnd.match_results.outcome
		if outcome ~= nil then
			str = str .. "\nlb_submit," .. tostring(outcome.lb_submit) .. ", " .. tostring(outcome.lb_response)
			str = str .. "\nwon," .. (outcome.won and "true" or "false") 
			str = str .. "\nround," .. tostring(outcome.round)
			str = str .. "\ntime," .. tostring(math.floor(outcome.time))
			str = str .. "\nscore," .. tostring(outcome.score)
			str = str .. "\ntributes_success," .. tostring(outcome.tributes_success)
			str = str .. "\ntributes_failed," .. tostring(outcome.tributes_failed)
		end
		
		local userid_index = 0
		str = str .. "\nfields,is_you"
		for i, v in ipairs(player_stats.fields) do
			if v == "userid" then
				userid_index = i
			elseif v ~= "netid" then
				str = str .. "," .. v
			end
		end
		
		for j, player in ipairs(player_stats.data) do
			str = str .. "\nplayer"..j
			for i, v in ipairs(player) do
				if player_stats.fields[i] ~= "netid" then
					str = str .. "," .. v or "<nil>"
				end
			end
		end
		print(str)

		str = str .. "\nendofmatch"

		print("Logging Match Statistics")
		local stats_file = "event_match_stats/"..GetActiveFestivalEventStatsFilePrefix().."_" .. string.gsub(os.date("%x"), "/", "-") .. ".csv"
		TheSim:GetPersistentString(stats_file, function(load_success, old_str) 
			if old_str ~= nil then
				str = str .. "\n" .. old_str
			end
			TheSim:SetPersistentString(stats_file, str, false, function() print("Done Logging Match Statistics") end)
		end)
		
	end
end

function QuagmireAnalytics:GetGameTime()
	return GetTime() - self.start_time
end

function QuagmireAnalytics:SendAnalyticsLobbyEvent(event, userid, data)
	
end

return QuagmireAnalytics

--[[
	Fox: some dug up data:
	Component is being updated on both side (umm...)
	If you mismatch craving speed gets divided by 2
	If you match it it drops to 0
	Level is... something. All we know is if the gnaw is angry (speed is above 8) it's 3
	if 4 it's 2 and otherwise it's 1
	levelstart sets to current every snackrifise for... reasons
]]
-- TheWorld.net.components.quagmire_hangriness:Start(1)

local UpvalueHacker = require("tools/upvaluehacker")

local RecipeAppraised

local function DoRumble(_netvars, major)
	if not TheWorld.components.quagmire.endgame then
		SetDirty(_netvars.rumbled, major)
		
		ShakeAllCameras(CAMERASHAKE.FULL, 1.15, .02 * (major and 1.5 or 1), .2, nil, 40)
		
		if GetGorgeGameModeProperty("sneezing_gnaw") then
			for i, player in ipairs(AllPlayers) do
				if math.random(1, 2) == 2 then
					local pos = player:GetPosition()
					local inst = SpawnAt("gnaw_projectile", Vector3(pos.x, 12, pos.z))
					inst.components.complexprojectile:Launch(pos, player, player)
				end
			end
		end
	end
end

rawset(_G, "tt", function(m ,f, d, r) --tt(10, .1, 0, .5)
	for i, player in ipairs(AllPlayers) do
		local pos = player:GetPosition()
		local inst = SpawnAt("gnaw_projectile", Vector3(pos.x, 12, pos.z))
	
		inst.components.complexprojectile:Launch(pos)
	end
end)

return {
	master_postinit = function(self, inst, netvars, MAX_HANGRY, TimeStr)
		self.max = MAX_HANGRY
		self.soul_task = nil
		
		-- netvars.soul = self.inst._soul_active
		
		-- OnUpdate is not initialized yet
		self.inst:DoTaskInTime(0, function(inst)
			self.DoDelta = UpvalueHacker.GetUpvalue(self.OnUpdate, "DoDelta")
		end)
		
		function self:GetDebugString()
			return string.format(
				"current: %3.2f speed:%3.2f\nlevelstart:%s time:%s rumbled:%s matched:%s",
				netvars.current:value() * 100,
				netvars.speed:value(),
				netvars.levelstart:value(),
				TimeStr(self:GetTimeRemaining()),
				tostring(netvars.rumbled:value()),
				tostring(netvars.matched:value())
			)
		end
		
		function self:DoStart()
			self:Start(self.max)
		end
		
		function self:DebugSetPercent(prcnt)
			SetDirty(netvars.current, MAX_HANGRY * prcnt)
		end
		
		function self:DebugSetSpeed(val)
			SetDirty(netvars.speed, val)
		end
		
		function self:DoRumble(major)
			DoRumble(netvars, major)
		end
		
		--[[
		function self:Stop()
			netvars.levelstart:set_local(0)
			netvars.levelstart:set(0)
		end]]
		
		function self:SoulPause()
			if self.soul_task then
				self.soul_task:Cancel()
			end
			
			if netvars.levelstart:value() ~= 0 then
				self:Stop()
			end
			
			self.inst._soul_active:set(true)
			self.soul_task = self.inst:DoTaskInTime(TUNING.GORGE.CHARACTERS.WORTOX_PAUSE, function()
				self.inst._soul_active:set(false)
				if netvars.levelstart:value() == 0 then
					self:Start(self.max)
				end
			end)
		end
	end,
	
	OnStart = function(_netvars, levelstart)
		SetDirty(_netvars.levelstart, levelstart)
	end,
	
	OnStop = function(_netvars)
		SetDirty(_netvars.levelstart, 0)
	end,
	
	GetRumbleDelay = function()
		return TUNING.GORGE.HANGRINESS.RUMBLE_DELAY
	end,
	
	DoRumble = DoRumble,
	
	DoSync = function(_netvars)
		SetDirty(_netvars.current, _netvars.current:value())
		SetDirty(_netvars.speed, _netvars.speed:value())
	end,
	
	OnDoDelta = function(self, new, _updating)
		TheWorld:PushEvent("hangriness_delta", {
			current = self:GetCurrent(),
			percent = self:GetCurrent()/self.max,
		})
		local delta = new - self:GetCurrent()
		return _updating and delta > 1 or false -- Fox: I don't know why we'd want to do ruble here, but ok I guess...
	end,
	
	OnCravingMatch = function(data, _netvars, DoDelta)
		local self = TheWorld.net.components.quagmire_hangriness
		
		SetDirty(_netvars.speed, GetGorgeGameModeProperty("never_satisfied") and _netvars.speed:value() / 2 or 0)
		
		-- Surg: MAX_HANGRY = 6000, can't include MAX_HANGRY, becouse it call error :(
		if data.salted then
			local current = _netvars.current:value()
			current = current + self.max * TUNING.GORGE.SALT_BONUS

			if current < 0 then
				current = 0
			end

			SetDirty(_netvars.current, current)
		end
	end,
	
	OnCravingMismatch = function(data, _netvars, DoDelta)
		if GetGorgeGameModeProperty("never_satisfied") then
			return
		end
	
		SetDirty(_netvars.speed, _netvars.speed:value() / 2)
	end,
	
	-- Fox: Here we initialize our event listeners
	OnLevelStart = function(inst, OnCravingMatch, OnCravingMismatch)
		RecipeAppraised = function(w, data, check)
			if data.matched then
				OnCravingMatch(w, data)
			else
				OnCravingMismatch(w, data)
			end
		end
		inst:ListenForEvent("ms_quagmirerecipeappraised", RecipeAppraised, TheWorld)
	end,
	
	OnLevelStop = function(inst, OnCravingMatch, OnCravingMismatch)
		if RecipeAppraised then
			inst:RemoveEventCallback("ms_quagmirerecipeappraised", RecipeAppraised, TheWorld)
			RecipeAppraised = nil
		end
	end,
}

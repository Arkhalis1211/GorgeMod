local ENDGAME_TIMING = 3.25

local function Wait(inst, condition, ondone)
	local function testcondition()
		if condition() then
			ondone()
		else
			inst.waittask = inst:DoTaskInTime(FRAMES, testcondition)
		end
	end
	
	testcondition()
end

local function StopTask(task)
	if task then
		task:Cancel()
	end
end

return {
	[GOATMUM_STATES.WELCOME] = {
		start = function(self)
			Wait(
				self.inst,
				function() return self.inst.sg:HasStateTag("idle") end,
				function()
					self:WelcomeSpeech()
				end
			)
		end,
		
		stop = function(self)
			StopTask(self.task)
			self.task = nil
			
			StopTask(self.inst.waittask)
			self.inst.waittask = nil
		end,
	},
	
	[GOATMUM_STATES.WAIT_FOR_PURCHASE] = {
		start = function(self)
			local function Talk()
				local str = FindClosestPlayerToInst(self.inst, 6, true) and "GOATMUM_TALK_START_CHOICE" or "GOATMUM_TALK_START_BECKON"
				self.talker:Chatter(str, math.random(1, #STRINGS[str]))
			end
			
			self.talk_task = self.inst:DoPeriodicTask(3, Talk)
			
			local function OnBought()
				if self.talk_task then
					self.talk_task:Cancel()
					self.talk_task = nil
				end
				
				self.talker:Chatter("GOATMUM_TALK_START_PURCHASE", 1, 3.5)
				
				self.firstpurchase = nil
				
				TheWorld.components.quagmire:UpdatePrototyping(true)
				TheWorld.components.quagmire:GenerateNextCraving()
			end
			
			self.inst:ListenForNextEvent("item_bought", OnBought)
		end,
		
		stop = function(self)
			StopTask(self.talk_task)
			self.talk_task = nil
		end,
	},
	
	[GOATMUM_STATES.GAMELOST] = {
		start = function(self)
			self.inst:DoTaskInTime(ENDGAME_TIMING, function()
				self.scared = false
				local i = 0
				local x, y, z = TheWorld.spawnportal.Transform:GetWorldPosition()
				
				self.inst.Transform:SetRotation(0)
				
				self.inst.Transform:SetPosition(x, y, z)
				
				local function speechfn()
					i = i + 1
					
					if i == #STRINGS.GOATMUM_LOST then
						self.specialtalk = "goodbye"
					end
					
					self.talker:Chatter("GOATMUM_LOST", i, 2.5)
					
					if i >= #STRINGS.GOATMUM_LOST then
						if self.task then
							self.task:Cancel()
							self.task = nil
						end
						
						self.task = self.inst:DoTaskInTime(2.5, function()
							-- Push death
							self.inst:DoTaskInTime(1, function()
								self.inst:PushEvent("gameend")
							end)
							TheWorld:PushEvent("updatecutscene")
						end)
					else
						self.task = self.inst:DoTaskInTime(2.5, speechfn)
					end
				end
				
				speechfn()
			end)
		end,
		
		stop = function(self)
			StopTask(self.task)
			self.task = nil
		end,
	},
	
	[GOATMUM_STATES.GAMEWON] = {
		start = function(self)
			self.scared = false
			self.happy = true
			
			self.inst:DoTaskInTime(3, function()
				local range = 5
				local angle = 10 * DEGREES
				local goatkid_offset = 25 * DEGREES
				local x, y, z = TheWorld.spawnportal.Transform:GetWorldPosition()
				self.inst.Transform:SetRotation(0)
				self.inst.Transform:SetPosition(x + math.cos(angle) * range, y, z + math.sin(angle) * range)
				self.inst.components.goatmum.shop_active = false
		
				self.billy = TheSim:FindFirstEntityWithTag("goatkid")
				if self.billy then
					self.billy.gameend = true
					self.billy.Transform:SetRotation(0)
					self.billy.Transform:SetPosition(x + math.cos(angle + goatkid_offset) * range, y, z + math.sin(angle + goatkid_offset) * range)
					self.billy:PushEvent("gameend", {win = true})
				end
			end)
			
			local function StartTalking()
				if self.billy then
					self.billy:PushEvent("jumping", {jumping = true})
				end
				
				local i = 0
				local function speechfn()
					i = i + 1
					
					if i == #STRINGS.GOATMUM_VICTORY then
						self.specialtalk = "goodbye"
					end
					
					self.talker:Chatter("GOATMUM_VICTORY", i, 2.5)
					
					if i >= #STRINGS.GOATMUM_VICTORY then
						if self.task then
							self.task:Cancel()
							self.task = nil
						end
						
						if self.billy then
							self.billy:PushEvent("jumping", {win = true})
						end
						
						self.inst:DoTaskInTime(2.5, function()
							TheWorld:PushEvent("updatecutscene")
						end)
					else
						self.task = self.inst:DoTaskInTime(2.5, speechfn)
					end
				end
				
				speechfn()
			end
			self.inst:ListenForNextEvent("start_talking", StartTalking)
		end,
		
		stop = function(self)
			StopTask(self.task)
			self.task = nil
		end,
	},
}

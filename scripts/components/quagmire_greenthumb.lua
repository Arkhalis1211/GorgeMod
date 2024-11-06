local GreenThumb = Class(function(self, inst)
    self.inst = inst
	
	self.cache = {}
	self.range = TUNING.GORGE.CHARACTERS.WORMWOOD_BUFF_RANGE
	
	self.task = self.inst:DoPeriodicTask(1, function() self:Update() end)
end)

function GreenThumb:Update()
	self:CheckCache()
	
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local plants = TheSim:FindEntities(x, y, z, self.range, {"crop"}, {"rotten"})
	if #plants > 0 then
		for i, plant in ipairs(plants) do
			if not self.cache[plant] then
				self.cache[plant] = true
				self.inst:ListenForEvent("onremove", function()
					self.cache[plant] = nil
				end, plant)
				plant:SetBoosted(true)
			end
		end
	end
	
	self.inst:PushEvent("crops_updated", next(self.cache) ~= nil)
end

function GreenThumb:CheckCache(force_clean)
	for plant, _ in pairs(self.cache) do
		if force_clean or not self.inst:IsNear(plant, self.range) then
			plant:SetBoosted(false)
			self.cache[plant] = nil
		end
	end
end

function GreenThumb:OnRemoveFromEntity()
	self:CheckCache(true)
	if self.task then
		self.task:Cancel()
		self.task = nil
	end
end
GreenThumb.OnRemoveEntity = GreenThumb.OnRemoveFromEntity

return GreenThumb
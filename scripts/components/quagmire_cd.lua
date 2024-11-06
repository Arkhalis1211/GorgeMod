local Quagmire_CD = Class(function(self, inst)
    self.inst = inst
	
	if TheWorld.ismastersim then
		self.task = nil
		self.cd = 0
	end
	
	self._cd = net_byte(inst.GUID, "quagmire_cd._cd")
	self._cdstopped = net_bool(inst.GUID, "quagmire_cd._cdstopped")
end)

function Quagmire_CD:StartCD(t)
	if self.task then
		self.task:Cancel()
	end
	
    self.cd = t
	self._cd:set(t)
	
	self.task = self.inst:DoPeriodicTask(1, function() self:Update() end)
end

function Quagmire_CD:StopCD()
	if self.task then
		self.task:Cancel()
	end
	self._cdstopped:set(true)
end

function Quagmire_CD:ResumeCD()
	if self.task then
		self.task:Cancel()
	end
	
	self._cdstopped:set(false)
	self.task = self.inst:DoPeriodicTask(1, function() self:Update() end)
end

function Quagmire_CD:Update()
	if self._cdstopped:value() ~= true then
		self.cd = math.max(self.cd - 1, 0)
		self._cd:set(self.cd)
		
		if self.cd <= 0 then
			if self.task then
				self.task:Cancel()
				self.task = nil
			end
			
			self.inst:PushEvent("cd_done")
		end
	end
end

function Quagmire_CD:GetCD()
	return self._cd:value() or self.cd
end

return Quagmire_CD

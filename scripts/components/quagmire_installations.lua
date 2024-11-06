local Quagmire_Installations = Class(function(self, inst)
	self.inst = inst
	self.empty = true
	self.oninstallfn = nil
end)

function Quagmire_Installations:IsEnabled()
	return self.empty
end

function Quagmire_Installations:Install(station)
	if self.empty then
		self.empty = false

		self.inst:RemoveTag("installations")

		self.inst:AddChild(station)
		station.entity:SetParent(self.inst.entity)
		station.Transform:SetPosition(0, 0, 0)

		if self.oninstallfn ~= nil then
			self.oninstallfn(self.inst, station)
		end

		if station.oninstallfn ~= nil then
			station.oninstallfn(station, self.inst)
		end
	end
end

return Quagmire_Installations

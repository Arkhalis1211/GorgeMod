local Saltable = Class(function(self, inst)
	self.inst = inst

	self.inst:AddTag("quagmire_saltable")
end)

function Saltable:Salt(boost, inv)
	if not inv then
		SpawnAt(self.inst.basedish == "plate" and "quagmire_salting_plate_fx" or "quagmire_salting_bowl_fx", self.inst)		
	end

	if boost > 0 and self.inst.components.perishable then
		local percent = self.inst.components.perishable:GetPercent()
		self.inst.components.perishable:SetPercent(percent + (boost * 0.4))
	end

	if not self.inst:HasTag("quagmire_salted") then
		self.inst:AddTag("quagmire_salted")

		UpdateStat(nil, "tributes_salted", 1)
	end

	self.inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/cooking/salt_shake")
end

return Saltable

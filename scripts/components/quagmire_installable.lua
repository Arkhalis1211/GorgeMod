local Quagmire_Installable = Class(function(self, inst)
	self.inst = inst
	self.installprefab = nil
end)

function Quagmire_Installable:SetPrefab(prefab)
	self.installprefab = prefab
end

return Quagmire_Installable

local Quagmire_Slaughtertool = Class(function(self, inst)
    self.inst = inst
end)

function Quagmire_Slaughtertool:Slaughter(killer, target)
	if killer.killer_task then
		killer.killer_task:Cancel()
		killer.killer_task = nil
	end
	
	if killer:HasTag("quagmire_butcher") then
		if target.components.lootdropper then
			target.components.lootdropper:SetLoot({"meat", "meat", "meat"})
		end
	end
	
	target.components.health.invincible = false
	target.components.health:Kill()
	
	for i, allkillers in ipairs(AllPlayers) do
		allkillers:AddTag("killer")
		allkillers.killer_task = allkillers:DoTaskInTime(TUNING.GORGE.KILLER_CD, function(allkillers)
			allkillers:RemoveTag("killer")
		end)
	end
end

return Quagmire_Slaughtertool
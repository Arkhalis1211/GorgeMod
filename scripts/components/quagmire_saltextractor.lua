local Quagmire_SaltExtractor = Class(function(self, inst)
	self.inst = inst
end)

function Quagmire_SaltExtractor:DoInstall(target)
	if target.saltrack ~= nil then
		return false
	end

	target.saltrack = SpawnPrefab("quagmire_salt_rack")
	target.saltrack.Transform:SetPosition(0, 0, 0)
	target.saltrack.entity:SetParent(target.entity)
	target.saltrack.parent = target

	RemovePhysicsColliders(target.saltrack)

	target:RemoveComponent("inspectable")
	target:RemoveComponent("fishable")
    MakeObstaclePhysics(target, 1.95)

	target:RemoveTag("saltpond")
	target:AddTag("NOCLICK")

	target.SoundEmitter:PlaySound("dontstarve/quagmire/common/craft/salt_rack")

	return true
end

return Quagmire_SaltExtractor

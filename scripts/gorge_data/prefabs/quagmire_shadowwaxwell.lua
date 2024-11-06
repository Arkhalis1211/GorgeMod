local brain = require "brains/quagmireshadowmaxwellbrain"

local function Kill(inst)
	SpawnAt("shadow_despawn", inst)
	SpawnAt("statue_transition_2", inst)

	local book = inst.book

	inst:Remove()

	if book ~= nil then
		book:PushEvent("shadowkill")
	end
end

return {
	master_postinit = function(inst)
		inst.entity:SetCanSleep(false)
		inst.persists = false

		inst:AddComponent("locomotor")
		inst.components.locomotor.runspeed = TUNING.SHADOWWAXWELL_SPEED
		inst.components.locomotor.pathcaps = { ignorecreep = true }
		inst.components.locomotor:SetSlowMultiplier(.6)

		inst:AddComponent("inventory")
		inst.components.inventory.maxslots = 1

		inst.Kill = Kill

		inst:SetBrain(brain)
		inst:SetStateGraph("SGshadowwaxwell")
	end,
}

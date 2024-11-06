return {
	master_postinit = function(inst)
		inst.components.workmultiplier:RemoveMultiplier(ACTIONS.CHOP, inst)
		inst.components.workmultiplier:RemoveMultiplier(ACTIONS.MINE, inst)
		inst.components.workmultiplier:RemoveMultiplier(ACTIONS.HAMMER, inst)

		inst:RemoveComponent("efficientuser")
	end
}

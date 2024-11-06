return {
	master_postinit = function(inst)
		inst.components.pickable:SetUp("twigs", TUNING.GORGE.SAPLING_REGROW_TIME)
	end,
}

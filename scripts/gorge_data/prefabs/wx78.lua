return {
	master_postinit = function(inst)
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "quagmire_speedup", TUNING.GORGE.CHARACTERS.WX_SPEEDMOD)
	end,
}

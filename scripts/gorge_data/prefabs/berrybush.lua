return {
	master_postinit = function(inst)
		local regen = GetGorgeGameModeProperty("item_regrowth")
		
		local GetRegenTime = regen and function(inst)
			return TUNING.GORGE.BUSH_REGROW_TIME
		end or nil
		
		inst.components.pickable:SetUp("berries", regen and TUNING.GORGE.BUSH_REGROW_TIME)
		inst.components.pickable.getregentimefn = GetRegenTime
		
		inst._noperd = true		
	end,
}

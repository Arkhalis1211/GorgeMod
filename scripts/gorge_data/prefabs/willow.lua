local function GetFuelMasterBonus(inst, item, target)
	return target:HasTag("campfire") and TUNING.GORGE.CHARACTERS.WILLOW_CAMPFIRE_FUEL_MULT or 1
end

return {
	master_postinit = function(inst)
		inst:AddComponent("fuelmaster")
		inst.components.fuelmaster:SetBonusFn(GetFuelMasterBonus)
	end,
}

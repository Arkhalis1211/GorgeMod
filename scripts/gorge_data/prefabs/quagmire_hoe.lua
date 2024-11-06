local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "quagmire_hoe", "swap_quagmire_hoe")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

return {
	master_postinit = function(inst)
		inst:AddComponent("inspectable")
		
		inst:AddComponent("inventoryitem")
		
		inst:AddComponent("quagmire_tiller")
		
		inst:AddComponent("equippable")
		inst.components.equippable:SetOnEquip(onequip)
		inst.components.equippable:SetOnUnequip(onunequip)
		
		inst:AddComponent("weapon")
		inst.components.weapon:SetDamage(17)

        inst:AddInherentAction(ACTIONS.TILL)
	end,
}

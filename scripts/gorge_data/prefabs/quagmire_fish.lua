local function stopkicking(inst)
    inst.AnimState:PlayAnimation("dead")
end

return {
    master_postinit = function(inst)
        inst:AddTag("show_spoilage")
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst:AddComponent("bait")

		inst:AddComponent("edible")
		inst.components.edible.ismeat = true
		inst.components.edible.foodtype = FOODTYPE.MEAT
	
        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.NORMAL)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    end,

    master_postinit_cooked = function(inst)
        inst:AddTag("quagmire_stewable")
    end,

    master_postinit_raw = function(inst, data)
        inst:AddTag("quagmire_stewable")

        inst.build = data.build --Asura: This is needs for SGwilson
        inst:AddComponent("cookable")
        if data.name == "quagmire_salmon" then
            inst.components.cookable.product = "quagmire_salmon_cooked"
            inst:DoTaskInTime(5, stopkicking)
        else
            inst.components.cookable.product = "quagmire_crabmeat_cooked"
        end
    end,
}
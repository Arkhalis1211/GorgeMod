return {
    master_postinit = function(inst)
        inst:AddTag("show_spoilage")

        inst:AddComponent("inspectable")

        inst:AddComponent("cookable")
        inst.components.cookable.product = "quagmire_mushrooms_cooked"

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.SLOW)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("inventoryitem")

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    end,
    
    master_postinit_cooked = function(inst)
        inst:AddTag("show_spoilage")

        inst:AddComponent("inspectable")

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.SLOW)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("inventoryitem")

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    end,

}
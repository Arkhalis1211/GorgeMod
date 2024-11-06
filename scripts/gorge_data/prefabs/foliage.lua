return {
    master_postinit = function(inst)
        inst:RemoveComponent("fuel")

        inst:AddTag("show_spoilage")
        inst:AddTag("quagmire_stewable")

        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.VERY_SLOW)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("cookable")
        inst.components.cookable.product = "quagmire_foliage_cooked"
    end,

    master_postinit_cooked = function(inst)
        inst:AddTag("quagmire_stewable")
        inst:AddTag("show_spoilage")

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.VERY_SLOW)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("inventoryitem")
        
        inst:AddComponent("inspectable")

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    end,
}
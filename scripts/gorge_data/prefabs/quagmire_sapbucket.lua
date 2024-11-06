return {
    master_postinit = function(inst)
        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("quagmire_tapper")
    end,
}

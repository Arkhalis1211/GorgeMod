return {
    master_postinit = function(inst)
        inst:AddTag("quagmire_stewable")

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
    end,
}

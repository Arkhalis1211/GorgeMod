return {
    master_postinit = function(inst, suffix, numslots)
        inst:AddComponent("inspectable")

        MakeQuagmireCookDish(inst, suffix, "oven")
    end,
}

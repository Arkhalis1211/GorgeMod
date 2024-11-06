return {
    master_postinit = function(inst)
        inst:AddTag("quagmire_stewable")
        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.SLOW)
    end,

    master_postinit_cooked = function(inst)
        inst:AddTag("quagmire_stewable")
        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.SLOW)
    end,
}

return {
    master_postinit = function(inst)
        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.NORMAL)
        inst:AddTag("quagmire_stewable")
    end,

    master_postinit_cooked = function(inst)
        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.NORMAL)
        inst:AddTag("quagmire_stewable")
    end,

    master_postinit_raw = function(inst)
        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.NORMAL)
        inst:AddTag("quagmire_stewable")
    end,

    master_postinit_smallmeat = function(inst)
        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.NORMAL)
        inst:AddTag("quagmire_stewable")
		
		inst:SetPrefabNameOverride("smallmeat")
    end,

    master_postinit_cookedsmallmeat = function(inst)
        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.NORMAL)
        inst:AddTag("quagmire_stewable")
		
		inst:SetPrefabNameOverride("cookedsmallmeat")
    end,
}
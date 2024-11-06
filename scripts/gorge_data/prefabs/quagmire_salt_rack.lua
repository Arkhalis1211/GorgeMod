local function ongrow(inst)
    inst.AnimState:Show("salt")
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle")
	
    inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishcaught")

    TheWorld:PushEvent("scannernotice", {scanpref = inst})
end

local function onharvest(inst)
    inst.AnimState:Hide("salt")
    inst.AnimState:PlayAnimation("picked")
    inst.AnimState:PushAnimation("idle")
	
	if inst.parent then
		inst.parent.AnimState:PlayAnimation("splash")    
		inst.parent.AnimState:PushAnimation("idle")
	end
	
    inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishcaught")
end

return {
    master_postinit_item = function(inst)
        inst.AnimState:SetBank("quagmire_salt_rack")
        inst.AnimState:SetBuild("quagmire_salt_rack")
        inst.AnimState:PlayAnimation("builder")
		
        inst:AddComponent("inspectable")
		
        inst:AddComponent("inventoryitem")
		
        inst:AddComponent("quagmire_saltextractor")
    end,

    master_postinit = function(inst)    
        inst.AnimState:Hide("salt")
        inst.AnimState:PlayAnimation("place")
        inst.AnimState:PushAnimation("idle")
        inst.AnimState:SetRayTestOnBB(true)

        inst:AddComponent("inspectable")
		
        inst:AddComponent("harvestable")
        inst.components.harvestable:SetProduct("quagmire_saltrock", 1)
        inst.components.harvestable:SetGrowTime(TUNING.GORGE.SALT_RACK_GROWTIME)
        inst.components.harvestable:SetOnGrowFn(ongrow)
        inst.components.harvestable:SetOnHarvestFn(onharvest)
        inst.components.harvestable:StartGrowing()
    end,
}

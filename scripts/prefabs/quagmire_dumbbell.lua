
local assets =
{
    Asset("ANIM", "anim/dumbbell.zip"),
    Asset("ANIM", "anim/swap_dumbbell.zip"),
}

local prefabs = 
{

}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_dumbbell", "swap_dumbbell")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    
    if inst:HasTag("lifting") then
        owner:PushEvent("stopliftingdumbbell", {instant = true})
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    -- inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("dumbbell")
    inst.AnimState:SetBuild("dumbbell")
    inst.AnimState:PlayAnimation("idle")

	inst:SetPrefabNameOverride("dumbbell")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "dumbbell"

    inst:AddComponent("inspectable")

    inst:AddComponent("mightydumbbell")
    inst.components.mightydumbbell:SetEfficiency(TUNING.DUMBBELL_EFFICIENCY_MED,  TUNING.DUMBBELL_EFFICIENCY_MED,  TUNING.DUMBBELL_EFFICIENCY_LOW)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.restrictedtag = "strongman"
	
    inst.swap_dumbbell = "swap_dumbbell"

    return inst
end

return Prefab("quagmire_dumbbell", fn, assets, prefabs)
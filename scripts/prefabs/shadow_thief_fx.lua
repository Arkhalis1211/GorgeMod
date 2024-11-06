local assets =
{
    Asset("ANIM", "anim/boat_death_shadows.zip"),
}

local s = 0.5

local function PlayFX(proxy)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBuild("shadow_wavey_jones")
    inst.AnimState:SetBank("shadow_wavey_jones")
    inst.AnimState:PlayAnimation("idle_in")
    inst.AnimState:PushAnimation("idle")
    inst.AnimState:PushAnimation("scared", false)
    inst.AnimState:SetDeltaTimeMultiplier(1.75)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetMultColour(0,0,0,0.5)
    inst.AnimState:UsePointFiltering(true)
	inst.AnimState:SetScale(.75,.75,.75)

    inst:ListenForEvent("animqueueover", inst.Remove)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBuild("boat_death_shadows")
    inst.AnimState:SetBank("boatdeathshadow")
    inst.AnimState:PlayAnimation("boat_death")
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetMultColour(0,0,0,0.5)
    inst.AnimState:UsePointFiltering(true)

    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, PlayFX)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.AnimState:SetScale(math.random() < .5 and -s or s, s)
	
    inst:ListenForEvent("animover", inst.Remove)
	
    inst.persists = false

    return inst
end

return Prefab("quagmire_shadow_thief_fx", fn, assets)
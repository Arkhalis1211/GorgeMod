local assets =
{
    Asset("ANIM", "anim/quagmire_wormwood_fx.zip"),
}

local s = 0.85

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("ember_particles")
    inst.AnimState:SetBuild("quagmire_wormwood_fx")
    inst.AnimState:PlayAnimation("pre")
    inst.AnimState:PushAnimation("loop", true)
	inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetHaunted(true)
    -- inst.AnimState:SetDeltaTimeMultiplier(2)

    inst:AddTag("FX")
    inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.AnimState:SetScale(math.random() < .5 and -s or s, s)
	
    inst.persists = false
	
	function inst.Kill(inst)
		inst.AnimState:PlayAnimation("pst", false)
	end
	
	inst:ListenForEvent("animover", function()
		if inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation("pst") then
			inst:Remove()
		end
	end)

    return inst
end

return Prefab("quagmire_wormwood_fx", fn, assets)

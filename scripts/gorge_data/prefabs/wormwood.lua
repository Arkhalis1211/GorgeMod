local function OnBloomFXDirty(inst)
    local fx = CreateEntity()

    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    --[[Non-networked entity]]
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddAnimState()

    fx.AnimState:SetBank("wormwood_bloom_fx")
    fx.AnimState:SetBuild("wormwood_bloom_fx")
    fx.AnimState:SetFinalOffset(2)

    if inst.replica.rider ~= nil and inst.replica.rider:IsRiding() then
        fx.Transform:SetSixFaced()
        fx.AnimState:PlayAnimation(inst.bloomfx:value() and "poof_mounted_less" or "poof_mounted")
    else
        fx.Transform:SetFourFaced()
        fx.AnimState:PlayAnimation(inst.bloomfx:value() and "poof_less" or "poof")
    end

    fx:ListenForEvent("animover", fx.Remove)

    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx.Transform:SetRotation(inst.Transform:GetRotation())

    local skin_build = string.match(inst.AnimState:GetSkinBuild() or "", "wormwood(_.+)") or ""
    skin_build = skin_build:match("(.*)_build$") or skin_build
    skin_build = skin_build:match("(.*)_stage_?%d$") or skin_build
    if skin_build:len() > 0 then
        fx.AnimState:OverrideSkinSymbol("bloom_fx_swap_leaf", "wormwood"..skin_build, "bloom_fx_swap_leaf")
    end
end

local function SetUserFlagLevel(inst, level)
    --No bit ops support, but in this case, + results in same as |
    local flags = USERFLAGS.CHARACTER_STATE_1 + USERFLAGS.CHARACTER_STATE_2 + USERFLAGS.CHARACTER_STATE_3
    if level > 0 then
        local addflag = USERFLAGS["CHARACTER_STATE_"..tostring(level)]
        --No bit ops support, but in this case, - results in same as &~
        inst.Network:RemoveUserFlag(flags - addflag)
        inst.Network:AddUserFlag(addflag)
    else
        inst.Network:RemoveUserFlag(flags)
    end
end

local function SpawnBloomFX(inst)
    inst.bloomfx:set_local(false)
    inst.bloomfx:set(inst.overrideskinmode == nil or inst.overrideskinmode == "stage_3")
    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        OnBloomFXDirty(inst)
    end
    inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds", nil, .6)
end

local function SetSkinType(inst, skintype, defaultbuild)
    --Return true if build change needs to spawn bloom FX
    local oldskintype = inst.components.skinner:GetSkinMode()
    if oldskintype ~= skintype and
        not (skintype == "ghost_skin" and oldskintype == "normal_skin") and
        not (oldskintype == "ghost_skin" and skintype == "normal_skin") then
        inst.components.skinner:SetSkinMode(skintype, defaultbuild)
        return true
    end
end

local function SetBloomStage(inst, blooming)
    if (inst.sg:HasStateTag("nomorph") or inst.sg:HasStateTag("silentmorph") or not inst.entity:IsVisible()) or inst.blooming == blooming then
        return
    end
	
    inst.blooming = blooming
	SetUserFlagLevel(inst, blooming and 3 or 0)
	SpawnBloomFX(inst)
	
	if blooming then
		inst.overrideskinmode = "stage_4"
		SetSkinType(inst, inst.overrideskinmode, "wilson")
	else
		inst.overrideskinmode = nil
		SetSkinType(inst, "normal_skin", "wilson")
	end
end

return {
	master_postinit = function(inst) -- ThePlayer:SetBloomStage(true)
		inst:RemoveTag("healonfertilize")
	
		inst.blooming = false
	
		inst:AddComponent("quagmire_greenthumb")
		
		inst.SetBloomStage = SetBloomStage
		
		inst:ListenForEvent("crops_updated", function(inst, value)
			inst:SetBloomStage(value)
		end)
	end,
}

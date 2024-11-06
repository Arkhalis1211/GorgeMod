local assets =
{
    Asset("ANIM", "anim/ds_spider_basic.zip"),
    Asset("ANIM", "anim/spider_build.zip"),
    Asset("ANIM", "anim/spider_wolf_build.zip"),
    Asset("ANIM", "anim/spider_wolf_build.zip"),
    Asset("SOUND", "sound/spider.fsb"),
}

local prefab =
{
    "die_fx",
}
local brain = require("brains/quagmirespiderbrain")

local SCALE = .75

local function SpawnFertilizeFx(inst, fx_prefab, scale)
    local fx = SpawnAt(fx_prefab, inst)
    fx.Transform:SetNoFaced()

    scale = scale or 1
    fx.Transform:SetScale(scale, scale, scale)
end

local function Fertilize(inst)
    SpawnFertilizeFx(inst, "spider_heal_ground_fx", .75)
    SpawnFertilizeFx(inst, "spider_heal_fx", SCALE)

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.GORGE.CHARACTERS.WEBBER_BUFF_RANGE, {"plantedsoil"})

    for i, ent in ipairs(ents) do
        if ent then
            SpawnFertilizeFx(ent, "spider_heal_target_fx")
            ent.components.quagmire_crop:SetTempBoost(TUNING.GORGE.CHARACTERS.WEBBER_BUFF_DURATION)
        end
    end
end

local function SetFertilizer(inst)
    inst:AddTag("fertilizer")

    inst.AnimState:SetBuild("spider_wolf_build")
    inst.AnimState:OverrideSymbol("swap_hat", "quagmire_swampig_build", "swap_hat3")

    inst.maxwork = TUNING.GORGE.CHARACTERS.WEBBER_SPIDERS.FERTILIZER.MAXWORK
    inst.retiredtime = TUNING.GORGE.CHARACTERS.WEBBER_SPIDERS.FERTILIZER.RETIRED_TIME
    
    inst.sounds = "webber1/creatures/spider_cannonfodder/"
end

local function SetHarvester(inst)
    inst:AddTag("harvester")

    inst.AnimState:OverrideSymbol("swap_hat", "quagmire_swampig_build", "swap_hat1")
    inst.AnimState:OverrideSymbol("face", "spider_build", "happy_face")    

    inst.maxwork = TUNING.GORGE.CHARACTERS.WEBBER_SPIDERS.HARVESTER.MAXWORK
    inst.retiredtime = TUNING.GORGE.CHARACTERS.WEBBER_SPIDERS.HARVESTER.RETIRED_TIME

    inst.sounds = "dontstarve/creatures/spider/"
end

local function SetTiller(inst)
    inst:AddTag("tiller")

    inst.AnimState:SetBuild("spider_warrior_build")
    inst.AnimState:OverrideSymbol("swap_hat", "quagmire_swampig_build", "swap_hat2")
    inst.AnimState:OverrideSymbol("face", "spider_warrior_build", "happy_face")    

    inst:AddComponent("quagmire_tiller")

    inst.maxwork = TUNING.GORGE.CHARACTERS.WEBBER_SPIDERS.TILLER.MAXWORK
    inst.retiredtime = TUNING.GORGE.CHARACTERS.WEBBER_SPIDERS.TILLER.RETIRED_TIME

    inst.sounds = "dontstarve/creatures/spiderwarrior/"
end

local function WorkDone(inst)
    if not inst.currentwork then
        inst.currentwork = inst.maxwork
    end
    inst.currentwork = inst.currentwork - 1
    
    if inst.currentwork < 1 then
        inst:PushEvent("timetorest")
        inst:AddTag("tired")
        inst:DoTaskInTime(inst.retiredtime, function()
            inst:PushEvent("onwakeup")
            inst:RemoveTag("tired")
            inst.currentwork = inst.maxwork
        end)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .2)

    inst.DynamicShadow:SetSize(1.5 * SCALE, .25 * SCALE)

    inst.Transform:SetScale(SCALE, SCALE, SCALE)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("spider")
    inst.AnimState:SetBuild("spider_build")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Show("hat")
    inst.SoundEmitter:OverrideVolumeMultiplier(SCALE)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("follower")

	inst:AddComponent("inventory")

	inst:AddComponent("locomotor")
	inst.components.locomotor.runspeed = 7
	inst.components.locomotor.walkspeed = 7

	inst:SetStateGraph("SGquagmirespider")
    inst:SetBrain(brain)
	
    inst.SetFertilizer = SetFertilizer
    inst.SetHarvester = SetHarvester
    inst.SetTiller = SetTiller
    inst.Fertilize = Fertilize

    inst:ListenForEvent("workdone", WorkDone)

    inst:ListenForEvent("ms_gameend", function(src, win)
        if win == 0 then
            SpawnAt("spider_mutate_fx", inst).Transform:SetScale(SCALE, SCALE, SCALE)
            inst:Remove()
        end
    end, TheWorld)
    
    return inst
end

local function TillerSpider()
	local inst = fn()
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst:SetTiller()
	
	return inst
end

local function HarvesterSpider()
	local inst = fn()
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst:SetHarvester()
	
	return inst
end

local function FertilizerSpider()
	local inst = fn()
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst:SetFertilizer()
	
	return inst
end

return Prefab("quagmire_spider", fn, assets, prefabs),
	Prefab("quagmire_spidertiller", TillerSpider, assets, prefabs),
	Prefab("quagmire_spiderharvester", HarvesterSpider, assets, prefabs),
	Prefab("quagmire_spiderfertilizer", FertilizerSpider, assets, prefabs)

local brain = require("brains/crittersbrain")

local assets =
{
    Asset("ANIM", "anim/pupington_build.zip"),
    Asset("ANIM", "anim/pupington_basic.zip"),
    Asset("ANIM", "anim/pupington_emotes.zip"),
    Asset("ANIM", "anim/pupington_traits.zip"),
    Asset("ANIM", "anim/pupington_jump.zip"),
    
    Asset("ANIM", "anim/pupington_woby_victorian_build.zip"),
	
    Asset("ANIM", "anim/pupington_woby_build.zip"),
    Asset("ANIM", "anim/pupington_transform.zip"),
    Asset("ANIM", "anim/woby_big_build.zip"),

    Asset("ANIM", "anim/quagmire_woby_3x1.zip"),
}

local prefabs = {}

local function LinkToPlayer(inst, player)
    inst._playerlink = player
    inst.components.follower:SetLeader(player)

    inst:ListenForEvent("onremove", inst._onlostplayerlink, player)
end

local function OnPlayerLinkDespawn(inst)
	if inst.components.container ~= nil then
		inst.components.container:Close()
		inst.components.container.canbeopened = false

		if GetGameModeProperty("drop_everything_on_despawn") then
			inst.components.container:DropEverything()
		else
			inst.components.container:DropEverythingWithTag("irreplaceable")
		end
	end

	if inst.components.drownable ~= nil then
		inst.components.drownable.enabled = false
	end

	local fx = SpawnPrefab(inst.spawnfx)
	fx.entity:SetParent(inst.entity)

	inst.components.colourtweener:StartTween({ 0, 0, 0, 1 }, 13 * FRAMES, inst.Remove)

	if not inst.sg:HasStateTag("busy") then
		inst.sg:GoToState("despawn")
	end
end

local function FinishTransformation(inst)
end

local function OnOpen(inst)
end

local function OnClose(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(1, .33)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("pupington")
    inst.AnimState:SetBuild("pupington_woby_build")
    inst.AnimState:AddOverrideBuild("pupington_woby_victorian_build")
    inst.AnimState:PlayAnimation("idle_loop")

    MakeCharacterPhysics(inst, 1, .5)

    -- critters dont really go do entitysleep as it triggers a teleport to near the owner, so no point in hitting the physics engine.
	inst.Physics:SetDontRemoveOnSleep(true)

    inst:AddTag("critter")
    inst:AddTag("fedbyall")
    inst:AddTag("companion")
    inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")
    inst:AddTag("small_livestock")
    inst:AddTag("noabandon")
    inst:AddTag("NOBLOCK")

    inst:AddComponent("spawnfader")
	
	inst:SetPrefabNameOverride("wobysmall")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.GetPeepChance = function() return 0.05 end
    inst.IsAffectionate = function() return false end
    inst.IsSuperCute = function() return false end
    inst.IsPlayful = function() return false end
    
	inst.playmatetags = {"critter"}

    inst:AddComponent("inspectable")

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(true)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.softstop = true
    inst.components.locomotor.walkspeed = TUNING.CRITTER_WALK_SPEED
    inst.components.locomotor:SetAllowPlatformHopping(true)

	inst:AddComponent("colourtweener")

    inst:AddComponent("timer")
    inst:AddComponent("crittertraits")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("quagmire_wobysmall")

    inst:SetBrain(brain)
    inst:SetStateGraph("SGwobysmall")

    inst.LinkToPlayer = LinkToPlayer
	inst.OnPlayerLinkDespawn = OnPlayerLinkDespawn
	inst._onlostplayerlink = function(player) inst._playerlink = nil end

    inst.FinishTransformation = FinishTransformation

    inst.persists = false

	inst.spawnfx = "spawn_fx_small"
	
	return inst
end

return Prefab("quagmire_wobysmall", fn, assets)
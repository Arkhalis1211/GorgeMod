
require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/brightmare_gestalt.zip"),
    Asset("ANIM", "anim/brightmare_gestalt_evolved.zip"),
}

local prefabs =
{
	"gestalt_head",
	"gestalt_trail",
}

local brain = require "brains/brightmare_gestaltbrain"

local function Evolve(inst)
    inst.AnimState:SetBuild("brightmare_gestalt_evolved")
    inst.AnimState:SetBank("brightmare_gestalt_evolved")
	if inst.blobhead then
		inst.blobhead.AnimState:SetBuild("brightmare_gestalt_head_evolved")
		inst.blobhead.AnimState:SetBank("brightmare_gestalt_head_evolved")	
		inst.blobhead.Follower:FollowSymbol(inst.GUID, "brightmare_gestalt_head_evolved", 0, 0, 0)
	end
    inst.AnimState:PlayAnimation("idle", true)
    inst.components.locomotor.walkspeed = TUNING.GESTALTGUARD_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.GESTALTGUARD_WALK_SPEED
end

local function FindRelocatePoint(inst)
	return TheWorld.components.quagmire_brightmarespawner:FindRelocatePoint(inst) or nil
end

local function SetTrackingTarget(inst, target, behaviour_level)
	local prev_target = inst.tracking_target
	inst.tracking_target = target
	inst.behaviour_level = behaviour_level
	if prev_target ~= inst.tracking_target then
		if inst.OnTrackingTargetRemoved ~= nil then
			inst:RemoveEventCallback("onremove", inst.OnTrackingTargetRemoved, prev_target)
			inst:RemoveEventCallback("death", inst.OnTrackingTargetRemoved, prev_target)
			inst.OnTrackingTargetRemoved = nil
		end
		if inst.tracking_target ~= nil then
			inst.OnTrackingTargetRemoved = function(target) inst.tracking_target = nil end
			inst:ListenForEvent("onremove", inst.OnTrackingTargetRemoved, inst.tracking_target)
			inst:ListenForEvent("death", inst.OnTrackingTargetRemoved, inst.tracking_target)
		end
	end
end

local function UpdateBestTrackingTarget(inst)
	local target, behaviour_level = TheWorld.components.quagmire_brightmarespawner:FindBestPlayer(inst)
	SetTrackingTarget(inst, target, behaviour_level)
end

local function Retarget(inst)
	return (inst.tracking_target ~= nil 
				and not inst.components.combat:InCooldown() 
				and inst:IsNear(inst.tracking_target, TUNING.GESTALT.AGGRESSIVE_RANGE)
				and not (inst.tracking_target.sg:HasStateTag("knockout") or inst.tracking_target.sg:HasStateTag("sleeping") or inst.tracking_target.sg:HasStateTag("bedroll") or inst.tracking_target.sg:HasStateTag("tent") or inst.tracking_target.sg:HasStateTag("waking"))
           ) and inst.tracking_target 
			or nil
end

local function OnNewCombatTarget(inst, data)
	if inst.components.inspectable == nil then
		inst:AddComponent("inspectable")
		inst:AddTag("scarytoprey")
	end
end

local function OnNoCombatTarget(inst)
	inst.components.combat:RestartCooldown()
	inst:RemoveComponent("inspectable")
	inst:RemoveTag("scarytoprey")
end

local function fn()
    local inst = CreateEntity()

    --Core components
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    --Initialize physics
    local phys = inst.entity:AddPhysics()
    phys:SetMass(1)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.FLYERS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.GROUND)
    phys:SetCapsule(0.5, 1)

	inst:AddTag("brightmare")
	inst:AddTag("brightmare_gestalt")
	inst:AddTag("NOBLOCK")

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBuild("brightmare_gestalt")
    inst.AnimState:SetBank("brightmare_gestalt")
    inst.AnimState:PlayAnimation("idle", true)

	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst._level = net_tinybyte(inst.GUID, "gestalt.level", "leveldirty")
    inst._level:set(1)

	if not TheNet:IsDedicated() then
		inst.blobhead = SpawnPrefab("gestalt_head")
		inst.blobhead.entity:SetParent(inst.entity) --prevent 1st frame sleep on clients
		inst.blobhead.Follower:FollowSymbol(inst.GUID, "head_fx", 0, 0, 0)
	
		inst.blobhead.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		inst.blobhead:DoPeriodicTask(0, function(head) head.Transform:SetRotation(inst.Transform:GetRotation()) end)

	    inst.highlightchildren = { inst.blobhead }
	end

	inst:SetPrefabNameOverride("gestalt")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	inst.tracking_target = nil
	inst.behaviour_level = 1
	inst.FindRelocatePoint = FindRelocatePoint
	inst.SetTrackingTarget = SetTrackingTarget
	inst:DoPeriodicTask(0.1, UpdateBestTrackingTarget, 0)

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.GESTALT.WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.GESTALT.WALK_SPEED
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(0)
	inst.components.combat:SetAttackPeriod(TUNING.GESTALT.ATTACK_COOLDOWN)
	inst.components.combat:SetRange(TUNING.GESTALT.ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(1, Retarget)
	inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
	inst:ListenForEvent("droppedtarget", OnNoCombatTarget)
	inst:ListenForEvent("losttarget", OnNoCombatTarget)
	
    inst:SetStateGraph("SGbrightmare_gestalt")
    inst:SetBrain(brain)
	
	inst.evolved = false
	inst.Evolve = Evolve
	
	inst:ListenForEvent("hangriness_delta", function(src, data)
		if not inst.evolved then
			inst.evolved = true
			if data.percent <= TUNING.GORGE.DANGER_THRESHOLD then
				Evolve(inst)
			end
		end
	end, TheWorld)
			
    return inst
end

return Prefab("quagmire_gestalt", fn, assets, prefabs)
